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

