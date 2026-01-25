# Code Inspector Tool

Full specification is in `Specs/CodeInspectorTool.md`.

## Resources

- If needed, full CodeInspector source code is available here: `H:/Documents/CodeInspector`
- The related paclet `CodeParser` is available here: `H:/Documents/CodeParser`

## TODO

### Phase 1: Setup & Infrastructure

- [x] Create directory structure `Kernel/Tools/CodeInspector/`
- [x] Add error messages to `Kernel/Messages.wl`:
  - `CodeInspectorNoInput`
  - `CodeInspectorAmbiguousInput`
  - `CodeInspectorFileNotFound`
  - `CodeInspectorNoFilesFound`
  - `CodeInspectorFailed`
- [x] Register subcontext `Wolfram`MCPServer`Tools`CodeInspector`` in `Kernel/Tools/Tools.wl`
- [x] Remove CodeInspector from the TODO comment in `Kernel/Tools/Tools.wl`

### Phase 2: Main Entry Point (`CodeInspector.wl`)

- [x] Create `Kernel/Tools/CodeInspector/CodeInspector.wl` with:
  - [x] Package header with context ``Wolfram`MCPServer`Tools`CodeInspector` ``
  - [x] Tool description string for MCP
  - [x] Tool definition in `$defaultMCPTools["CodeInspector"]` with all parameters:
    - `code` (String, optional)
    - `file` (String, optional)
    - `tagExclusions` (String, default `""`)
    - `severityExclusions` (String, default `"Formatting,Remark,Scoping"`)
    - `confidenceLevel` (String, default `"0.75"`)
    - `limit` (Integer, default `100`)
  - [x] Main entry function `codeInspectorTool`
  - [x] Input validation function `validateAndNormalizeInput`
  - [x] Load submodules via `Get`

### Phase 3: Core Inspection Logic (`Inspection.wl`)

- [x] Create `Kernel/Tools/CodeInspector/Inspection.wl` with:
  - [x] `runInspection[code_String, opts_Association]` - inspect code strings
  - [x] `runInspection[File[path_String], opts_Association]` - inspect single files
  - [x] `runInspectionOnDirectory[dir_String, opts_Association]` - recursive directory inspection
  - [x] `parseExclusions[str_String]` - parse comma-separated exclusions to list (in CodeInspector.wl)
  - [x] `parseConfidenceLevel[str_String]` - parse confidence level string to number (in CodeInspector.wl)
  - [x] `filterInspections[inspections_List, opts_Association]` - filter by tag, severity, confidence
- [x] Write and run unit tests, fixing test failures until all tests pass

### Phase 4: Markdown Formatting (`Formatting.wl`)

- [x] Create `Kernel/Tools/CodeInspector/Formatting.wl` with:
  - [x] `inspectionsToMarkdown[inspections_List, source_, opts_Association]` - main formatter
  - [x] `summaryTable[inspections_List]` - generate severity count table
  - [x] `formatInspection[inspection_InspectionObject, index_Integer, source_]` - format single issue
  - [x] `extractCodeSnippet[source_, location_, contextLines_Integer]` - extract code with context
  - [x] `formatLocation[source_, location_]` - format as `file:line:col`
  - [x] Handle "no issues found" case with settings summary
  - [x] Handle truncation notice when limit exceeded
- [x] Write and run unit tests, fixing test failures until all tests pass

### Phase 5: CodeAction Handling (`CodeActions.wl`)

- [x] Create `Kernel/Tools/CodeInspector/CodeActions.wl` with:
  - [x] `formatCodeActions[actions_List]` - format list of CodeActions as suggestions
  - [x] `codeActionCommandToString[command_]` - convert command to human-readable text
    - `"ReplaceText"` → "Replace with"
    - `"DeleteText"` → "Delete"
    - `"InsertText"` → "Insert"
  - [x] `formatSingleCodeAction[CodeAction[label_, command_, data_]]` - format single action
- [x] Write and run unit tests, fixing test failures until all tests pass

### Phase 6: Testing (`Tests/CodeInspectorTool.wlt`)

- [x] Add full integration tests for the tool in `Tests/CodeInspectorTool.wlt`

  **Basic Functionality:**
  - [x] Code string inspection with known issues
  - [x] Single file inspection
  - [x] Recursive directory inspection
  - [x] Clean code returns "no issues found" message

  **Parameter Handling:**
  - [x] Tag exclusions filter correctly
  - [x] Severity exclusions filter correctly
  - [x] Confidence level filtering works
  - [x] Limit parameter truncates output correctly

  **Error Handling:**
  - [x] Error when neither `code` nor `file` provided
  - [x] Error when both `code` and `file` provided
  - [x] Error for non-existent file
  - [x] Error for directory with no matching files
  - [x] Graceful handling of invalid confidence level

  **Output Format:**
  - [x] Summary table has correct format
  - [x] Issue markdown structure is correct
  - [x] Code snippets include line numbers and context
  - [x] CodeActions are formatted as suggestions

### Phase 7: Verification

- [ ] Run full test suite to ensure there are no regressions
- [ ] Manual testing via MCP client:
  - [ ] Test basic code inspection: `{"code": "If[a, b, b]"}`
  - [ ] Test file inspection with custom settings
  - [ ] Test directory inspection
  - [ ] Test error cases