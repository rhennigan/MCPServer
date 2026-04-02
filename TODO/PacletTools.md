# Paclet Tools — TODO

Tasks for implementing the [PacletTools specification](../Specs/PacletTools.md).
Each item is a logical unit of work for one coding session.

---

- [x] **1. Add error messages and registration points**

  Add the two shared message tags (`PacletToolsInvalidPath`, `PacletCICDLoadFailed`) to `Messages.wl`. Add the `PacletTools` subcontext to `$subcontexts` in `Tools.wl`. Add `CheckPaclet`, `BuildPaclet`, `SubmitPaclet` to the `"WolframPacletDevelopment"` server's tool list in `DefaultServers.wl`. These are prerequisites for the implementation files.

  **Files:** `Kernel/Messages.wl`, `Kernel/Tools/Tools.wl`, `Kernel/DefaultServers.wl`

---

- [x] **2. Implement PacletTools.wl (main module with shared helpers and tool definitions)**

  Create the `Kernel/Tools/PacletTools/` directory and the main `PacletTools.wl` file. This contains the package header, shared helpers (`ensurePacletCICD`, `validatePacletPath`), tool description strings, all three `$defaultMCPTools` definitions, and the submodule `Get` calls. Follow the `CodeInspector/CodeInspector.wl` pattern for structure.

  **Files:** `Kernel/Tools/PacletTools/PacletTools.wl`

---

- [x] **3. Implement CheckPaclet.wl**

  Create `CheckPaclet.wl` with the `checkPacletTool` function and `formatCheckResult` formatter. The formatter must handle empty datasets ("No issues found") and mixed-severity datasets (summary table + grouped numbered lists). Must use `"FailureCondition" -> None`.

  **Files:** `Kernel/Tools/PacletTools/CheckPaclet.wl`

---

- [ ] **4. Implement BuildPaclet.wl**

  Create `BuildPaclet.wl` with the `buildPacletTool` function and `formatBuildResult` formatter. The formatter must handle `Success["PacletBuild", ...]` (extract archive path, name, version) and `Failure` results (including the `"CheckPaclet::errors"` case that reuses `formatCheckResult`). Supports the optional `check` boolean parameter.

  **Files:** `Kernel/Tools/PacletTools/BuildPaclet.wl`

---

- [ ] **5. Implement SubmitPaclet.wl**

  Create `SubmitPaclet.wl` with the `submitPacletTool` function and `formatSubmitResult` formatter. The formatter must handle `Success["ResourceSubmission", ...]` (extract name, version, status, optional UUID/SubmissionID/warnings) and `Failure` results (including nested authentication failures with user guidance).

  **Files:** `Kernel/Tools/PacletTools/SubmitPaclet.wl`

---

- [ ] **6. Write and run tests**

  Create `Tests/PacletTools.wlt` covering:
  - [ ] `validatePacletPath` returns `File[...]` for existing paths and throws for missing paths
  - [ ] `formatCheckResult` for empty dataset and mixed-severity dataset
  - [ ] `formatBuildResult` for success and `"CheckPaclet::errors"` failure
  - [ ] `formatSubmitResult` for success and nested authentication failure

  **Files:** `Tests/PacletTools.wlt`

---

- [ ] **7. Update server documentation**

  Add `CheckPaclet`, `BuildPaclet`, and `SubmitPaclet` to the `WolframPacletDevelopment` tool table in `docs/servers.md`.

  **Files:** `docs/servers.md`

---

- [ ] **8. Rebuild agent skills**

  Run `Scripts/BuildAgentSkills.wls` to regenerate skill artifacts now that new MCP tool definitions exist. Verify the generated output includes the new tools.

  **Files:** `Scripts/BuildAgentSkills.wls`, `AgentSkills/`

---
