# MCP Roots — TODO

Tasks for implementing the [MCP Roots specification](../Specs/MCPRoots.md).
Each item is a logical unit of work for one coding session.

Nothing from the spec is implemented yet.

---

- [x] **1. Extend `MCPServerTestUtilities.wl` for server-to-client traffic**

  The harness primitives every later integration test depends on: arbitrary
  client capabilities in `MCPInitialize`, plus helpers to read a server-issued
  request and send a JSON-RPC response back.

  **Files:** `Tests/MCPServerTestUtilities.wl`

---

- [x] **2. Build the client-request infrastructure (`MCPClientRequests.wl`)**

  Subsystem 1. Includes the `processRequest` and notifications-branch edits
  in `StartMCPServer.wl`, the symbol declarations in `CommonSymbols.wl`, and
  the `Main.wl` context entry. The spec doesn't name a test file — put the
  registry/dispatcher unit tests in a new `Tests/MCPClientRequests.wlt`.

  **Files:** `Kernel/MCPClientRequests.wl`, `Kernel/CommonSymbols.wl`,
  `Kernel/Main.wl`, `Kernel/StartMCPServer.wl`, `Tests/MCPClientRequests.wlt`

---

- [ ] **3. Build the roots feature (`MCPRoots.wl`)**

  Subsystem 2. Includes the `useEvaluatorKernel` relocation
  (`Tools/Tools.wl:8` → `CommonSymbols.wl`), the `$clientSupportsRoots`
  detection and TODO removal in `handleMethod["initialize", …]`
  (`StartMCPServer.wl:516–523`), and the `Main.wl` context entry. Spec
  doesn't name a test file — put unit tests for `rootURIToPath`,
  `pickFirstValidRoot`, and `handleRootsListResponse` in a new
  `Tests/MCPRoots.wlt`.

  **Files:** `Kernel/MCPRoots.wl`, `Kernel/CommonSymbols.wl`,
  `Kernel/Tools/Tools.wl`, `Kernel/Main.wl`, `Kernel/StartMCPServer.wl`,
  `Tests/MCPRoots.wlt`

---

- [ ] **4. Wire `$mcpRoot` into `TestReport`'s `RunProcess` call**

  The single call site at `Kernel/Tools/TestReport.wl:100`, plus the relative-
  path test in `Tests/Tools.wlt` (guarded with the existing `$allowExternal`
  convention near line 481).

  **Files:** `Kernel/Tools/TestReport.wl`, `Tests/Tools.wlt`

---

- [ ] **5. End-to-end roots handshake tests in `Tests/StartMCPServer.wlt`**

  The four scenarios from the testing plan (initialize-with-roots, initialized
  triggers `roots/list`, response handling, `list_changed` re-fetch) plus the
  no-`roots`-capability negative path.

  **Files:** `Tests/StartMCPServer.wlt`

---
