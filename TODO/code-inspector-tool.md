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

- [ ] Create `Kernel/Tools/CodeInspector/Formatting.wl` with:
  - [ ] `inspectionsToMarkdown[inspections_List, source_, opts_Association]` - main formatter
  - [ ] `summaryTable[inspections_List]` - generate severity count table
  - [ ] `formatInspection[inspection_InspectionObject, index_Integer, source_]` - format single issue
  - [ ] `extractCodeSnippet[source_, location_, contextLines_Integer]` - extract code with context
  - [ ] `formatLocation[source_, location_]` - format as `file:line:col`
  - [ ] Handle "no issues found" case with settings summary
  - [ ] Handle truncation notice when limit exceeded
- [ ] Write and run unit tests, fixing test failures until all tests pass

### Phase 5: CodeAction Handling (`CodeActions.wl`)

- [ ] Create `Kernel/Tools/CodeInspector/CodeActions.wl` with:
  - [ ] `formatCodeActions[actions_List]` - format list of CodeActions as suggestions
  - [ ] `codeActionCommandToString[command_]` - convert command to human-readable text
    - `"ReplaceText"` → "Replace with"
    - `"DeleteText"` → "Delete"
    - `"InsertText"` → "Insert"
  - [ ] `formatSingleCodeAction[CodeAction[label_, command_, data_]]` - format single action
- [ ] Write and run unit tests, fixing test failures until all tests pass

### Phase 6: Testing (`Tests/CodeInspectorTool.wlt`)

- [ ] Add full integration tests for the tool in `Tests/CodeInspectorTool.wlt`

  **Basic Functionality:**
  - [ ] Code string inspection with known issues
  - [ ] Single file inspection
  - [ ] Recursive directory inspection
  - [ ] Clean code returns "no issues found" message

  **Parameter Handling:**
  - [ ] Tag exclusions filter correctly
  - [ ] Severity exclusions filter correctly
  - [ ] Confidence level filtering works
  - [ ] Limit parameter truncates output correctly

  **Error Handling:**
  - [ ] Error when neither `code` nor `file` provided
  - [ ] Error when both `code` and `file` provided
  - [ ] Error for non-existent file
  - [ ] Error for directory with no matching files
  - [ ] Graceful handling of invalid confidence level

  **Output Format:**
  - [ ] Summary table has correct format
  - [ ] Issue markdown structure is correct
  - [ ] Code snippets include line numbers and context
  - [ ] CodeActions are formatted as suggestions

### Phase 7: Verification

- [ ] Run full test suite to ensure there are no regressions
- [ ] Manual testing via MCP client:
  - [ ] Test basic code inspection: `{"code": "If[a, b, b]"}`
  - [ ] Test file inspection with custom settings
  - [ ] Test directory inspection
  - [ ] Test error cases