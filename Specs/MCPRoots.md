# MCP Roots — Design Specification

## Overview

This specification defines support for the [MCP Roots](https://modelcontextprotocol.io/specification/2025-11-25/client/roots.md) protocol feature in the AgentTools MCP server. When a client (e.g. Claude Code) advertises a project directory, the server queries it via `roots/list`, picks a single working directory, and configures the main kernel, the local evaluator kernel, and `RunProcess`-based tools to operate inside that directory.

## Behavior

- When a client advertises the `roots` capability during `initialize` and then sends `notifications/initialized`, the server issues a `roots/list` request to the client.
- The first valid existing directory in the response is selected as the project root.
- The selected root is stored in `$mcpRoot` and propagated to:
  - The main kernel via `SetDirectory`
  - The local evaluator kernel (when `WolframLanguageEvaluator`'s `Method` is `"Local"`)
  - Tools that invoke external processes via `RunProcess` (currently `TestReport`)
- When the client sends `notifications/roots/list_changed`, the server re-fetches the roots and replaces `$mcpRoot` with the new selection.
- Any failure path (no `roots` capability, error response, empty list, invalid directories, never-replies) leaves `$mcpRoot = None` and tools run with the kernel's original `cwd`.

## URI Handling

MCP root entries look like `<| "uri" -> "file:///C:/Users/.../proj", "name" -> "..." |>`. The server converts each `file://` URI to a native path and verifies the path is an existing directory. Some clients (notably Claude Code on Windows) emit malformed file URIs containing backslashes and only two slashes before the drive letter, like `file://H:\Documents\AgentTools`; these are normalized to a well-formed form before decoding.

Non-`file://` URIs are skipped during selection.

## RunProcess and Working Directory

Tools that invoke external processes via `RunProcess` pass `ProcessDirectory -> $mcpRoot` (when non-`None`) so child processes inherit the project root. Calls that already use a deliberate, explicit `ProcessDirectory` for another purpose (e.g., `git rev-parse` in `Common.wl`) are unaffected.

## Error and Edge-Case Behavior

| Condition | Behavior |
|---|---|
| Client does not advertise `roots` capability | No `roots/list` ever sent. Tools run with kernel's original `cwd`. |
| Client never replies to `roots/list` | No timeout. Tools run with kernel's original `cwd`. |
| Response contains `"error"` | Error logged; no root applied. |
| Response result has empty `roots` list | Logged; no root applied. |
| All roots fail `DirectoryQ` | Same as empty: logged, no root applied. |
| URI is not `file://` | The entry is skipped during scan. |

In all of these cases the server stays alive and continues serving tool calls — `$mcpRoot` simply remains `None`, and tools fall through to today's behavior.

---

## Race Condition: `tools/call` Before `roots/list` Resolves

Because the server processes messages strictly in arrival order, a client that fires a `tools/call` before responding to our `roots/list` will have that tool execute with `$mcpRoot === None` (i.e., the kernel's original `cwd`). This is **accepted, not mitigated**, in v1:

- In practice, MCP clients sequence `notifications/initialized` immediately after `initialize` and do not fire `tools/call` until the user takes an action, by which point the `roots/list` round-trip has long completed.
- A queueing layer would meaningfully complicate the message loop and is unjustified for a race that has not been observed.

Tools should therefore tolerate `$mcpRoot === None` and behave as they do today.

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

The first entry is skipped (`DirectoryQ` returns `False`) and `H:\Documents\AgentTools` is selected.

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

Response result is `{ "roots": [] }`. No root is applied; the empty list is logged. Tools run with the kernel's original `cwd`.

### Example 6 — Error Response

```json
{
  "jsonrpc": "2.0",
  "id": "9c8e1d6e-...",
  "error": { "code": -32601, "message": "Method not found" }
}
```

The error is logged; no root is applied.

---

## Future Considerations

1. **Generic readiness gate** for tools that need a root — a way for path-sensitive tools to await `applyMCPRoot` without blocking the whole loop. Useful only if the race becomes observable in practice.
2. **Multi-root awareness** — tools that legitimately span multiple project directories could be extended to consume the full roots list rather than only the first valid entry.
3. **Root marker scoring** — replace the strict "first valid" heuristic with one that prefers roots containing project markers (`PacletInfo.wl`, `.git`, `.claude/`).
4. **Directory-stack hygiene** — track a baseline directory at startup and `ResetDirectory[]` before each `SetDirectory[root]` to prevent stack growth across many `list_changed` events.
5. **Local kernel restart resilience** — when the evaluator method is `"Local"`, re-run `useEvaluatorKernel[SetDirectory[$mcpRoot]]` defensively before each tool invocation that uses the local kernel, so a kernel restart mid-session doesn't lose the root.
6. **Reuse for sampling and elicitation** — the generic `sendClientRequest` infrastructure paves the way for `sampling/createMessage` and `elicitation/create` requests to the client; future specs can reference this one rather than redefining the registry.
7. **Server-initiated roots query without `roots` capability** — the spec currently keys off the client capability; if the protocol later allows opportunistic queries, lift that gate.
