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

## Session 7

Completed TODO task 7:

- No code changes needed in `CreateMCPServer.wl` — the validation path already handles paclet-qualified names correctly via changes from Tasks 4 and 5: `validateTool` passes through `/`-containing strings without resolution, and `convertStringTools0` only resolves them at property access time
- Added 24 new tests (55 total) to `Tests/CreateMCPServer.wlt` covering:
  - Three-segment paclet-qualified tool name stored as string in data and WXF
  - Two-segment paclet-qualified tool name preserved
  - Mixed tool types (LLMTool objects + paclet-qualified strings) preserved correctly
  - Multiple paclet-qualified tool names from different paclets
  - Paclet-qualified prompt names stored as strings
  - End-to-end mock paclet test: string stored at creation, resolved to LLMTool at access time
- Key insight: `validateTools` validates each tool via `validateTool` but returns the **original** tools list (`Flatten @ { tools }`), not the validated results. So paclet-qualified strings survive as plain strings in `Metadata.wxf` without any code changes to `CreateMCPServer.wl`
- All 55 CreateMCPServer tests pass, all 70 MCPServerObject tests pass, code inspector clean

## Session 8

Completed TODO task 9:

- Added `ensurePacletsForStart` — extracts paclet-qualified tool/prompt names from server data and ensures each referenced paclet is installed via `PacletInstall` before tool/prompt resolution. Uses `PacletDependencyMissing` error (with server name context) when a paclet fails to install.
- Added `ensurePacletForStart` — helper that installs a single paclet for a qualified name, with server-name-aware error reporting
- Added `runServerInitialization` — runs server-level `"Initialization"` code for paclet-backed servers by reloading the server definition and accessing the `"Initialization"` key (which uses `RuleDelayed` for lazy evaluation). No-op for built-in and file-based servers.
- Added `runToolInitialization` — runs `"Initialization"` code for all tools at startup (behavioral change: previously only done at install time). Iterates over resolved `LLMTool` objects and accesses their `"Initialization"` key.
- Modified `startMCPServer` to call these functions in order: (1) `ensurePacletsForStart` before resolution, (2) `runServerInitialization` before tool resolution, (3) `runToolInitialization` after tools are resolved to `LLMTool` objects
- Added 14 new tests (46 total) to `Tests/StartMCPServer.wlt` covering:
  - `runToolInitialization`: runs both inits, no-init tools are no-op, empty list, mixed init/no-init
  - `ensurePacletsForStart`: installed paclet succeeds, no paclet tools is no-op, empty evaluator, no evaluator, paclet tools succeed
  - `ensurePacletForStart`: installed paclet returns PacletObject, missing paclet throws PacletDependencyMissing
  - `runServerInitialization`: built-in server no-op, file-based server no-op, paclet server with no init returns Null
- All 46 StartMCPServer tests pass, 70 MCPServerObject tests pass, 176 InstallMCPServer tests pass, code inspector clean

## Session 9

Completed TODO task 10:

- Added `disambiguateToolNames` — after all tools are resolved to `LLMTool` objects, groups them by MCP-exposed name, appends numeric suffixes (`Name1`, `Name2`, ...) for groups with collisions, and returns an association keyed by disambiguated names. Non-conflicting tools keep their original name.
- Modified `startMCPServer` to use `disambiguateToolNames` instead of manually building the `llmTools` association. This also fixes a pre-existing edge case where two tools with the same name would silently overwrite each other in the association.
- Changed `toolList` construction from `createMCPToolData /@ Values @ llmTools` to `KeyValueMap[createMCPToolData, llmTools]` so disambiguated names are passed through.
- Added two-argument `createMCPToolData[mcpName_String, tool_LLMTool]` that uses the provided MCP name instead of `tool["Name"]`. The one-argument form delegates to it.
- No changes needed to `evaluateTool` — it already looks up tools in `$llmTools` by the name the client sends, and `$llmTools` is now keyed by disambiguated names.
- Added 13 new tests (59 total) covering: empty list, no collisions, two/three tools with same name, mixed collisions, multiple collision groups, value preservation, single tool, `createMCPToolData` name override, single-arg backward compat, wire name integration, lookup routing integration
- All 59 StartMCPServer tests pass, code inspector clean

## Session 10

Completed TODO task 11:

- Implemented `ValidateMCPPacletExtension` in `Kernel/ValidateMCPPacletExtension.wl` with all four validation check categories:
  1. **Extension structure** — checks for MCP extension presence, valid keys, valid declaration forms
  2. **File existence** — checks root directory, per-item and combined files, warns on duplicate definition files
  3. **File contents** — validates definition files evaluate to associations with required keys (LLMEvaluator for servers, Name/Function/Parameters for tools, Name for prompts)
  4. **Cross-references** — validates tool/prompt names referenced by servers are declared in the same paclet or are fully qualified names
- Returns `Success["ValidMCPPacletExtension", <|"Servers" -> ..., "Tools" -> ..., "Prompts" -> ...|>]` on success, `Failure["InvalidMCPPacletExtension", <|"Errors" -> {...}|>]` with detailed error associations on failure
- Each error association includes "Type", "Message", and context-specific keys (e.g., "Item", "ExpectedPath", "MissingKeys")
- Used functional error-collection approach (each helper returns error list) rather than mutable `AppendTo` — WL passes values not references, so `AppendTo` on a function parameter fails with `AppendTo::rvalue`
- Used `catchAlways` wrapper in `tryGetExtensionDirectory` to catch `throwInternalFailure` from `getMCPExtensionDirectory` when root directory doesn't exist
- `catchMine` sets `$messageSymbol` to the exported function symbol (`ValidateMCPPacletExtension`), so messages are issued as `ValidateMCPPacletExtension::InvalidMCPPacletExtension` rather than `MCPServer::InvalidMCPPacletExtension`
- Created 7 mock paclets in `TestResources/` for testing various validation scenarios: InvalidKeys, MissingFiles, BadContents, BadCrossRef, BadDecl, DupFiles, NoRoot
- Added 36 tests covering all validation categories, success/failure paths, and error detail inspection
- All 36 ValidateMCPPacletExtension tests pass, all 52 PacletExtension tests pass, code inspector clean

