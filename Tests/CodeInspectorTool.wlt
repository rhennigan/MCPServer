(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/CodeInspectorTool.wlt:7,1-12,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/CodeInspectorTool.wlt:14,1-19,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`Tools`CodeInspector`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadCodeInspectorContext@@Tests/CodeInspectorTool.wlt:21,1-26,2"
]

VerificationTest[
    Needs[ "CodeInspector`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadCodeInspectorPackage@@Tests/CodeInspectorTool.wlt:28,1-33,2"
]

VerificationTest[
    Module[ { path },
        path = FileNameJoin @ {
            DirectoryName @ DirectoryName @ $TestFileName,
            "Kernel",
            "Tools",
            "CodeInspector",
            "Rules.wl"
        };
        Get @ path;
        True
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "ReloadCodeInspectorRules@@Tests/CodeInspectorTool.wlt:35,1-50,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Registration*)
VerificationTest[
    $codeInspectorTool = $DefaultMCPTools[ "CodeInspector" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "GetTool@@Tests/CodeInspectorTool.wlt:55,1-60,2"
]

VerificationTest[
    $codeInspectorTool[ "Name" ],
    "CodeInspector",
    SameTest -> SameQ,
    TestID   -> "ToolName@@Tests/CodeInspectorTool.wlt:62,1-67,2"
]

VerificationTest[
    StringQ @ $codeInspectorTool[ "Description" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ToolDescription@@Tests/CodeInspectorTool.wlt:69,1-74,2"
]

VerificationTest[
    ListQ @ $codeInspectorTool[ "Parameters" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ToolParameters@@Tests/CodeInspectorTool.wlt:76,1-81,2"
]

VerificationTest[
    Length @ $codeInspectorTool[ "Parameters" ],
    6,
    SameTest -> SameQ,
    TestID   -> "ToolParameterCount@@Tests/CodeInspectorTool.wlt:83,1-88,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Parameter Parsing*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseExclusions*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseExclusions[ Missing[ "KeyAbsent" ] ],
    { },
    SameTest -> MatchQ,
    TestID   -> "ParseExclusions-Missing@@Tests/CodeInspectorTool.wlt:97,1-102,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseExclusions[ "" ],
    { },
    SameTest -> MatchQ,
    TestID   -> "ParseExclusions-Empty@@Tests/CodeInspectorTool.wlt:104,1-109,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseExclusions[ "Warning" ],
    { "Warning" },
    SameTest -> MatchQ,
    TestID   -> "ParseExclusions-Single@@Tests/CodeInspectorTool.wlt:111,1-116,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseExclusions[ "Warning,Error,Remark" ],
    { "Warning", "Error", "Remark" },
    SameTest -> MatchQ,
    TestID   -> "ParseExclusions-Multiple@@Tests/CodeInspectorTool.wlt:118,1-123,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseExclusions[ "  Warning  ,  Error  " ],
    { "Warning", "Error" },
    SameTest -> MatchQ,
    TestID   -> "ParseExclusions-Whitespace@@Tests/CodeInspectorTool.wlt:125,1-130,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseExclusions[ Missing[ "KeyAbsent" ], { "Default1", "Default2" } ],
    { "Default1", "Default2" },
    SameTest -> MatchQ,
    TestID   -> "ParseExclusions-MissingWithDefault@@Tests/CodeInspectorTool.wlt:132,1-137,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseExclusions[ "", { "A", "B" } ],
    { },
    SameTest -> MatchQ,
    TestID   -> "ParseExclusions-EmptyWithDefault@@Tests/CodeInspectorTool.wlt:139,1-144,2"
]

(* ::**************************************************************************************************************:: *)
(*parseConfidenceLevel*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ Missing[ "KeyAbsent" ] ],
    0.75,
    SameTest -> SameQ,
    TestID   -> "ParseConfidenceLevel-Missing@@Tests/CodeInspectorTool.wlt:148,1-153,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ 0.5 ],
    0.5,
    SameTest -> SameQ,
    TestID   -> "ParseConfidenceLevel-Valid@@Tests/CodeInspectorTool.wlt:155,1-160,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ 0 ],
    0.0,
    SameTest -> SameQ,
    TestID   -> "ParseConfidenceLevel-IntegerValue@@Tests/CodeInspectorTool.wlt:162,1-167,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ 1.5 ],
    _Failure,
    { MCPServer::CodeInspectorInvalidConfidence },
    SameTest -> MatchQ,
    TestID   -> "ParseConfidenceLevel-OutOfRange@@Tests/CodeInspectorTool.wlt:169,1-175,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseLimit*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseLimit[ Missing[ "KeyAbsent" ] ],
    100,
    SameTest -> SameQ,
    TestID   -> "ParseLimit-Missing@@Tests/CodeInspectorTool.wlt:180,1-185,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseLimit[ 50 ],
    50,
    SameTest -> SameQ,
    TestID   -> "ParseLimit-Valid@@Tests/CodeInspectorTool.wlt:187,1-192,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseLimit[ -5 ],
    100,
    SameTest -> SameQ,
    TestID   -> "ParseLimit-Negative@@Tests/CodeInspectorTool.wlt:194,1-199,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Input Validation*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validateAndNormalizeInput*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ "If[a,b,c]", Missing[ "KeyAbsent" ] ],
    "If[a,b,c]",
    SameTest -> SameQ,
    TestID   -> "ValidateInput-CodeString@@Tests/CodeInspectorTool.wlt:208,1-213,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ Missing[ "KeyAbsent" ], $InstallationDirectory ],
    $InstallationDirectory,
    SameTest -> SameQ,
    TestID   -> "ValidateInput-Directory@@Tests/CodeInspectorTool.wlt:215,1-220,2"
]

VerificationTest[
    (* Use a file from the MCPServer paclet that's guaranteed to exist *)
    $testFile = FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" };
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ Missing[ "KeyAbsent" ], $testFile ],
    File[ $testFile ],
    SameTest -> MatchQ,
    TestID   -> "ValidateInput-File@@Tests/CodeInspectorTool.wlt:222,1-229,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ Missing[ "KeyAbsent" ], Missing[ "KeyAbsent" ] ],
    _Failure,
    { MCPServer::CodeInspectorNoInput },
    SameTest -> MatchQ,
    TestID   -> "ValidateInput-NoInput@@Tests/CodeInspectorTool.wlt:231,1-237,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ "code", "file" ],
    _Failure,
    { MCPServer::CodeInspectorAmbiguousInput },
    SameTest -> MatchQ,
    TestID   -> "ValidateInput-BothInputs@@Tests/CodeInspectorTool.wlt:239,1-245,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ Missing[ "KeyAbsent" ], "/nonexistent/path/file.wl" ],
    _Failure,
    { MCPServer::CodeInspectorFileNotFound },
    SameTest -> MatchQ,
    TestID   -> "ValidateInput-FileNotFound@@Tests/CodeInspectorTool.wlt:247,1-253,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Code Inspection*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*runInspection - Code String*)
VerificationTest[
    $codeResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "If[a, b, b]",
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    { _InspectionObject .. },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-CodeString@@Tests/CodeInspectorTool.wlt:262,1-270,2"
]

VerificationTest[
    (* The code "If[a, b, b]" should produce at least one DuplicateClauses inspection *)
    MemberQ[ $codeResult, InspectionObject[ "DuplicateClauses", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "RunInspection-FindsDuplicateClauses@@Tests/CodeInspectorTool.wlt:272,1-278,2"
]

VerificationTest[
    (* Clean code should return empty list *)
    Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "f[x_] := x + 1",
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    { },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-CleanCode@@Tests/CodeInspectorTool.wlt:280,1-289,2"
]

VerificationTest[
    (* Test with severity exclusions *)
    $filteredResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "If[a, b, b]",
        <| "tagExclusions" -> { }, "severityExclusions" -> { "Warning", "Error" }, "confidenceLevel" -> 0.5 |>
    ],
    { },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-WithSeverityExclusions@@Tests/CodeInspectorTool.wlt:291,1-300,2"
]

VerificationTest[
    (* Test with tag exclusions *)
    $tagFilteredResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "If[a, b, b]",
        <| "tagExclusions" -> { "DuplicateClauses::If" }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    { },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-WithTagExclusions@@Tests/CodeInspectorTool.wlt:302,1-311,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*runInspection - File*)
VerificationTest[
    (* Create a temporary test file with known issues *)
    $tempDir = CreateDirectory[ ];
    $testWLFile = FileNameJoin @ { $tempDir, "test.wl" };
    Export[ $testWLFile, "If[x, y, y]", "Text" ];
    FileExistsQ @ $testWLFile,
    True,
    SameTest -> SameQ,
    TestID   -> "RunInspection-CreateTestFile@@Tests/CodeInspectorTool.wlt:316,1-325,2"
]

VerificationTest[
    $fileResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        File[ $testWLFile ],
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    { _InspectionObject .. },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-File@@Tests/CodeInspectorTool.wlt:327,1-335,2"
]

VerificationTest[
    MemberQ[ $fileResult, InspectionObject[ "DuplicateClauses", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "RunInspection-FileFindsIssues@@Tests/CodeInspectorTool.wlt:337,1-342,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*runInspection - Directory*)
VerificationTest[
    (* Add another file to the temp directory *)
    $testWLFile2 = FileNameJoin @ { $tempDir, "test2.wl" };
    Export[ $testWLFile2, "Switch[x, 1, a, 1, b]", "Text" ];
    FileExistsQ @ $testWLFile2,
    True,
    SameTest -> SameQ,
    TestID   -> "RunInspection-CreateSecondTestFile@@Tests/CodeInspectorTool.wlt:347,1-355,2"
]

VerificationTest[
    $dirResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        $tempDir,
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    _Association,
    SameTest -> MatchQ,
    TestID   -> "RunInspection-DirectoryReturnsAssociation@@Tests/CodeInspectorTool.wlt:357,1-365,2"
]

VerificationTest[
    Length @ Keys @ $dirResult,
    2,
    SameTest -> SameQ,
    TestID   -> "RunInspection-DirectoryFindsAllFiles@@Tests/CodeInspectorTool.wlt:367,1-372,2"
]

VerificationTest[
    AllTrue[ Values @ $dirResult, MatchQ[ { ___InspectionObject } ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "RunInspection-DirectoryAllInspectionObjects@@Tests/CodeInspectorTool.wlt:374,1-379,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup Test Files*)
VerificationTest[
    DeleteDirectory[ $tempDir, DeleteContents -> True ];
    ! DirectoryQ @ $tempDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Cleanup-TempDirectory@@Tests/CodeInspectorTool.wlt:384,1-390,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Formatting*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*summaryTable*)
VerificationTest[
    $summaryTableResult = Wolfram`MCPServer`Tools`CodeInspector`Private`summaryTable @ {
        InspectionObject[ "Tag1", "Desc1", "Error", <| ConfidenceLevel -> 0.9 |> ],
        InspectionObject[ "Tag2", "Desc2", "Warning", <| ConfidenceLevel -> 0.8 |> ],
        InspectionObject[ "Tag3", "Desc3", "Error", <| ConfidenceLevel -> 0.7 |> ]
    },
    _String,
    SameTest -> MatchQ,
    TestID   -> "SummaryTable-ReturnsString@@Tests/CodeInspectorTool.wlt:399,1-408,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "## Summary" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-HasHeader@@Tests/CodeInspectorTool.wlt:410,1-415,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "| Error | 2 |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-CountsErrors@@Tests/CodeInspectorTool.wlt:417,1-422,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "| Warning | 1 |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-CountsWarnings@@Tests/CodeInspectorTool.wlt:424,1-429,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "| **Total** | **3** |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-ShowsTotal@@Tests/CodeInspectorTool.wlt:431,1-436,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatLocation*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatLocation[
        "If[a, b, b]",
        { { 1, 7 }, { 1, 8 } }
    ],
    "Line 1, Column 7 - Line 1, Column 8",
    SameTest -> SameQ,
    TestID   -> "FormatLocation-CodeStringRange@@Tests/CodeInspectorTool.wlt:441,1-449,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatLocation[
        "x",
        { { 1, 1 }, { 1, 1 } }
    ],
    "Line 1, Column 1",
    SameTest -> SameQ,
    TestID   -> "FormatLocation-CodeStringSinglePoint@@Tests/CodeInspectorTool.wlt:451,1-459,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatLocation[
        File[ "/path/to/file.wl" ],
        { { 42, 7 }, { 42, 15 } }
    ],
    "`file.wl:42:7`",
    SameTest -> SameQ,
    TestID   -> "FormatLocation-File@@Tests/CodeInspectorTool.wlt:461,1-469,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatLocation[
        "code",
        Missing[ "NotAvailable" ]
    ],
    "Unknown",
    SameTest -> SameQ,
    TestID   -> "FormatLocation-Missing@@Tests/CodeInspectorTool.wlt:471,1-479,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*extractCodeSnippet*)
VerificationTest[
    $snippetResult = Wolfram`MCPServer`Tools`CodeInspector`Private`extractCodeSnippet[
        "If[a, b, b]",
        { { 1, 7 }, { 1, 8 } },
        1
    ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "ExtractCodeSnippet-ReturnsString@@Tests/CodeInspectorTool.wlt:484,1-493,2"
]

VerificationTest[
    StringContainsQ[ $snippetResult, "**Code:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-HasCodeHeader@@Tests/CodeInspectorTool.wlt:495,1-500,2"
]

VerificationTest[
    StringContainsQ[ $snippetResult, "```wl" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-HasCodeBlock@@Tests/CodeInspectorTool.wlt:502,1-507,2"
]

VerificationTest[
    (* Multi-line code with context *)
    $multiLineSnippet = Wolfram`MCPServer`Tools`CodeInspector`Private`extractCodeSnippet[
        "line1\nline2\nIf[a, b, b]\nline4\nline5",
        { { 3, 7 }, { 3, 8 } },
        1
    ];
    StringContainsQ[ $multiLineSnippet, "2 | line2" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-ShowsContextBefore@@Tests/CodeInspectorTool.wlt:509,1-520,2"
]

VerificationTest[
    StringContainsQ[ $multiLineSnippet, "4 | line4" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-ShowsContextAfter@@Tests/CodeInspectorTool.wlt:522,1-527,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`extractCodeSnippet[
        "code",
        Missing[ "NotAvailable" ],
        1
    ],
    "",
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-MissingLocationReturnsEmpty@@Tests/CodeInspectorTool.wlt:529,1-538,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatInspection*)
VerificationTest[
    $formattedInspection = Wolfram`MCPServer`Tools`CodeInspector`Private`formatInspection[
        InspectionObject[
            "DuplicateClauses",
            "Both branches of ``If`` are the same.",
            "Error",
            <| ConfidenceLevel -> 0.95, CodeParser`Source -> { { 1, 7 }, { 1, 8 } } |>
        ],
        1,
        "If[a, b, b]"
    ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "FormatInspection-ReturnsString@@Tests/CodeInspectorTool.wlt:543,1-557,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "### Issue 1: DuplicateClauses" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-HasHeader@@Tests/CodeInspectorTool.wlt:559,1-564,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "(Error, 95%)" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-ShowsSeverityAndConfidence@@Tests/CodeInspectorTool.wlt:566,1-571,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "**Location:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-HasLocation@@Tests/CodeInspectorTool.wlt:573,1-578,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "**Description:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-HasDescription@@Tests/CodeInspectorTool.wlt:580,1-585,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectionsToMarkdown - No Issues*)
VerificationTest[
    $noIssuesResult = Wolfram`MCPServer`Tools`CodeInspector`Private`inspectionsToMarkdown[
        { },
        "f[x_] := x + 1",
        <| "confidenceLevel" -> 0.75, "severityExclusions" -> { "Formatting" }, "tagExclusions" -> { }, "limit" -> 100 |>
    ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "InspectionsToMarkdown-NoIssuesReturnsString@@Tests/CodeInspectorTool.wlt:590,1-599,2"
]

VerificationTest[
    StringContainsQ[ $noIssuesResult, "No issues found matching the specified criteria." ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-NoIssuesMessage@@Tests/CodeInspectorTool.wlt:601,1-606,2"
]

VerificationTest[
    StringContainsQ[ $noIssuesResult, "Confidence Level: 0.75" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsConfidenceLevel@@Tests/CodeInspectorTool.wlt:608,1-613,2"
]

VerificationTest[
    StringContainsQ[ $noIssuesResult, "Severity Exclusions: Formatting" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsSeverityExclusions@@Tests/CodeInspectorTool.wlt:615,1-620,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectionsToMarkdown - With Issues*)
VerificationTest[
    $withIssuesResult = Wolfram`MCPServer`Tools`CodeInspector`Private`inspectionsToMarkdown[
        {
            InspectionObject[
                "DuplicateClauses",
                "Both branches are the same.",
                "Error",
                <| ConfidenceLevel -> 0.95, CodeParser`Source -> { { 1, 7 }, { 1, 8 } } |>
            ]
        },
        "If[a, b, b]",
        <| "confidenceLevel" -> 0.75, "severityExclusions" -> { }, "tagExclusions" -> { }, "limit" -> 100 |>
    ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "InspectionsToMarkdown-WithIssuesReturnsString@@Tests/CodeInspectorTool.wlt:625,1-641,2"
]

VerificationTest[
    StringContainsQ[ $withIssuesResult, "# Code Inspection Results" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-HasMainHeader@@Tests/CodeInspectorTool.wlt:643,1-648,2"
]

VerificationTest[
    StringContainsQ[ $withIssuesResult, "## Summary" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-HasSummary@@Tests/CodeInspectorTool.wlt:650,1-655,2"
]

VerificationTest[
    StringContainsQ[ $withIssuesResult, "## Issues" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-HasIssuesSection@@Tests/CodeInspectorTool.wlt:657,1-662,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectionsToMarkdown - Truncation*)
VerificationTest[
    $truncatedResult = Wolfram`MCPServer`Tools`CodeInspector`Private`inspectionsToMarkdown[
        Table[
            InspectionObject[ "Tag" <> ToString @ i, "Desc", "Warning", <| ConfidenceLevel -> 0.9 |> ],
            { i, 10 }
        ],
        "code",
        <| "confidenceLevel" -> 0.5, "severityExclusions" -> { }, "tagExclusions" -> { }, "limit" -> 5 |>
    ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "InspectionsToMarkdown-TruncationReturnsString@@Tests/CodeInspectorTool.wlt:667,1-679,2"
]

VerificationTest[
    StringContainsQ[ $truncatedResult, "Showing 5 of 10 issues" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsTruncationNotice@@Tests/CodeInspectorTool.wlt:681,1-686,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectionsToMarkdown - File Source*)
VerificationTest[
    $fileSourceResult = Wolfram`MCPServer`Tools`CodeInspector`Private`inspectionsToMarkdown[
        {
            InspectionObject[
                "TestIssue",
                "Test description.",
                "Warning",
                <| ConfidenceLevel -> 0.9, CodeParser`Source -> { { 1, 1 }, { 1, 5 } } |>
            ]
        },
        File[ "/path/to/test.wl" ],
        <| "confidenceLevel" -> 0.5, "severityExclusions" -> { }, "tagExclusions" -> { }, "limit" -> 100 |>
    ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "InspectionsToMarkdown-FileSourceReturnsString@@Tests/CodeInspectorTool.wlt:691,1-707,2"
]

VerificationTest[
    StringContainsQ[ $fileSourceResult, "**File:** `/path/to/test.wl`" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsFileHeader@@Tests/CodeInspectorTool.wlt:709,1-714,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*CodeActions Formatting*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatCodeActions - Empty List*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatCodeActions[ { } ],
    "",
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-EmptyList@@Tests/CodeInspectorTool.wlt:723,1-728,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatCodeActions - Single Action*)
VerificationTest[
    $singleActionResult = Wolfram`MCPServer`Tools`CodeInspector`Private`formatCodeActions @ {
        CodeParser`CodeAction[ "Delete ``,``", CodeParser`DeleteText, <| CodeParser`Source -> { { 1, 5 }, { 1, 6 } } |> ]
    },
    _String,
    SameTest -> MatchQ,
    TestID   -> "FormatCodeActions-SingleAction-ReturnsString@@Tests/CodeInspectorTool.wlt:733,1-740,2"
]

VerificationTest[
    StringContainsQ[ $singleActionResult, "**Suggested Fix:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-SingleAction-HasHeader@@Tests/CodeInspectorTool.wlt:742,1-747,2"
]

VerificationTest[
    StringContainsQ[ $singleActionResult, "Delete `,`" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-SingleAction-HasLabel@@Tests/CodeInspectorTool.wlt:749,1-754,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatCodeActions - Multiple Actions*)
VerificationTest[
    $multiActionResult = Wolfram`MCPServer`Tools`CodeInspector`Private`formatCodeActions @ {
        CodeParser`CodeAction[ "Insert ``*``", CodeParser`InsertNode, <| CodeParser`Source -> { { 1, 5 }, { 1, 5 } } |> ],
        CodeParser`CodeAction[ "Insert ``,``", CodeParser`InsertNode, <| CodeParser`Source -> { { 1, 5 }, { 1, 5 } } |> ]
    },
    _String,
    SameTest -> MatchQ,
    TestID   -> "FormatCodeActions-MultipleActions-ReturnsString@@Tests/CodeInspectorTool.wlt:759,1-767,2"
]

VerificationTest[
    StringContainsQ[ $multiActionResult, "**Suggested Fixes:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-MultipleActions-HasPluralHeader@@Tests/CodeInspectorTool.wlt:769,1-774,2"
]

VerificationTest[
    StringCount[ $multiActionResult, "- Insert" ],
    2,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-MultipleActions-HasTwoActions@@Tests/CodeInspectorTool.wlt:776,1-781,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatSingleCodeAction*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatSingleCodeAction[
        CodeParser`CodeAction[ "Replace with ``StringQ``", CodeParser`ReplaceNode, <| "ReplacementNode" -> CodeParser`LeafNode[ Symbol, "StringQ", <||> ] |> ]
    ],
    _String ? (StringContainsQ[ #, "Replace with `StringQ`" ] &),
    SameTest -> MatchQ,
    TestID   -> "FormatSingleCodeAction-ReplaceNode@@Tests/CodeInspectorTool.wlt:786,1-793,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatSingleCodeAction[
        CodeParser`CodeAction[ "Delete key 1", CodeParser`DeleteNode, <| CodeParser`Source -> { { 1, 1 }, { 1, 5 } } |> ]
    ],
    _String ? (StringContainsQ[ #, "Delete key 1" ] &),
    SameTest -> MatchQ,
    TestID   -> "FormatSingleCodeAction-DeleteNode@@Tests/CodeInspectorTool.wlt:795,1-802,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatSingleCodeAction[ "invalid" ],
    "",
    SameTest -> SameQ,
    TestID   -> "FormatSingleCodeAction-Invalid@@Tests/CodeInspectorTool.wlt:804,1-809,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*codeActionCommandToString*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`ReplaceText ],
    "Replace with",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-ReplaceText@@Tests/CodeInspectorTool.wlt:814,1-819,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`DeleteText ],
    "Delete",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-DeleteText@@Tests/CodeInspectorTool.wlt:821,1-826,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`InsertText ],
    "Insert",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-InsertText@@Tests/CodeInspectorTool.wlt:828,1-833,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`ReplaceNode ],
    "Replace with",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-ReplaceNode@@Tests/CodeInspectorTool.wlt:835,1-840,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`DeleteNode ],
    "Delete",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-DeleteNode@@Tests/CodeInspectorTool.wlt:842,1-847,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`InsertNode ],
    "Insert",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-InsertNode@@Tests/CodeInspectorTool.wlt:849,1-854,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`InsertNodeAfter ],
    "Insert after",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-InsertNodeAfter@@Tests/CodeInspectorTool.wlt:856,1-861,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ UnknownCommand ],
    "UnknownCommand",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-Unknown@@Tests/CodeInspectorTool.wlt:863,1-868,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*cleanLabel*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`cleanLabel[ "Replace with ``StringQ``" ],
    "Replace with `StringQ`",
    SameTest -> SameQ,
    TestID   -> "CleanLabel-SingleBackticks@@Tests/CodeInspectorTool.wlt:873,1-878,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`cleanLabel[ "Insert ``*`` and ``+``" ],
    "Insert `*` and `+`",
    SameTest -> SameQ,
    TestID   -> "CleanLabel-MultipleBackticks@@Tests/CodeInspectorTool.wlt:880,1-885,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`cleanLabel[ "No backticks here" ],
    "No backticks here",
    SameTest -> SameQ,
    TestID   -> "CleanLabel-NoBackticks@@Tests/CodeInspectorTool.wlt:887,1-892,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatCodeActions Integration with formatInspection*)
VerificationTest[
    (* Test that formatInspection includes CodeActions *)
    $inspectionWithActions = Wolfram`MCPServer`Tools`CodeInspector`Private`formatInspection[
        InspectionObject[
            "Comma",
            "Extra comma.",
            "Error",
            <|
                ConfidenceLevel -> 1.0,
                CodeParser`Source -> { { 1, 5 }, { 1, 5 } },
                CodeParser`CodeActions -> {
                    CodeParser`CodeAction[ "Delete ``,``", CodeParser`DeleteText, <| CodeParser`Source -> { { 1, 5 }, { 1, 6 } } |> ]
                }
            |>
        ],
        1,
        "1+f[,2]"
    ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "FormatInspection-WithCodeActions-ReturnsString@@Tests/CodeInspectorTool.wlt:897,1-918,2"
]

VerificationTest[
    StringContainsQ[ $inspectionWithActions, "**Suggested Fix:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-WithCodeActions-ShowsSuggestedFix@@Tests/CodeInspectorTool.wlt:920,1-925,2"
]

VerificationTest[
    StringContainsQ[ $inspectionWithActions, "Delete `,`" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-WithCodeActions-ShowsActionLabel@@Tests/CodeInspectorTool.wlt:927,1-932,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Error Cases*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Empty Directory*)
VerificationTest[
    $emptyDir = CreateDirectory[ ];
    DirectoryQ @ $emptyDir,
    True,
    SameTest -> SameQ,
    TestID   -> "ErrorCase-CreateEmptyDir@@Tests/CodeInspectorTool.wlt:941,1-947,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        $emptyDir,
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    _Failure,
    { MCPServer::CodeInspectorNoFilesFound },
    SameTest -> MatchQ,
    TestID   -> "ErrorCase-EmptyDirectory@@Tests/CodeInspectorTool.wlt:949,1-958,2"
]

VerificationTest[
    DeleteDirectory[ $emptyDir ];
    ! DirectoryQ @ $emptyDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Cleanup-EmptyDirectory@@Tests/CodeInspectorTool.wlt:960,1-966,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Integration Tests - Basic Functionality*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Code String Inspection with Known Issues*)
VerificationTest[
    $integrationCodeResult = CodeInspectorToolFunction @ <|
        "code"               -> "If[a, b, b]",
        "severityExclusions" -> ""
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-CodeStringWithIssues-ReturnsString@@Tests/CodeInspectorTool.wlt:975,1-983,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "# Code Inspection Results" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CodeStringWithIssues-HasHeader@@Tests/CodeInspectorTool.wlt:985,1-990,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "DuplicateClauses" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CodeStringWithIssues-FindsDuplicateClauses@@Tests/CodeInspectorTool.wlt:992,1-997,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "## Summary" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CodeStringWithIssues-HasSummary@@Tests/CodeInspectorTool.wlt:999,1-1004,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "## Issues" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CodeStringWithIssues-HasIssuesSection@@Tests/CodeInspectorTool.wlt:1006,1-1011,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Clean Code Returns No Issues Found*)
VerificationTest[
    $integrationCleanResult = CodeInspectorToolFunction @ <| "code" -> "f[x_] := x + 1" |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-CleanCode-ReturnsString@@Tests/CodeInspectorTool.wlt:1016,1-1021,2"
]

VerificationTest[
    StringContainsQ[ $integrationCleanResult, "No issues found matching the specified criteria." ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CleanCode-ShowsNoIssuesMessage@@Tests/CodeInspectorTool.wlt:1023,1-1028,2"
]

VerificationTest[
    StringContainsQ[ $integrationCleanResult, "**Settings:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CleanCode-ShowsSettings@@Tests/CodeInspectorTool.wlt:1030,1-1035,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Single File Inspection*)
VerificationTest[
    $integrationTempDir = CreateDirectory[ ];
    $integrationTestFile = FileNameJoin @ { $integrationTempDir, "testfile.wl" };
    Export[ $integrationTestFile, "If[x, y, y]", "Text" ];
    FileExistsQ @ $integrationTestFile,
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-SingleFile-CreateTestFile@@Tests/CodeInspectorTool.wlt:1040,1-1048,2"
]

VerificationTest[
    $integrationFileResult = CodeInspectorToolFunction @ <|
        "file"               -> $integrationTestFile,
        "severityExclusions" -> ""
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-SingleFile-ReturnsString@@Tests/CodeInspectorTool.wlt:1050,1-1058,2"
]

VerificationTest[
    StringContainsQ[ $integrationFileResult, "**File:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-SingleFile-ShowsFileHeader@@Tests/CodeInspectorTool.wlt:1060,1-1065,2"
]

VerificationTest[
    StringContainsQ[ $integrationFileResult, "DuplicateClauses" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-SingleFile-FindsIssues@@Tests/CodeInspectorTool.wlt:1067,1-1072,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Recursive Directory Inspection*)
VerificationTest[
    $integrationTestFile2 = FileNameJoin @ { $integrationTempDir, "testfile2.wl" };
    Export[ $integrationTestFile2, "Switch[x, 1, a, 1, b]", "Text" ];
    FileExistsQ @ $integrationTestFile2,
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Directory-CreateSecondTestFile@@Tests/CodeInspectorTool.wlt:1077,1-1084,2"
]

VerificationTest[
    $integrationDirResult = CodeInspectorToolFunction @ <|
        "file"               -> $integrationTempDir,
        "severityExclusions" -> ""
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-Directory-ReturnsString@@Tests/CodeInspectorTool.wlt:1086,1-1094,2"
]

VerificationTest[
    StringContainsQ[ $integrationDirResult, "**Directory:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Directory-ShowsDirectoryHeader@@Tests/CodeInspectorTool.wlt:1096,1-1101,2"
]

VerificationTest[
    StringContainsQ[ $integrationDirResult, "**Files inspected:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Directory-ShowsFileCount@@Tests/CodeInspectorTool.wlt:1103,1-1108,2"
]

VerificationTest[
    StringContainsQ[ $integrationDirResult, "testfile.wl" ] && StringContainsQ[ $integrationDirResult, "testfile2.wl" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Directory-ShowsBothFiles@@Tests/CodeInspectorTool.wlt:1110,1-1115,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Integration Tests - Parameter Handling*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tag Exclusions Filter Correctly*)
VerificationTest[
    $integrationTagExcludeResult = CodeInspectorToolFunction @ <|
        "code"               -> "If[a, b, b]",
        "tagExclusions"      -> "DuplicateClauses::If",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-TagExclusions-ReturnsString@@Tests/CodeInspectorTool.wlt:1124,1-1134,2"
]

VerificationTest[
    (* When DuplicateClauses is excluded, we should see "No issues found" for this code *)
    StringContainsQ[ $integrationTagExcludeResult, "No issues found matching the specified criteria." ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-TagExclusions-ExcludesDuplicateClauses@@Tests/CodeInspectorTool.wlt:1136,1-1142,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Severity Exclusions Filter Correctly*)
VerificationTest[
    $integrationSeverityExcludeResult = CodeInspectorToolFunction @ <|
        "code"               -> "If[a, b, b]",
        "severityExclusions" -> "Warning,Error",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-SeverityExclusions-ReturnsString@@Tests/CodeInspectorTool.wlt:1147,1-1156,2"
]

VerificationTest[
    (* DuplicateClauses is typically Warning or Error, so excluding both should filter it out *)
    StringContainsQ[ $integrationSeverityExcludeResult, "No issues found matching the specified criteria." ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-SeverityExclusions-FiltersCorrectly@@Tests/CodeInspectorTool.wlt:1158,1-1164,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Confidence Level Filtering Works*)
VerificationTest[
    (* With high confidence threshold, low-confidence issues should be filtered *)
    $integrationHighConfResult = CodeInspectorToolFunction @ <|
        "code"               -> "If[a, b, b]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 1.0  (* Only 100% confidence issues *)
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-ConfidenceLevel-HighThreshold-ReturnsString@@Tests/CodeInspectorTool.wlt:1169,1-1179,2"
]

VerificationTest[
    (* With very low confidence threshold, issues should appear *)
    $integrationLowConfResult = CodeInspectorToolFunction @ <|
        "code"               -> "If[a, b, b]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0  (* Include all issues *)
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-ConfidenceLevel-LowThreshold-ReturnsString@@Tests/CodeInspectorTool.wlt:1181,1-1191,2"
]

VerificationTest[
    StringContainsQ[ $integrationLowConfResult, "DuplicateClauses" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-ConfidenceLevel-LowThreshold-FindsIssues@@Tests/CodeInspectorTool.wlt:1193,1-1198,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Limit Parameter Truncates Output Correctly*)
VerificationTest[
    (* Create code with multiple issues *)
    $integrationLimitResult = CodeInspectorToolFunction @ <|
        "code"               -> "If[a, b, b]; If[c, d, d]; If[e, f, f]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0,
        "limit"              -> 1  (* Only show 1 issue *)
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-Limit-ReturnsString@@Tests/CodeInspectorTool.wlt:1203,1-1214,2"
]

VerificationTest[
    (* Should have "Issue 1" but not "Issue 2" (due to limit) *)
    StringContainsQ[ $integrationLimitResult, "### Issue 1:" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Limit-ShowsFirstIssue@@Tests/CodeInspectorTool.wlt:1216,1-1222,2"
]

VerificationTest[
    (* Should show truncation notice *)
    StringContainsQ[ $integrationLimitResult, "Showing 1 of" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Limit-ShowsTruncationNotice@@Tests/CodeInspectorTool.wlt:1224,1-1230,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Integration Tests - Error Handling*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error When Neither code nor file Provided*)
VerificationTest[
    CodeInspectorToolFunction @ <| |>,
    _Failure,
    { CodeInspectorToolFunction::CodeInspectorNoInput },
    SameTest -> MatchQ,
    TestID   -> "Integration-Error-NoInput@@Tests/CodeInspectorTool.wlt:1239,1-1245,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error When Both code and file Provided*)
VerificationTest[
    CodeInspectorToolFunction @ <| "code" -> "f[x_] := x", "file" -> $integrationTestFile |>,
    _Failure,
    { CodeInspectorToolFunction::CodeInspectorAmbiguousInput },
    SameTest -> MatchQ,
    TestID   -> "Integration-Error-BothInputs@@Tests/CodeInspectorTool.wlt:1250,1-1256,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error For Non-Existent File*)
VerificationTest[
    CodeInspectorToolFunction @ <| "file" -> "/nonexistent/path/to/file.wl" |>,
    _Failure,
    { CodeInspectorToolFunction::CodeInspectorFileNotFound },
    SameTest -> MatchQ,
    TestID   -> "Integration-Error-FileNotFound@@Tests/CodeInspectorTool.wlt:1261,1-1267,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error For Directory With No Matching Files*)
VerificationTest[
    $integrationEmptyDir = CreateDirectory[ ];
    DirectoryQ @ $integrationEmptyDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Error-CreateEmptyDir@@Tests/CodeInspectorTool.wlt:1272,1-1278,2"
]

VerificationTest[
    CodeInspectorToolFunction @ <| "file" -> $integrationEmptyDir |>,
    _Failure,
    { CodeInspectorToolFunction::CodeInspectorNoFilesFound },
    SameTest -> MatchQ,
    TestID   -> "Integration-Error-EmptyDirectory@@Tests/CodeInspectorTool.wlt:1280,1-1286,2"
]

VerificationTest[
    DeleteDirectory[ $integrationEmptyDir ];
    ! DirectoryQ @ $integrationEmptyDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Cleanup-EmptyDir@@Tests/CodeInspectorTool.wlt:1288,1-1294,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error on Out-of-Range Confidence Level*)
VerificationTest[
    (* Out of range confidence level should throw an error *)
    CodeInspectorToolFunction @ <| "code" -> "f[x_] := x + 1", "confidenceLevel" -> 2.5 |>,
    _Failure,
    { CodeInspectorToolFunction::CodeInspectorInvalidConfidence },
    SameTest -> MatchQ,
    TestID   -> "Integration-OutOfRangeConfidence-ReturnsFailure@@Tests/CodeInspectorTool.wlt:1299,1-1306,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Integration Tests - Output Format*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Summary Table Has Correct Format*)
VerificationTest[
    (* Summary table should have proper markdown table formatting *)
    StringContainsQ[ $integrationCodeResult, "| Severity | Count |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-SummaryTableHeaders@@Tests/CodeInspectorTool.wlt:1315,1-1321,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "|----------|-------|" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-SummaryTableSeparator@@Tests/CodeInspectorTool.wlt:1323,1-1328,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "| **Total** |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-SummaryTableTotal@@Tests/CodeInspectorTool.wlt:1330,1-1335,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Issue Markdown Structure Is Correct*)
VerificationTest[
    (* Issue should have proper header format *)
    StringMatchQ[ $integrationCodeResult, ___ ~~ "### Issue " ~~ DigitCharacter ~~ ": " ~~ ___ ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-IssueHeader@@Tests/CodeInspectorTool.wlt:1340,1-1346,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "**Location:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-IssueLocation@@Tests/CodeInspectorTool.wlt:1348,1-1353,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "**Description:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-IssueDescription@@Tests/CodeInspectorTool.wlt:1355,1-1360,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Code Snippets Include Line Numbers and Context*)
VerificationTest[
    StringContainsQ[ $integrationCodeResult, "**Code:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-CodeHeader@@Tests/CodeInspectorTool.wlt:1365,1-1370,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "```wl" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-CodeBlockStart@@Tests/CodeInspectorTool.wlt:1372,1-1377,2"
]

VerificationTest[
    (* Line number format: "1 | " *)
    StringMatchQ[ $integrationCodeResult, ___ ~~ DigitCharacter ~~ " | " ~~ ___ ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-LineNumbers@@Tests/CodeInspectorTool.wlt:1379,1-1385,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*CodeActions Are Formatted As Suggestions*)
VerificationTest[
    (* Create code that produces CodeActions (extra comma) *)
    $integrationCodeActionsResult = CodeInspectorToolFunction @ <|
        "code"               -> "f[,2]",  (* Extra leading comma *)
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-OutputFormat-CodeActionsReturnsString@@Tests/CodeInspectorTool.wlt:1390,1-1400,2"
]

VerificationTest[
    (* CodeActions should appear as "Suggested Fix" when present.
       Since we can't guarantee every issue has CodeActions, we verify:
       - Either there's a Suggested Fix section
       - Or there are issues but no CodeActions (which is valid)
       The unit tests verify CodeAction formatting works correctly. *)
    StringContainsQ[ $integrationCodeActionsResult, "Suggested Fix" ] ||
    StringContainsQ[ $integrationCodeActionsResult, "## Issues" ],  (* Valid result with issues, CodeActions are optional *)
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-SuggestedFix@@Tests/CodeInspectorTool.wlt:1402,1-1413,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Custom Rules - NegatedDateObject*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectNegatedDateObject - Basic Detection*)
VerificationTest[
    $negatedDateResult = CodeInspectorToolFunction @ <|
        "code"               -> "SortBy[files, -FileDate[#1] &]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NegatedDateObject-FileDate-ReturnsString@@Tests/CodeInspectorTool.wlt:1422,1-1431,2"
]

VerificationTest[
    StringContainsQ[ $negatedDateResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-FileDate-HasTag@@Tests/CodeInspectorTool.wlt:1433,1-1438,2"
]

VerificationTest[
    StringContainsQ[ $negatedDateResult, "Negating a ``DateObject`` does not produce a meaningful result" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-FileDate-HasDescription@@Tests/CodeInspectorTool.wlt:1440,1-1445,2"
]

VerificationTest[
    StringContainsQ[ $negatedDateResult, "(Error" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-FileDate-IsError@@Tests/CodeInspectorTool.wlt:1447,1-1452,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectNegatedDateObject - Now and Today*)
VerificationTest[
    $negatedNowResult = CodeInspectorToolFunction @ <|
        "code"               -> "x = -Now",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NegatedDateObject-Now-ReturnsString@@Tests/CodeInspectorTool.wlt:1457,1-1466,2"
]

VerificationTest[
    StringContainsQ[ $negatedNowResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-Now-HasTag@@Tests/CodeInspectorTool.wlt:1468,1-1473,2"
]

VerificationTest[
    $negatedTodayResult = CodeInspectorToolFunction @ <|
        "code"               -> "y = -Today",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NegatedDateObject-Today-ReturnsString@@Tests/CodeInspectorTool.wlt:1475,1-1484,2"
]

VerificationTest[
    StringContainsQ[ $negatedTodayResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-Today-HasTag@@Tests/CodeInspectorTool.wlt:1486,1-1491,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectNegatedDateObject - Other Date Functions*)
VerificationTest[
    $negatedDateObjectResult = CodeInspectorToolFunction @ <|
        "code"               -> "z = -DateObject[]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NegatedDateObject-DateObject-ReturnsString@@Tests/CodeInspectorTool.wlt:1496,1-1505,2"
]

VerificationTest[
    StringContainsQ[ $negatedDateObjectResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-DateObject-HasTag@@Tests/CodeInspectorTool.wlt:1507,1-1512,2"
]

VerificationTest[
    $negatedRandomDateResult = CodeInspectorToolFunction @ <|
        "code"               -> "w = -RandomDate[]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NegatedDateObject-RandomDate-ReturnsString@@Tests/CodeInspectorTool.wlt:1514,1-1523,2"
]

VerificationTest[
    StringContainsQ[ $negatedRandomDateResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-RandomDate-HasTag@@Tests/CodeInspectorTool.wlt:1525,1-1530,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectNegatedDateObject - Multiple Negations*)
VerificationTest[
    $multipleNegatedResult = CodeInspectorToolFunction @ <|
        "code"               -> "x = -Now; y = -Today; z = -Tomorrow; w = -Yesterday",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NegatedDateObject-Multiple-ReturnsString@@Tests/CodeInspectorTool.wlt:1535,1-1544,2"
]

VerificationTest[
    StringCount[ $multipleNegatedResult, "NegatedDateObject" ],
    4,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-Multiple-FindsAllFour@@Tests/CodeInspectorTool.wlt:1546,1-1551,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Custom Rules - ReadStringCharacterEncoding*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectReadStringWithCharacterEncoding - Basic Detection*)
VerificationTest[
    $readStringResult = CodeInspectorToolFunction @ <|
        "code"               -> "ReadString[\"file.txt\", CharacterEncoding -> \"UTF-8\"]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "ReadStringCharacterEncoding-Basic-ReturnsString@@Tests/CodeInspectorTool.wlt:1560,1-1569,2"
]

VerificationTest[
    StringContainsQ[ $readStringResult, "ReadStringCharacterEncoding" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ReadStringCharacterEncoding-Basic-HasTag@@Tests/CodeInspectorTool.wlt:1571,1-1576,2"
]

VerificationTest[
    StringContainsQ[ $readStringResult, "``ReadString`` does not support the ``CharacterEncoding`` option" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ReadStringCharacterEncoding-Basic-HasDescription@@Tests/CodeInspectorTool.wlt:1578,1-1583,2"
]

VerificationTest[
    StringContainsQ[ $readStringResult, "(Error" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ReadStringCharacterEncoding-Basic-IsError@@Tests/CodeInspectorTool.wlt:1585,1-1590,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectReadStringWithCharacterEncoding - No False Positive*)
VerificationTest[
    $readStringCleanResult = CodeInspectorToolFunction @ <|
        "code"               -> "ReadString[\"file.txt\"]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "ReadStringCharacterEncoding-NoFalsePositive-ReturnsString@@Tests/CodeInspectorTool.wlt:1595,1-1604,2"
]

VerificationTest[
    StringContainsQ[ $readStringCleanResult, "ReadStringCharacterEncoding" ],
    False,
    SameTest -> SameQ,
    TestID   -> "ReadStringCharacterEncoding-NoFalsePositive-NoTag@@Tests/CodeInspectorTool.wlt:1606,1-1611,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Custom Rules - ExcessiveLineLength*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Line Exceeding Maximum Length*)
VerificationTest[
    $longLineCode = "x = " <> StringJoin @ Table[ "a", 200 ];
    $longLineInspections = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        $longLineCode,
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.0 |>
    ],
    { __InspectionObject },
    SameTest -> MatchQ,
    TestID   -> "ExcessiveLineLength-Detected-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1620,1-1629,2"
]

VerificationTest[
    MemberQ[ $longLineInspections, InspectionObject[ "ExcessiveLineLength", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExcessiveLineLength-Detected-HasTag@@Tests/CodeInspectorTool.wlt:1631,1-1636,2"
]

VerificationTest[
    MemberQ[ $longLineInspections, InspectionObject[ "ExcessiveLineLength", _, "Formatting", _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExcessiveLineLength-Detected-IsFormatting@@Tests/CodeInspectorTool.wlt:1638,1-1643,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Line Exactly at Maximum Length*)
VerificationTest[
    $exactLineInspections = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        StringJoin @ Table[ "a", 200 ],
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.0 |>
    ],
    { ___InspectionObject },
    SameTest -> MatchQ,
    TestID   -> "ExcessiveLineLength-ExactLimit-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1648,1-1656,2"
]

VerificationTest[
    MemberQ[ $exactLineInspections, InspectionObject[ "ExcessiveLineLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "ExcessiveLineLength-ExactLimit-NotDetected@@Tests/CodeInspectorTool.wlt:1658,1-1663,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Short Lines Only*)
VerificationTest[
    $shortLineInspections = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "f[x_] := x + 1\ng[y_] := y * 2",
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.0 |>
    ],
    { ___InspectionObject },
    SameTest -> MatchQ,
    TestID   -> "ExcessiveLineLength-ShortLines-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1668,1-1676,2"
]

VerificationTest[
    MemberQ[ $shortLineInspections, InspectionObject[ "ExcessiveLineLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "ExcessiveLineLength-ShortLines-NotDetected@@Tests/CodeInspectorTool.wlt:1678,1-1683,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Custom Rules - ExcessiveFileLength*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*File Exceeding Maximum Lines*)
VerificationTest[
    $longFileCode = StringJoin @ Table[ "x = 1\n", 10001 ];
    $longFileInspections = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        $longFileCode,
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.0 |>
    ],
    { __InspectionObject },
    SameTest -> MatchQ,
    TestID   -> "ExcessiveFileLength-Detected-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1692,1-1701,2"
]

VerificationTest[
    MemberQ[ $longFileInspections, InspectionObject[ "ExcessiveFileLength", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExcessiveFileLength-Detected-HasTag@@Tests/CodeInspectorTool.wlt:1703,1-1708,2"
]

VerificationTest[
    MemberQ[ $longFileInspections, InspectionObject[ "ExcessiveFileLength", _, "Formatting", _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExcessiveFileLength-Detected-IsFormatting@@Tests/CodeInspectorTool.wlt:1710,1-1715,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*File Within Maximum Lines*)
VerificationTest[
    $shortFileInspections = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        StringJoin @ Table[ "x = 1\n", 100 ],
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.0 |>
    ],
    { ___InspectionObject },
    SameTest -> MatchQ,
    TestID   -> "ExcessiveFileLength-ShortFile-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1720,1-1728,2"
]

VerificationTest[
    MemberQ[ $shortFileInspections, InspectionObject[ "ExcessiveFileLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "ExcessiveFileLength-ShortFile-NotDetected@@Tests/CodeInspectorTool.wlt:1730,1-1735,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Custom Rules - Formatting Severity Exclusion*)
VerificationTest[
    $formattingExcludedInspections = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "x = " <> StringJoin @ Table[ "a", 200 ],
        <| "tagExclusions" -> { }, "severityExclusions" -> { "Formatting" }, "confidenceLevel" -> 0.0 |>
    ],
    { ___InspectionObject },
    SameTest -> MatchQ,
    TestID   -> "FormattingExclusion-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1740,1-1748,2"
]

VerificationTest[
    MemberQ[ $formattingExcludedInspections, InspectionObject[ "ExcessiveLineLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "FormattingExclusion-SuppressesLineLength@@Tests/CodeInspectorTool.wlt:1750,1-1755,2"
]

VerificationTest[
    MemberQ[ $formattingExcludedInspections, InspectionObject[ "ExcessiveFileLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "FormattingExclusion-SuppressesFileLength@@Tests/CodeInspectorTool.wlt:1757,1-1762,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Custom Rules - AmbiguousMapSyntax*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectAmbiguousMapSyntax - Basic Detection*)
VerificationTest[
    $ambiguousMapCST = CodeParser`CodeConcreteParse[ "Quiet @ DeleteFile /@ files" ];
    Cases[
        $ambiguousMapCST,
        Wolfram`MCPServer`Tools`CodeInspector`Private`$$ambiguousAtMapSyntax,
        Infinity
    ],
    { _CodeParser`BinaryNode },
    SameTest -> MatchQ,
    TestID   -> "AmbiguousMapSyntax-Basic-MatchesPattern@@Tests/CodeInspectorTool.wlt:1771,1-1781,2"
]

VerificationTest[
    $ambiguousMapInspection = With[
        {
            pos = First @ Position[
                $ambiguousMapCST,
                Wolfram`MCPServer`Tools`CodeInspector`Private`$$ambiguousAtMapSyntax,
                Infinity
            ]
        },
        Wolfram`MCPServer`Tools`CodeInspector`Private`inspectAmbiguousMapSyntax[ pos, $ambiguousMapCST ]
    ],
    InspectionObject[ "AmbiguousMapSyntax", _String, "Warning", _Association ],
    SameTest -> MatchQ,
    TestID   -> "AmbiguousMapSyntax-Basic-ProducesInspection@@Tests/CodeInspectorTool.wlt:1783,1-1797,2"
]

VerificationTest[
    $ambiguousMapDescription = Replace[
        $ambiguousMapInspection,
        InspectionObject[ "AmbiguousMapSyntax", description_String, _, _ ] :> description
    ];
    StringContainsQ[ $ambiguousMapDescription, "parsed as ``Map[Quiet[DeleteFile], files]``" ],
    True,
    SameTest -> SameQ,
    TestID   -> "AmbiguousMapSyntax-Basic-HasParseDescription@@Tests/CodeInspectorTool.wlt:1799,1-1808,2"
]

VerificationTest[
    $ambiguousMapActions = Replace[
        $ambiguousMapInspection,
        InspectionObject[ "AmbiguousMapSyntax", _, _, as_Association ] :> Lookup[ as, CodeParser`CodeActions, { } ]
    ];
    MatchQ[
        Cases[ $ambiguousMapActions, CodeParser`CodeAction[ label_String, __ ] :> label ],
        {
            "Replace with ``Quiet[DeleteFile /@ files]``",
            "Replace with ``Quiet[DeleteFile] /@ files``"
        }
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "AmbiguousMapSyntax-Basic-HasSuggestions@@Tests/CodeInspectorTool.wlt:1810,1-1825,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectAmbiguousMapSyntax - CallNode Right-Hand Side*)
VerificationTest[
    $ambiguousMapCallCST = CodeParser`CodeConcreteParse[ "f @ g[h] /@ x" ];
    Cases[
        $ambiguousMapCallCST,
        Wolfram`MCPServer`Tools`CodeInspector`Private`$$ambiguousAtMapSyntax,
        Infinity
    ],
    { _CodeParser`BinaryNode },
    SameTest -> MatchQ,
    TestID   -> "AmbiguousMapSyntax-CallNode-MatchesPattern@@Tests/CodeInspectorTool.wlt:1830,1-1840,2"
]

VerificationTest[
    MatchQ[
        With[
            {
                pos = First @ Position[
                    $ambiguousMapCallCST,
                    Wolfram`MCPServer`Tools`CodeInspector`Private`$$ambiguousAtMapSyntax,
                    Infinity
                ]
            },
            Wolfram`MCPServer`Tools`CodeInspector`Private`inspectAmbiguousMapSyntax[ pos, $ambiguousMapCallCST ]
        ],
        InspectionObject[ "AmbiguousMapSyntax", _String, "Warning", _Association ]
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "AmbiguousMapSyntax-CallNode-Detected@@Tests/CodeInspectorTool.wlt:1842,1-1859,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectAmbiguousMapSyntax - No False Positives*)
VerificationTest[
    Cases[
        CodeParser`CodeConcreteParse[ "f[g /@ x]" ],
        Wolfram`MCPServer`Tools`CodeInspector`Private`$$ambiguousAtMapSyntax,
        Infinity
    ],
    { },
    SameTest -> MatchQ,
    TestID   -> "AmbiguousMapSyntax-NoFalsePositive-NestedMap-NoTag@@Tests/CodeInspectorTool.wlt:1864,1-1873,2"
]

VerificationTest[
    Cases[
        CodeParser`CodeConcreteParse[ "Map[f @ g, x]" ],
        Wolfram`MCPServer`Tools`CodeInspector`Private`$$ambiguousAtMapSyntax,
        Infinity
    ],
    { },
    SameTest -> MatchQ,
    TestID   -> "AmbiguousMapSyntax-NoFalsePositive-MapCall-NoTag@@Tests/CodeInspectorTool.wlt:1875,1-1884,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Custom Rules - NothingValueInAssociation*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectNothingInAssociation - Basic Detection*)
VerificationTest[
    $nothingAssocResult = CodeInspectorToolFunction @ <|
        "code"               -> "<|\"a\" -> 1, \"b\" -> Nothing|>",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NothingValueInAssociation-Basic-ReturnsString@@Tests/CodeInspectorTool.wlt:1893,1-1902,2"
]

VerificationTest[
    StringCount[ $nothingAssocResult, "Issue " ~~ DigitCharacter.. ~~ ": NothingValueInAssociation" ],
    1,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-Basic-HasTag@@Tests/CodeInspectorTool.wlt:1904,1-1909,2"
]

VerificationTest[
    StringContainsQ[ $nothingAssocResult, "``Nothing`` used as a value in an ``Association`` is not automatically removed" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-Basic-HasDescription@@Tests/CodeInspectorTool.wlt:1911,1-1916,2"
]

VerificationTest[
    StringContainsQ[ $nothingAssocResult, "(Warning" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-Basic-HasSeverity@@Tests/CodeInspectorTool.wlt:1918,1-1923,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectNothingInAssociation - RuleDelayed*)
VerificationTest[
    $nothingAssocDelayedResult = CodeInspectorToolFunction @ <|
        "code"               -> "<|\"a\" -> 1, \"b\" :> Nothing|>",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NothingValueInAssociation-RuleDelayed-ReturnsString@@Tests/CodeInspectorTool.wlt:1928,1-1937,2"
]

VerificationTest[
    StringCount[ $nothingAssocDelayedResult, "Issue " ~~ DigitCharacter.. ~~ ": NothingValueInAssociation" ],
    1,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-RuleDelayed-HasTag@@Tests/CodeInspectorTool.wlt:1939,1-1944,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectNothingInAssociation - Multiple Nothing Values*)
VerificationTest[
    $nothingAssocMultiResult = CodeInspectorToolFunction @ <|
        "code"               -> "<|\"a\" -> Nothing, \"b\" -> Nothing, \"c\" :> Nothing|>",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NothingValueInAssociation-Multiple-ReturnsString@@Tests/CodeInspectorTool.wlt:1949,1-1958,2"
]

VerificationTest[
    StringCount[ $nothingAssocMultiResult, "Issue " ~~ DigitCharacter.. ~~ ": NothingValueInAssociation" ],
    3,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-Multiple-FindsAllThree@@Tests/CodeInspectorTool.wlt:1960,1-1965,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectNothingInAssociation - No False Positives*)
VerificationTest[
    $nothingAssocCleanResult = CodeInspectorToolFunction @ <|
        "code"               -> "<|\"a\" -> 1, \"b\" -> 2|>",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NothingValueInAssociation-NoFalsePositive-Clean-ReturnsString@@Tests/CodeInspectorTool.wlt:1970,1-1979,2"
]

VerificationTest[
    StringContainsQ[ $nothingAssocCleanResult, "NothingValueInAssociation" ],
    False,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-NoFalsePositive-Clean-NoTag@@Tests/CodeInspectorTool.wlt:1981,1-1986,2"
]

(* Nothing as standalone element in Association is fine *)
VerificationTest[
    $nothingStandaloneResult = CodeInspectorToolFunction @ <|
        "code"               -> "<|\"a\" -> 1, Nothing|>",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NothingValueInAssociation-NoFalsePositive-Standalone-ReturnsString@@Tests/CodeInspectorTool.wlt:1989,1-1998,2"
]

VerificationTest[
    StringContainsQ[ $nothingStandaloneResult, "NothingValueInAssociation" ],
    False,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-NoFalsePositive-Standalone-NoTag@@Tests/CodeInspectorTool.wlt:2000,1-2005,2"
]

(* Nothing in a regular list rule is fine *)
VerificationTest[
    $nothingListRuleResult = CodeInspectorToolFunction @ <|
        "code"               -> "{a -> Nothing}",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NothingValueInAssociation-NoFalsePositive-ListRule-ReturnsString@@Tests/CodeInspectorTool.wlt:2008,1-2017,2"
]

VerificationTest[
    StringContainsQ[ $nothingListRuleResult, "NothingValueInAssociation" ],
    False,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-NoFalsePositive-ListRule-NoTag@@Tests/CodeInspectorTool.wlt:2019,1-2024,2"
]

(* Nothing as argument inside a value is fine *)
VerificationTest[
    $nothingArgResult = CodeInspectorToolFunction @ <|
        "code"               -> "<|\"a\" -> f[Nothing]|>",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NothingValueInAssociation-NoFalsePositive-AsArgument-ReturnsString@@Tests/CodeInspectorTool.wlt:2027,1-2036,2"
]

VerificationTest[
    StringContainsQ[ $nothingArgResult, "NothingValueInAssociation" ],
    False,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-NoFalsePositive-AsArgument-NoTag@@Tests/CodeInspectorTool.wlt:2038,1-2043,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Custom Rules - KeyExistsQNestedKeyPath*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectKeyExistsQWithList - Basic Detection*)
VerificationTest[
    $keyExistsQResult = CodeInspectorToolFunction @ <|
        "code"               -> "KeyExistsQ[assoc, {\"k1\", \"k2\"}]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "KeyExistsQNestedKeyPath-Basic-ReturnsString@@Tests/CodeInspectorTool.wlt:2052,1-2061,2"
]

VerificationTest[
    StringCount[ $keyExistsQResult, "Issue " ~~ DigitCharacter.. ~~ ": KeyExistsQNestedKeyPath" ],
    1,
    SameTest -> SameQ,
    TestID   -> "KeyExistsQNestedKeyPath-Basic-HasTag@@Tests/CodeInspectorTool.wlt:2063,1-2068,2"
]

VerificationTest[
    StringContainsQ[ $keyExistsQResult, "``KeyExistsQ`` with a ``List`` as its second argument checks for a literal list key" ],
    True,
    SameTest -> SameQ,
    TestID   -> "KeyExistsQNestedKeyPath-Basic-HasDescription@@Tests/CodeInspectorTool.wlt:2070,1-2075,2"
]

VerificationTest[
    StringContainsQ[ $keyExistsQResult, "(Warning" ],
    True,
    SameTest -> SameQ,
    TestID   -> "KeyExistsQNestedKeyPath-Basic-HasSeverity@@Tests/CodeInspectorTool.wlt:2077,1-2082,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectKeyExistsQWithList - Single Key in List*)
VerificationTest[
    $keyExistsQSingleResult = CodeInspectorToolFunction @ <|
        "code"               -> "KeyExistsQ[assoc, {\"key\"}]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "KeyExistsQNestedKeyPath-SingleKey-ReturnsString@@Tests/CodeInspectorTool.wlt:2087,1-2096,2"
]

VerificationTest[
    StringCount[ $keyExistsQSingleResult, "Issue " ~~ DigitCharacter.. ~~ ": KeyExistsQNestedKeyPath" ],
    1,
    SameTest -> SameQ,
    TestID   -> "KeyExistsQNestedKeyPath-SingleKey-HasTag@@Tests/CodeInspectorTool.wlt:2098,1-2103,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectKeyExistsQWithList - No False Positives*)

(* KeyExistsQ with a plain string key should not trigger *)
VerificationTest[
    $keyExistsQCleanResult = CodeInspectorToolFunction @ <|
        "code"               -> "KeyExistsQ[assoc, \"key\"]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "KeyExistsQNestedKeyPath-NoFalsePositive-StringKey-ReturnsString@@Tests/CodeInspectorTool.wlt:2110,1-2119,2"
]

VerificationTest[
    StringContainsQ[ $keyExistsQCleanResult, "KeyExistsQNestedKeyPath" ],
    False,
    SameTest -> SameQ,
    TestID   -> "KeyExistsQNestedKeyPath-NoFalsePositive-StringKey-NoTag@@Tests/CodeInspectorTool.wlt:2121,1-2126,2"
]

(* KeyExistsQ with a symbol key should not trigger *)
VerificationTest[
    $keyExistsQSymbolResult = CodeInspectorToolFunction @ <|
        "code"               -> "KeyExistsQ[assoc, key]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "KeyExistsQNestedKeyPath-NoFalsePositive-SymbolKey-ReturnsString@@Tests/CodeInspectorTool.wlt:2129,1-2138,2"
]

VerificationTest[
    StringContainsQ[ $keyExistsQSymbolResult, "KeyExistsQNestedKeyPath" ],
    False,
    SameTest -> SameQ,
    TestID   -> "KeyExistsQNestedKeyPath-NoFalsePositive-SymbolKey-NoTag@@Tests/CodeInspectorTool.wlt:2140,1-2145,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Custom Rules - UnreachableConditionalDefinition*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectConditionalOwnValueOrdering - Basic Detection*)
VerificationTest[
    $ownValueCondResult = CodeInspectorToolFunction @ <|
        "code"               -> "x /; True := 1;\nx := 2",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "UnreachableConditionalDefinition-OwnValue-ReturnsString@@Tests/CodeInspectorTool.wlt:2154,1-2163,2"
]

VerificationTest[
    StringCount[ $ownValueCondResult, "Issue " ~~ DigitCharacter.. ~~ ": UnreachableConditionalDefinition" ],
    1,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-OwnValue-HasTag@@Tests/CodeInspectorTool.wlt:2165,1-2170,2"
]

VerificationTest[
    StringContainsQ[ $ownValueCondResult, "conditional definition of" ],
    True,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-OwnValue-HasDescription@@Tests/CodeInspectorTool.wlt:2172,1-2177,2"
]

VerificationTest[
    StringContainsQ[ $ownValueCondResult, "(Warning" ],
    True,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-OwnValue-HasSeverity@@Tests/CodeInspectorTool.wlt:2179,1-2184,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectConditionalDownValueOrdering - Basic Detection*)
VerificationTest[
    $downValueCondResult = CodeInspectorToolFunction @ <|
        "code" -> "f[] /; True := 1;\nf[] := 2"
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "UnreachableConditionalDefinition-DownValue-ReturnsString@@Tests/CodeInspectorTool.wlt:2189,1-2196,2"
]

VerificationTest[
    StringCount[ $downValueCondResult, "Issue " ~~ DigitCharacter.. ~~ ": UnreachableConditionalDefinition" ],
    1,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-DownValue-HasTag@@Tests/CodeInspectorTool.wlt:2198,1-2203,2"
]

VerificationTest[
    StringContainsQ[ $downValueCondResult, "conditional definition of" ],
    True,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-DownValue-HasDescription@@Tests/CodeInspectorTool.wlt:2205,1-2210,2"
]

VerificationTest[
    StringContainsQ[ $downValueCondResult, "(Warning" ],
    True,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-DownValue-HasSeverity@@Tests/CodeInspectorTool.wlt:2212,1-2217,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectConditionalDownValueOrdering - Code Between Definitions*)
VerificationTest[
    $betweenDefsResult = CodeInspectorToolFunction @ <|
        "code" -> "f[] /; cond := a;\n\nf[x_] := x + 1;\n\nf[] := b"
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "UnreachableConditionalDefinition-BetweenDefs-ReturnsString@@Tests/CodeInspectorTool.wlt:2222,1-2229,2"
]

VerificationTest[
    StringCount[ $betweenDefsResult, "Issue " ~~ DigitCharacter.. ~~ ": UnreachableConditionalDefinition" ],
    1,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-BetweenDefs-HasTag@@Tests/CodeInspectorTool.wlt:2231,1-2236,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectConditionalOwnValueOrdering - No False Positives*)

(* Standalone conditional definition without an unconditional counterpart should not trigger *)
VerificationTest[
    $standaloneCondResult = CodeInspectorToolFunction @ <|
        "code" -> "x /; cond := 1"
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "UnreachableConditionalDefinition-Standalone-ReturnsString@@Tests/CodeInspectorTool.wlt:2243,1-2250,2"
]

VerificationTest[
    StringContainsQ[ $standaloneCondResult, "UnreachableConditionalDefinition" ],
    False,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-Standalone-NoTag@@Tests/CodeInspectorTool.wlt:2252,1-2257,2"
]

(* All-conditional definitions should not trigger *)
VerificationTest[
    $allCondResult = CodeInspectorToolFunction @ <|
        "code" -> "g[] /; True := 1;\ng[] /; False := 2"
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "UnreachableConditionalDefinition-AllConditional-ReturnsString@@Tests/CodeInspectorTool.wlt:2260,1-2267,2"
]

VerificationTest[
    StringContainsQ[ $allCondResult, "UnreachableConditionalDefinition" ],
    False,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-AllConditional-NoTag@@Tests/CodeInspectorTool.wlt:2269,1-2274,2"
]

(* Definitions with patterns in arguments should not trigger *)
VerificationTest[
    $patternArgsResult = CodeInspectorToolFunction @ <|
        "code" -> "h[_] /; True := 1;\nh[_] := 2"
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "UnreachableConditionalDefinition-PatternArgs-ReturnsString@@Tests/CodeInspectorTool.wlt:2277,1-2284,2"
]

VerificationTest[
    StringContainsQ[ $patternArgsResult, "UnreachableConditionalDefinition" ],
    False,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-PatternArgs-NoTag@@Tests/CodeInspectorTool.wlt:2286,1-2291,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Integration Tests - Cleanup*)
VerificationTest[
    DeleteDirectory[ $integrationTempDir, DeleteContents -> True ];
    ! DirectoryQ @ $integrationTempDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Cleanup-TempDirectory@@Tests/CodeInspectorTool.wlt:2296,1-2302,2"
]

(* :!CodeAnalysis::EndBlock:: *)
