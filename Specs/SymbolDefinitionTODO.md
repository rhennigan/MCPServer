# SymbolDefinition Tool - Implementation TODO

This checklist tracks all tasks needed to fully implement and test the `SymbolDefinition` tool as specified in `SymbolDefinition.md`.

---

## 1. Project Setup

- [ ] Create `Kernel/Tools/SymbolDefinition.wl` file with package header
- [ ] Add context to `$subcontexts` in `Kernel/Tools/Tools.wl`:
  ```wl
  (* Tools: SymbolDefinition *)
  "Wolfram`MCPServer`Tools`SymbolDefinition`"
  ```
- [ ] Add `"ReadableForm"` version to `$resourceVersions` in `Kernel/Common.wl`
- [ ] Import required resource function:
  ```wl
  importResourceFunction[ readableForm, "ReadableForm" ];
  ```

---

## 2. Tool Definition

- [ ] Define `$symbolDefinitionToolDescription` string
- [ ] Define `$defaultMCPTools["SymbolDefinition"]` with `LLMTool`:
  - [ ] `"Name"` -> `"SymbolDefinition"`
  - [ ] `"DisplayName"` -> `"Symbol Definition"`
  - [ ] `"Description"` -> `$symbolDefinitionToolDescription`
  - [ ] `"Function"` -> `getSymbolDefinition`
  - [ ] `"Parameters"`:
    - [ ] `"symbols"` (String, Required)
    - [ ] `"includeContextDetails"` (Boolean, Optional, default: `false`)
    - [ ] `"maxLength"` (Integer, Optional, default: `10000`)

---

## 3. Input Parsing

- [ ] Implement `parseSymbolNames` function:
  - [ ] Split input string on commas
  - [ ] Trim whitespace from each symbol name
  - [ ] Return list of symbol name strings

---

## 4. Symbol Validation

- [ ] Implement `validateSymbolName` function:
  - [ ] Use ``Internal`SymbolNameQ[name, True]`` to validate fully qualified names
  - [ ] Return validation result (valid/invalid)
- [ ] Implement `symbolExistsQ` function:
  - [ ] Check if symbol name corresponds to an existing symbol
  - [ ] Handle case where symbol doesn't exist in any context

---

## 5. Attribute Checking

- [ ] Implement `isLockedAndReadProtectedQ` function:
  - [ ] Check if symbol has both `Locked` and `ReadProtected` attributes
  - [ ] Return `True` if inaccessible, `False` otherwise
- [ ] Implement `isReadProtectedQ` function:
  - [ ] Check if symbol has `ReadProtected` attribute (but not `Locked`)

---

## 6. Definition Extraction

- [ ] Implement `extractDefinition` function:
  - [ ] Use `Internal`InheritedBlock` to temporarily clear `ReadProtected`
  - [ ] Convert `Definition[symbol]` to held expression:
    ```wl
    ToExpression[ToString[Definition[symbol], InputForm], InputForm, HoldComplete]
    ```
  - [ ] Remove `Null` entries from result
  - [ ] Return held definition expression

---

## 7. Kernel Code Detection

- [ ] Implement `getKernelCodeDefinitions` function:
  - [ ] Check ``System`Private`HasDownCodeQ[symbol]``:
    - [ ] If true, add `symbol[___] := <kernel function>`
  - [ ] Check ``System`Private`HasOwnCodeQ[symbol]``:
    - [ ] If true, add `symbol := <kernel function>`
  - [ ] Check ``System`Private`HasSubCodeQ[symbol]``:
    - [ ] If true, add `symbol[___][___] := <kernel function>`
  - [ ] Check ``System`Private`HasUpCodeQ[symbol]``:
    - [ ] If true, add `_[___, symbol, ___] := <kernel function>`
  - [ ] Check ``System`Private`HasPrintCodeQ[symbol]``:
    - [ ] If true, add `Format[symbol, _] := <kernel function>`
  - [ ] Return list of kernel code placeholder definitions

---

## 8. Context Analysis

- [ ] Implement `extractSymbolsFromDefinition` function:
  - [ ] Use `Cases` to extract all atomic symbols from held definition
  - [ ] Return list of `HoldForm[symbol]` entries
- [ ] Implement `getContextsFromSymbols` function:
  - [ ] Extract context from each symbol using `Context`
  - [ ] Return list of unique contexts
- [ ] Implement `buildOptimalContextPath` function:
  - [ ] Combine contexts with `{"Global`", "System`"}`
  - [ ] Remove duplicates and reverse order
- [ ] Implement `generateContextMap` function:
  - [ ] Group symbols by context
  - [ ] Convert to JSON string format

---

## 9. Readable Formatting

- [ ] Implement `formatDefinitionReadable` function:
  - [ ] Build optimal context path
  - [ ] Use `Block` to set `$ContextPath` and `$Context`
  - [ ] Apply `readableForm` (imported resource function) with `PageWidth -> 120`
  - [ ] Wrap in `TimeConstrained` with 5-second timeout
  - [ ] Return formatted string or `$TimedOut`
- [ ] Implement `formatDefinitionFallback` function:
  - [ ] Use standard `InputForm` conversion as fallback
  - [ ] Apply same context path optimization

---

## 10. Truncation

- [ ] Implement `truncateIfNeeded` function:
  - [ ] Check if string length exceeds `maxLength`
  - [ ] If so, truncate and append: `... [truncated, showing {n}/{total} characters]`
  - [ ] Return truncated or original string

---

## 11. Output Formatting

- [ ] Implement `formatSymbolOutput` function:
  - [ ] Generate `# SymbolName` header
  - [ ] Add `## Definition` section with code block
  - [ ] Optionally add `## Contexts` section with JSON
  - [ ] Handle error cases with appropriate messages
- [ ] Implement `combineSymbolOutputs` function:
  - [ ] Join individual symbol outputs with double newlines
  - [ ] Return combined markdown string

---

## 12. Error Handling

- [ ] Handle invalid symbol names:
  - [ ] Return: `Error: Invalid symbol name "..."`
- [ ] Handle non-existent symbols:
  - [ ] Return: `Error: Symbol "..." does not exist`
- [ ] Handle `Locked` + `ReadProtected` symbols:
  - [ ] Return: `Error: SymbolName is \`Locked\` and \`ReadProtected\``
- [ ] Handle symbols with no definitions:
  - [ ] Return: `No definitions found`
  - [ ] But still check for kernel code definitions
- [ ] Handle `ReadableForm` timeout:
  - [ ] Fall back to `InputForm` formatting

---

## 13. Main Entry Point

- [ ] Implement `getSymbolDefinition` function:
  - [ ] Parse `KeyValuePattern` for parameters
  - [ ] Extract `symbols`, `includeContextDetails`, `maxLength` with defaults
  - [ ] Parse symbol names from input string
  - [ ] Process each symbol:
    - [ ] Validate symbol name
    - [ ] Check if symbol exists
    - [ ] Check for Locked/ReadProtected
    - [ ] Extract definition
    - [ ] Detect kernel code
    - [ ] Format output
    - [ ] Apply truncation
  - [ ] Combine all outputs
  - [ ] Return final markdown string

---

## 14. Testing

### Unit Tests

- [ ] Create `Tests/Tools/SymbolDefinition.wlt` test file

#### Input Parsing Tests
- [ ] Test single symbol name parsing
- [ ] Test multiple comma-separated symbol names
- [ ] Test whitespace handling around commas
- [ ] Test empty input handling

#### Validation Tests
- [ ] Test valid simple symbol name
- [ ] Test valid fully qualified symbol name
- [ ] Test invalid symbol name (special characters)
- [ ] Test non-existent symbol detection

#### Definition Extraction Tests
- [ ] Test basic function definition extraction
- [ ] Test multiple down values extraction
- [ ] Test up values extraction
- [ ] Test attributes extraction
- [ ] Test default values extraction

#### ReadProtected Handling Tests
- [ ] Test bypassing `ReadProtected` attribute
- [ ] Test `Locked` + `ReadProtected` error case
- [ ] Test `Locked` only (should still work if not `ReadProtected`)

#### Kernel Code Detection Tests
- [ ] Test `HasDownCodeQ` detection (e.g., `Plus`)
- [ ] Test `HasOwnCodeQ` detection
- [ ] Test `HasSubCodeQ` detection
- [ ] Test `HasUpCodeQ` detection
- [ ] Test `HasPrintCodeQ` detection
- [ ] Test symbol with multiple kernel code types

#### Context Analysis Tests
- [ ] Test symbol extraction from definition
- [ ] Test context grouping
- [ ] Test context path optimization
- [ ] Test context map JSON generation

#### Formatting Tests
- [ ] Test `ReadableForm` formatting
- [ ] Test fallback to `InputForm` on timeout
- [ ] Test context path reduces qualified names

#### Truncation Tests
- [ ] Test output below `maxLength` (no truncation)
- [ ] Test output above `maxLength` (truncation applied)
- [ ] Test truncation message format
- [ ] Test custom `maxLength` parameter

#### Output Format Tests
- [ ] Test single symbol markdown structure
- [ ] Test multiple symbols markdown structure
- [ ] Test `includeContextDetails: false` (no Contexts section)
- [ ] Test `includeContextDetails: true` (Contexts section present)

#### Error Output Tests
- [ ] Test invalid symbol name error message
- [ ] Test non-existent symbol error message
- [ ] Test Locked+ReadProtected error message
- [ ] Test "No definitions found" message

### Integration Tests

- [ ] Test end-to-end with System symbol (e.g., `Plus`)
- [ ] Test end-to-end with paclet symbol (e.g., `Wolfram`MCPServer`CreateMCPServer`)
- [ ] Test end-to-end with private symbol
- [ ] Test end-to-end with multiple mixed symbols (valid, invalid, errors)
- [ ] Test with very large definition (truncation)

---

## 15. Documentation

- [ ] Add tool to MCP server documentation if applicable
- [ ] Update any relevant README sections
- [ ] Ensure spec file is complete and accurate

---

## 16. Final Verification

- [ ] Run all tests and verify they pass
- [ ] Test tool manually via MCP client
- [ ] Verify MX build works with new resource function
- [ ] Code review for style consistency with codebase patterns
- [ ] Check error messages are defined in `Kernel/Messages.wl` if needed

---

## Notes

- Remember to use `beginDefinition`/`endDefinition` wrappers for all functions
- Use `Enclose`/`Confirm` pattern for error handling in internal functions
- Use `catchMine` for the main entry point function
- Follow existing code style in `Kernel/Tools/` directory
