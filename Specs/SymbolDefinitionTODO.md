# SymbolDefinition Tool - Implementation TODO

This checklist tracks all tasks needed to fully implement and test the `SymbolDefinition` tool as specified in `Specs/SymbolDefinition.md`. Edit this file as needed to track your progress.

If you have to work through any surprising issues, add notes to the end of this file to document what you've learned. This will help resume work from where you left off.

---

## 1. Project Setup

- [x] Create `Kernel/Tools/SymbolDefinition.wl` file with package header
- [x] Add context to `$subcontexts` in `Kernel/Tools/Tools.wl`:
  ```wl
  (* Tools: SymbolDefinition *)
  "Wolfram`MCPServer`Tools`SymbolDefinition`"
  ```
- [x] Add `"ReadableForm"` version to `$resourceVersions` in `Kernel/Common.wl`
- [x] Import required resource function:
  ```wl
  importResourceFunction[ readableForm, "ReadableForm" ];
  ```

---

## 2. Tool Definition

- [x] Define `$symbolDefinitionToolDescription` string
- [x] Define `$defaultMCPTools["SymbolDefinition"]` with `LLMTool`:
  - [x] `"Name"` -> `"SymbolDefinition"`
  - [x] `"DisplayName"` -> `"Symbol Definition"`
  - [x] `"Description"` -> `$symbolDefinitionToolDescription`
  - [x] `"Function"` -> `getSymbolDefinition`
  - [x] `"Parameters"`:
    - [x] `"symbols"` (String, Required)
    - [x] `"includeContextDetails"` (Boolean, Optional, default: `false`)
    - [x] `"maxLength"` (Integer, Optional, default: `10000`)

---

## 3. Input Parsing

- [x] Implement `parseSymbolNames` function:
  - [x] Split input string on commas
  - [x] Trim whitespace from each symbol name
  - [x] Return list of symbol name strings

---

## 4. Symbol Validation

- [x] Implement `validateSymbolName` function:
  - [x] Use ``Internal`SymbolNameQ[name, True]`` to validate fully qualified names
  - [x] Return validation result (valid/invalid)
- [x] Implement `symbolExistsQ` function:
  - [x] Check if symbol name corresponds to an existing symbol
  - [x] Handle case where symbol doesn't exist in any context

---

## 5. Attribute Checking

- [x] Implement `isLockedAndReadProtectedQ` function:
  - [x] Check if symbol has both `Locked` and `ReadProtected` attributes
  - [x] Return `True` if inaccessible, `False` otherwise
- [x] Implement `isReadProtectedQ` function:
  - [x] Check if symbol has `ReadProtected` attribute (but not `Locked`)

---

## 6. Definition Extraction

- [x] Implement `extractDefinition` function:
  - [x] Use `Internal`InheritedBlock` to temporarily clear `ReadProtected`
  - [x] Convert `Definition[symbol]` to held expression:
    ```wl
    ToExpression[ToString[Definition[symbol], InputForm], InputForm, HoldComplete]
    ```
  - [x] Remove `Null` entries from result
  - [x] Return held definition expression

---

## 7. Kernel Code Detection

- [x] Implement `getKernelCodeDefinitions` function:
  - [x] Check ``System`Private`HasDownCodeQ[symbol]``:
    - [x] If true, add `symbol[___] := <kernel function>`
  - [x] Check ``System`Private`HasOwnCodeQ[symbol]``:
    - [x] If true, add `symbol := <kernel function>`
  - [x] Check ``System`Private`HasSubCodeQ[symbol]``:
    - [x] If true, add `symbol[___][___] := <kernel function>`
  - [x] Check ``System`Private`HasUpCodeQ[symbol]``:
    - [x] If true, add `_[___, symbol, ___] := <kernel function>`
  - [x] Check ``System`Private`HasPrintCodeQ[symbol]``:
    - [x] If true, add `Format[symbol, _] := <kernel function>`
  - [x] Return list of kernel code placeholder definitions

---

## 8. Context Analysis

- [x] Implement `extractSymbolsFromDefinition` function:
  - [x] Use `Cases` to extract all atomic symbols from held definition
  - [x] Return list of `HoldForm[symbol]` entries
- [x] Implement `getContextsFromSymbols` function:
  - [x] Extract context from each symbol using `Context`
  - [x] Return list of unique contexts
- [x] Implement `buildOptimalContextPath` function:
  - [x] Combine contexts with `{"Global`", "System`"}`
  - [x] Remove duplicates and reverse order
- [x] Implement `generateContextMap` function:
  - [x] Group symbols by context
  - [x] Convert to JSON string format

---

## 9. Readable Formatting

- [x] Implement `formatDefinitionReadable` function:
  - [x] Build optimal context path
  - [x] Use `Block` to set `$ContextPath` and `$Context`
  - [x] Apply `readableForm` (imported resource function) with `PageWidth -> 120`
  - [x] Wrap in `TimeConstrained` with 5-second timeout
  - [x] Return formatted string or `$TimedOut`
- [x] Implement `formatDefinitionFallback` function:
  - [x] Use standard `InputForm` conversion as fallback
  - [x] Apply same context path optimization

---

## 10. Truncation

- [x] Implement `truncateIfNeeded` function:
  - [x] Check if string length exceeds `maxLength`
  - [x] If so, truncate and append: `... [truncated, showing {n}/{total} characters]`
  - [x] Return truncated or original string

---

## 11. Output Formatting

- [x] Implement `formatSymbolOutput` function:
  - [x] Generate `# SymbolName` header
  - [x] Add `## Definition` section with code block
  - [x] Optionally add `## Contexts` section with JSON
  - [x] Handle error cases with appropriate messages
- [x] Implement `combineSymbolOutputs` function:
  - [x] Join individual symbol outputs with double newlines
  - [x] Return combined markdown string

---

## 12. Error Handling

- [x] Handle invalid symbol names:
  - [x] Return: `Error: Invalid symbol name "..."`
- [x] Handle non-existent symbols:
  - [x] Return: `Error: Symbol "..." does not exist`
- [x] Handle `Locked` + `ReadProtected` symbols:
  - [x] Return: `Error: SymbolName is \`Locked\` and \`ReadProtected\``
- [x] Handle symbols with no definitions:
  - [x] Return: `No definitions found`
  - [x] But still check for kernel code definitions
- [x] Handle `ReadableForm` timeout:
  - [x] Fall back to `InputForm` formatting

---

## 13. Main Entry Point

- [x] Implement `getSymbolDefinition` function:
  - [x] Parse `KeyValuePattern` for parameters
  - [x] Extract `symbols`, `includeContextDetails`, `maxLength` with defaults
  - [x] Parse symbol names from input string
  - [x] Process each symbol:
    - [x] Validate symbol name
    - [x] Check if symbol exists
    - [x] Check for Locked/ReadProtected
    - [x] Extract definition
    - [x] Detect kernel code
    - [x] Format output
    - [x] Apply truncation
  - [x] Combine all outputs
  - [x] Return final markdown string

---

## 14. Testing

### Unit Tests

- [x] Added tests to `Tests/Tools.wlt` (in the SymbolDefinition section)

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

### Session 1 Progress (2026-01-19)

**Files Created/Modified:**
1. `Kernel/Tools/SymbolDefinition.wl` - Created with full implementation
2. `Kernel/Tools/Tools.wl` - Added `"Wolfram`MCPServer`Tools`SymbolDefinition`"` to `$subcontexts`
3. `Kernel/Common.wl` - Added `"ReadableForm" -> "1.0.0"` to `$resourceVersions`
4. `Tests/Tools.wlt` - Added "SymbolDefinition" to expected keys and added test section

