# CodeInspectorTool - Detailed Specification

## Overview

This specification defines an MCP tool for inspecting Wolfram Language code using the CodeInspector package. The tool finds and reports problems in code, including style issues, potential bugs, and best practice violations.

## Goals

- Create an MCP tool to inspect Wolfram Language code for issues
- Support inspection of code strings, files, and directories
- Provide configurable filtering by severity, tags, and confidence level
- Format output as readable markdown optimized for LLM consumption
- Include code snippets with context around issues
- Surface suggested fixes (CodeActions) when available

---

## Tool: CodeInspector

### Purpose

Inspects Wolfram Language code using the CodeInspector package and returns a formatted report of issues found. The tool supports inspecting code strings, individual files, or entire directories of Wolfram Language source files.

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `code` | String | No* | - | Wolfram Language code string to inspect |
| `file` | String | No* | - | File or directory path to inspect |
| `tagExclusions` | String | No | `""` | Comma-separated list of tags to exclude |
| `severityExclusions` | String | No | `"Formatting,Remark,Scoping"` | Comma-separated list of severities to exclude |
| `confidenceLevel` | String | No | `"0.75"` | Minimum confidence level (0.0 to 1.0) |
| `limit` | Integer | No | `100` | Maximum number of issues to display |

*One of `code` or `file` must be provided, but not both.

#### Parameter Details

##### code

A string containing Wolfram Language code to inspect. The code is passed directly to `CodeInspect["code", ...]`.

**Example:**
```
"If[a, b, b]"
```

##### file

A file path or directory path to inspect:

- **File path**: Inspects a single file using `CodeInspect[File[path], ...]`
- **Directory path**: Recursively finds all `.wl`, `.m`, and `.wls` files and inspects each

**Examples:**
```
"C:/Projects/MyPaclet/Kernel/Main.wl"
"C:/Projects/MyPaclet/Kernel/"
```

##### tagExclusions

A comma-separated list of inspection tags to exclude from the results. Tags identify specific types of issues (e.g., "DuplicateClauses", "UnusedVariable").

**Example:**
```
"UnusedVariable,SuspiciousSessionSymbol"
```

##### severityExclusions

A comma-separated list of severity levels to exclude. The default excludes formatting issues, remarks, and scoping warnings to focus on more significant problems.

**Available severities:**
- `"Fatal"` - Critical errors that prevent code from running
- `"Error"` - Likely bugs or incorrect code
- `"Warning"` - Potential issues that may indicate problems
- `"Scoping"` - Scoping-related warnings (variable shadowing, etc.)
- `"Remark"` - Minor suggestions and style notes
- `"Formatting"` - Code formatting issues

**Example:**
```
"Formatting,Remark"
```

##### confidenceLevel

A decimal number between 0.0 and 1.0 representing the minimum confidence threshold. Issues with confidence below this level are excluded.

- `"0.0"` - Include all issues regardless of confidence
- `"0.75"` - Include issues with 75%+ confidence (default)
- `"0.95"` - Include only high-confidence issues
- `"1.0"` - Include only issues with 100% confidence

**Example:**
```
"0.8"
```

##### limit

Maximum number of issues to include in the output. When the limit is exceeded, a truncation notice is shown.

---

### Input Handling

#### Code String Input

When `code` is provided:
```wl
CodeInspect[code, ConfidenceLevel -> confidenceLevel]
```

#### File Input

When `file` points to a file:
```wl
CodeInspect[File[file], ConfidenceLevel -> confidenceLevel]
```

#### Directory Input

When `file` points to a directory:
1. Recursively find all files matching `*.wl`, `*.m`, `*.wls`
2. Inspect each file individually
3. Aggregate results with file paths

```wl
files = FileNames[{"*.wl", "*.m", "*.wls"}, directory, Infinity];
results = Map[CodeInspect[File[#], ...] &, files];
```

---

### Output Format

The tool returns markdown formatted for optimal LLM consumption.

#### Summary Table

A table showing issue counts by severity:

```markdown
# Code Inspection Results

## Summary

| Severity | Count |
|----------|-------|
| Error    | 3     |
| Warning  | 7     |
| Total    | 10    |
```

#### Issue Details

For each issue:

````markdown
## Issues

### Issue 1: DuplicateClauses (Error, 95%)

**Location:** `Kernel/Main.wl:42:7`

**Description:** Both branches of `If` are the same.

**Code:**
```wl
41 |     result = If[
42 |         condition,
43 |         value,  (* <- issue here *)
44 |         value
45 |     ]
```

**Suggested Fix:**
Remove the duplicate branch or differentiate the logic.
````

#### Code Snippet Format

Code snippets include:
- 1 line of context before the issue
- The issue line(s) with a marker
- 1 line of context after the issue
- Line numbers for reference

**Format:**
```
{line-1} | {code before}
{line}   | {code with issue}  (* <- issue here *)
{line+1} | {code after}
```

#### Truncation Notice

When results exceed the limit:

```markdown
---

*Showing 100 of 247 issues. Adjust the `limit` parameter to see more.*
```

#### No Issues Found

When no issues are found:

```markdown
# Code Inspection Results

No issues found matching the specified criteria.

**Settings:**
- Confidence Level: 0.75
- Severity Exclusions: Formatting, Remark, Scoping
- Tag Exclusions: (none)
```

---

### InspectionObject Structure

The CodeInspector package returns `InspectionObject` with this structure:

```wl
InspectionObject[tag, description, severity, data]
```

Where:
- `tag` - String identifying the issue type (e.g., "DuplicateClauses")
- `description` - Human-readable description of the issue
- `severity` - One of: "Fatal", "Error", "Warning", "Scoping", "Remark", "Formatting"
- `data` - Association containing:
  - ``CodeParser`Source`` -> {{startLine, startCol}, {endLine, endCol}}`
  - `"AdditionalSources"` -> List of additional source locations
  - `ConfidenceLevel` -> Numeric confidence (0.0 to 1.0)
  - `"CodeActions"` -> List of suggested fixes (when available)

#### CodeAction Structure

When available, CodeActions provide suggested fixes:

```wl
CodeAction[label, command, data]
```

Where:
- `label` - Description of the action
- `command` - One of: "ReplaceText", "DeleteText", "InsertText"
- `data` - Association with replacement details

---

### Error Messages

Add the following messages to `Kernel/Messages.wl`:

| Tag | Message |
|-----|---------|
| `CodeInspectorNoInput` | `"Either 'code' or 'file' parameter must be provided."` |
| `CodeInspectorAmbiguousInput` | `"Provide either 'code' or 'file', not both."` |
| `CodeInspectorFileNotFound` | `"File or directory not found: \`1\`."` |
| `CodeInspectorNoFilesFound` | `"No .wl, .m, or .wls files found in directory: \`1\`."` |
| `CodeInspectorFailed` | `"CodeInspector failed: \`1\`."` |

---

### Implementation Structure

#### Directory Structure

Create a new directory for the tool:

```
Kernel/Tools/CodeInspector/
    CodeInspector.wl      - Main entry point, tool definition
    Inspection.wl         - Core inspection logic
    Formatting.wl         - Markdown output formatting
    CodeActions.wl        - CodeAction text conversion
```

#### File: CodeInspector.wl

Main entry point and tool registration.

**Contents:**
- Package header with context ``Wolfram`MCPServer`Tools`CodeInspector` ``
- Tool description string
- Tool definition in `$defaultMCPTools["CodeInspector"]`
- Main entry function `codeInspectorTool`
- Input validation function `validateAndNormalizeInput`
- Load submodules via `Get`

**Key Functions:**

```wl
codeInspectorTool // beginDefinition;

codeInspectorTool[ KeyValuePattern @ {
    "code"               -> code_,
    "file"               -> file_,
    "tagExclusions"      -> tagExclusions_,
    "severityExclusions" -> severityExclusions_,
    "confidenceLevel"    -> confidenceLevel_,
    "limit"              -> limit_
} ] := Enclose[
    Module[{ ... },
        (* Validate input *)
        (* Normalize parameters *)
        (* Run inspection *)
        (* Format results *)
    ],
    throwInternalFailure
];

codeInspectorTool // endDefinition;
```

#### File: Inspection.wl

Core inspection logic.

**Key Functions:**

```wl
(* Run inspection on code string *)
runInspection[ code_String, opts_Association ] := ...

(* Run inspection on single file *)
runInspection[ File[ path_String ], opts_Association ] := ...

(* Run inspection on directory *)
runInspectionOnDirectory[ dir_String, opts_Association ] := ...

(* Parse comma-separated exclusions to list *)
parseExclusions[ str_String ] := ...

(* Parse confidence level string to number *)
parseConfidenceLevel[ str_String ] := ...

(* Filter inspections by tag, severity, confidence *)
filterInspections[ inspections_List, opts_Association ] := ...
```

#### File: Formatting.wl

Markdown output formatting.

**Key Functions:**

```wl
(* Main formatting function *)
inspectionsToMarkdown[ inspections_List, source_, opts_Association ] := ...

(* Generate summary table *)
summaryTable[ inspections_List ] := ...

(* Format single inspection as markdown *)
formatInspection[ inspection_InspectionObject, index_Integer, source_ ] := ...

(* Extract code snippet with context *)
extractCodeSnippet[ source_, location_, contextLines_Integer ] := ...

(* Format source location as file:line:col *)
formatLocation[ source_, location_ ] := ...
```

#### File: CodeActions.wl

CodeAction conversion to readable text.

**Key Functions:**

```wl
(* Format CodeActions as readable suggestions *)
formatCodeActions[ actions_List ] := ...

(* Convert command to human-readable text *)
codeActionCommandToString[ "ReplaceText" ] := "Replace with"
codeActionCommandToString[ "DeleteText" ] := "Delete"
codeActionCommandToString[ "InsertText" ] := "Insert"

(* Format single CodeAction *)
formatSingleCodeAction[ CodeAction[ label_, command_, data_ ] ] := ...
```

---

### Registration

#### Tools.wl

Add the new subcontext to `$subcontexts` in `Kernel/Tools/Tools.wl`:

```wl
$subcontexts = {
    ...
    (* Tools: CodeInspector *)
    "Wolfram`MCPServer`Tools`CodeInspector`"
};
```

Also remove the CodeInspector item from the TODO comment at the top of the file.

#### Messages.wl

Add error messages to `Kernel/Messages.wl`:

```wl
MCPServer::CodeInspectorNoInput        = "Either 'code' or 'file' parameter must be provided.";
MCPServer::CodeInspectorAmbiguousInput = "Provide either 'code' or 'file', not both.";
MCPServer::CodeInspectorFileNotFound   = "File or directory not found: `1`.";
MCPServer::CodeInspectorNoFilesFound   = "No .wl, .m, or .wls files found in directory: `1`.";
MCPServer::CodeInspectorFailed         = "CodeInspector failed: `1`.";
```

---

### Testing

Create `Tests/CodeInspectorTool.wlt` with tests for:

#### Basic Functionality

1. **Code string inspection** - Simple code with known issues
2. **File inspection** - Single file inspection
3. **Directory inspection** - Recursive directory inspection
4. **No issues found** - Clean code returns appropriate message

#### Parameter Handling

5. **Tag exclusions** - Verify specific tags are excluded
6. **Severity exclusions** - Verify specific severities are excluded
7. **Confidence level** - Verify low-confidence issues are filtered
8. **Limit parameter** - Verify truncation works correctly

#### Error Handling

9. **No input** - Error when neither code nor file provided
10. **Ambiguous input** - Error when both code and file provided
11. **File not found** - Error for non-existent file
12. **No files in directory** - Error for empty directory
13. **Invalid confidence level** - Handles invalid values gracefully

#### Output Format

14. **Summary table** - Verify table format
15. **Issue formatting** - Verify markdown structure
16. **Code snippets** - Verify line numbers and context
17. **CodeActions** - Verify suggestions are formatted

---

## Examples

### Basic Code Inspection

**Request:**
```json
{
  "tool": "CodeInspector",
  "parameters": {
    "code": "If[a, b, b]"
  }
}
```

**Response:**
````markdown
# Code Inspection Results

## Summary

| Severity | Count |
|----------|-------|
| Error    | 1     |
| Total    | 1     |

## Issues

### Issue 1: DuplicateClauses (Error, 95%)

**Location:** Line 1, Column 7-11

**Description:** Both branches of `If` are the same.

**Code:**
```wl
1 | If[a, b, b]
          ^~~~
```
````

### File Inspection with Custom Settings

**Request:**
```json
{
  "tool": "CodeInspector",
  "parameters": {
    "file": "C:/Projects/MyPaclet/Kernel/Main.wl",
    "severityExclusions": "Formatting,Remark",
    "confidenceLevel": "0.8"
  }
}
```

**Response:**
````markdown
# Code Inspection Results

**File:** `C:/Projects/MyPaclet/Kernel/Main.wl`

## Summary

| Severity | Count |
|----------|-------|
| Error    | 2     |
| Warning  | 5     |
| Total    | 7     |

## Issues

### Issue 1: UnusedVariable (Warning, 85%)

**Location:** `Main.wl:15:5`

**Description:** Variable `temp` is assigned but never used.

**Code:**
```wl
14 |     Module[{result, temp},
15 |         temp = computeValue[x];  (* <- issue here *)
16 |         result = otherValue[y];
17 |         result
```

**Suggested Fix:**
Remove the unused variable assignment.

---

### Issue 2: DuplicateClauses (Error, 95%)

**Location:** `Main.wl:42:9`

**Description:** Both branches of `If` are the same.

...
````

### Directory Inspection

**Request:**
```json
{
  "tool": "CodeInspector",
  "parameters": {
    "file": "C:/Projects/MyPaclet/Kernel/",
    "limit": 50
  }
}
```

**Response:**
````markdown
# Code Inspection Results

**Directory:** `C:/Projects/MyPaclet/Kernel/`
**Files inspected:** 12

## Summary

| Severity | Count |
|----------|-------|
| Error    | 5     |
| Warning  | 23    |
| Scoping  | 8     |
| Total    | 36    |

## Issues by File

### Main.wl (3 issues)

#### Issue 1: SuspiciousSessionSymbol (Warning, 80%)
...

### Utilities.wl (7 issues)

#### Issue 4: UnusedVariable (Warning, 90%)
...

---

*Showing 36 of 36 issues.*
````

### No Issues Found

**Request:**
```json
{
  "tool": "CodeInspector",
  "parameters": {
    "code": "f[x_] := x + 1"
  }
}
```

**Response:**
````markdown
# Code Inspection Results

No issues found matching the specified criteria.

**Settings:**
- Confidence Level: 0.75
- Severity Exclusions: Formatting, Remark, Scoping
- Tag Exclusions: (none)
````

### Error: Missing Input

**Request:**
```json
{
  "tool": "CodeInspector",
  "parameters": {}
}
```

**Response:**
```
Error: Either 'code' or 'file' parameter must be provided.
```

---

## Implementation Files Summary

| File | Action | Purpose |
|------|--------|---------|
| `Specs/CodeInspectorTool.md` | Create | This specification |
| `Kernel/Tools/CodeInspector/CodeInspector.wl` | Create | Main entry point and tool definition |
| `Kernel/Tools/CodeInspector/Inspection.wl` | Create | Core inspection logic |
| `Kernel/Tools/CodeInspector/Formatting.wl` | Create | Markdown output formatting |
| `Kernel/Tools/CodeInspector/CodeActions.wl` | Create | CodeAction text conversion |
| `Kernel/Messages.wl` | Edit | Add error messages |
| `Kernel/Tools/Tools.wl` | Edit | Register subcontext |
| `Tests/CodeInspectorTool.wlt` | Create | Test suite |

---

## Verification Steps

1. **Build paclet**: `wolframscript -f Scripts/BuildPaclet.wls -c`
2. **Run tests**: Use TestReport MCP tool on `Tests/CodeInspectorTool.wlt`
3. **Manual testing**: Invoke the tool via MCP client with various inputs

---

## Future Considerations

1. **Batch mode**: Support inspecting multiple separate code strings
2. **JSON output**: Option for structured JSON output instead of markdown
3. **Diff mode**: Compare two versions and show new/fixed issues
4. **Configuration file**: Support `.codeinspector` config files in projects
5. **Integration with editor**: Line-by-line issue annotations
6. **Custom rules**: Support for user-defined inspection rules
