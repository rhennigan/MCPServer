# Progress

Append concise notes about your progress to this file (don't remove existing notes). Include the following types of information:

- What was achieved during this session
- Anything you learned that would be helpful to others resuming your work

Use the following format incrementing the session number from the latest entry:

## Session {sessionNumber}

{your notes}

## Session 1

**Completed Phase 1: Core infrastructure**

Added MCP prompts support following the pattern established by the Tools system:

1. **Error messages** (`Kernel/Messages.wl`):
   - Added `InvalidMCPPromptSpecification`, `InvalidMCPPromptsSpecification`, `PromptNameNotFound`, and `DeprecatedPromptData` messages

2. **Created `Kernel/Prompts/Prompts.wl`**:
   - Defines `$DefaultMCPPrompts` (analogous to `$DefaultMCPTools`)
   - Follows the same pattern as `Kernel/Tools/Tools.wl`
   - Loads subcontexts and registers with `$MCPServerContexts`

3. **Created `Kernel/Prompts/Search.wl`**:
   - Defines three search prompts: `WolframSearch`, `WolframLanguageSearch`, `WolframAlphaSearch`
   - All share MCP name "Search" but provide different content based on server type
   - Functions `generateWolframSearchPrompt`, `generateWLSearchPrompt`, `generateWASearchPrompt` call existing context functions from `Tools`Context``

4. **Updated `Kernel/Main.wl`**:
   - Added `$DefaultMCPPrompts` to exported symbols
   - Added `Wolfram`MCPServer`Prompts`` to `$MCPServerContexts`
   - Added `$DefaultMCPPrompts` to protected names list

5. **Updated `PacletInfo.wl`**:
   - Added `Wolfram`MCPServer`$DefaultMCPPrompts` to Symbols list

6. **Created `Tests/Prompts.wlt`**:
   - 20 tests covering `$DefaultMCPPrompts` structure, keys, prompt properties, MCP name mapping, and individual prompt definitions
   - All tests pass

**Next steps**: Phase 2 - Property access and validation in `MCPServerObject.wl`

## Session 2

**Completed Phase 2: Property access and validation**

Updated `Kernel/MCPServerObject.wl` to support the new `"MCPPrompts"` LLMEvaluator property:

1. **Validation support**:
   - Added `validateLLMEvaluator0["MCPPrompts", ...]` to validate prompts during server creation
   - Added `validateMCPPrompts` to validate lists of prompt specifications (strings or associations)
   - Added `validateMCPPrompt` to validate individual prompts (checks `$DefaultMCPPrompts` for string names)

2. **Updated `getPromptData`**:
   - Now checks for `"MCPPrompts"` first (new property)
   - Falls back to `"PromptData"` and issues deprecation failure
   - Returns empty list if neither property exists

3. **Normalization functions**:
   - Added `normalizePromptData` to convert prompt specifications (strings to `$DefaultMCPPrompts` lookups, associations get type inference)
   - Added `determinePromptType` to infer prompt type from content when `"Type"` is `Automatic` or missing

4. **Tests** (23 new tests added to `Tests/Prompts.wlt`):
   - `validateMCPPrompts` and `validateMCPPrompt` validation
   - `normalizePromptData` string lookup and type inference
   - `determinePromptType` for various content types
   - `getPromptData` with MCPPrompts, inline prompts, and deprecation warning

All 371 tests pass.

**Next steps**: Phase 3 - Protocol handling in `StartMCPServer.wl`

## Session 3

**Completed Phase 3: Protocol handling**

Updated `Kernel/StartMCPServer.wl` to handle Function-type prompts and normalize keys for MCP protocol:

1. **Updated `makePromptContent`**:
   - Added handler for `"Type" -> "Function"` prompts that calls the function with arguments
   - Added fallback handler that converts non-string content to string using `ToString`
   - Existing handlers for Text type, StringTemplate, and plain strings preserved

2. **Updated `makePromptData`**:
   - Refactored to use new `makePromptData0` helper function
   - Properly normalizes capitalized keys (`"Name"`, `"Description"`, `"Arguments"`) to lowercase MCP format
   - Handles both capitalized and lowercase input keys
   - Only includes `"arguments"` in output if the list is non-empty

3. **Added `normalizeArguments` and `normalizeArgument`**:
   - Normalize argument specifications to lowercase MCP format
   - Handle both capitalized and lowercase input keys
   - Provide defaults for missing `"description"` (empty string) and `"required"` (False)

4. **Tests** (17 new tests added to `Tests/Prompts.wlt`):
   - `makePromptContent` with Function type, Text type, StringTemplate, plain string, and fallback
   - `makePromptData` with capitalized keys, lowercase keys, arguments, and no arguments
   - `normalizeArguments` with capitalized keys, lowercase keys, multiple arguments, and empty list
   - `normalizeArgument` with all fields, defaults, and lowercase keys

All 388 tests pass.

**Next steps**: Phase 4 - Server configuration in `DefaultServers.wl`

## Session 4

**Completed Phase 4: Server configuration**

Updated `Kernel/DefaultServers.wl` to add `"MCPPrompts"` configurations to all default servers:

1. **Server configurations updated**:
   - `"Wolfram"` -> `"MCPPrompts" -> { "WolframSearch" }`
   - `"WolframAlpha"` -> `"MCPPrompts" -> { "WolframAlphaSearch" }`
   - `"WolframLanguage"` -> `"MCPPrompts" -> { "WolframLanguageSearch" }`
   - `"WolframPacletDevelopment"` -> `"MCPPrompts" -> { "WolframLanguageSearch" }`

2. **Integration tests** (10 new tests added to `Tests/Prompts.wlt`):
   - Server configuration tests verifying each server has correct `MCPPrompts` property
   - Server `PromptData` property tests verifying prompts are accessible via `MCPServerObject`
   - Tests for prompt type consistency (all Function type)
   - Tests for MCP name consistency (all use "Search" name)

Note: `MCPServerObject` accesses nested `LLMEvaluator` properties directly via `["MCPPrompts"]` rather than `["LLMEvaluator", "MCPPrompts"]`.

All 398 tests pass.

**Next steps**: Phase 5 - Developer documentation

## Session 5

**Completed Phase 5: Investigate MCP Error**

Investigated and fixed the "MCP error -32603: Internal error" that occurred when using prompt commands via MCP.

1. **Root cause identified**:
   - The functions `relatedDocumentation`, `relatedWolframContext`, and `relatedWolframAlphaResults` were defined in the private context of `Wolfram`MCPServer`Tools`Context`` and were not accessible from `Prompts/Search.wl`

2. **Fix: Symbol sharing via CommonSymbols.wl**:
   - Added `relatedDocumentation`, `relatedWolframContext`, and `relatedWolframAlphaResults` to `Kernel/CommonSymbols.wl`
   - This makes these symbols available in the `Wolfram`MCPServer`Common`` context and accessible to all packages that load it

3. **Additional improvement: Error handling in makePromptContent**:
   - Added `catchPromptFunction` helper that wraps function calls with error handling
   - Added `formatPromptError` to format failure messages into user-friendly strings
   - Function-type prompts now gracefully handle failures by returning an error message as content instead of throwing an MCP error

4. **Cleanup**:
   - Removed debug `Export` statement from `processRequest` in `StartMCPServer.wl`
   - Deleted `error.wxf` debug file

5. **Tests** (8 new tests added to `Tests/Prompts.wlt`):
   - `catchPromptFunction` success case, returns failure, throws failure
   - `formatPromptError` with message, no message, non-failure input
   - `makePromptContent` with function returning failure, function throwing failure

All 406 tests pass.

**Next steps**: User needs to restart MCP server to verify fix, then Phase 6 - Developer documentation

