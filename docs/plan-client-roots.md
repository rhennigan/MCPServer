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
2. The *next* message read from stdin will be the client's response to that request (not a new client request)
3. The server must correlate this response back to its outgoing request by `id`

This is a significant architectural change — the server needs to support **server-initiated requests** and handle responses to those requests, not just client-initiated request/response pairs.

### Current Message Flow

```
Client -> Server: initialize request
Server -> Client: initialize response
Client -> Server: notifications/initialized
Client -> Server: tools/list, tools/call, etc.
```

### New Message Flow with Roots

```
Client -> Server: initialize request (includes capabilities.roots)
Server -> Client: initialize response
Client -> Server: notifications/initialized
Server -> Client: roots/list request          ← NEW: server-initiated request
Client -> Server: roots/list response         ← NEW: response to server request
Client -> Server: tools/list, tools/call, etc.
...
Client -> Server: notifications/roots/list_changed  ← NEW: dynamic update
Server -> Client: roots/list request                 ← NEW: re-query
Client -> Server: roots/list response                ← NEW: response
```

## Implementation Steps

### Step 1: Add server-to-client request infrastructure

**File:** `Kernel/StartMCPServer.wl`

Add the ability for the server to send requests to the client and receive responses:

1. Add a `$serverRequestID` counter (starting at `"s-0"` or similar to avoid collisions with client request IDs)
2. Create a `sendServerRequest[method, params]` function that:
   - Generates a unique request ID
   - Writes a JSON-RPC request to stdout
   - Reads the next line from stdin
   - Parses and returns the response
   - Has a timeout mechanism to avoid blocking forever
3. Create a `$pendingServerRequests` association to track outstanding requests if needed

Key design decision: Since stdio MCP uses a synchronous line-based protocol, the simplest approach is to make `sendServerRequest` blocking — write the request, then immediately read the response. This works because MCP stdio transport is inherently sequential.

```wl
(* New package-scoped variables *)
$serverRequestID = 0;
$clientCapabilities = <| |>;
$clientRoots = { };

(* Send a request from server to client *)
sendServerRequest // beginDefinition;

sendServerRequest[ method_String ] :=
    sendServerRequest[ method, <| |> ];

sendServerRequest[ method_String, params_Association ] := Enclose[
    Module[ { id, request, requestJSON, stdin, response },
        id = "s-" <> ToString[ ++$serverRequestID ];
        request = <|
            "jsonrpc" -> "2.0",
            "id"      -> id,
            "method"  -> method,
            "params"  -> params
        |>;
        requestJSON = Developer`WriteRawJSONString[ request, "Compact" -> True ];
        WriteLine[ "stdout", requestJSON ];
        (* Read the response *)
        stdin = InputString[ "" ];
        response = ConfirmBy[ Developer`ReadRawJSONString @ stdin, AssociationQ ];
        ConfirmAssert[ response[ "id" ] === id ];
        response
    ],
    throwInternalFailure
];

sendServerRequest // endDefinition;
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
queryAndApplyClientRoots // beginDefinition;

queryAndApplyClientRoots[ ] := Enclose[
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

### Step 6: Handle the read-response interleaving in the main loop

**File:** `Kernel/StartMCPServer.wl`

The critical challenge is that when the server writes a `roots/list` request, the next stdin read must receive the client's *response* to that request — but the current main loop always interprets stdin as a new *request from the client*.

Two approaches:

**Approach A — Inline in notification handler (Recommended):**
The `sendServerRequest` function handles the round-trip synchronously: it writes to stdout and immediately reads from stdin. Since this happens inside `handleNotification` (which is called from `processRequest`), the main loop doesn't see any interleaving — the entire query-and-apply happens within a single "turn" of the loop. The main loop only resumes reading new client requests after the root query completes.

This works because:
- The server sends the `roots/list` request to stdout
- The client sees it and sends back the response on stdin
- `sendServerRequest` reads that response from stdin before returning
- The main loop's next `processRequest` call reads the *next* client message as usual

**Approach B — Pending request queue:**
For more complex scenarios (multiple concurrent server-to-client requests), maintain a pending requests map and handle response routing in `processRequest`. This is more complex and likely unnecessary for the stdio transport.

**Recommendation:** Use Approach A for simplicity. The stdio transport is inherently sequential, so blocking on a response is natural and simple.

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

1. **Timing of `roots/list` request:** After the server sends the `initialize` response, the client should send `notifications/initialized` before the server sends `roots/list`. But what if the client sends other requests first? The `sendServerRequest` approach assumes the next message on stdin is the response. If another message arrives first, it will be misinterpreted.

   **Mitigation:** We could read messages in a loop, dispatching any incoming client requests normally, until we receive the response matching our request ID. This is essentially Approach B (pending request queue) and adds complexity but is more robust.

2. **Client compatibility:** Not all MCP clients support roots. We must check `$clientCapabilities` before sending `roots/list`. If the client doesn't support roots, we should not send the request.

3. **Multiple roots:** When multiple roots are provided, which directory should we set? The plan uses the first valid directory. This could be made configurable.

4. **Non-file URIs:** The spec allows non-`file://` URIs (e.g., `https://`). We should only set the directory for `file://` URIs and gracefully ignore others.

5. **Security:** While the spec mentions validating root URIs to prevent path traversal, in this context the server trusts the client's declared roots as advisory boundaries. The server is running locally, so the security model is different from a remote deployment.

6. **MX build compatibility:** New symbols and functions need to be compatible with the MX build system. Ensure `addToMXInitialization` is called appropriately for any new state that needs initialization.
