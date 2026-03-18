# DeployAgentTools — TODO

Tasks for implementing the [DeployAgentTools specification](../Specs/DeployAgentTools.md).
Each item is a logical unit of work for one coding session.

---

- [x] **1. Add `"MCPServerName"` property to built-in server definitions**

  Add `"MCPServerName" -> "Wolfram"` to all four built-in server definitions in `DefaultServers.wl` (`"Wolfram"`, `"WolframAlpha"`, `"WolframLanguage"`, `"WolframPacletDevelopment"`). This is the prerequisite that makes built-in servers share a single config key by default.

  **Files:** `Kernel/DefaultServers.wl`

---

- [ ] **2. Add `"MCPServerName"` option to `InstallMCPServer` / `UninstallMCPServer`**

  Add `"MCPServerName" -> Automatic` option to both functions. Implement the config-key resolution precedence chain (option → server property → `"Name"`). Replace the config-file key usage (usage 2) with the resolved MCPServerName in both the JSON path and the Codex TOML path, while preserving `obj["Name"]` for JSON extraction (usage 1). Add logic to clear stale built-in installation records when one built-in variant overwrites another under the shared `"Wolfram"` key. Write and run tests covering the verification cases in the spec (items 1–7).

  **Files:** `Kernel/InstallMCPServer.wl`, `Tests/InstallMCPServer.wlt`, `Tests/UninstallMCPServer.wlt`

---

- [ ] **3. Export shared symbols to `CommonSymbols.wl` and add `$deploymentsPath`**

  Declare `$deploymentsPath`, `toInstallName`, `installLocation`, `projectInstallLocation`, and `guessClientName` in `CommonSymbols.wl` so they are accessible from `DeployAgentTools.wl`. Add the `$deploymentsPath` definition in `Files.wl` following the existing pattern (`$UserBaseDirectory/ApplicationData/Wolfram/MCPServer/Deployments`). Register the `DeployAgentTools` context in `$MCPServerContexts` in `Main.wl`.

  **Files:** `Kernel/CommonSymbols.wl`, `Kernel/Files.wl`, `Kernel/Main.wl`

---

- [ ] **4. Add deployment-related messages**

  Add `MCPServer::DeploymentExists`, `MCPServer::DeploymentNotFound`, and `MCPServer::InvalidDeploymentData` message definitions.

  **Files:** `Kernel/Messages.wl`

---

- [ ] **5. Implement `AgentToolsDeployment` object**

  Create `Kernel/DeployAgentTools.wl`. Implement the `AgentToolsDeployment` data model: schema validation using `HoldSetValid`/`HoldNotValidQ`, property access (all properties from the spec table), `DeleteObject` UpValue with `deleteDeployment` / `ensureDeploymentExists` internals, and `MakeBoxes` formatting via `ArrangeSummaryBox`. Include internal helpers `agentToolsDeploymentQ` and `deploymentDirectory`. Write and run tests for object construction, property access, validation, and formatting.

  **Files:** `Kernel/DeployAgentTools.wl`, `Tests/DeployAgentTools.wlt`

---

- [ ] **6. Implement `DeployAgentTools` function**

  Implement the main `DeployAgentTools` function with all four call signatures. Cover: target resolution (aliases, `{name, dir}` pairs, `File[...]`), existing-deployment duplicate checking against `"MCP"/"ConfigFile"`, `OverwriteTarget` logic, `InstallMCPServer` passthrough with `FilterRules`, deployment record construction (UUID, timestamp, version, MCP component, empty Skills/Hooks/Meta), WXF serialization under `$deploymentsPath/<ClientName>/<uuid>/Deployment.wxf`. Write and run tests covering spec verification items 1–2 and 6–8.

  **Files:** `Kernel/DeployAgentTools.wl`, `Tests/DeployAgentTools.wlt`

---

- [ ] **7. Implement `AgentToolsDeployments` function**

  Implement the listing/query function: no-argument form (scan all client subdirectories), single-argument form (filter by client name with alias resolution). Handle corrupted/invalid records gracefully. Write and run tests covering spec verification items 3–4.

  **Files:** `Kernel/DeployAgentTools.wl`, `Tests/DeployAgentTools.wlt`

---

- [ ] **8. Implement `DeleteObject` for `AgentToolsDeployment` and end-to-end tests**

  Implement the full delete flow: `UninstallMCPServer` call with filtered options (wrapped in `catchAlways`), deployment directory cleanup. Write and run end-to-end tests covering spec verification item 5 (delete removes config entry and deployment directory), plus round-trip deploy → list → delete → verify-gone scenarios.

  **Files:** `Kernel/DeployAgentTools.wl`, `Tests/DeployAgentTools.wlt`

---

- [ ] **9. Run CodeInspector and final verification**

  Run `CodeInspector` on `Kernel/DeployAgentTools.wl` and fix any issues. Run the full `Tests/DeployAgentTools.wlt` test suite end-to-end. Verify all spec verification items pass.

  **Files:** `Kernel/DeployAgentTools.wl`, `Tests/DeployAgentTools.wlt`
