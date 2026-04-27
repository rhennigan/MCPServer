# MCP Roots — Design Specification

## Overview

This specification defines support for the [MCP Roots](https://modelcontextprotocol.io/specification/2025-11-25/client/roots.md) protocol feature in the AgentTools MCP server. When a client (e.g. Claude Code) advertises a project directory, the server queries it via `roots/list`, picks a single working directory, and configures the main kernel, the local evaluator kernel, and `RunProcess`-based tools to operate inside that directory. The spec also defines a new generic infrastructure for **server-to-client requests**, since this is the first feature in AgentTools that requires it.

## Goals

- Detect when a client supports the MCP `roots` capability and apply the resulting project directory to the server's tools.
- Establish a reusable, asynchronous **server-to-client request** mechanism, with a UUID-keyed registry of pending requests and a callback per response, so future features (sampling, elicitation) can reuse it.
- Differentiate inbound JSON-RPC **responses** (replies to our requests) from inbound JSON-RPC **requests** (calls from the client) inside the message loop.
- Handle the `notifications/initialized` notification (currently dropped) so the server can issue post-initialize requests.
- Pick a single root from the (possibly multi-root) list using a deterministic "first valid directory" heuristic.
- Set the main-kernel `Directory[]`, the local evaluator kernel's `Directory[]`, and `ProcessDirectory` for `RunProcess`-using tools so paths resolve relative to the project root.
- Re-apply roots when the client sends `notifications/roots/list_changed`.
- Fail soft: any error path (no roots capability, error response, empty list, never-replies) leaves tools functional with the kernel's original `cwd`.

---

## Subsystem 1 — Client Request Infrastructure

This subsystem is the prerequisite for roots and is intentionally generic. It lives in **`Kernel/MCPClientRequests.wl`** so future server-to-client features (sampling, elicitation, etc.) can reuse it.

### Pending-Request Registry

A package-scoped Association tracks server-issued requests awaiting a response:

```wl
$mcpClientRequests = <| |>;
```

Each entry maps a UUID string to a record describing the outstanding request:

```wl
$mcpClientRequests[ uuid ] = <|
    "id"      -> uuid,
    "request" -> <| ... |>,    (* the JSON-RPC message we sent to the client *)
    "handler" -> handlerFn     (* called when the response arrives *)
|>
```

### Sending Requests — `sendClientRequest`

`sendClientRequest` formats and writes a JSON-RPC request to stdout, registers a handler, and returns the UUID:

```wl
sendClientRequest // beginDefinition;

sendClientRequest[ method_String, params_, handler_ ] :=
    Module[ { uuid, request },
        uuid    = CreateUUID[ ];
        request = <|
            "jsonrpc" -> "2.0",
            "id"      -> uuid,
            "method"  -> method,
            "params"  -> params
        |>;
        $mcpClientRequests[ uuid ] = <|
            "id"      -> uuid,
            "request" -> request,
            "handler" -> handler
        |>;
        WriteLine[ "stdout", Developer`WriteRawJSONString[ request, "Compact" -> True ] ];
        writeLog[ "ClientRequest" -> request ];
        uuid
    ];

sendClientRequest // endDefinition;
```

**Why UUIDs and not integers:** clients commonly start their JSON-RPC ids at `0` and increment, so an integer chosen by the server would risk colliding with a future client id. UUIDs avoid the collision without bookkeeping.

### Differentiating Responses from Requests in the Loop

Today, `processRequest` (in `Kernel/StartMCPServer.wl` lines 485–509) treats every inbound message as a request: it extracts `method` and dispatches via `handleMethod`. Server-issued requests require checking, *before* method dispatch, whether the inbound message is a **response** to one of our outstanding requests.

The minimal change to `processRequest`:

```wl
processRequest[ ] :=
    Catch @ Enclose @ Module[ { stdin, message, method, id, req, response },
        stdin = InputString[ "" ];
        If[ stdin === "Quit", Exit[ 0 ] ];
        If[ ! StringQ @ stdin || StringTrim @ stdin === "", Throw @ EndOfFile ];
        message = ConfirmBy[ Developer`ReadRawJSONString @ stdin, AssociationQ ];
        writeLog[ "Request" -> message ];
        method = Lookup[ message, "method", None ];
        id     = Lookup[ message, "id", Null ];

        (* New: response to one of our outstanding requests *)
        If[ method === None && StringQ @ id && KeyExistsQ[ $mcpClientRequests, id ],
            handleClientResponse[ id, message ];
            Throw @ Null
        ];

        req      = <| "jsonrpc" -> "2.0", "id" -> id |>;
        response = catchAlways @ handleMethod[ method, message, req ];
        If[ method === "tools/list", $warmupTools = True ];
        writeLog[ "Response" -> response ];
        If[ FailureQ @ response,
            <| req, "error" -> <| "code" -> -32603, "message" -> "Internal error" |> |>,
            response
        ]
    ];
```

Returning `Null` for a recognized response causes the main loop's `If[ AssociationQ @ response, ... ]` guard (line 153 of `StartMCPServer.wl`) to skip writing to stdout, which is what we want.

### `handleClientResponse`

```wl
handleClientResponse // beginDefinition;

handleClientResponse[ id_String, message_Association ] :=
    Catch @ Module[ { entry, handler, request },
        entry = Lookup[ $mcpClientRequests, id, None ];
        If[ entry === None, Throw @ Null ];
        handler = entry[ "handler" ];
        request = entry[ "request" ];
        KeyDropFrom[ $mcpClientRequests, id ];
        handler[ request, message ]
    ];

handleClientResponse // endDefinition;
```

The handler receives both the original request and the response so it can correlate context (e.g., which call to `roots/list` this answers, in case multiple are outstanding).

### Error Responses

If the response contains an `"error"` key instead of a `"result"`, the handler is still invoked — it is the handler's responsibility to inspect the response shape. The infrastructure does not interpret JSON-RPC error semantics on behalf of the caller.

### Notification Dispatch — `handleNotification`

Today all `notifications/*` messages are silently dropped (see `handleMethod` in `StartMCPServer.wl`). To fire actions on specific notifications without breaking the catch-all behavior for unknown ones, introduce a small dispatcher:

```wl
handleNotification // beginDefinition;
handleNotification[ "notifications/initialized"        , msg_ ] := onClientInitialized @ msg;
handleNotification[ "notifications/roots/list_changed" , msg_ ] := onRootsListChanged @ msg;
handleNotification[ _, _ ] := Null;   (* unknown notifications: still ignored *)
handleNotification // endDefinition;
```

`handleMethod`'s notifications branch routes through it:

```wl
handleMethod[ method_String, msg_, req_ ] /; StringStartsQ[ method, "notifications/" ] := (
    handleNotification[ method, msg ];
    Null
);
```

The return value remains `Null`, so the main loop continues to skip the stdout write for notifications.

---

## Subsystem 2 — Roots Feature

The roots-specific logic lives in **`Kernel/MCPRoots.wl`**.

### Session State

```wl
$clientSupportsRoots = False;
$mcpRoot             = None;   (* resolved root directory string, or None *)
```

These are declared in `Kernel/CommonSymbols.wl` so they are reachable from `StartMCPServer.wl` and tools.

### Capability Detection (during `initialize`)

In `handleMethod["initialize", …]` (today at lines 518–523 of `StartMCPServer.wl`), alongside the existing `$clientSupportsUI` line:

```wl
$clientSupportsRoots = ! MissingQ @ msg[ "params", "capabilities", "roots" ];
```

The `listChanged` sub-capability is not separately tracked: per the MCP spec, a client may only send `notifications/roots/list_changed` if it advertised `listChanged: true`, and the server's response is the same either way (re-fetch). The server does **not** advertise any new server-side capability of its own — `roots` is purely a client capability per the MCP specification. The existing TODO at lines 516–517 of `StartMCPServer.wl` is removed when this code lands.

### `onClientInitialized` — Triggering the First `roots/list`

When `notifications/initialized` arrives, if the client advertised `roots`, send a `roots/list` request:

```wl
onClientInitialized // beginDefinition;

onClientInitialized[ _ ] :=
    If[ TrueQ @ $clientSupportsRoots,
        sendClientRequest[ "roots/list", <| |>, handleRootsListResponse ]
    ];

onClientInitialized // endDefinition;
```

### `handleRootsListResponse` — Selecting and Applying a Root

```wl
handleRootsListResponse // beginDefinition;

handleRootsListResponse[ request_, response_Association ] :=
    Catch @ Module[ { roots, root },
        If[ KeyExistsQ[ response, "error" ],
            writeLog[ "RootsListError" -> response[ "error" ] ];
            Throw @ Null
        ];
        roots = response[ "result", "roots" ];
        root  = pickFirstValidRoot @ roots;
        If[ StringQ @ root,
            applyMCPRoot @ root,
            writeLog[ "RootsListEmptyOrInvalid" -> roots ]
        ]
    ];

handleRootsListResponse // endDefinition;
```

### URI → Path Conversion and Validation

MCP root entries look like `<| "uri" -> "file:///C:/Users/.../proj", "name" -> "..." |>`. We must convert the `file://` URI to a native path, then verify it's an existing directory. `ExpandFileName[LocalObject[uri]]` handles the platform-specific URI parsing for us — on Windows it yields `C:\path\to\file` for `file:///C:/path/to/file`, and on Unix it yields `/path/to/file` for `file:///path/to/file`.

```wl
rootURIToPath // beginDefinition;
rootURIToPath[ uri_String? (StringStartsQ[ "file://" ]) ] := ExpandFileName @ LocalObject @ uri;
rootURIToPath[ _ ] := None;
rootURIToPath // endDefinition;
```

`pickFirstValidRoot` walks the list in declaration order, converting each URI and rejecting non-directory paths:

```wl
pickFirstValidRoot // beginDefinition;

pickFirstValidRoot[ roots_List ] :=
    SelectFirst[
        rootURIToPath /@ Cases[ roots, KeyValuePattern[ "uri" -> uri_String ] :> uri ],
        StringQ[ # ] && DirectoryQ[ # ] &,
        None
    ];

pickFirstValidRoot[ _ ] := None;

pickFirstValidRoot // endDefinition;
```

### `applyMCPRoot`

This is the focal action that propagates the root everywhere a tool might observe it:

```wl
applyMCPRoot // beginDefinition;

applyMCPRoot[ root_String ] := (
    $mcpRoot = root;
    SetDirectory @ root;
    If[ toolOptionValue[ "WolframLanguageEvaluator", "Method" ] === "Local",
        useEvaluatorKernel @ SetDirectory @ root (* runs in the local evaluator kernel *)
    ];
    writeLog[ "RootApplied" -> root ];
);

applyMCPRoot // endDefinition;
```

**Stack note:** `SetDirectory` pushes onto a directory stack. If `applyMCPRoot` is called multiple times (via `notifications/roots/list_changed`), the stack grows. This is acceptable in v1 — the stack only matters if code calls `ResetDirectory[]`, which the server does not. A more careful implementation could `ResetDirectory[]` back to a saved baseline before each `SetDirectory`; this is left as a future refinement.

### Eager Evaluator Kernel Setup

The notes call out that `useEvaluatorKernel[SetDirectory[root]]` must be invoked when `$evaluatorMethod === "Local"`, since the local evaluator kernel is a separate process with its own `Directory[]`. Doing this **eagerly** in `applyMCPRoot` means that when a tool like `WolframLanguageEvaluator` first runs, that kernel is already sitting in the right directory.

Guard the call with `toolOptionValue[ "WolframLanguageEvaluator", "Method" ] === "Local"`. The existing `useEvaluatorKernel` helper intentionally evaluates in the main kernel when the evaluator method is not `"Local"`; without this guard, default `"Session"` mode would call `SetDirectory[root]` twice and grow the main kernel's directory stack twice per root application.

`useEvaluatorKernel` is currently declared at the package level of `Kernel/Tools/Tools.wl` (in the `Wolfram`AgentTools`Tools`` context). Move that declaration to `Kernel/CommonSymbols.wl` so `MCPRoots.wl` can resolve it without needing to load the Tools subcontext first. The definition stays in `Kernel/Tools/WolframLanguageEvaluator.wl`, which already `Needs` the Common context, so the existing definition still attaches to the symbol after the move. Existing callers (`Kernel/Tools/SymbolDefinition.wl`) already `Needs` both Common and Tools, so they continue to resolve the symbol unqualified.

### Re-applying on `notifications/roots/list_changed`

```wl
onRootsListChanged // beginDefinition;

onRootsListChanged[ _ ] :=
    If[ TrueQ @ $clientSupportsRoots,
        sendClientRequest[ "roots/list", <| |>, handleRootsListResponse ]
    ];

onRootsListChanged // endDefinition;
```

This re-uses `handleRootsListResponse`. The new root replaces `$mcpRoot` and triggers another `SetDirectory` / `useEvaluatorKernel[SetDirectory]`. Since the client owns the authoritative roots state, no diffing is performed — whatever comes back wins.

### `RunProcess` Updates

Tools that invoke external processes via `RunProcess` must explicitly pass `ProcessDirectory -> $mcpRoot` (when `$mcpRoot` is non-`None`) so child processes inherit the root. Each call site is updated individually; no wrapper.

The known call sites:

- `Kernel/Tools/TestReport.wl` (~line 100) — `RunProcess` invocation for the external Wolfram process running tests.
- `Kernel/Common.wl` also calls `RunProcess` for `git rev-parse`, but it already passes `ProcessDirectory -> dir` intentionally. Do **not** replace that with `$mcpRoot`; it is release-ID plumbing, not a tool execution working directory.

Pattern:

```wl
RunProcess[
    args,
    ProcessDirectory -> If[ StringQ @ $mcpRoot, $mcpRoot, Inherited ]
]
```

Any additional tool-facing `RunProcess` call sites discovered during implementation get the same treatment. Calls that already use a deliberate, explicit `ProcessDirectory` for another purpose should be reviewed case-by-case rather than mechanically changed.

### Error and Edge-Case Behavior

| Condition | Behavior |
|---|---|
| Client does not advertise `roots` capability | `$clientSupportsRoots = False`; no `roots/list` ever sent. Tools run with kernel's original `cwd`. |
| Client never replies to `roots/list` | Pending entry stays in `$mcpClientRequests` forever; no timeout. Tools run with kernel's original `cwd`. |
| Response contains `"error"` | `writeLog["RootsListError" -> error]`; no root applied. |
| Response result has empty `roots` list | `writeLog["RootsListEmptyOrInvalid" -> {}]`; no root applied. |
| All roots fail `DirectoryQ` | Same as empty: log and continue. |
| URI is not `file://` | `rootURIToPath` returns `None`; the entry is skipped during scan. |

In all of these cases the server stays alive and continues serving tool calls — `$mcpRoot` simply remains `None`, and tools fall through to today's behavior.

---

## Race Condition: `tools/call` Before `roots/list` Resolves

Because the server processes messages strictly in arrival order, a client that fires a `tools/call` before responding to our `roots/list` will have that tool execute with `$mcpRoot === None` (i.e., the kernel's original `cwd`). This is **accepted, not mitigated**, in v1:

- In practice, MCP clients sequence `notifications/initialized` immediately after `initialize` and do not fire `tools/call` until the user takes an action, by which point the `roots/list` round-trip has long completed.
- A queueing layer would meaningfully complicate the message loop and is unjustified for a race that has not been observed.

Tools should therefore tolerate `$mcpRoot === None` and behave as they do today.

---

## File Layout

| File | Status | Purpose |
|---|---|---|
| `Kernel/MCPClientRequests.wl` | NEW | `$mcpClientRequests`, `sendClientRequest`, `handleClientResponse`, `handleNotification` |
| `Kernel/MCPRoots.wl` | NEW | `$mcpRoot`, capability flags, `onClientInitialized`, `onRootsListChanged`, `handleRootsListResponse`, `pickFirstValidRoot`, `rootURIToPath`, `applyMCPRoot` |
| `Kernel/StartMCPServer.wl` | EDIT | `processRequest` distinguishes responses from requests; `handleMethod["initialize", …]` reads roots capabilities; notifications branch routes through `handleNotification`; remove TODO at lines 516–517 |
| `Kernel/CommonSymbols.wl` | EDIT | Declare the cross-file symbols: `$mcpClientRequests`, `$mcpRoot`, `$clientSupportsRoots`, `sendClientRequest`, `handleClientResponse`, `handleNotification`, `onClientInitialized`, `onRootsListChanged`. Also relocate `useEvaluatorKernel` here from `Kernel/Tools/Tools.wl` (remove the `` `useEvaluatorKernel; `` line there). Symbols only used inside a single new file (`pickFirstValidRoot`, `rootURIToPath`, `applyMCPRoot`, `handleRootsListResponse`) stay private to that file. |
| `Kernel/Tools/Tools.wl` | EDIT | Drop the `` `useEvaluatorKernel; `` declaration line; the symbol now lives in CommonSymbols.wl |
| `Kernel/Main.wl` | EDIT | Add `"Wolfram`AgentTools`MCPClientRequests`"` and `"Wolfram`AgentTools`MCPRoots`"` to `$AgentToolsContexts` so the new files load |
| `Kernel/Tools/TestReport.wl` | EDIT | Add `ProcessDirectory -> If[ StringQ @ $mcpRoot, $mcpRoot, Inherited ]` to the `RunProcess` call (~line 100) |
| `Kernel/Tools/WolframLanguageEvaluator.wl` | NO CHANGE | The local kernel's directory is set via `useEvaluatorKernel[SetDirectory[…]]` from `applyMCPRoot`; tool code does not need to know about `$mcpRoot` |
| `Tests/MCPServerTestUtilities.wl` | EDIT | Add helpers to initialize with arbitrary client capabilities, read server-to-client requests, and send JSON-RPC responses back to the server |
| `Tests/StartMCPServer.wlt` | EDIT | Add integration tests for initialize-with-roots, `notifications/initialized` issuing `roots/list`, root response handling, and `notifications/roots/list_changed` issuing another request |
| `Tests/Tools.wlt` | EDIT | Add focused coverage that `TestReport` honors `$mcpRoot` for relative paths when running through the external `RunProcess` path |

---

## Testing Plan

- Unit-test `pickFirstValidRoot` and `rootURIToPath` with valid file URIs, non-file URIs, missing `"uri"` entries, nonexistent directories, and multi-root fallback ordering.
- Unit-test `handleRootsListResponse` with success, error response, missing `"result"`, missing `"roots"`, empty roots, and invalid roots. Include a regression test that a nested result is read correctly rather than via `Lookup[response, {"result", "roots"}, {}]`.
- Extend `Tests/MCPServerTestUtilities.wl` so integration tests can respond to server-to-client `roots/list` requests. The existing `SendMCPRequest` helper only covers client-to-server requests and will treat the server's `roots/list` message as an ordinary response unless there is a dedicated helper.
- Add `Tests/StartMCPServer.wlt` integration coverage for the full handshake: initialize with `<| "roots" -> <| "listChanged" -> True |> |>`, send `notifications/initialized`, read the server's `roots/list`, respond with a temporary directory root, and verify a later evaluator call observes that directory via `Directory[]`.
- Add a `notifications/roots/list_changed` integration test that verifies a second `roots/list` request is emitted and the new response replaces `$mcpRoot`.
- Add `Tests/Tools.wlt` coverage for `TestReport` using a relative path under a temporary `$mcpRoot` with `"newKernel" -> True`, guarded consistently with the existing `$allowExternal` convention.

---

## Examples

### Example 1 — Successful Roots Handshake

**Client → Server: `initialize`**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2024-11-05",
    "capabilities": {
      "roots": { "listChanged": true }
    },
    "clientInfo": { "name": "claude-code", "version": "0.1.0" }
  }
}
```

**Server → Client: `initialize` response** (unchanged from today; capability flags are stored as a side effect)

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": { "protocolVersion": "2024-11-05", "capabilities": { "...": "..." } }
}
```

**Client → Server: `notifications/initialized`**

```json
{ "jsonrpc": "2.0", "method": "notifications/initialized" }
```

**Server → Client: `roots/list`** (UUID `id`)

```json
{
  "jsonrpc": "2.0",
  "id": "9c8e1d6e-3a8f-4f0a-8b1e-1f2a4c5e6d7f",
  "method": "roots/list"
}
```

**Client → Server: `roots/list` response**

```json
{
  "jsonrpc": "2.0",
  "id": "9c8e1d6e-3a8f-4f0a-8b1e-1f2a4c5e6d7f",
  "result": {
    "roots": [
      { "uri": "file:///H:/Documents/AgentTools", "name": "AgentTools" }
    ]
  }
}
```

Server applies: `$mcpRoot = "H:\\Documents\\AgentTools"` and `SetDirectory[$mcpRoot]`; when the evaluator method is `"Local"`, it also applies `SetDirectory[$mcpRoot]` inside the local evaluator kernel. Subsequent `tools/call` invocations resolve relative paths against this root, and `RunProcess` calls in `TestReport` start in this directory.

### Example 2 — Multi-Root with Invalid First Entry

```json
{
  "result": {
    "roots": [
      { "uri": "file:///nonexistent/path",        "name": "stale" },
      { "uri": "file:///H:/Documents/AgentTools", "name": "AgentTools" }
    ]
  }
}
```

`pickFirstValidRoot` skips the first entry (`DirectoryQ` returns `False`) and returns `H:\Documents\AgentTools`.

### Example 3 — `roots/list_changed`

After session is established and `$mcpRoot = "H:\\Documents\\AgentTools"`:

**Client → Server:**

```json
{ "jsonrpc": "2.0", "method": "notifications/roots/list_changed" }
```

**Server → Client:** another `roots/list` (new UUID); the response handler reapplies `$mcpRoot` to whatever new directory comes back.

### Example 4 — Client Without `roots` Capability

```json
{
  "params": {
    "capabilities": { }
  }
}
```

`$clientSupportsRoots` stays `False`; on `notifications/initialized`, no `roots/list` is sent. Tools run with the kernel's original `cwd`, exactly as today.

### Example 5 — Empty Roots List

Response result is `{ "roots": [] }`. `pickFirstValidRoot` returns `None`; `applyMCPRoot` is not called; the empty list is logged via `writeLog["RootsListEmptyOrInvalid" -> {}]`. Tools run with the kernel's original `cwd`.

### Example 6 — Error Response

```json
{
  "jsonrpc": "2.0",
  "id": "9c8e1d6e-...",
  "error": { "code": -32601, "message": "Method not found" }
}
```

`handleRootsListResponse` detects `"error"`, logs `"RootsListError"`, does not apply a root.

---

## Future Considerations

1. **Generic readiness gate** for tools that need a root — a way for path-sensitive tools to await `applyMCPRoot` without blocking the whole loop. Useful only if the race becomes observable in practice.
2. **Multi-root awareness** — tools that legitimately span multiple project directories could be extended to consume the full roots list rather than only the first valid entry.
3. **Root marker scoring** — replace the strict "first valid" heuristic with one that prefers roots containing project markers (`PacletInfo.wl`, `.git`, `.claude/`).
4. **Directory-stack hygiene** — track a baseline directory at startup and `ResetDirectory[]` before each `SetDirectory[root]` to prevent stack growth across many `list_changed` events.
5. **Local kernel restart resilience** — when the evaluator method is `"Local"`, re-run `useEvaluatorKernel[SetDirectory[$mcpRoot]]` defensively before each tool invocation that uses the local kernel, so a kernel restart mid-session doesn't lose the root.
6. **Reuse for sampling and elicitation** — the generic `sendClientRequest` infrastructure paves the way for `sampling/createMessage` and `elicitation/create` requests to the client; future specs can reference this one rather than redefining the registry.
7. **Server-initiated roots query without `roots` capability** — the spec currently keys off the client capability; if the protocol later allows opportunistic queries, lift that gate.
