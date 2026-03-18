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
- Key gotcha: System context symbols (`AgentToolsDeployment`, `AgentToolsDeployments`, `DeployAgentTools`) need `Unprotect`/`ClearAll` at the top of the file because `Main.wl` sets `{Protected, ReadProtected}` on them, which persists across `Get` reloads.
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

