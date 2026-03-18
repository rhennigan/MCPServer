# Progress

Append concise notes about your progress to this file (don't remove existing notes). Include the following types of information:

- What was achieved during this session
- Anything you learned that would be helpful to others resuming your work

Use the following format incrementing the session number from the latest entry:

## Session {sessionNumber}

{your notes}

## Session 1

- Completed Task 1: Added `"MCPServerName" -> "Wolfram"` to all four built-in server definitions in `DefaultServers.wl` (`"Wolfram"`, `"WolframAlpha"`, `"WolframLanguage"`, `"WolframPacletDevelopment"`).
- Verified via CodeInspector (no issues) and WolframLanguageEvaluator (all servers return `"Wolfram"` for `"MCPServerName"` while retaining their distinct `"Name"` values).
- The `MCPServerObject` generic property handling already exposes `"MCPServerName"` without any changes to `MCPServerObject.wl`.

## Session 2

- Completed Task 2: Added `"MCPServerName" -> Automatic` option to both `InstallMCPServer` and `UninstallMCPServer`.
- Implemented `resolveMCPServerName` with the precedence chain: option value → `obj["MCPServerName"]` property → `obj["Name"]` fallback.
- Added `$installMCPServerName` Block variable threaded through both install and uninstall dispatches.
- Both `installMCPServer` and `uninstallMCPServer` now use the resolved MCPServerName as the config file key (usage 2) while preserving `obj["Name"]` for JSON extraction (usage 1), in both JSON and Codex TOML paths.
- Implemented `clearStaleBuiltInRecords` to clear installation records from other built-in Wolfram variants when one is installed under the shared `"Wolfram"` key.
- Key gotcha: `$defaultMCPServers` (lowercase, plural) is private to `DefaultServers.wl`. Must use `$DefaultMCPServers` (uppercase, public) instead.
- Updated 20+ existing tests in `InstallMCPServer.wlt` and restructured `UninstallMCPServer.wlt` to reflect the shared `"Wolfram"` config key behavior.
- Added new "MCPServerName Option" test section covering all 7 spec verification items: built-in key resolution, overwrite behavior, custom server unchanged, uninstall by resolved key, option override, two built-in with different overrides coexisting, and stale record clearing.
- All 179 InstallMCPServer tests and 17 UninstallMCPServer tests pass. CodeInspector clean.

## Session 4

- Completed Task 4: Added deployment-related messages to `Messages.wl`.
- Added `MCPServer::DeploymentExists`, `MCPServer::DeploymentNotFound`, and `MCPServer::InvalidDeploymentData` message definitions.
- CodeInspector clean.

## Session 5

- Completed Task 5: Implemented `AgentToolsDeployment` object in `Kernel/DeployAgentTools.wl`.
- Implemented schema validation using `System`Private`HoldSetValid`/`HoldNotValidQ`, following the `MCPServerObject` pattern.
- Implemented all property access: top-level keys (`UUID`, `Timestamp`, `PacletVersion`, `CreatedBy`, `MCP`, `Skills`, `Hooks`, `Meta`), MCP shortcut properties (`ClientName`, `Target`, `Server`, `ConfigFile`), derived properties (`Data`, `Location`, `Properties`), and two-argument sub-association access (`dep["MCP", "Options"]`).
- Implemented `DeleteObject` UpValue with `deleteDeployment`/`ensureDeploymentExists` internals. `deleteDeployment` calls `UninstallMCPServer` (wrapped in `catchAlways`) then removes the deployment directory.
- Implemented `MakeBoxes` formatting via `BoxForm`ArrangeSummaryBox` with summary rows (Target, Server) and hidden rows (UUID, ConfigFile, Timestamp).
- Implemented `agentToolsDeploymentQ` and `deploymentDirectory` internal helpers.
- Key gotcha: System context symbols (`AgentToolsDeployment`, `DeployedAgentTools`, `DeployAgentTools`) need `Unprotect`/`ClearAll` at the top of the file because `Main.wl` sets `{Protected, ReadProtected}` on them, which persists across `Get` reloads.
- Key gotcha: Error messages are issued on `AgentToolsDeployment` (not `MCPServer`) because `catchTop[..., AgentToolsDeployment]` sets `$messageSymbol` to `AgentToolsDeployment`. The `messageFailure` function automatically copies message text from `MCPServer` to the target symbol. Tests must expect `AgentToolsDeployment::tag` not `MCPServer::tag`.
- Key gotcha: `MakeBoxes` holds its arguments, so formatting tests must use `With[{obj = AgentToolsDeployment[data]}, MakeBoxes[obj, StandardForm]]` to inject an already-evaluated (valid) object.
- All 36 DeployAgentTools tests pass. CodeInspector clean on both source and test files. All 196 existing tests (InstallMCPServer + UninstallMCPServer) still pass.

## Session 3

- Completed Task 3: Exported shared symbols to `CommonSymbols.wl` and added `$deploymentsPath`.
- Declared `$deploymentsPath`, `toInstallName`, `installLocation`, `projectInstallLocation`, and `guessClientName` in `CommonSymbols.wl` so they are accessible from `DeployAgentTools.wl`.
- Added `$deploymentsPath` definition in `Files.wl` following the existing pattern (`$UserBaseDirectory/ApplicationData/Wolfram/MCPServer/Deployments`).
- Registered the `DeployAgentTools` context (`Wolfram`MCPServer`DeployAgentTools``) in `$MCPServerContexts` in `Main.wl`.
- Created skeleton `Kernel/DeployAgentTools.wl` so the `Needs` call in `Main.wl` doesn't fail.
- Key gotcha: moving `toInstallName`, `installLocation`, `projectInstallLocation` from `InstallMCPServer`Private`` to `Common`` context required updating test references — 32 tests referenced the old fully-qualified `InstallMCPServer`Private`` paths. Updated all to `Common`` context. `guessClientNameFromJSON` stays private.
- All 179 InstallMCPServer tests and 17 UninstallMCPServer tests pass. CodeInspector clean on all 4 modified files.

## Session 6

- Completed Task 6: Implemented `DeployAgentTools` function in `Kernel/DeployAgentTools.wl`.
- Implemented all four call signatures: `DeployAgentTools[target]`, `DeployAgentTools[target, opts]`, `DeployAgentTools[target, server]`, `DeployAgentTools[target, server, opts]`.
- Implemented target resolution via `resolveDeployTarget` handling three target forms: string client names (with alias resolution via `toInstallName`), `{name, dir}` project-level pairs, and `File[...]` direct paths.
- Implemented duplicate-checking via `findExistingDeployment` which scans the client subdirectory under `$deploymentsPath` and compares stored `ConfigFile` paths using `ExpandFileName` for equivalence.
- Implemented `OverwriteTarget` logic: `False` (default) returns `Failure["DeploymentExists", ...]`; `True` deletes the existing deployment first.
- Options are passed through to `InstallMCPServer` using `FilterRules`, and the install-relevant options are stored in the deployment record for use by `DeleteObject`.
- Deployment records are written as WXF under `$deploymentsPath/<ClientName>/<UUID>/Deployment.wxf`.
- Key fix: `deploymentDirectory` was returning raw strings from `FileNames` instead of `File[...]` — fixed to always return `File[...]` via `fileNameJoin`.
- Helper functions added: `resolveDeployTarget`, `findExistingDeployment`, `loadDeploymentFromDir`, `configFilesEqual`.
- Added 24 new tests covering spec verification items 1-2 (deploy and verify properties/config), 6 (duplicate fails), 7 (overwrite replaces), and 8 (equivalent target forms detected as same deployment).
- All 60 DeployAgentTools tests pass. All 196 existing tests (InstallMCPServer + UninstallMCPServer) still pass. CodeInspector clean.

## Session 7

- Completed Task 7: Implemented `DeployedAgentTools` listing/query function in `Kernel/DeployAgentTools.wl`.
- Implemented no-argument form: scans all client subdirectories under `$deploymentsPath`, reads `Deployment.wxf` from each UUID subdirectory, filters out corrupted/invalid records.
- Implemented single-argument form: resolves the target string through `toInstallName` (alias resolution via `$aliasToCanonicalName`), then scans only the matching `$deploymentsPath/<ClientName>/` subdirectory.
- Added `deploymentsInClientDir` internal helper that maps `loadDeploymentFromDir` over UUID subdirectories and filters out `Missing` results.
- Fixed pre-existing syntax error in test file: `TestID -"..."s"` → `TestID -> "..."` on the EquivalentTargetFails test.
- Key gotcha: `ClaudeCode` has no aliases, so alias resolution tests should use `"Claude"` → `"ClaudeDesktop"` instead.
- Key gotcha: `$deploymentsPath` in tests is set via `= Wolfram`MCPServer`Common`$deploymentsPath` (value assignment to Global context). To Block it in tests, must use the fully qualified `Wolfram`MCPServer`Common`$deploymentsPath` symbol.
- Added 10 new tests covering spec verification items 3-4: list all deployments, filter by client name, alias resolution, non-existent client returns empty list, empty deployments path, and corrupted records filtered out.
- All 70 DeployAgentTools tests pass. All 196 existing tests (InstallMCPServer + UninstallMCPServer) still pass. CodeInspector clean on both source and test files.

## Session 8

- Completed Task 8: Added end-to-end tests for `DeleteObject` on `AgentToolsDeployment`.
- The `deleteDeployment` implementation was already complete from Session 5 (calls `UninstallMCPServer` wrapped in `catchAlways`, then removes the deployment directory). This session focused on verification tests.
- Fixed 12 broken `TestID` syntax issues in the test file from Session 7 (e.g. `TestID -"..."2"` → `TestID -> "..."`). The broken syntax caused tests to run with auto-generated IDs rather than named IDs, but didn't prevent them from passing.
- Added 11 new tests covering spec verification item 5 and round-trip scenarios:
  - Pre-delete state verification: config file has entry, deployment directory exists, deployment appears in listing
  - Delete operation returns `Null`
  - Post-delete state: config entry removed, deployment directory removed, deployment gone from listing
  - Delete-again fails with `DeploymentNotFound` message
  - Full round-trip: deploy → list → delete → verify config and listing both clean
- All 81 DeployAgentTools tests pass. All 196 existing tests (InstallMCPServer + UninstallMCPServer) still pass. CodeInspector clean on both source and test files.

## Session 9

- Completed Task 9: Final verification — ran CodeInspector and full test suite.
- CodeInspector: no issues on `Kernel/DeployAgentTools.wl` or `Tests/DeployAgentTools.wlt`.
- All 81 DeployAgentTools tests pass (100%) in 3.7s.
- All spec verification items covered by tests across sessions 5–8.
- DeployAgentTools feature is complete.

