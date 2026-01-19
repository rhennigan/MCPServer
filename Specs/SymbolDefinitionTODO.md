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

- [x] Created dedicated test file `Tests/SymbolDefinition.wlt` with 63 comprehensive tests

#### Input Parsing Tests
- [x] Test single symbol name parsing
- [x] Test multiple comma-separated symbol names
- [x] Test whitespace handling around commas
- [x] Test empty input handling

#### Validation Tests
- [x] Test valid simple symbol name
- [x] Test valid fully qualified symbol name
- [x] Test invalid symbol name (special characters)
- [x] Test non-existent symbol detection

#### Definition Extraction Tests
- [x] Test basic function definition extraction
- [x] Test multiple down values extraction
- [x] Test attributes extraction

#### ReadProtected Handling Tests
- [x] Test bypassing `ReadProtected` attribute
- [x] Test `Locked` attribute checking

#### Kernel Code Detection Tests
- [x] Test `HasDownCodeQ` detection (e.g., `Plus`)
- [x] Test `HasPrintCodeQ` detection
- [x] Test symbol with multiple kernel code types
- [x] Test symbol with no kernel code (paclet symbols)

#### Context Analysis Tests
- [x] Test symbol extraction from definition
- [x] Test context grouping
- [x] Test context path optimization
- [x] Test context map JSON generation

#### Truncation Tests
- [x] Test output below `maxLength` (no truncation)
- [x] Test output above `maxLength` (truncation applied)
- [x] Test truncation message format
- [x] Test custom `maxLength` parameter

#### Output Format Tests
- [x] Test single symbol markdown structure
- [x] Test multiple symbols markdown structure
- [x] Test `includeContextDetails: false` (no Contexts section)
- [x] Test `includeContextDetails: true` (Contexts section present)

#### Error Output Tests
- [x] Test invalid symbol name error message
- [x] Test non-existent symbol error message
- [x] Test error formatting

### Integration Tests

- [x] Test end-to-end with System symbol (e.g., `Plus`)
- [x] Test end-to-end with paclet symbol (e.g., `Wolfram`MCPServer`CreateMCPServer`)
- [x] Test end-to-end with private symbol
- [x] Test end-to-end with multiple mixed symbols (valid, invalid, errors)
- [x] Test with truncation

---

## 15. Documentation

- [ ] Add tool to MCP server documentation if applicable
- [ ] Update any relevant README sections
- [ ] Ensure spec file is complete and accurate

---

## 16. Final Verification

- [x] Run all tests and verify they pass (63/63 passing)
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

### Session 2 Progress (2026-01-19)

**Testing Implementation:**
1. Created dedicated test file `Tests/SymbolDefinition.wlt` with 63 comprehensive tests
2. Moved all SymbolDefinition tests from `Tests/Tools.wlt` to the dedicated file
3. All 63 tests pass (100%)

**Bug Fixes:**
1. Fixed `symbolExistsQ` - was comparing full name against short names from `Names[]`
2. Fixed `getKernelCodeDefinitions` - `$kernelFunctionString` wasn't being injected into `HoldForm` properly (used `With` to inject)
3. Fixed `getSymbolDefinition` - wasn't handling `Missing["NoInput"]` for optional parameters from LLMTool

**Test Categories Covered:**
- Tool registration (4 tests)
- Input parsing (4 tests)
- Symbol validation (7 tests)
- Attribute checking (3 tests)
- Definition extraction (4 tests)
- Kernel code detection (4 tests)
- Context analysis (5 tests)
- Split symbol name (3 tests)
- Truncation (3 tests)
- Error formatting (2 tests)
- Basic examples (6 tests)
- Multiple symbols (2 tests)
- Context details (3 tests)
- Error cases (2 tests)
- Truncation integration (2 tests)
- Integration tests (6 tests)

