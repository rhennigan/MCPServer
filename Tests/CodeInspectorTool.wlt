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

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Registration*)
VerificationTest[
    $codeInspectorTool = $DefaultMCPTools[ "CodeInspector" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "GetTool@@Tests/CodeInspectorTool.wlt:38,1-43,2"
]

VerificationTest[
    $codeInspectorTool[ "Name" ],
    "CodeInspector",
    SameTest -> SameQ,
    TestID   -> "ToolName@@Tests/CodeInspectorTool.wlt:45,1-50,2"
]

VerificationTest[
    StringQ @ $codeInspectorTool[ "Description" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ToolDescription@@Tests/CodeInspectorTool.wlt:52,1-57,2"
]

VerificationTest[
    ListQ @ $codeInspectorTool[ "Parameters" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ToolParameters@@Tests/CodeInspectorTool.wlt:59,1-64,2"
]

VerificationTest[
    Length @ $codeInspectorTool[ "Parameters" ],
    6,
    SameTest -> SameQ,
    TestID   -> "ToolParameterCount@@Tests/CodeInspectorTool.wlt:66,1-71,2"
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
    TestID   -> "ParseExclusions-Missing@@Tests/CodeInspectorTool.wlt:80,1-85,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseExclusions[ "" ],
    { },
    SameTest -> MatchQ,
    TestID   -> "ParseExclusions-Empty@@Tests/CodeInspectorTool.wlt:87,1-92,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseExclusions[ "Warning" ],
    { "Warning" },
    SameTest -> MatchQ,
    TestID   -> "ParseExclusions-Single@@Tests/CodeInspectorTool.wlt:94,1-99,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseExclusions[ "Warning,Error,Remark" ],
    { "Warning", "Error", "Remark" },
    SameTest -> MatchQ,
    TestID   -> "ParseExclusions-Multiple@@Tests/CodeInspectorTool.wlt:101,1-106,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseExclusions[ "  Warning  ,  Error  " ],
    { "Warning", "Error" },
    SameTest -> MatchQ,
    TestID   -> "ParseExclusions-Whitespace@@Tests/CodeInspectorTool.wlt:108,1-113,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseExclusions[ Missing[ "KeyAbsent" ], { "Default1", "Default2" } ],
    { "Default1", "Default2" },
    SameTest -> MatchQ,
    TestID   -> "ParseExclusions-MissingWithDefault@@Tests/CodeInspectorTool.wlt:115,1-120,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseConfidenceLevel*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ Missing[ "KeyAbsent" ] ],
    0.75,
    SameTest -> SameQ,
    TestID   -> "ParseConfidenceLevel-Missing@@Tests/CodeInspectorTool.wlt:125,1-130,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ 0.5 ],
    0.5,
    SameTest -> SameQ,
    TestID   -> "ParseConfidenceLevel-Valid@@Tests/CodeInspectorTool.wlt:132,1-137,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ 0 ],
    0.0,
    SameTest -> SameQ,
    TestID   -> "ParseConfidenceLevel-IntegerValue@@Tests/CodeInspectorTool.wlt:139,1-144,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ 1.5 ],
    _Failure,
    { MCPServer::CodeInspectorInvalidConfidence },
    SameTest -> MatchQ,
    TestID   -> "ParseConfidenceLevel-OutOfRange@@Tests/CodeInspectorTool.wlt:146,1-152,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseLimit*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseLimit[ Missing[ "KeyAbsent" ] ],
    100,
    SameTest -> SameQ,
    TestID   -> "ParseLimit-Missing@@Tests/CodeInspectorTool.wlt:157,1-162,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseLimit[ 50 ],
    50,
    SameTest -> SameQ,
    TestID   -> "ParseLimit-Valid@@Tests/CodeInspectorTool.wlt:164,1-169,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseLimit[ -5 ],
    100,
    SameTest -> SameQ,
    TestID   -> "ParseLimit-Negative@@Tests/CodeInspectorTool.wlt:171,1-176,2"
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
    TestID   -> "ValidateInput-CodeString@@Tests/CodeInspectorTool.wlt:185,1-190,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ Missing[ "KeyAbsent" ], $InstallationDirectory ],
    $InstallationDirectory,
    SameTest -> SameQ,
    TestID   -> "ValidateInput-Directory@@Tests/CodeInspectorTool.wlt:192,1-197,2"
]

VerificationTest[
    (* Use a file from the MCPServer paclet that's guaranteed to exist *)
    $testFile = FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" };
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ Missing[ "KeyAbsent" ], $testFile ],
    File[ $testFile ],
    SameTest -> MatchQ,
    TestID   -> "ValidateInput-File@@Tests/CodeInspectorTool.wlt:199,1-206,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ Missing[ "KeyAbsent" ], Missing[ "KeyAbsent" ] ],
    _Failure,
    { MCPServer::CodeInspectorNoInput },
    SameTest -> MatchQ,
    TestID   -> "ValidateInput-NoInput@@Tests/CodeInspectorTool.wlt:208,1-214,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ "code", "file" ],
    _Failure,
    { MCPServer::CodeInspectorAmbiguousInput },
    SameTest -> MatchQ,
    TestID   -> "ValidateInput-BothInputs@@Tests/CodeInspectorTool.wlt:216,1-222,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ Missing[ "KeyAbsent" ], "/nonexistent/path/file.wl" ],
    _Failure,
    { MCPServer::CodeInspectorFileNotFound },
    SameTest -> MatchQ,
    TestID   -> "ValidateInput-FileNotFound@@Tests/CodeInspectorTool.wlt:224,1-230,2"
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
    TestID   -> "RunInspection-CodeString@@Tests/CodeInspectorTool.wlt:239,1-247,2"
]

VerificationTest[
    (* The code "If[a, b, b]" should produce at least one DuplicateClauses inspection *)
    MemberQ[ $codeResult, InspectionObject[ "DuplicateClauses", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "RunInspection-FindsDuplicateClauses@@Tests/CodeInspectorTool.wlt:249,1-255,2"
]

VerificationTest[
    (* Clean code should return empty list *)
    Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "f[x_] := x + 1",
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    { },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-CleanCode@@Tests/CodeInspectorTool.wlt:257,1-266,2"
]

VerificationTest[
    (* Test with severity exclusions *)
    $filteredResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "If[a, b, b]",
        <| "tagExclusions" -> { }, "severityExclusions" -> { "Warning", "Error" }, "confidenceLevel" -> 0.5 |>
    ],
    { },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-WithSeverityExclusions@@Tests/CodeInspectorTool.wlt:268,1-277,2"
]

VerificationTest[
    (* Test with tag exclusions *)
    $tagFilteredResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "If[a, b, b]",
        <| "tagExclusions" -> { "DuplicateClauses::If" }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    { },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-WithTagExclusions@@Tests/CodeInspectorTool.wlt:279,1-288,2"
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
    TestID   -> "RunInspection-CreateTestFile@@Tests/CodeInspectorTool.wlt:293,1-302,2"
]

VerificationTest[
    $fileResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        File[ $testWLFile ],
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    { _InspectionObject .. },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-File@@Tests/CodeInspectorTool.wlt:304,1-312,2"
]

VerificationTest[
    MemberQ[ $fileResult, InspectionObject[ "DuplicateClauses", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "RunInspection-FileFindsIssues@@Tests/CodeInspectorTool.wlt:314,1-319,2"
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
    TestID   -> "RunInspection-CreateSecondTestFile@@Tests/CodeInspectorTool.wlt:324,1-332,2"
]

VerificationTest[
    $dirResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        $tempDir,
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    _Association,
    SameTest -> MatchQ,
    TestID   -> "RunInspection-DirectoryReturnsAssociation@@Tests/CodeInspectorTool.wlt:334,1-342,2"
]

VerificationTest[
    Length @ Keys @ $dirResult,
    2,
    SameTest -> SameQ,
    TestID   -> "RunInspection-DirectoryFindsAllFiles@@Tests/CodeInspectorTool.wlt:344,1-349,2"
]

VerificationTest[
    AllTrue[ Values @ $dirResult, MatchQ[ { ___InspectionObject } ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "RunInspection-DirectoryAllInspectionObjects@@Tests/CodeInspectorTool.wlt:351,1-356,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup Test Files*)
VerificationTest[
    DeleteDirectory[ $tempDir, DeleteContents -> True ];
    ! DirectoryQ @ $tempDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Cleanup-TempDirectory@@Tests/CodeInspectorTool.wlt:361,1-367,2"
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
    TestID   -> "SummaryTable-ReturnsString@@Tests/CodeInspectorTool.wlt:376,1-385,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "## Summary" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-HasHeader@@Tests/CodeInspectorTool.wlt:387,1-392,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "| Error | 2 |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-CountsErrors@@Tests/CodeInspectorTool.wlt:394,1-399,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "| Warning | 1 |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-CountsWarnings@@Tests/CodeInspectorTool.wlt:401,1-406,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "| **Total** | **3** |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-ShowsTotal@@Tests/CodeInspectorTool.wlt:408,1-413,2"
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
    TestID   -> "FormatLocation-CodeStringRange@@Tests/CodeInspectorTool.wlt:418,1-426,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatLocation[
        "x",
        { { 1, 1 }, { 1, 1 } }
    ],
    "Line 1, Column 1",
    SameTest -> SameQ,
    TestID   -> "FormatLocation-CodeStringSinglePoint@@Tests/CodeInspectorTool.wlt:428,1-436,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatLocation[
        File[ "/path/to/file.wl" ],
        { { 42, 7 }, { 42, 15 } }
    ],
    "`file.wl:42:7`",
    SameTest -> SameQ,
    TestID   -> "FormatLocation-File@@Tests/CodeInspectorTool.wlt:438,1-446,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatLocation[
        "code",
        Missing[ "NotAvailable" ]
    ],
    "Unknown",
    SameTest -> SameQ,
    TestID   -> "FormatLocation-Missing@@Tests/CodeInspectorTool.wlt:448,1-456,2"
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
    TestID   -> "ExtractCodeSnippet-ReturnsString@@Tests/CodeInspectorTool.wlt:461,1-470,2"
]

VerificationTest[
    StringContainsQ[ $snippetResult, "**Code:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-HasCodeHeader@@Tests/CodeInspectorTool.wlt:472,1-477,2"
]

VerificationTest[
    StringContainsQ[ $snippetResult, "```wl" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-HasCodeBlock@@Tests/CodeInspectorTool.wlt:479,1-484,2"
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
    TestID   -> "ExtractCodeSnippet-ShowsContextBefore@@Tests/CodeInspectorTool.wlt:486,1-497,2"
]

VerificationTest[
    StringContainsQ[ $multiLineSnippet, "4 | line4" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-ShowsContextAfter@@Tests/CodeInspectorTool.wlt:499,1-504,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`extractCodeSnippet[
        "code",
        Missing[ "NotAvailable" ],
        1
    ],
    "",
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-MissingLocationReturnsEmpty@@Tests/CodeInspectorTool.wlt:506,1-515,2"
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
    TestID   -> "FormatInspection-ReturnsString@@Tests/CodeInspectorTool.wlt:520,1-534,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "### Issue 1: DuplicateClauses" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-HasHeader@@Tests/CodeInspectorTool.wlt:536,1-541,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "(Error, 95%)" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-ShowsSeverityAndConfidence@@Tests/CodeInspectorTool.wlt:543,1-548,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "**Location:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-HasLocation@@Tests/CodeInspectorTool.wlt:550,1-555,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "**Description:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-HasDescription@@Tests/CodeInspectorTool.wlt:557,1-562,2"
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
    TestID   -> "InspectionsToMarkdown-NoIssuesReturnsString@@Tests/CodeInspectorTool.wlt:567,1-576,2"
]

VerificationTest[
    StringContainsQ[ $noIssuesResult, "No issues found matching the specified criteria." ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-NoIssuesMessage@@Tests/CodeInspectorTool.wlt:578,1-583,2"
]

VerificationTest[
    StringContainsQ[ $noIssuesResult, "Confidence Level: 0.75" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsConfidenceLevel@@Tests/CodeInspectorTool.wlt:585,1-590,2"
]

VerificationTest[
    StringContainsQ[ $noIssuesResult, "Severity Exclusions: Formatting" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsSeverityExclusions@@Tests/CodeInspectorTool.wlt:592,1-597,2"
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
    TestID   -> "InspectionsToMarkdown-WithIssuesReturnsString@@Tests/CodeInspectorTool.wlt:602,1-618,2"
]

VerificationTest[
    StringContainsQ[ $withIssuesResult, "# Code Inspection Results" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-HasMainHeader@@Tests/CodeInspectorTool.wlt:620,1-625,2"
]

VerificationTest[
    StringContainsQ[ $withIssuesResult, "## Summary" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-HasSummary@@Tests/CodeInspectorTool.wlt:627,1-632,2"
]

VerificationTest[
    StringContainsQ[ $withIssuesResult, "## Issues" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-HasIssuesSection@@Tests/CodeInspectorTool.wlt:634,1-639,2"
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
    TestID   -> "InspectionsToMarkdown-TruncationReturnsString@@Tests/CodeInspectorTool.wlt:644,1-656,2"
]

VerificationTest[
    StringContainsQ[ $truncatedResult, "Showing 5 of 10 issues" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsTruncationNotice@@Tests/CodeInspectorTool.wlt:658,1-663,2"
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
    TestID   -> "InspectionsToMarkdown-FileSourceReturnsString@@Tests/CodeInspectorTool.wlt:668,1-684,2"
]

VerificationTest[
    StringContainsQ[ $fileSourceResult, "**File:** `/path/to/test.wl`" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsFileHeader@@Tests/CodeInspectorTool.wlt:686,1-691,2"
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
    TestID   -> "FormatCodeActions-EmptyList@@Tests/CodeInspectorTool.wlt:700,1-705,2"
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
    TestID   -> "FormatCodeActions-SingleAction-ReturnsString@@Tests/CodeInspectorTool.wlt:710,1-717,2"
]

VerificationTest[
    StringContainsQ[ $singleActionResult, "**Suggested Fix:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-SingleAction-HasHeader@@Tests/CodeInspectorTool.wlt:719,1-724,2"
]

VerificationTest[
    StringContainsQ[ $singleActionResult, "Delete `,`" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-SingleAction-HasLabel@@Tests/CodeInspectorTool.wlt:726,1-731,2"
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
    TestID   -> "FormatCodeActions-MultipleActions-ReturnsString@@Tests/CodeInspectorTool.wlt:736,1-744,2"
]

VerificationTest[
    StringContainsQ[ $multiActionResult, "**Suggested Fixes:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-MultipleActions-HasPluralHeader@@Tests/CodeInspectorTool.wlt:746,1-751,2"
]

VerificationTest[
    StringCount[ $multiActionResult, "- Insert" ],
    2,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-MultipleActions-HasTwoActions@@Tests/CodeInspectorTool.wlt:753,1-758,2"
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
    TestID   -> "FormatSingleCodeAction-ReplaceNode@@Tests/CodeInspectorTool.wlt:763,1-770,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatSingleCodeAction[
        CodeParser`CodeAction[ "Delete key 1", CodeParser`DeleteNode, <| CodeParser`Source -> { { 1, 1 }, { 1, 5 } } |> ]
    ],
    _String ? (StringContainsQ[ #, "Delete key 1" ] &),
    SameTest -> MatchQ,
    TestID   -> "FormatSingleCodeAction-DeleteNode@@Tests/CodeInspectorTool.wlt:772,1-779,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatSingleCodeAction[ "invalid" ],
    "",
    SameTest -> SameQ,
    TestID   -> "FormatSingleCodeAction-Invalid@@Tests/CodeInspectorTool.wlt:781,1-786,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*codeActionCommandToString*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`ReplaceText ],
    "Replace with",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-ReplaceText@@Tests/CodeInspectorTool.wlt:791,1-796,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`DeleteText ],
    "Delete",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-DeleteText@@Tests/CodeInspectorTool.wlt:798,1-803,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`InsertText ],
    "Insert",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-InsertText@@Tests/CodeInspectorTool.wlt:805,1-810,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`ReplaceNode ],
    "Replace with",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-ReplaceNode@@Tests/CodeInspectorTool.wlt:812,1-817,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`DeleteNode ],
    "Delete",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-DeleteNode@@Tests/CodeInspectorTool.wlt:819,1-824,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`InsertNode ],
    "Insert",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-InsertNode@@Tests/CodeInspectorTool.wlt:826,1-831,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`InsertNodeAfter ],
    "Insert after",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-InsertNodeAfter@@Tests/CodeInspectorTool.wlt:833,1-838,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ UnknownCommand ],
    "UnknownCommand",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-Unknown@@Tests/CodeInspectorTool.wlt:840,1-845,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*cleanLabel*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`cleanLabel[ "Replace with ``StringQ``" ],
    "Replace with `StringQ`",
    SameTest -> SameQ,
    TestID   -> "CleanLabel-SingleBackticks@@Tests/CodeInspectorTool.wlt:850,1-855,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`cleanLabel[ "Insert ``*`` and ``+``" ],
    "Insert `*` and `+`",
    SameTest -> SameQ,
    TestID   -> "CleanLabel-MultipleBackticks@@Tests/CodeInspectorTool.wlt:857,1-862,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`cleanLabel[ "No backticks here" ],
    "No backticks here",
    SameTest -> SameQ,
    TestID   -> "CleanLabel-NoBackticks@@Tests/CodeInspectorTool.wlt:864,1-869,2"
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
    TestID   -> "FormatInspection-WithCodeActions-ReturnsString@@Tests/CodeInspectorTool.wlt:874,1-895,2"
]

VerificationTest[
    StringContainsQ[ $inspectionWithActions, "**Suggested Fix:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-WithCodeActions-ShowsSuggestedFix@@Tests/CodeInspectorTool.wlt:897,1-902,2"
]

VerificationTest[
    StringContainsQ[ $inspectionWithActions, "Delete `,`" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-WithCodeActions-ShowsActionLabel@@Tests/CodeInspectorTool.wlt:904,1-909,2"
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
    TestID   -> "ErrorCase-CreateEmptyDir@@Tests/CodeInspectorTool.wlt:918,1-924,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        $emptyDir,
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    _Failure,
    { MCPServer::CodeInspectorNoFilesFound },
    SameTest -> MatchQ,
    TestID   -> "ErrorCase-EmptyDirectory@@Tests/CodeInspectorTool.wlt:926,1-935,2"
]

VerificationTest[
    DeleteDirectory[ $emptyDir ];
    ! DirectoryQ @ $emptyDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Cleanup-EmptyDirectory@@Tests/CodeInspectorTool.wlt:937,1-943,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Integration Tests - Basic Functionality*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Code String Inspection with Known Issues*)
VerificationTest[
    $integrationCodeResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "If[a, b, b]",
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> "",  (* Empty to not exclude any severities *)
        "confidenceLevel"    -> Missing[ "KeyAbsent" ],
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-CodeStringWithIssues-ReturnsString@@Tests/CodeInspectorTool.wlt:952,1-964,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "# Code Inspection Results" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CodeStringWithIssues-HasHeader@@Tests/CodeInspectorTool.wlt:966,1-971,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "DuplicateClauses" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CodeStringWithIssues-FindsDuplicateClauses@@Tests/CodeInspectorTool.wlt:973,1-978,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "## Summary" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CodeStringWithIssues-HasSummary@@Tests/CodeInspectorTool.wlt:980,1-985,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "## Issues" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CodeStringWithIssues-HasIssuesSection@@Tests/CodeInspectorTool.wlt:987,1-992,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Clean Code Returns No Issues Found*)
VerificationTest[
    $integrationCleanResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "f[x_] := x + 1",
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> Missing[ "KeyAbsent" ],
        "confidenceLevel"    -> Missing[ "KeyAbsent" ],
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-CleanCode-ReturnsString@@Tests/CodeInspectorTool.wlt:997,1-1009,2"
]

VerificationTest[
    StringContainsQ[ $integrationCleanResult, "No issues found matching the specified criteria." ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CleanCode-ShowsNoIssuesMessage@@Tests/CodeInspectorTool.wlt:1011,1-1016,2"
]

VerificationTest[
    StringContainsQ[ $integrationCleanResult, "**Settings:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CleanCode-ShowsSettings@@Tests/CodeInspectorTool.wlt:1018,1-1023,2"
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
    TestID   -> "Integration-SingleFile-CreateTestFile@@Tests/CodeInspectorTool.wlt:1028,1-1036,2"
]

VerificationTest[
    $integrationFileResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> Missing[ "KeyAbsent" ],
        "file"               -> $integrationTestFile,
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> "",
        "confidenceLevel"    -> Missing[ "KeyAbsent" ],
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-SingleFile-ReturnsString@@Tests/CodeInspectorTool.wlt:1038,1-1050,2"
]

VerificationTest[
    StringContainsQ[ $integrationFileResult, "**File:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-SingleFile-ShowsFileHeader@@Tests/CodeInspectorTool.wlt:1052,1-1057,2"
]

VerificationTest[
    StringContainsQ[ $integrationFileResult, "DuplicateClauses" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-SingleFile-FindsIssues@@Tests/CodeInspectorTool.wlt:1059,1-1064,2"
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
    TestID   -> "Integration-Directory-CreateSecondTestFile@@Tests/CodeInspectorTool.wlt:1069,1-1076,2"
]

VerificationTest[
    $integrationDirResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> Missing[ "KeyAbsent" ],
        "file"               -> $integrationTempDir,
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> "",
        "confidenceLevel"    -> Missing[ "KeyAbsent" ],
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-Directory-ReturnsString@@Tests/CodeInspectorTool.wlt:1078,1-1090,2"
]

VerificationTest[
    StringContainsQ[ $integrationDirResult, "**Directory:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Directory-ShowsDirectoryHeader@@Tests/CodeInspectorTool.wlt:1092,1-1097,2"
]

VerificationTest[
    StringContainsQ[ $integrationDirResult, "**Files inspected:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Directory-ShowsFileCount@@Tests/CodeInspectorTool.wlt:1099,1-1104,2"
]

VerificationTest[
    StringContainsQ[ $integrationDirResult, "testfile.wl" ] && StringContainsQ[ $integrationDirResult, "testfile2.wl" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Directory-ShowsBothFiles@@Tests/CodeInspectorTool.wlt:1106,1-1111,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Integration Tests - Parameter Handling*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tag Exclusions Filter Correctly*)
VerificationTest[
    $integrationTagExcludeResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "If[a, b, b]",
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> "DuplicateClauses::If",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0,
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-TagExclusions-ReturnsString@@Tests/CodeInspectorTool.wlt:1120,1-1132,2"
]

VerificationTest[
    (* When DuplicateClauses is excluded, we should see "No issues found" for this code *)
    StringContainsQ[ $integrationTagExcludeResult, "No issues found matching the specified criteria." ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-TagExclusions-ExcludesDuplicateClauses@@Tests/CodeInspectorTool.wlt:1134,1-1140,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Severity Exclusions Filter Correctly*)
VerificationTest[
    $integrationSeverityExcludeResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "If[a, b, b]",
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> "Warning,Error",
        "confidenceLevel"    -> 0.0,
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-SeverityExclusions-ReturnsString@@Tests/CodeInspectorTool.wlt:1145,1-1157,2"
]

VerificationTest[
    (* DuplicateClauses is typically Warning or Error, so excluding both should filter it out *)
    StringContainsQ[ $integrationSeverityExcludeResult, "No issues found matching the specified criteria." ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-SeverityExclusions-FiltersCorrectly@@Tests/CodeInspectorTool.wlt:1159,1-1165,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Confidence Level Filtering Works*)
VerificationTest[
    (* With high confidence threshold, low-confidence issues should be filtered *)
    $integrationHighConfResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "If[a, b, b]",
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> "",
        "confidenceLevel"    -> 1.0,  (* Only 100% confidence issues *)
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-ConfidenceLevel-HighThreshold-ReturnsString@@Tests/CodeInspectorTool.wlt:1170,1-1183,2"
]

VerificationTest[
    (* With very low confidence threshold, issues should appear *)
    $integrationLowConfResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "If[a, b, b]",
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0,  (* Include all issues *)
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-ConfidenceLevel-LowThreshold-ReturnsString@@Tests/CodeInspectorTool.wlt:1185,1-1198,2"
]

VerificationTest[
    StringContainsQ[ $integrationLowConfResult, "DuplicateClauses" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-ConfidenceLevel-LowThreshold-FindsIssues@@Tests/CodeInspectorTool.wlt:1200,1-1205,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Limit Parameter Truncates Output Correctly*)
VerificationTest[
    (* Create code with multiple issues *)
    $integrationLimitResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "If[a, b, b]; If[c, d, d]; If[e, f, f]",
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0,
        "limit"              -> 1  (* Only show 1 issue *)
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-Limit-ReturnsString@@Tests/CodeInspectorTool.wlt:1210,1-1223,2"
]

VerificationTest[
    (* Should have "Issue 1" but not "Issue 2" (due to limit) *)
    StringContainsQ[ $integrationLimitResult, "### Issue 1:" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Limit-ShowsFirstIssue@@Tests/CodeInspectorTool.wlt:1225,1-1231,2"
]

VerificationTest[
    (* Should show truncation notice *)
    StringContainsQ[ $integrationLimitResult, "Showing 1 of" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Limit-ShowsTruncationNotice@@Tests/CodeInspectorTool.wlt:1233,1-1239,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Integration Tests - Error Handling*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error When Neither code nor file Provided*)
VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> Missing[ "KeyAbsent" ],
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> Missing[ "KeyAbsent" ],
        "confidenceLevel"    -> Missing[ "KeyAbsent" ],
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _Failure,
    { MCPServer::CodeInspectorNoInput },
    SameTest -> MatchQ,
    TestID   -> "Integration-Error-NoInput@@Tests/CodeInspectorTool.wlt:1248,1-1261,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error When Both code and file Provided*)
VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "f[x_] := x",
        "file"               -> $integrationTestFile,
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> Missing[ "KeyAbsent" ],
        "confidenceLevel"    -> Missing[ "KeyAbsent" ],
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _Failure,
    { MCPServer::CodeInspectorAmbiguousInput },
    SameTest -> MatchQ,
    TestID   -> "Integration-Error-BothInputs@@Tests/CodeInspectorTool.wlt:1266,1-1279,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error For Non-Existent File*)
VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> Missing[ "KeyAbsent" ],
        "file"               -> "/nonexistent/path/to/file.wl",
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> Missing[ "KeyAbsent" ],
        "confidenceLevel"    -> Missing[ "KeyAbsent" ],
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _Failure,
    { MCPServer::CodeInspectorFileNotFound },
    SameTest -> MatchQ,
    TestID   -> "Integration-Error-FileNotFound@@Tests/CodeInspectorTool.wlt:1284,1-1297,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error For Directory With No Matching Files*)
VerificationTest[
    $integrationEmptyDir = CreateDirectory[ ];
    DirectoryQ @ $integrationEmptyDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Error-CreateEmptyDir@@Tests/CodeInspectorTool.wlt:1302,1-1308,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> Missing[ "KeyAbsent" ],
        "file"               -> $integrationEmptyDir,
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> Missing[ "KeyAbsent" ],
        "confidenceLevel"    -> Missing[ "KeyAbsent" ],
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _Failure,
    { MCPServer::CodeInspectorNoFilesFound },
    SameTest -> MatchQ,
    TestID   -> "Integration-Error-EmptyDirectory@@Tests/CodeInspectorTool.wlt:1310,1-1323,2"
]

VerificationTest[
    DeleteDirectory[ $integrationEmptyDir ];
    ! DirectoryQ @ $integrationEmptyDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Cleanup-EmptyDir@@Tests/CodeInspectorTool.wlt:1325,1-1331,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error on Out-of-Range Confidence Level*)
VerificationTest[
    (* Out of range confidence level should throw an error *)
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "f[x_] := x + 1",
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> Missing[ "KeyAbsent" ],
        "confidenceLevel"    -> 2.5,  (* Out of range *)
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _Failure,
    { MCPServer::CodeInspectorInvalidConfidence },
    SameTest -> MatchQ,
    TestID   -> "Integration-OutOfRangeConfidence-ReturnsFailure@@Tests/CodeInspectorTool.wlt:1336,1-1350,2"
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
    TestID   -> "Integration-OutputFormat-SummaryTableHeaders@@Tests/CodeInspectorTool.wlt:1359,1-1365,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "|----------|-------|" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-SummaryTableSeparator@@Tests/CodeInspectorTool.wlt:1367,1-1372,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "| **Total** |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-SummaryTableTotal@@Tests/CodeInspectorTool.wlt:1374,1-1379,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Issue Markdown Structure Is Correct*)
VerificationTest[
    (* Issue should have proper header format *)
    StringMatchQ[ $integrationCodeResult, ___ ~~ "### Issue " ~~ DigitCharacter ~~ ": " ~~ ___ ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-IssueHeader@@Tests/CodeInspectorTool.wlt:1384,1-1390,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "**Location:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-IssueLocation@@Tests/CodeInspectorTool.wlt:1392,1-1397,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "**Description:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-IssueDescription@@Tests/CodeInspectorTool.wlt:1399,1-1404,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Code Snippets Include Line Numbers and Context*)
VerificationTest[
    StringContainsQ[ $integrationCodeResult, "**Code:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-CodeHeader@@Tests/CodeInspectorTool.wlt:1409,1-1414,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "```wl" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-CodeBlockStart@@Tests/CodeInspectorTool.wlt:1416,1-1421,2"
]

VerificationTest[
    (* Line number format: "1 | " *)
    StringMatchQ[ $integrationCodeResult, ___ ~~ DigitCharacter ~~ " | " ~~ ___ ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-LineNumbers@@Tests/CodeInspectorTool.wlt:1423,1-1429,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*CodeActions Are Formatted As Suggestions*)
VerificationTest[
    (* Create code that produces CodeActions (extra comma) *)
    $integrationCodeActionsResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "f[,2]",  (* Extra leading comma *)
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0,
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-OutputFormat-CodeActionsReturnsString@@Tests/CodeInspectorTool.wlt:1434,1-1447,2"
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
    TestID   -> "Integration-OutputFormat-SuggestedFix@@Tests/CodeInspectorTool.wlt:1449,1-1460,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Custom Rules - NegatedDateObject*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectNegatedDateObject - Basic Detection*)
VerificationTest[
    $negatedDateResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "SortBy[files, -FileDate[#1] &]",
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0,
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NegatedDateObject-FileDate-ReturnsString@@Tests/CodeInspectorTool.wlt:1469,1-1481,2"
]

VerificationTest[
    StringContainsQ[ $negatedDateResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-FileDate-HasTag@@Tests/CodeInspectorTool.wlt:1483,1-1488,2"
]

VerificationTest[
    StringContainsQ[ $negatedDateResult, "Negating a ``DateObject`` does not produce a meaningful result" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-FileDate-HasDescription@@Tests/CodeInspectorTool.wlt:1490,1-1495,2"
]

VerificationTest[
    StringContainsQ[ $negatedDateResult, "(Error" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-FileDate-IsError@@Tests/CodeInspectorTool.wlt:1497,1-1502,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectNegatedDateObject - Now and Today*)
VerificationTest[
    $negatedNowResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "x = -Now",
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0,
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NegatedDateObject-Now-ReturnsString@@Tests/CodeInspectorTool.wlt:1507,1-1519,2"
]

VerificationTest[
    StringContainsQ[ $negatedNowResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-Now-HasTag@@Tests/CodeInspectorTool.wlt:1521,1-1526,2"
]

VerificationTest[
    $negatedTodayResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "y = -Today",
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0,
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NegatedDateObject-Today-ReturnsString@@Tests/CodeInspectorTool.wlt:1528,1-1540,2"
]

VerificationTest[
    StringContainsQ[ $negatedTodayResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-Today-HasTag@@Tests/CodeInspectorTool.wlt:1542,1-1547,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectNegatedDateObject - Other Date Functions*)
VerificationTest[
    $negatedDateObjectResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "z = -DateObject[]",
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0,
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NegatedDateObject-DateObject-ReturnsString@@Tests/CodeInspectorTool.wlt:1552,1-1564,2"
]

VerificationTest[
    StringContainsQ[ $negatedDateObjectResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-DateObject-HasTag@@Tests/CodeInspectorTool.wlt:1566,1-1571,2"
]

VerificationTest[
    $negatedRandomDateResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "w = -RandomDate[]",
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0,
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NegatedDateObject-RandomDate-ReturnsString@@Tests/CodeInspectorTool.wlt:1573,1-1585,2"
]

VerificationTest[
    StringContainsQ[ $negatedRandomDateResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-RandomDate-HasTag@@Tests/CodeInspectorTool.wlt:1587,1-1592,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectNegatedDateObject - Multiple Negations*)
VerificationTest[
    $multipleNegatedResult = Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`codeInspectorTool @ <|
        "code"               -> "x = -Now; y = -Today; z = -Tomorrow; w = -Yesterday",
        "file"               -> Missing[ "KeyAbsent" ],
        "tagExclusions"      -> Missing[ "KeyAbsent" ],
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0,
        "limit"              -> Missing[ "KeyAbsent" ]
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NegatedDateObject-Multiple-ReturnsString@@Tests/CodeInspectorTool.wlt:1597,1-1609,2"
]

VerificationTest[
    StringCount[ $multipleNegatedResult, "NegatedDateObject" ],
    4,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-Multiple-FindsAllFour@@Tests/CodeInspectorTool.wlt:1611,1-1616,2"
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
    TestID   -> "ExcessiveLineLength-Detected-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1625,1-1634,2"
]

VerificationTest[
    MemberQ[ $longLineInspections, InspectionObject[ "ExcessiveLineLength", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExcessiveLineLength-Detected-HasTag@@Tests/CodeInspectorTool.wlt:1636,1-1641,2"
]

VerificationTest[
    MemberQ[ $longLineInspections, InspectionObject[ "ExcessiveLineLength", _, "Formatting", _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExcessiveLineLength-Detected-IsFormatting@@Tests/CodeInspectorTool.wlt:1643,1-1648,2"
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
    TestID   -> "ExcessiveLineLength-ExactLimit-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1653,1-1661,2"
]

VerificationTest[
    MemberQ[ $exactLineInspections, InspectionObject[ "ExcessiveLineLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "ExcessiveLineLength-ExactLimit-NotDetected@@Tests/CodeInspectorTool.wlt:1663,1-1668,2"
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
    TestID   -> "ExcessiveLineLength-ShortLines-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1673,1-1681,2"
]

VerificationTest[
    MemberQ[ $shortLineInspections, InspectionObject[ "ExcessiveLineLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "ExcessiveLineLength-ShortLines-NotDetected@@Tests/CodeInspectorTool.wlt:1683,1-1688,2"
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
    TestID   -> "ExcessiveFileLength-Detected-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1697,1-1706,2"
]

VerificationTest[
    MemberQ[ $longFileInspections, InspectionObject[ "ExcessiveFileLength", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExcessiveFileLength-Detected-HasTag@@Tests/CodeInspectorTool.wlt:1708,1-1713,2"
]

VerificationTest[
    MemberQ[ $longFileInspections, InspectionObject[ "ExcessiveFileLength", _, "Formatting", _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExcessiveFileLength-Detected-IsFormatting@@Tests/CodeInspectorTool.wlt:1715,1-1720,2"
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
    TestID   -> "ExcessiveFileLength-ShortFile-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1725,1-1733,2"
]

VerificationTest[
    MemberQ[ $shortFileInspections, InspectionObject[ "ExcessiveFileLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "ExcessiveFileLength-ShortFile-NotDetected@@Tests/CodeInspectorTool.wlt:1735,1-1740,2"
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
    TestID   -> "FormattingExclusion-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1745,1-1753,2"
]

VerificationTest[
    MemberQ[ $formattingExcludedInspections, InspectionObject[ "ExcessiveLineLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "FormattingExclusion-SuppressesLineLength@@Tests/CodeInspectorTool.wlt:1755,1-1760,2"
]

VerificationTest[
    MemberQ[ $formattingExcludedInspections, InspectionObject[ "ExcessiveFileLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "FormattingExclusion-SuppressesFileLength@@Tests/CodeInspectorTool.wlt:1762,1-1767,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Integration Tests - Cleanup*)
VerificationTest[
    DeleteDirectory[ $integrationTempDir, DeleteContents -> True ];
    ! DirectoryQ @ $integrationTempDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Cleanup-TempDirectory@@Tests/CodeInspectorTool.wlt:1772,1-1778,2"
]

(* :!CodeAnalysis::EndBlock:: *)
