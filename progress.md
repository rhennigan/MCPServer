# Progress

Append concise notes about your progress to this file (don't remove existing notes). Include the following types of information:

- What was achieved during this session
- Anything you learned that would be helpful to others resuming your work

Use the following format incrementing the session number from the latest entry:

## Session 1

Completed TODO task 1:

- Added 7 shared symbols to `CommonSymbols.wl`
- Added `ValidateMCPPacletExtension` export to `Main.wl` and `PacletInfo.wl`
- Registered subcontexts in `$MCPServerContexts`
- Added 10 new error messages to `Messages.wl` matching spec templates
- Created stub files `Kernel/PacletExtension.wl` and `Kernel/ValidateMCPPacletExtension.wl` so `Needs` in `Main.wl` succeeds
- Verified paclet loads cleanly with all new symbols, messages, and contexts present

## Session 2

Completed TODO task 2:

- Implemented `pacletQualifiedNameQ` — checks if a string contains `/`
- Implemented `parsePacletQualifiedName` — parses 2-segment (`"PacletName/ItemName"`) and 3-segment (`"PublisherID/PacletShortName/ItemName"`) names into an association with `"PacletName"` and `"ItemName"` keys
- Implemented `findMCPPaclets` — uses `PacletTools`PacletExtensions` to discover installed paclets with `"MCP"` extensions
- Added `mcpPacletQ` helper to check if a paclet has an MCP extension
- Created `Tests/PacletExtension.wlt` with 15 tests covering valid/invalid name parsing, `pacletQualifiedNameQ` for various inputs, and `findMCPPaclets` return type
- All tests pass, code inspector clean

## Session 3

Completed TODO task 3:

- Implemented `getMCPExtension`, `getMCPExtensionData`, `getMCPExtensionDirectory` — helpers to extract MCP extension data and root directory from a PacletObject using `PacletTools`PacletExtensions` and `PacletTools`PacletExtensionDirectory`
- Implemented `extractItemName` — handles all three declaration forms (string, {name, description}, association)
- Implemented `getMCPDeclaredItems` — extracts declared item names of a given type from a paclet's MCP extension
- Implemented `findInstalledPaclet` — finds an installed paclet by name via `PacletFind`
- Implemented `loadFile` — loads definition files with .mx (Import MX), .wxf (readWXFFile), .wl (Get) support
- Implemented `findPerItemFile` and `findCombinedFile` — file resolution with .mx > .wxf > .wl priority
- Implemented `loadPacletDefinitionFile` — full definition file loading with per-item/combined file resolution and session-level caching keyed by {pacletName, version, type, name}
- Implemented `qualifyName` and `qualifyNamesInLLMEvaluator` — pre-qualifies short tool/prompt names to fully qualified names within server definitions
- Implemented `resolvePacletTool`, `resolvePacletServer`, `resolvePacletPrompt` — parse qualified name, find paclet, verify declaration, load definition; server resolution pre-qualifies LLMEvaluator names
- Added `clearPacletDefinitionCache`, `findInstalledPaclet`, `getMCPDeclaredItems`, `getMCPExtension`, `getMCPExtensionData`, `getMCPExtensionDirectory` to `CommonSymbols.wl` for use by future tasks
- Extended tests to 52 total (37 new) using mock paclet directories with per-item and combined file layouts
- Fixed HoldForm scoping issue in throwFailure calls — use `With` to inject string values into `HoldForm @ PacletInstall[...]`
- All tests pass, code inspector clean

## Session 4

Completed TODO task 4:

- Updated `$$metadata` pattern to accept `_PacletObject` as a valid `"Location"` alongside `_File` and `"BuiltIn"`
- Added `"ToolNames"` and `"PromptNames"` to `$specialProperties`
- Implemented `getToolNames` and `getPromptNames` — extract tool/prompt name lists from server metadata, with location-aware dispatch for paclet-backed vs file-based servers
- Added `_PacletObject` case to `mcpServerExistsQ` — checks via `PacletFind`
- Added `_PacletObject` case to `deleteMCPServer` — refuses deletion with `DeletePacletMCPServer` error, with early dispatch to avoid calling `UninstallMCPServer` on paclet-backed servers
- Extended `getMCPServerObjectByName` — routes paclet-qualified names (containing `/`) to `checkPacletMCPServer` instead of `checkBuiltInMCPServer`
- Implemented `checkPacletMCPServer` — resolves installed paclet servers via `resolvePacletServer`, falls back to remote metadata via `checkRemotePacletMCPServer`
- Implemented `buildPacletServerMetadata` — constructs metadata association for installed paclet servers
- Implemented `checkRemotePacletMCPServer` and `buildRemotePacletServerMetadata` — constructs partial metadata from PacletInfo for uninstalled remote paclets
- Made `validateTool` and `validateMCPPrompt` pass through paclet-qualified names (strings containing `/`) without attempting resolution — minimum change needed for paclet-backed MCPServerObject creation; full resolution pipeline changes are in Task 5
- Updated `validateTools` to accept strings alongside `LLMTool` objects in validation result
- Extended MCPServerObject tests from 20 to 45 (25 new) covering paclet server creation, properties, ToolNames/PromptNames, DeleteObject refusal, and error cases
- All tests pass, code inspector clean

## Session 5

Completed TODO task 5:

- Extended `convertStringTools0` with paclet-qualified name resolution — names containing `/` are resolved via `resolvePacletTool` and wrapped in `LLMTool`
- Extended `normalizePromptData` with paclet-qualified prompt resolution — names containing `/` are resolved via `resolvePacletPrompt` then normalized (adds "Type" key)
- `validateTool` and `validateMCPPrompt` already had paclet pass-through from Task 4 — verified they work correctly
- `getToolList` works without changes since `convertStringTools0` now resolves paclet tools to `LLMTool` objects
- Added 13 new tests (58 total) covering: `convertStringTools0` paclet resolution, `normalizePromptData` paclet resolution, `obj["Tools"]` and `obj["PromptData"]` for paclet-backed servers, `obj["LLMConfiguration"]` for paclet servers, error cases (tool not found, prompt not found, paclet not installed), and `validateTool`/`validateMCPPrompt` pass-through verification
- Error tests use `catchAlways` wrapper since these internal functions are designed to run inside `catchMine`/`catchAlways` contexts
- All tests pass, code inspector clean

## Session 6

Completed TODO task 6:

- Extended `MCPServerObjects` to accept options via `OptionsPattern` with `Optional` default pattern (`All`)
- Added `"IncludeBuiltIn"`, `"IncludeRemotePaclets"`, and `UpdatePacletSites` options with `False` defaults
- Supports options-only syntax: `MCPServerObjects["IncludeBuiltIn" -> True]` (pattern defaults to `All`)
- Replaced `getMatchingMCPServerObjects` with modular architecture:
  - `mcpServerObjects` — orchestrator that combines all server sources and deduplicates by name
  - `getFileBasedServers` — file-based servers (renamed from `getMatchingMCPServerObjects`, logic unchanged)
  - `getInstalledPacletServers` / `installedPacletToServers` — discovers installed paclets with MCP extensions via `findMCPPaclets`, creates MCPServerObjects for each declared server
  - `getBuiltInServers` — returns `$DefaultMCPServers` values, filtered by pattern
  - `getRemotePacletServers` / `remotePacletToServers` — discovers uninstalled remote paclets via `findRemoteMCPPaclets`, constructs metadata-only MCPServerObjects
  - `filterServersByPattern` — filters server list by `StringMatchQ` on name
- Added `findRemoteMCPPaclets` to `PacletExtension.wl` and `CommonSymbols.wl` — uses `PacletFindRemote` + `mcpPacletQ`, calls `PacletSiteUpdate` when `updateSites` is True
- Added 12 new tests (70 total) covering: installed paclet servers in default listing, `"IncludeBuiltIn"` option (options-only and with pattern), built-in excluded by default, pattern matching for paclet servers, `"IncludeRemotePaclets"` no-error, options declaration, deduplication, `All` equivalence
- All tests pass, code inspector clean

