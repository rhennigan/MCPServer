# Implementation Plan: Client Roots Support

**TODO item:** Query client roots and set directory appropriately
**Spec:** https://modelcontextprotocol.io/specification/2025-11-25/client/roots#protocol-messages

## Overview

The MCP roots feature allows clients to declare filesystem boundaries (URIs) that the server should operate within. During initialization, clients can declare a `roots` capability. The server can then send a `roots/list` request *to the client* to discover which directories/URIs it should scope its operations to.

This feature will enable the MCPServer to:
1. Detect if the connected client supports roots
2. Query the client for its root list after initialization
3. Set the working directory (`SetDirectory`) to the appropriate root
4. Respond to dynamic root changes via `notifications/roots/list_changed`

## MCP Protocol Details

### Client declares roots capability in `initialize` request

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2024-11-05",
    "capabilities": {
      "roots": {
        "listChanged": true
      }
    },
    "clientInfo": {
      "name": "ExampleClient",
      "version": "1.0.0"
    }
  }
}
```

### Server sends `roots/list` request to client

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "roots/list"
}
```

### Client responds with list of roots

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "roots": [
      {
        "uri": "file:///home/user/projects/myproject",
        "name": "My Project"
      }
    ]
  }
}
```

### Client sends change notification (if `listChanged` is true)

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/roots/list_changed"
}
```

## Architecture Considerations

### Bidirectional Communication Challenge

The current server architecture processes stdin line-by-line and writes responses to stdout. The main loop in `startMCPServer` (`Kernel/StartMCPServer.wl:94-108`) reads a request, processes it, and writes a response. This is a simple request-response model.

However, `roots/list` requires the **server** to send a request **to the client** and receive a response back. This means:

1. After processing the `initialize` message, the server must write a `roots/list` request to stdout
2. The server must then read from stdin until it receives the matching response
3. The server must correlate the response back to its outgoing request by `id`

This is a significant architectural change — the server needs to support **server-initiated requests** and handle responses to those requests, not just client-initiated request/response pairs.

### Non-Synchronous stdin

**Critical constraint:** We cannot assume that the next message on stdin after we write a `roots/list` request will be the client's response. The client may have already buffered other messages (requests, notifications) on stdin before it even sees our outgoing request. For example:

```
Client -> Server: initialize request
Server -> Client: initialize response
Client -> Server: notifications/initialized    ← triggers roots query
Client -> Server: tools/list                   ← ALREADY BUFFERED on stdin
Server -> Client: roots/list request           ← server sends this...
Client -> Server: roots/list response          ← ...but tools/list arrives first!
```

This means `sendServerRequest` must implement a **drain-and-dispatch loop**: after writing the outgoing request, it reads messages from stdin in a loop. Any incoming client requests or notifications are handled normally (dispatched and responses written to stdout). Only when the matching response (identified by `id`) arrives does the function return.

### Current Message Flow

```
Client -> Server: initialize request
Server -> Client: initialize response
Client -> Server: notifications/initialized
Client -> Server: tools/list, tools/call, etc.
```

### New Message Flow with Roots (realistic interleaving)

```
Client -> Server: initialize request (includes capabilities.roots)
Server -> Client: initialize response
Client -> Server: notifications/initialized    ← server decides to query roots
Client -> Server: tools/list                   ← buffered, arrives before response
Server -> Client: roots/list request
Server reads stdin: gets tools/list → handles it normally
Server -> Client: tools/list response
Server reads stdin: gets roots/list response   ← now we have our answer
Server applies roots (SetDirectory, etc.)
...
Client -> Server: notifications/roots/list_changed  ← dynamic update
Server -> Client: roots/list request                 ← re-query
Client -> Server: roots/list response
```

## Implementation Steps

### Step 1: Add server-to-client request infrastructure

**File:** `Kernel/StartMCPServer.wl`

Add the ability for the server to send requests to the client and receive responses:

1. Add a `$serverRequestID` counter (starting at `"s-0"` or similar to avoid collisions with client request IDs)
2. Create a `sendServerRequest[method, params]` function that:
   - Generates a unique request ID
   - Writes a JSON-RPC request to stdout
   - Enters a **drain-and-dispatch loop** reading from stdin
   - Any client requests/notifications read during this loop are dispatched normally (responses written to stdout)
   - When the message matching our request ID arrives, return it
   - Has a timeout mechanism to avoid blocking forever

**Key design decision:** We cannot assume the next stdin message is the response to our request. The client may have buffered other messages. Therefore `sendServerRequest` must drain stdin, dispatching interleaved client messages, until it finds the response matching our request ID.

```wl
(* New package-scoped variables *)
$serverRequestID = 0;
$clientCapabilities = <| |>;
$clientRoots = { };

(* Send a request from server to client and wait for the response,
   dispatching any interleaved client messages along the way. *)
sendServerRequest // beginDefinition;

sendServerRequest[ method_String ] :=
    sendServerRequest[ method, <| |> ];

sendServerRequest[ method_String, params_Association ] := Enclose[
    Module[ { id, request, requestJSON },
        id = "s-" <> ToString[ ++$serverRequestID ];
        request = <|
            "jsonrpc" -> "2.0",
            "id"      -> id,
            "method"  -> method,
            "params"  -> params
        |>;
        requestJSON = Developer`WriteRawJSONString[ request, "Compact" -> True ];
        WriteLine[ "stdout", requestJSON ];
        writeLog[ "ServerRequest" -> request ];
        (* Enter drain-and-dispatch loop to collect the response *)
        ConfirmBy[ awaitServerResponse @ id, AssociationQ, "Response" ]
    ],
    throwInternalFailure
];

sendServerRequest // endDefinition;
```

#### Drain-and-dispatch loop

This is the core of the non-synchronous handling. It reads messages from stdin in a loop. Each message is classified:

- **Response** (has `"result"` or `"error"`, no `"method"`): Check if it matches our pending request ID. If yes, return it. Otherwise log a warning and continue.
- **Request** (has `"method"` and `"id"`): Dispatch via `handleMethod`, write the response to stdout, continue looping.
- **Notification** (has `"method"`, no `"id"`): Dispatch via `handleMethod`, continue looping. **Important:** Must avoid re-entrancy — if the notification is `notifications/roots/list_changed` and we're already inside a `sendServerRequest` for `roots/list`, we should not recursively send another `roots/list` request. Use a guard variable (`$queryingRoots`) for this.

```wl
awaitServerResponse // beginDefinition;

awaitServerResponse[ expectedID_ ] := Enclose[
    Module[ { attempts = 0, maxAttempts = 1000 },
        While[ attempts < maxAttempts,
            attempts++;
            Module[ { stdin, message, method, id, isResponse },
                stdin = InputString[ "" ];
                If[ ! StringQ @ stdin || StringTrim @ stdin === "",
                    Pause[ 0.05 ];
                    Continue[ ]
                ];
                message = Quiet @ Developer`ReadRawJSONString @ stdin;
                If[ ! AssociationQ @ message,
                    Continue[ ]
                ];

                writeLog[ "DrainRead" -> message ];

                method = Lookup[ message, "method", None ];
                id     = Lookup[ message, "id", Null ];

                (* Classify: is this a response to a server-initiated request? *)
                isResponse = And[
                    method === None,  (* no method field *)
                    Or[ KeyExistsQ[ message, "result" ], KeyExistsQ[ message, "error" ] ]
                ];

                If[ isResponse,
                    (* It's a response — check if it matches our expected ID *)
                    If[ message[ "id" ] === expectedID,
                        Return[ message, Module ]
                    ];
                    (* Otherwise it's a response to a different request — log and continue *)
                    writeLog[ "UnexpectedResponse" -> message ];
                    Continue[ ]
                ];

                (* It's a client request or notification — handle it normally *)
                Module[ { req, response },
                    req = <| "jsonrpc" -> "2.0", "id" -> id |>;
                    response = catchAlways @ handleMethod[ method, message, req ];
                    writeLog[ "InterstitialResponse" -> response ];
                    If[ AssociationQ @ response,
                        WriteLine[ "stdout",
                            Developer`WriteRawJSONString[ response, "Compact" -> True ]
                        ]
                    ]
                ]
            ]
        ];
        (* If we exhaust attempts, return $Failed *)
        $Failed
    ],
    throwInternalFailure
];

awaitServerResponse // endDefinition;
```

#### Re-entrancy guard

Since `handleMethod` is called from within the drain loop, a `notifications/roots/list_changed` notification could arrive while we're already waiting for a `roots/list` response. We must prevent recursive `sendServerRequest` calls:

```wl
$queryingRoots = False;

queryAndApplyClientRoots[ ] /; TrueQ @ $queryingRoots := Null; (* already in progress *)

queryAndApplyClientRoots[ ] := Block[ { $queryingRoots = True },
    (* ... actual implementation ... *)
];
```

### Step 2: Capture client capabilities during initialization

**File:** `Kernel/StartMCPServer.wl`

Modify the `handleMethod["initialize", ...]` handler to capture and store the client's declared capabilities:

```wl
handleMethod[ "initialize", msg_, req_ ] := (
    $clientName = Replace[
        msg[[ "params", "clientInfo", "name" ]],
        Except[ _String ] :> None
    ];
    $clientCapabilities = Replace[
        msg[[ "params", "capabilities" ]],
        Except[ _Association ] :> <| |>
    ];
    If[ ! stderrEnabledQ[ ], $Messages = { } ];
    <| req, "result" -> $initResult |>
);
```

Add a helper to check roots support:

```wl
clientSupportsRootsQ // beginDefinition;
clientSupportsRootsQ[ ] := AssociationQ @ $clientCapabilities[ "roots" ];
clientSupportsRootsQ // endDefinition;

clientSupportsRootsListChangedQ // beginDefinition;
clientSupportsRootsListChangedQ[ ] :=
    TrueQ @ $clientCapabilities[ "roots", "listChanged" ];
clientSupportsRootsListChangedQ // endDefinition;
```

### Step 3: Query roots after initialization

**File:** `Kernel/StartMCPServer.wl`

After the server sends the initialize response, the client will send a `notifications/initialized` notification. At that point, we should query for roots if the client supports them.

Modify the notification handler to trigger root querying:

```wl
handleMethod[ method_String, _, req_ ] /; StringStartsQ[ method, "notifications/" ] :=
    handleNotification[ method ];

handleNotification // beginDefinition;

handleNotification[ "notifications/initialized" ] := (
    If[ clientSupportsRootsQ[ ],
        queryAndApplyClientRoots[ ]
    ];
    Null
);

handleNotification[ "notifications/roots/list_changed" ] := (
    If[ clientSupportsRootsQ[ ],
        queryAndApplyClientRoots[ ]
    ];
    Null
);

handleNotification[ _ ] := Null;

handleNotification // endDefinition;
```

### Step 4: Implement root querying and directory setting

**File:** `Kernel/StartMCPServer.wl`

```wl
$queryingRoots = False;

queryAndApplyClientRoots // beginDefinition;

(* Re-entrancy guard: if we're already inside a roots query
   (e.g. a notifications/roots/list_changed arrived while draining stdin
   for a pending roots/list response), skip the redundant query. *)
queryAndApplyClientRoots[ ] /; TrueQ @ $queryingRoots := Null;

queryAndApplyClientRoots[ ] := Block[ { $queryingRoots = True },
    Enclose[
        Module[ { response, roots },
            response = sendServerRequest[ "roots/list" ];
            roots = Replace[
                response[[ "result", "roots" ]],
                Except[ { ___Association } ] :> { }
            ];
            $clientRoots = roots;
            applyClientRoots @ roots;
        ],
        (* Don't throw on failure — roots are advisory, not critical *)
        Function[ failure,
            writeLog[ "RootsQueryFailed" -> failure ];
            debugPrint[ "Failed to query client roots: ", failure ];
        ]
    ]
];

queryAndApplyClientRoots // endDefinition;
```

```wl
applyClientRoots // beginDefinition;

applyClientRoots[ { } ] := Null; (* No roots declared *)

applyClientRoots[ roots: { __Association } ] := Enclose[
    Module[ { fileRoots, directories, dir },
        (* Extract file:// URIs and convert to local paths *)
        fileRoots = Cases[ roots, KeyValuePattern[ "uri" -> uri_String ] :> uri ];
        directories = Select[ fileURIToPath /@ fileRoots, DirectoryQ ];
        If[ Length @ directories > 0,
            dir = First @ directories;
            SetDirectory @ dir;
            debugPrint[ "Set directory to client root: ", dir ];
        ]
    ],
    Function[ failure,
        writeLog[ "ApplyRootsFailed" -> failure ];
        debugPrint[ "Failed to apply client roots: ", failure ];
    ]
];

applyClientRoots // endDefinition;
```

### Step 5: Implement `file://` URI to path conversion

**File:** `Kernel/StartMCPServer.wl`

```wl
fileURIToPath // beginDefinition;

(* Unix/Mac: file:///path/to/dir -> /path/to/dir *)
fileURIToPath[ uri_String ] /; StringStartsQ[ uri, "file:///" ] :=
    URLDecode @ StringDrop[ uri, 7 ]; (* Drop "file://" keeping the leading "/" *)

(* Windows: file:///C:/path -> C:/path *)
(* Already handled by the above case since StringDrop[..., 7] yields "/C:/path"
   which is valid, but we may want to strip the leading "/" on Windows *)
fileURIToPath[ uri_String ] /; $OperatingSystem === "Windows" && StringStartsQ[ uri, "file:///" ] :=
    URLDecode @ StringDrop[ uri, 8 ]; (* Drop "file:///" for Windows drive letters *)

(* Fallback: return the URI unchanged *)
fileURIToPath[ uri_String ] := uri;

fileURIToPath // endDefinition;
```

### Step 6: Refactor `processRequest` to share message classification logic

**File:** `Kernel/StartMCPServer.wl`

The drain-and-dispatch loop in `awaitServerResponse` (Step 1) duplicates some logic from `processRequest` — both read from stdin, parse JSON, and dispatch by method. To avoid duplication and bugs, we should refactor:

1. Extract message reading and parsing into a shared helper `readMessage[]` that returns the parsed association or `$Failed`/`EndOfFile`.
2. Extract message dispatch into a shared helper `dispatchMessage[message]` that classifies (request vs notification vs response) and handles accordingly.
3. Both `processRequest` and `awaitServerResponse` use these shared helpers.

Alternatively, keep the implementations separate but simple — the drain loop is temporary and bounded, so some duplication is acceptable to keep the code straightforward. The main risk with sharing is that `processRequest` writes to stdout at the end, while the drain loop writes immediately. Keeping them separate avoids subtle ordering bugs.

**Recommendation:** Keep the implementations separate for now. The drain loop is a focused piece of code with a clear purpose. If the server later needs more server-to-client request types (e.g., sampling), a shared abstraction can be introduced then.

### Step 7: Declare `$clientRoots` in `CommonSymbols.wl` (if needed by other files)

**File:** `Kernel/CommonSymbols.wl`

If tools or other components need access to the client roots (e.g., for path validation or scoping), declare the shared symbols:

```wl
`$clientRoots;
`$clientCapabilities;
```

This allows tools to check roots when performing file operations, potentially restricting operations to within declared root boundaries.

### Step 8: Add error messages

**File:** `Kernel/Messages.wl`

No new error messages are strictly required since root querying failures are handled gracefully (logged but not thrown). However, if we want to surface root-related errors:

```wl
MCPServer::RootsQueryFailed = "Failed to query client roots: `1`.";
```

### Step 9: Write tests

**File:** `Tests/StartMCPServer.wlt`

The existing test infrastructure supports sending notifications and requests. We need to:

1. Update `MCPInitialize` in `Tests/MCPServerTestUtilities.wl` to include `roots` capability:
   ```wl
   MCPInitialize[ opts: OptionsPattern[ ] ] := Module[
       { clientName, protocolVersion, timeout, capabilities, response },
       ...
       capabilities = <|
           "roots" -> <| "listChanged" -> True |>
       |>;
       response = SendMCPRequest[
           "initialize",
           <|
               "clientInfo" -> <| "name" -> clientName |>,
               "protocolVersion" -> protocolVersion,
               "capabilities" -> capabilities
           |>,
           "Timeout" -> timeout
       ];
       ...
   ];
   ```

2. **Major challenge:** Testing `roots/list` requires the test harness to *respond* to a server-initiated request. The current `SendMCPRequest` model only supports client-initiated requests. We need to add a function that reads a request from the server and sends back a response:
   ```wl
   HandleServerRequest // ClearAll;
   HandleServerRequest[ process_, responseData_Association ] := Module[
       { line, parsed, id, response, responseJSON },
       (* Read the server's request from stdout *)
       line = TimeConstrained[ ReadLine @ process, 5, $TimedOut ];
       If[ line === $TimedOut, Return @ $TimedOut ];
       parsed = Developer`ReadRawJSONString @ line;
       id = parsed[ "id" ];
       (* Send back the response *)
       response = <| "jsonrpc" -> "2.0", "id" -> id, "result" -> responseData |>;
       responseJSON = Developer`WriteRawJSONString[ response, "Compact" -> True ];
       WriteLine[ process, responseJSON ];
       parsed (* Return the original request for verification *)
   ];
   ```

3. Add test cases:
   - Client declares roots capability → server queries roots after `notifications/initialized`
   - Client without roots capability → server does NOT query roots
   - Empty roots list → directory unchanged
   - Single root → directory set to that root
   - Multiple roots → directory set to first valid root
   - `notifications/roots/list_changed` → server re-queries and updates directory
   - Invalid/non-existent root URI → graceful handling

### Step 10: Update TODO.md

Mark the roots item as complete once implementation is verified.

## File Change Summary

| File | Changes |
|------|---------|
| `Kernel/StartMCPServer.wl` | Major: Add `$clientCapabilities`, `$clientRoots`, `$serverRequestID`; add `sendServerRequest`, `queryAndApplyClientRoots`, `applyClientRoots`, `fileURIToPath`, `clientSupportsRootsQ`, `handleNotification`; modify `handleMethod["initialize", ...]` and notification handler |
| `Kernel/CommonSymbols.wl` | Minor: Declare `$clientRoots`, `$clientCapabilities` if needed by other files |
| `Kernel/Messages.wl` | Optional: Add `RootsQueryFailed` message |
| `Tests/MCPServerTestUtilities.wl` | Add `HandleServerRequest` function; update `MCPInitialize` to declare roots capability |
| `Tests/StartMCPServer.wlt` | Add roots-related integration tests |
| `TODO.md` | Mark roots item as complete |

## Risks and Open Questions

1. **Re-entrancy in the drain loop:** While `awaitServerResponse` dispatches interleaved client messages, those handlers could themselves trigger server-to-client requests (e.g., a `notifications/roots/list_changed` arriving while we're already awaiting a `roots/list` response). The `$queryingRoots` guard prevents recursive root queries, but if we later add more server-to-client request types, we'll need a more general solution (e.g., a pending requests map that `awaitServerResponse` can serve multiple waiters).

2. **Timeout in the drain loop:** The drain loop has a max-attempts bound (1000 iterations), but no wall-clock timeout. If the client never responds to `roots/list`, the server will be stuck dispatching other messages until it hits the attempt limit. Consider adding a `TimeConstrained` wrapper or a wall-clock check in the loop.

3. **Client compatibility:** Not all MCP clients support roots. We must check `$clientCapabilities` before sending `roots/list`. If the client doesn't support roots, we should not send the request.

4. **Multiple roots:** When multiple roots are provided, which directory should we set? The plan uses the first valid directory. This could be made configurable.

5. **Non-file URIs:** The spec allows non-`file://` URIs (e.g., `https://`). We should only set the directory for `file://` URIs and gracefully ignore others.

6. **Security:** While the spec mentions validating root URIs to prevent path traversal, in this context the server trusts the client's declared roots as advisory boundaries. The server is running locally, so the security model is different from a remote deployment.

7. **MX build compatibility:** New symbols and functions need to be compatible with the MX build system. Ensure `addToMXInitialization` is called appropriately for any new state that needs initialization.

8. **Main loop response writing:** The main loop in `startMCPServer` writes responses to stdout after `processRequest` returns. But when `processRequest` calls into `handleNotification`, which calls `sendServerRequest`, which calls `awaitServerResponse`, that drain loop also writes responses to stdout for interleaved messages. We need to ensure there's no double-write — the main loop must know that some responses were already sent during the drain. The simplest approach: have `processRequest` return `Null` for notifications (which it already does), so the main loop's `If[AssociationQ @ response, ...]` guard prevents double-writing.
