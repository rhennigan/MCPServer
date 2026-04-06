# Paclet Tools - Detailed Specification

## Overview

This specification defines three MCP tools for paclet development workflows: checking paclets for issues, building `.paclet` archives, and submitting paclets to the Wolfram Language Paclet Repository. These tools wrap functions from the `Wolfram/PacletCICD` paclet and are designed to be used by LLMs assisting with paclet development.

## Goals

- Create three MCP tools (`CheckPaclet`, `BuildPaclet`, `SubmitPaclet`) for the `"WolframPacletDevelopment"` server
- Wrap ``Wolfram`PacletCICD`CheckPaclet``, ``Wolfram`PacletCICD`BuildPaclet``, and ``Wolfram`PacletCICD`SubmitPaclet``
- Convert structured outputs (Datasets, Success/Failure objects) into readable markdown for LLMs
- Ensure `Wolfram/PacletCICD` is installed before use via `PacletInstall`

---

## Shared Infrastructure

### File Layout

```
Kernel/Tools/PacletTools/
    PacletTools.wl          -- Package header, tool definitions, shared helpers, submodule loading
    CheckPaclet.wl          -- CheckPaclet implementation and formatting
    BuildPaclet.wl          -- BuildPaclet implementation and formatting
    SubmitPaclet.wl         -- SubmitPaclet implementation and formatting
```

### Registration Points

1. **`Kernel/Tools/Tools.wl`** -- Add to `$subcontexts`:
   ```wl
   (* Tools: CheckPaclet, BuildPaclet, SubmitPaclet *)
   "Wolfram`AgentTools`Tools`PacletTools`"
   ```

2. **`Kernel/DefaultServers.wl`** -- Add to `"WolframPacletDevelopment"` server's `"Tools"` list:
   ```wl
   "CheckPaclet",
   "BuildPaclet",
   "SubmitPaclet"
   ```

3. **`docs/servers.md`** -- Update the `WolframPacletDevelopment` server documentation to list the new tools.

4. **`Tests/PacletTools.wlt`** -- Add tool-level tests for path validation and result formatting.

5. **Agent skill rebuild** -- Because this changes MCP tool definitions, run `Scripts/BuildAgentSkills.wls` after implementation to keep generated skill artifacts in sync.

### PacletCICD Loading

All three tools depend on `Wolfram/PacletCICD`. A shared helper ensures the paclet is installed and loaded:

```wl
ensurePacletCICD // beginDefinition;

ensurePacletCICD[] := ensurePacletCICD[] = Enclose[
    Module[ { paclet },
        paclet = PacletInstall[ "Wolfram/PacletCICD" ];

        If[ ! MatchQ[ paclet, _PacletObject ],
            throwFailure[ "PacletCICDLoadFailed" ]
        ];

        Needs[ "Wolfram`PacletCICD`" -> None ];
        Null
    ],
    throwInternalFailure
];

ensurePacletCICD // endDefinition;
```

`PacletInstall` is fast for already-installed paclets. The memoization (`ensurePacletCICD[] = ...`) ensures the install/load happens only once per session.

### Path Validation

A shared helper validates and normalizes the `path` parameter:

```wl
validatePacletPath // beginDefinition;

validatePacletPath[ path_String ] :=
    Module[ { expanded },
        expanded = ExpandFileName @ path;

        If[ DirectoryQ @ expanded || FileExistsQ @ expanded,
            File @ expanded,
            throwFailure[ "PacletToolsInvalidPath", path ]
        ]
    ];

validatePacletPath // endDefinition;
```

This helper only checks that the supplied path exists and normalizes it to `File[...]`. The `Wolfram/PacletCICD` paclet still performs the stricter validation that the target is either a paclet directory containing a definition notebook or a valid definition notebook file.

### PacletTools.wl Structure

```wl
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`AgentTools`Tools`PacletTools`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`AgentTools`"        ];
Needs[ "Wolfram`AgentTools`Common`" ];
Needs[ "Wolfram`AgentTools`Tools`"  ];

(* ::Section::Closed:: *)
(*Config*)
(* Shared constants *)

(* ::Section::Closed:: *)
(*Shared Helpers*)
(* ensurePacletCICD, validatePacletPath *)

(* ::Section::Closed:: *)
(*Prompts*)
(* $checkPacletDescription, $buildPacletDescription, $submitPacletDescription *)

(* ::Section::Closed:: *)
(*Tool Definitions*)
(* $defaultMCPTools for all three tools *)

(* ::Section::Closed:: *)
(*Submodules*)
<< Wolfram`AgentTools`Tools`PacletTools`CheckPaclet`;
<< Wolfram`AgentTools`Tools`PacletTools`BuildPaclet`;
<< Wolfram`AgentTools`Tools`PacletTools`SubmitPaclet`;

(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
```

---

## Tool: CheckPaclet

### Purpose

Checks a Wolfram Language paclet for issues such as missing metadata, invalid structure, documentation problems, and other conditions that would prevent successful building or submission. Returns a summary of issues organized by severity.

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `path` | String | Yes | - | Absolute path to the paclet directory or definition notebook (`.nb`) file. |

### Tool Definition

```wl
$checkPacletDescription = "\
Checks a Wolfram Language paclet for issues such as missing metadata, \
invalid structure, or other problems that would prevent successful building or submission. \
Returns a summary of issues organized by severity (Error, Warning, Suggestion). \
Use this tool before BuildPaclet or SubmitPaclet to identify and fix problems early. \
The path should be an absolute path to either the paclet root directory or \
the definition notebook (.nb) file.";

$defaultMCPTools[ "CheckPaclet" ] := LLMTool @ <|
    "Name"        -> "CheckPaclet",
    "DisplayName" -> "Check Paclet",
    "Description" -> $checkPacletDescription,
    "Function"    -> checkPacletTool,
    "Options"     -> { },
    "Parameters"  -> {
        "path" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Absolute path to the paclet directory or definition notebook (.nb) file.",
            "Required"    -> True
        |>
    }
|>;
```

### Implementation

```wl
checkPacletTool // beginDefinition;

checkPacletTool[ KeyValuePattern[ "path" -> path_String ] ] :=
    checkPacletTool @ path;

checkPacletTool[ path_String ] := Enclose[
    Module[ { file, result },
        ensurePacletCICD[];
        file   = ConfirmBy[ validatePacletPath @ path, MatchQ @ File[ _String ], "ValidatePath" ];
        result = Wolfram`PacletCICD`CheckPaclet[ file, "FailureCondition" -> None ];
        ConfirmBy[ formatCheckResult @ result, StringQ, "FormatResult" ]
    ],
    throwInternalFailure
];

checkPacletTool // endDefinition;
```

Key implementation detail: `"FailureCondition" -> None` ensures the function always returns a `Dataset` of issues, never a `Failure` object. This option is intended for CI/CD exit codes and is not relevant in an MCP tool context.

### Output Format

#### No Issues Found

````markdown
# Paclet Check Results

No issues found. The paclet is ready to build.
````

#### Issues Found

````markdown
# Paclet Check Results

## Summary

| Level | Count |
|-------|-------|
| Error | 2 |
| Warning | 1 |
| Suggestion | 3 |

## Errors

1. **MissingPublisherID**: No publisher ID specified in PacletInfo.wl
2. **InvalidVersion**: Version string "1.0" does not follow semantic versioning

## Warnings

1. **PacletVersionUnchanged**: Paclet version has not changed since last submission

## Suggestions

1. **MissingDocumentation**: No documentation pages found for exported symbols
2. **MissingTests**: No test files found
3. **MissingReadme**: No README file found in paclet directory
````

### Formatting Logic

The `formatCheckResult` function processes the `Dataset` returned by `CheckPaclet`:

1. **Extract rows**: Convert the Dataset to a list of associations, each with keys `"Level"`, `"Message"`, `"Tag"`, `"CellID"`
2. **Handle empty results**: If no rows, return the "No issues found" message
3. **Build summary table**: Count issues per level (`"Error"`, `"Warning"`, `"Suggestion"`), omitting levels with zero count
4. **Group issues by level**: Group rows by `"Level"`, ordered as Error > Warning > Suggestion
5. **Format each issue**: Display as numbered list items with `**Tag**: Message`
6. **Omit CellID**: This is an internal identifier not useful to LLMs

---

## Tool: BuildPaclet

### Purpose

Builds a Wolfram Language paclet, producing a `.paclet` archive file suitable for distribution or submission to the Wolfram Language Paclet Repository. Can optionally run `CheckPaclet` before building.

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `path` | String | Yes | - | Absolute path to the paclet directory or definition notebook (`.nb`) file. |
| `check` | Boolean | No | `false` | Whether to run CheckPaclet before building. If the check finds errors, the build is aborted. |

### Tool Definition

```wl
$buildPacletDescription = "\
Builds a Wolfram Language paclet, producing a .paclet archive file. \
This can be a long-running operation, especially for paclets with extensive documentation. \
Optionally runs CheckPaclet first to validate the paclet before building. \
The path should be an absolute path to either the paclet root directory or \
the definition notebook (.nb) file.";

$defaultMCPTools[ "BuildPaclet" ] := LLMTool @ <|
    "Name"        -> "BuildPaclet",
    "DisplayName" -> "Build Paclet",
    "Description" -> $buildPacletDescription,
    "Function"    -> buildPacletTool,
    "Options"     -> { },
    "Parameters"  -> {
        "path" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Absolute path to the paclet directory or definition notebook (.nb) file.",
            "Required"    -> True
        |>,
        "check" -> <|
            "Interpreter" -> "Boolean",
            "Help"        -> "Whether to run CheckPaclet before building (default: false).",
            "Required"    -> False
        |>
    }
|>;
```

### Implementation

```wl
buildPacletTool // beginDefinition;

buildPacletTool[ KeyValuePattern @ { "path" -> path_String, "check" -> check_ } ] :=
    buildPacletTool[ path, check ];

buildPacletTool[ path_String, check_ ] := Enclose[
    Module[ { file, checkValue, result },
        ensurePacletCICD[];
        file       = ConfirmBy[ validatePacletPath @ path, MatchQ @ File[ _String ], "ValidatePath" ];
        checkValue = Replace[ check, Except[ True | False ] -> False ];
        result     = Wolfram`PacletCICD`BuildPaclet[ file, "Check" -> checkValue ];
        ConfirmBy[ formatBuildResult @ result, StringQ, "FormatResult" ]
    ],
    throwInternalFailure
];

buildPacletTool // endDefinition;
```

### Output Format

#### Build Successful

````markdown
# Paclet Build Successful

| Field | Value |
|-------|-------|
| Paclet | PublisherID/PacletName |
| Version | 1.2.0 |
| Archive | /path/to/build/PublisherID__PacletName-1.2.0.paclet |
````

The formatting function extracts info from the `Success["PacletBuild", <|...|>]` result:
- **Paclet name and version**: From the `PacletObject` associated with the built archive, or from the `Success` association keys
- **Archive path**: From the `"PacletArchive"` key in the `Success` association

#### Build Failed

````markdown
# Paclet Build Failed

Error: Failed to build paclet.

Details: <message extracted from the Failure object>
````

#### Build Aborted by Check (when `check` is `true`)

When the pre-build check finds errors, `BuildPaclet` returns a `Failure["CheckPaclet::errors", ...]` containing the check results. The formatting should present these using the same format as the `CheckPaclet` tool output:

````markdown
# Paclet Build Aborted

The pre-build check found errors that must be fixed before building:

## Summary

| Level | Count |
|-------|-------|
| Error | 2 |

## Errors

1. **MissingPublisherID**: No publisher ID specified in PacletInfo.wl
2. **InvalidVersion**: Version string "1.0" does not follow semantic versioning
````

### Formatting Logic

The `formatBuildResult` function handles two cases:

1. **`Success["PacletBuild", data_Association]`**:
   - Extract `data["PacletArchive"]` for the archive path
   - Extract paclet name and version from the archive path or associated `PacletObject`
   - Format as a success summary table

2. **`Failure[tag_, data_Association]`**:
   - If `tag` is `"CheckPaclet::errors"`, extract the check result from `data["CheckResult"]` and format using the same logic as `formatCheckResult`, with a "Build Aborted" header
   - Otherwise, extract the failure message and format as a build error

---

## Tool: SubmitPaclet

### Purpose

Submits a Wolfram Language paclet to the [Wolfram Language Paclet Repository](https://paclets.com/). This builds the paclet internally before submitting. Requires authentication via `$PublisherID` or an active Wolfram Cloud connection.

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `path` | String | Yes | - | Absolute path to the paclet directory or definition notebook (`.nb`) file. |

### Tool Definition

```wl
$submitPacletDescription = "\
Submits a Wolfram Language paclet to the Wolfram Language Paclet Repository (paclets.com). \
This builds the paclet and then submits it for review. \
Requires prior authentication via $PublisherID or an active Wolfram Cloud connection. \
Use CheckPaclet first to verify the paclet is ready for submission. \
This is a long-running operation that involves building and uploading. \
The path should be an absolute path to either the paclet root directory or \
the definition notebook (.nb) file.";

$defaultMCPTools[ "SubmitPaclet" ] := LLMTool @ <|
    "Name"        -> "SubmitPaclet",
    "DisplayName" -> "Submit Paclet",
    "Description" -> $submitPacletDescription,
    "Function"    -> submitPacletTool,
    "Options"     -> { },
    "Parameters"  -> {
        "path" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Absolute path to the paclet directory or definition notebook (.nb) file.",
            "Required"    -> True
        |>
    }
|>;
```

### Implementation

```wl
submitPacletTool // beginDefinition;

submitPacletTool[ KeyValuePattern[ "path" -> path_String ] ] :=
    submitPacletTool @ path;

submitPacletTool[ path_String ] := Enclose[
    Module[ { file, result },
        ensurePacletCICD[];
        file   = ConfirmBy[ validatePacletPath @ path, MatchQ @ File[ _String ], "ValidatePath" ];
        result = Wolfram`PacletCICD`SubmitPaclet @ file;
        ConfirmBy[ formatSubmitResult @ result, StringQ, "FormatResult" ]
    ],
    throwInternalFailure
];

submitPacletTool // endDefinition;
```

### Output Format

#### Submission Successful

````markdown
# Paclet Submission Successful

| Field | Value |
|-------|-------|
| Name | PublisherID/PacletName |
| Version | 1.2.0 |
| Status | Your paclet resource is being published |

The paclet has been submitted to the Wolfram Language Paclet Repository for review.
````

The formatting function extracts info from the `Success["ResourceSubmission", data]` result:
- **Name**: From `data["Name"]` (e.g. `"SamplePublisher/SamplePaclet"`)
- **Version**: From `data["Version"]`
- **Status**: From `data["Message"]`

Additional fields like `"UUID"` and `"SubmissionID"` may be included if present.

#### Submission Failed

````markdown
# Paclet Submission Failed

Error: <message extracted from the Failure object>
````

#### Authentication Required

If the submission fails due to missing authentication, the output should guide the user. In practice, `SubmitPaclet` wraps failures in `Failure["SubmitPacletFailure", <| "Result" -> innerFailure, ... |>]`, so the formatter should inspect the nested `"Result"` failure (and its message text) rather than relying only on the top-level failure tag.

````markdown
# Paclet Submission Failed

Error: Authentication required.

To submit paclets, you need to configure authentication:
- Set `$PublisherID` to your publisher identifier
- Or connect to the Wolfram Cloud via `CloudConnect[]`
````

### Formatting Logic

The `formatSubmitResult` function handles two cases:

1. **`Success["ResourceSubmission", data_Association]`**:
   - Extract `"Name"`, `"Version"`, `"Message"` from the data association
   - Include `"UUID"` and `"SubmissionID"` if present
   - Note any warnings from `data["Warnings"]` if non-empty
   - Format as a success summary table with a confirmation message

2. **`Failure[tag_, data_Association]`**:
   - Check if the failure is authentication-related and provide specific guidance
   - Otherwise, extract the failure message and format as a submission error

---

## Error Handling

### Common Errors (All Tools)

#### Invalid Path

When the `path` parameter does not point to an existing directory or file:

````markdown
Error: The path "/some/invalid/path" does not exist. Provide an absolute path to either the paclet root directory or the definition notebook (.nb) file.
````

Implementation: Define shared `AgentTools` message tags in `Kernel/Messages.wl`:

```wl
AgentTools::PacletToolsInvalidPath = "The path \"`1`\" does not exist. Provide an absolute path to either the paclet root directory or the definition notebook (.nb) file.";
AgentTools::PacletCICDLoadFailed  = "Could not load the Wolfram/PacletCICD paclet. Ensure it is installed or that you have internet access.";
```

#### PacletCICD Installation Failure

If `PacletInstall["Wolfram/PacletCICD"]` fails (e.g. no internet), `ensurePacletCICD[]` should throw `throwFailure["PacletCICDLoadFailed"]`:

````markdown
Error: Could not load the Wolfram/PacletCICD paclet. Ensure it is installed or that you have internet access.
````

### Tool-Specific Errors

#### CheckPaclet

With `"FailureCondition" -> None`, `CheckPaclet` always returns a Dataset (never a Failure), so the only errors are path validation and PacletCICD loading.

#### BuildPaclet

- **Build compilation failure**: Format the `Failure` message from `BuildPaclet`
- **Check failure** (when `check` is `true`): Format the check issues from the `Failure["CheckPaclet::errors", ...]` result

#### SubmitPaclet

- **Authentication failure**: Detect and provide specific guidance (see [Authentication Required](#authentication-required) output format)
- **Server-side submission failure**: Format the `Failure` message from `SubmitPaclet`

---

## Examples

### CheckPaclet - Clean Paclet

**Request:**
```json
{
  "tool": "CheckPaclet",
  "parameters": {
    "path": "C:/Users/dev/MyPaclet"
  }
}
```

**Response:**
````markdown
# Paclet Check Results

No issues found. The paclet is ready to build.
````

### CheckPaclet - Paclet With Issues

**Request:**
```json
{
  "tool": "CheckPaclet",
  "parameters": {
    "path": "C:/Users/dev/ProblematicPaclet"
  }
}
```

**Response:**
````markdown
# Paclet Check Results

## Summary

| Level | Count |
|-------|-------|
| Error | 1 |
| Warning | 2 |
| Suggestion | 1 |

## Errors

1. **DocumentationBuildErrors**: Documentation build failed for symbol `MyFunction`

## Warnings

1. **PacletVersionUnchanged**: Paclet version has not changed since last submission
2. **DocumentationWrongPacletName**: Documentation page references incorrect paclet name

## Suggestions

1. **DescriptionEndsInPunctuation**: Paclet description should not end with punctuation
````

### BuildPaclet - Successful Build

**Request:**
```json
{
  "tool": "BuildPaclet",
  "parameters": {
    "path": "C:/Users/dev/MyPaclet"
  }
}
```

**Response:**
````markdown
# Paclet Build Successful

| Field | Value |
|-------|-------|
| Paclet | DevPublisher/MyPaclet |
| Version | 1.0.0 |
| Archive | C:/Users/dev/MyPaclet/build/DevPublisher__MyPaclet-1.0.0.paclet |
````

### BuildPaclet - With Check Enabled

**Request:**
```json
{
  "tool": "BuildPaclet",
  "parameters": {
    "path": "C:/Users/dev/MyPaclet",
    "check": true
  }
}
```

**Response (check passes, build succeeds):**
````markdown
# Paclet Build Successful

| Field | Value |
|-------|-------|
| Paclet | DevPublisher/MyPaclet |
| Version | 1.0.0 |
| Archive | C:/Users/dev/MyPaclet/build/DevPublisher__MyPaclet-1.0.0.paclet |
````

**Response (check fails):**
````markdown
# Paclet Build Aborted

The pre-build check found errors that must be fixed before building:

## Summary

| Level | Count |
|-------|-------|
| Error | 1 |

## Errors

1. **MissingPublisherID**: No publisher ID specified in PacletInfo.wl
````

### SubmitPaclet - Successful Submission

**Request:**
```json
{
  "tool": "SubmitPaclet",
  "parameters": {
    "path": "C:/Users/dev/MyPaclet"
  }
}
```

**Response:**
````markdown
# Paclet Submission Successful

| Field | Value |
|-------|-------|
| Name | DevPublisher/MyPaclet |
| Version | 1.0.0 |
| Status | Your paclet resource is being published |

The paclet has been submitted to the Wolfram Language Paclet Repository for review.
````

### SubmitPaclet - Authentication Failure

**Request:**
```json
{
  "tool": "SubmitPaclet",
  "parameters": {
    "path": "C:/Users/dev/MyPaclet"
  }
}
```

**Response:**
````markdown
# Paclet Submission Failed

Error: Authentication required.

To submit paclets, you need to configure authentication:
- Set `$PublisherID` to your publisher identifier
- Or connect to the Wolfram Cloud via `CloudConnect[]`
````

### Invalid Path (Any Tool)

**Request:**
```json
{
  "tool": "CheckPaclet",
  "parameters": {
    "path": "C:/nonexistent/path"
  }
}
```

**Response:**
````markdown
Error: The path "C:/nonexistent/path" does not exist. Provide an absolute path to either the paclet root directory or the definition notebook (.nb) file.
````

---

## Implementation Notes

1. **File Location**: `Kernel/Tools/PacletTools/` directory with four files (see [File Layout](#file-layout))

2. **Submodule Pattern**: Follow the `Kernel/Tools/CodeInspector/` pattern where the main file (`PacletTools.wl`) contains tool definitions and shared helpers, and then loads submodule files containing the per-tool implementations

3. **Submodule Files**: Each submodule (`CheckPaclet.wl`, `BuildPaclet.wl`, `SubmitPaclet.wl`) should use the parent package context, matching the existing multi-file tool modules in this repo:
   ```wl
   BeginPackage[ "Wolfram`AgentTools`Tools`PacletTools`" ];
   Begin[ "`Private`" ];
   ```
   The files are still loaded by path/context name (for example `<< Wolfram`AgentTools`Tools`PacletTools`CheckPaclet``), but they should reopen the parent package context so shared helper functions and prompt strings remain directly accessible.

4. **PacletInstall**: `PacletInstall["Wolfram/PacletCICD"]` must be called before using any PacletCICD functions. It is fast for already-installed paclets. The memoized `ensurePacletCICD[]` helper handles this.

5. **FailureCondition**: `CheckPaclet` must always be called with `"FailureCondition" -> None` to ensure it returns a `Dataset` rather than a `Failure` object. The `FailureCondition` option is for CI/CD scripts that need non-zero exit codes.

6. **Frontend Dependency**: `BuildPaclet` and `SubmitPaclet` in PacletCICD open definition notebooks through the frontend. This should work in the MCP server context since a frontend is typically available, but may need special handling if running headless.

7. **Long-Running Operations**: `BuildPaclet` and `SubmitPaclet` can take significant time (especially for documentation-heavy paclets). The tool descriptions warn about this. No explicit `timeConstraint` parameter is exposed.

8. **Return Type**: All tools must return strings (markdown). The formatting functions (`formatCheckResult`, `formatBuildResult`, `formatSubmitResult`) convert structured Wolfram Language objects to markdown strings.

---

## Testing

Add a dedicated `Tests/PacletTools.wlt` file that covers at least:

1. `validatePacletPath` returning `File[...]` for an existing directory and throwing `PacletToolsInvalidPath` for a missing path
2. `formatCheckResult` for both an empty `Dataset` and a mixed-severity `Dataset`
3. `formatBuildResult` for a `Failure["CheckPaclet::errors", <| "CheckResult" -> dataset, ... |>]` result
4. `formatSubmitResult` for a nested `Failure["SubmitPacletFailure", <| "Result" -> innerFailure, ... |>]` authentication error

---

## Future Considerations

1. **TestPaclet Tool**: Wrap ``Wolfram`PacletCICD`TestPaclet`` for running paclet tests
2. **DeployPaclet Tool**: Wrap ``Wolfram`PacletCICD`DeployPaclet`` for deployment to servers
3. **DisabledHints Parameter**: Allow suppressing specific CheckPaclet hint tags
4. **Target Parameter**: Expose CheckPaclet's `"Target"` option (`"Submit"` vs `"Build"`)
5. **Dry Run for SubmitPaclet**: Validate submission requirements without actually submitting
6. **Progress Reporting**: If MCP supports streaming/progress, report build progress to the client
7. **Check Option on SubmitPaclet**: Add `check` parameter (like BuildPaclet) to validate before submitting
