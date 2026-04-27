# Progress

Append concise notes about your progress to this file (don't remove existing notes). Include the following types of information:

- What was achieved during this session
- Anything you learned that would be helpful to others resuming your work

Use the following format incrementing the session number from the latest entry:

## Session {sessionNumber}

{your notes}

## Session 1

Completed Task 1 of `TODO/MCPRoots.md` — extending `Tests/MCPServerTestUtilities.wl`
with the harness primitives for server-to-client traffic.

Changes:

- `MCPInitialize` now accepts a `"Capabilities"` option (default `<||>`) that
  is passed through to the `initialize` request's `params.capabilities`. Tests
  can now advertise e.g. `<| "roots" -> <| "listChanged" -> True |> |>`.
- New `ReadMCPMessage[]` helper (with `"Timeout"` option, default 60s) reads a
  single JSON-RPC message from the server's stdout. Used to receive
  server-issued requests like `roots/list` and any out-of-band notifications.
  It reuses the existing `readJSONResponse` pump under a `TimeConstrained`.
- New `SendMCPResponse` helper for replying to a server-issued request:
    - `SendMCPResponse[id, result]` — success response with the given result
    - `SendMCPResponse[id, code, message]` — error response

All three new symbols are exported from the test utilities package. Code
inspection passes; smoke-tested in a fresh kernel that the symbols load and
return `Failure` when no test server is running.

Notes for the next session:

- The integration tests in Task 5 will use these helpers. The natural flow is
  `MCPInitialize["Capabilities" -> <| "roots" -> <| "listChanged" -> True |> |>]`
  (which sends `initialize` and `notifications/initialized`), then
  `ReadMCPMessage[]` to grab the server's `roots/list` request, then
  `SendMCPResponse[id, <| "roots" -> { ... } |>]` to reply.
- The unit tests (`MCPRoots.wlt`) for `handleRootsListResponse`,
  `pickFirstValidRoot`, and `rootURIToPath` do not need these helpers —
  they call the package functions directly.
- Tasks 2 and 3 (the two new server-side packages) and Task 4 (the
  `TestReport` `RunProcess` plumbing) are independent of each other and of
  this session's work; pick whichever fits best next.

## Session 2

Completed Task 2 of `TODO/MCPRoots.md` — built the client-request
infrastructure (Subsystem 1).

Changes:

- New `Kernel/MCPClientRequests.wl` with `$mcpClientRequests` registry,
  `sendClientRequest`, `handleClientResponse`, and `handleNotification`.
  The registry is reset to `<||>` in `addToMXInitialization` so a fresh MX
  load starts with a clean registry.
- `Kernel/CommonSymbols.wl` now declares `$mcpClientRequests`,
  `sendClientRequest`, `handleClientResponse`, `handleNotification`,
  `onClientInitialized`, `onRootsListChanged`, and `writeLog`. The Roots
  feature symbols (`onClientInitialized`, `onRootsListChanged`) are declared
  here even though their definitions land in Task 3 — they're referenced by
  `handleNotification`'s dispatch rules. `writeLog` was hoisted from
  `StartMCPServer.wl`'s private context so `MCPClientRequests.wl` can call
  it; the definition stays in `StartMCPServer.wl`.
- `Kernel/StartMCPServer.wl` `processRequest` now distinguishes server-issued
  responses from inbound requests before method dispatch — if the message has
  no `method` and a `StringQ` `id` that matches a pending entry, it routes to
  `handleClientResponse` and returns `Null` (which makes the main loop skip
  the stdout write). The notifications branch in `handleMethod` now routes
  through `handleNotification[method, msg]` then returns `Null`.
- `Kernel/Main.wl`: added `Wolfram\`AgentTools\`MCPClientRequests\`` to
  `$AgentToolsContexts` (alphabetical position before `MCPServerObject`).
- New `Tests/MCPClientRequests.wlt` with 11 tests covering: registry
  initial state, `sendClientRequest` registration + UUID uniqueness,
  `handleClientResponse` happy-path/unknown-id/error-response, and the three
  `handleNotification` branches. The dispatch tests for
  `notifications/initialized` and `notifications/roots/list_changed` mock
  `onClientInitialized`/`onRootsListChanged` via `Block` so they pass before
  Task 3 lands their real definitions.

Test runs:

- `Tests/MCPClientRequests.wlt` — 11/11 pass.
- `Tests/StartMCPServer.wlt` — 68/68 still pass (regression).
- `Tests/MCPApps.wlt` + `Tests/MCPAppsTest.wlt` — 93/93 still pass.

CodeInspector clean on all changed files.

Notes for the next session:

- Task 3 (Roots feature) is the natural next step — it defines the
  `onClientInitialized` and `onRootsListChanged` symbols already declared
  in `CommonSymbols.wl`, so the dispatcher rules wired up in this session
  start firing real handlers.
- Task 4 (`TestReport` `$mcpRoot` plumbing) is independent of Task 3 but
  references `$mcpRoot`, which is declared in `CommonSymbols.wl` only when
  Task 3 lands.
- Task 5 (end-to-end roots handshake tests) needs Tasks 2 and 3 both done;
  the test helpers from Session 1 (`MCPInitialize` with `"Capabilities"`,
  `ReadMCPMessage`, `SendMCPResponse`) are ready to drive the full flow.
- One subtle thing about `handleNotification`'s dispatch rules: they call
  `onClientInitialized[msg]` even before Task 3 defines the symbol. Until
  then, the call evaluates to literally `onClientInitialized[msg]`
  (unevaluated). The result is discarded by the
  `(handleNotification[method, msg]; Null)` wrapper in
  `handleMethod`'s notifications branch, so this is harmless in production
  but worth knowing if you grep for "unhandled notification" behavior.

## Session 3

Completed Task 3 of `TODO/MCPRoots.md` — built the roots feature
(Subsystem 2).

Changes:

- New `Kernel/MCPRoots.wl` with `$clientSupportsRoots`, `$mcpRoot`, the
  `onClientInitialized` and `onRootsListChanged` handlers, and the private
  helpers `handleRootsListResponse`, `pickFirstValidRoot`, `rootURIToPath`,
  and `applyMCPRoot`. The session-state vars are reset to their initial
  values in `addToMXInitialization` so a fresh MX load starts clean.
- `Kernel/CommonSymbols.wl`: declared `$clientSupportsRoots`, `$mcpRoot`,
  and (per the spec) hoisted `useEvaluatorKernel` here so `MCPRoots.wl`
  can call it without needing to load the Tools subcontext first. The
  definition still lives in `Kernel/Tools/WolframLanguageEvaluator.wl`.
- `Kernel/Tools/Tools.wl`: dropped the `` `useEvaluatorKernel; ``
  package-scope declaration since the symbol now lives in CommonSymbols.
- `Kernel/StartMCPServer.wl`: removed the TODO at the top of
  `handleMethod["initialize", ...]` and added the
  `$clientSupportsRoots = ! MissingQ @ msg["params", "capabilities", "roots"]`
  side-effect alongside the existing `$clientSupportsUI` line.
- `Kernel/Main.wl`: added `Wolfram\`AgentTools\`MCPRoots\`` to
  `$AgentToolsContexts` (alphabetical position after `MCPClientRequests`,
  before `MCPServerObject`).
- New `Tests/MCPRoots.wlt` with 22 tests covering: session-state types
  (`BooleanQ` + `None|String`), `rootURIToPath` (file-scheme, non-file,
  non-string), `pickFirstValidRoot` (single, multi-fallback, empty,
  no-uri-key, non-file scheme, all-invalid, non-list),
  `handleRootsListResponse` (success, error, empty, all-invalid),
  `onClientInitialized` (no-cap and with-cap), and `onRootsListChanged`
  (no-cap and with-cap).

Test runs:

- `Tests/MCPRoots.wlt` — 22/22 pass.
- `Tests/MCPClientRequests.wlt` — 11/11 still pass (regression).
- `Tests/StartMCPServer.wlt` — 68/68 still pass (regression).
- `Tests/MCPApps.wlt` — 74/74 still pass (regression).
- `Tests/Tools.wlt` — 59/59 still pass (`useEvaluatorKernel` relocation).

CodeInspector clean on all changed files.

Notes for the next session:

- Two gotchas hit while writing the unit tests, both worth knowing if you
  add more `pickFirstValidRoot` / `handleRootsListResponse` tests:
  - `WithCleanup[result = ...; check = DirectoryQ[result], DeleteDirectory[...]]`
    must compute the boolean *before* the cleanup runs. Earlier drafts had
    `WithCleanup[result = ..., DeleteDirectory[...]]; DirectoryQ[result]`,
    which checks `DirectoryQ` after the directory has been deleted — gives
    `False` even though the function returned the right path.
  - `applyMCPRoot` is private to `MCPRoots.wl`. Tests stub it via
    `Block[ { Wolfram\`AgentTools\`MCPRoots\`Private\`applyMCPRoot = ... }, ... ]`
    so `handleRootsListResponse` can be exercised without actually calling
    `SetDirectory` / `useEvaluatorKernel`.
- Task 4 (`TestReport` `$mcpRoot` plumbing) is the natural next step.
  `$mcpRoot` is now declared in `CommonSymbols.wl` so the call site in
  `Kernel/Tools/TestReport.wl` can reference it directly.
- Task 5 (end-to-end roots handshake tests) is now unblocked. The flow is:
  `MCPInitialize["Capabilities" -> <| "roots" -> <| "listChanged" -> True |> |>]`
  → `ReadMCPMessage[]` to grab the server's `roots/list` request →
  `SendMCPResponse[id, <| "roots" -> {...} |>]` to reply.
