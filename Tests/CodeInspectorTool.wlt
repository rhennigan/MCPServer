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
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ "0.5" ],
    0.5,
    SameTest -> SameQ,
    TestID   -> "ParseConfidenceLevel-Valid@@Tests/CodeInspectorTool.wlt:132,1-137,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ "0.95" ],
    0.95,
    SameTest -> SameQ,
    TestID   -> "ParseConfidenceLevel-HighValue@@Tests/CodeInspectorTool.wlt:139,1-144,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ "invalid" ],
    0.75,
    SameTest -> SameQ,
    TestID   -> "ParseConfidenceLevel-Invalid@@Tests/CodeInspectorTool.wlt:146,1-151,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ "1.5" ],
    0.75,
    SameTest -> SameQ,
    TestID   -> "ParseConfidenceLevel-OutOfRange@@Tests/CodeInspectorTool.wlt:153,1-158,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseLimit*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseLimit[ Missing[ "KeyAbsent" ] ],
    100,
    SameTest -> SameQ,
    TestID   -> "ParseLimit-Missing@@Tests/CodeInspectorTool.wlt:163,1-168,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseLimit[ 50 ],
    50,
    SameTest -> SameQ,
    TestID   -> "ParseLimit-Valid@@Tests/CodeInspectorTool.wlt:170,1-175,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseLimit[ -5 ],
    100,
    SameTest -> SameQ,
    TestID   -> "ParseLimit-Negative@@Tests/CodeInspectorTool.wlt:177,1-182,2"
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
    TestID   -> "ValidateInput-CodeString@@Tests/CodeInspectorTool.wlt:191,1-196,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ Missing[ "KeyAbsent" ], $InstallationDirectory ],
    $InstallationDirectory,
    SameTest -> SameQ,
    TestID   -> "ValidateInput-Directory@@Tests/CodeInspectorTool.wlt:198,1-203,2"
]

VerificationTest[
    (* Use a file from the MCPServer paclet that's guaranteed to exist *)
    $testFile = FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" };
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ Missing[ "KeyAbsent" ], $testFile ],
    File[ $testFile ],
    SameTest -> MatchQ,
    TestID   -> "ValidateInput-File@@Tests/CodeInspectorTool.wlt:205,1-212,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ Missing[ "KeyAbsent" ], Missing[ "KeyAbsent" ] ],
    _Failure,
    { MCPServer::CodeInspectorNoInput },
    SameTest -> MatchQ,
    TestID   -> "ValidateInput-NoInput@@Tests/CodeInspectorTool.wlt:214,1-220,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ "code", "file" ],
    _Failure,
    { MCPServer::CodeInspectorAmbiguousInput },
    SameTest -> MatchQ,
    TestID   -> "ValidateInput-BothInputs@@Tests/CodeInspectorTool.wlt:222,1-228,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`validateAndNormalizeInput[ Missing[ "KeyAbsent" ], "/nonexistent/path/file.wl" ],
    _Failure,
    { MCPServer::CodeInspectorFileNotFound },
    SameTest -> MatchQ,
    TestID   -> "ValidateInput-FileNotFound@@Tests/CodeInspectorTool.wlt:230,1-236,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Inspection Filtering*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*passesFilters*)
VerificationTest[
    $testInspection = InspectionObject[
        "DuplicateClauses",
        "Both branches of ``If`` are the same.",
        "Warning",
        <| ConfidenceLevel -> 0.95 |>
    ];
    Wolfram`MCPServer`Tools`CodeInspector`Private`passesFilters[ $testInspection, { }, { }, 0.5 ],
    True,
    SameTest -> SameQ,
    TestID   -> "PassesFilters-NoExclusions@@Tests/CodeInspectorTool.wlt:245,1-256,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`passesFilters[ $testInspection, { "DuplicateClauses" }, { }, 0.5 ],
    False,
    SameTest -> SameQ,
    TestID   -> "PassesFilters-TagExcluded@@Tests/CodeInspectorTool.wlt:258,1-263,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`passesFilters[ $testInspection, { }, { "Warning" }, 0.5 ],
    False,
    SameTest -> SameQ,
    TestID   -> "PassesFilters-SeverityExcluded@@Tests/CodeInspectorTool.wlt:265,1-270,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`passesFilters[ $testInspection, { }, { }, 0.99 ],
    False,
    SameTest -> SameQ,
    TestID   -> "PassesFilters-BelowConfidence@@Tests/CodeInspectorTool.wlt:272,1-277,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`passesFilters[ $testInspection, { }, { }, 0.95 ],
    True,
    SameTest -> SameQ,
    TestID   -> "PassesFilters-AtConfidence@@Tests/CodeInspectorTool.wlt:279,1-284,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*filterInspections*)
VerificationTest[
    $testInspections = {
        InspectionObject[ "Tag1", "Desc1", "Error", <| ConfidenceLevel -> 0.9 |> ],
        InspectionObject[ "Tag2", "Desc2", "Warning", <| ConfidenceLevel -> 0.8 |> ],
        InspectionObject[ "Tag3", "Desc3", "Remark", <| ConfidenceLevel -> 0.7 |> ]
    };
    Wolfram`MCPServer`Tools`CodeInspector`Private`filterInspections[
        $testInspections,
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    { _InspectionObject, _InspectionObject, _InspectionObject },
    SameTest -> MatchQ,
    TestID   -> "FilterInspections-NoFilter@@Tests/CodeInspectorTool.wlt:289,1-302,2"
]

VerificationTest[
    Length @ Wolfram`MCPServer`Tools`CodeInspector`Private`filterInspections[
        $testInspections,
        <| "tagExclusions" -> { "Tag2" }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    2,
    SameTest -> SameQ,
    TestID   -> "FilterInspections-TagFilter@@Tests/CodeInspectorTool.wlt:304,1-312,2"
]

VerificationTest[
    Length @ Wolfram`MCPServer`Tools`CodeInspector`Private`filterInspections[
        $testInspections,
        <| "tagExclusions" -> { }, "severityExclusions" -> { "Remark" }, "confidenceLevel" -> 0.5 |>
    ],
    2,
    SameTest -> SameQ,
    TestID   -> "FilterInspections-SeverityFilter@@Tests/CodeInspectorTool.wlt:314,1-322,2"
]

VerificationTest[
    Length @ Wolfram`MCPServer`Tools`CodeInspector`Private`filterInspections[
        $testInspections,
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.85 |>
    ],
    1,
    SameTest -> SameQ,
    TestID   -> "FilterInspections-ConfidenceFilter@@Tests/CodeInspectorTool.wlt:324,1-332,2"
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
    TestID   -> "RunInspection-CodeString@@Tests/CodeInspectorTool.wlt:341,1-349,2"
]

VerificationTest[
    (* The code "If[a, b, b]" should produce at least one DuplicateClauses inspection *)
    MemberQ[ $codeResult, InspectionObject[ "DuplicateClauses", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "RunInspection-FindsDuplicateClauses@@Tests/CodeInspectorTool.wlt:351,1-357,2"
]

VerificationTest[
    (* Clean code should return empty list *)
    Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "f[x_] := x + 1",
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    { },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-CleanCode@@Tests/CodeInspectorTool.wlt:359,1-368,2"
]

VerificationTest[
    (* Test with severity exclusions *)
    $filteredResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "If[a, b, b]",
        <| "tagExclusions" -> { }, "severityExclusions" -> { "Warning", "Error" }, "confidenceLevel" -> 0.5 |>
    ],
    { },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-WithSeverityExclusions@@Tests/CodeInspectorTool.wlt:370,1-379,2"
]

VerificationTest[
    (* Test with tag exclusions *)
    $tagFilteredResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "If[a, b, b]",
        <| "tagExclusions" -> { "DuplicateClauses" }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    { },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-WithTagExclusions@@Tests/CodeInspectorTool.wlt:381,1-390,2"
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
    TestID   -> "RunInspection-CreateTestFile@@Tests/CodeInspectorTool.wlt:395,1-404,2"
]

VerificationTest[
    $fileResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        File[ $testWLFile ],
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    { _InspectionObject .. },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-File@@Tests/CodeInspectorTool.wlt:406,1-414,2"
]

VerificationTest[
    MemberQ[ $fileResult, InspectionObject[ "DuplicateClauses", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "RunInspection-FileFindsIssues@@Tests/CodeInspectorTool.wlt:416,1-421,2"
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
    TestID   -> "RunInspection-CreateSecondTestFile@@Tests/CodeInspectorTool.wlt:426,1-434,2"
]

VerificationTest[
    $dirResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        $tempDir,
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    _Association,
    SameTest -> MatchQ,
    TestID   -> "RunInspection-DirectoryReturnsAssociation@@Tests/CodeInspectorTool.wlt:436,1-444,2"
]

VerificationTest[
    Length @ Keys @ $dirResult,
    2,
    SameTest -> SameQ,
    TestID   -> "RunInspection-DirectoryFindsAllFiles@@Tests/CodeInspectorTool.wlt:446,1-451,2"
]

VerificationTest[
    AllTrue[ Values @ $dirResult, MatchQ[ { ___InspectionObject } ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "RunInspection-DirectoryAllInspectionObjects@@Tests/CodeInspectorTool.wlt:453,1-458,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup Test Files*)
VerificationTest[
    DeleteDirectory[ $tempDir, DeleteContents -> True ];
    ! DirectoryQ @ $tempDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Cleanup-TempDirectory@@Tests/CodeInspectorTool.wlt:463,1-469,2"
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
    TestID   -> "SummaryTable-ReturnsString@@Tests/CodeInspectorTool.wlt:478,1-487,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "## Summary" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-HasHeader@@Tests/CodeInspectorTool.wlt:489,1-494,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "| Error | 2 |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-CountsErrors@@Tests/CodeInspectorTool.wlt:496,1-501,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "| Warning | 1 |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-CountsWarnings@@Tests/CodeInspectorTool.wlt:503,1-508,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "| **Total** | **3** |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-ShowsTotal@@Tests/CodeInspectorTool.wlt:510,1-515,2"
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
    TestID   -> "FormatLocation-CodeStringRange@@Tests/CodeInspectorTool.wlt:520,1-528,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatLocation[
        "x",
        { { 1, 1 }, { 1, 1 } }
    ],
    "Line 1, Column 1",
    SameTest -> SameQ,
    TestID   -> "FormatLocation-CodeStringSinglePoint@@Tests/CodeInspectorTool.wlt:530,1-538,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatLocation[
        File[ "/path/to/file.wl" ],
        { { 42, 7 }, { 42, 15 } }
    ],
    "`file.wl:42:7`",
    SameTest -> SameQ,
    TestID   -> "FormatLocation-File@@Tests/CodeInspectorTool.wlt:540,1-548,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatLocation[
        "code",
        Missing[ "NotAvailable" ]
    ],
    "Unknown",
    SameTest -> SameQ,
    TestID   -> "FormatLocation-Missing@@Tests/CodeInspectorTool.wlt:550,1-558,2"
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
    TestID   -> "ExtractCodeSnippet-ReturnsString@@Tests/CodeInspectorTool.wlt:563,1-572,2"
]

VerificationTest[
    StringContainsQ[ $snippetResult, "**Code:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-HasCodeHeader@@Tests/CodeInspectorTool.wlt:574,1-579,2"
]

VerificationTest[
    StringContainsQ[ $snippetResult, "```wl" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-HasCodeBlock@@Tests/CodeInspectorTool.wlt:581,1-586,2"
]

VerificationTest[
    StringContainsQ[ $snippetResult, "(* <- issue here *)" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-HasIssueMarker@@Tests/CodeInspectorTool.wlt:588,1-593,2"
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
    TestID   -> "ExtractCodeSnippet-ShowsContextBefore@@Tests/CodeInspectorTool.wlt:595,1-606,2"
]

VerificationTest[
    StringContainsQ[ $multiLineSnippet, "4 | line4" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-ShowsContextAfter@@Tests/CodeInspectorTool.wlt:608,1-613,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`extractCodeSnippet[
        "code",
        Missing[ "NotAvailable" ],
        1
    ],
    "",
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-MissingLocationReturnsEmpty@@Tests/CodeInspectorTool.wlt:615,1-624,2"
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
    TestID   -> "FormatInspection-ReturnsString@@Tests/CodeInspectorTool.wlt:629,1-643,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "### Issue 1: DuplicateClauses" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-HasHeader@@Tests/CodeInspectorTool.wlt:645,1-650,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "(Error, 95%)" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-ShowsSeverityAndConfidence@@Tests/CodeInspectorTool.wlt:652,1-657,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "**Location:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-HasLocation@@Tests/CodeInspectorTool.wlt:659,1-664,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "**Description:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-HasDescription@@Tests/CodeInspectorTool.wlt:666,1-671,2"
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
    TestID   -> "InspectionsToMarkdown-NoIssuesReturnsString@@Tests/CodeInspectorTool.wlt:676,1-685,2"
]

VerificationTest[
    StringContainsQ[ $noIssuesResult, "No issues found matching the specified criteria." ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-NoIssuesMessage@@Tests/CodeInspectorTool.wlt:687,1-692,2"
]

VerificationTest[
    StringContainsQ[ $noIssuesResult, "Confidence Level: 0.75" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsConfidenceLevel@@Tests/CodeInspectorTool.wlt:694,1-699,2"
]

VerificationTest[
    StringContainsQ[ $noIssuesResult, "Severity Exclusions: Formatting" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsSeverityExclusions@@Tests/CodeInspectorTool.wlt:701,1-706,2"
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
    TestID   -> "InspectionsToMarkdown-WithIssuesReturnsString@@Tests/CodeInspectorTool.wlt:711,1-727,2"
]

VerificationTest[
    StringContainsQ[ $withIssuesResult, "# Code Inspection Results" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-HasMainHeader@@Tests/CodeInspectorTool.wlt:729,1-734,2"
]

VerificationTest[
    StringContainsQ[ $withIssuesResult, "## Summary" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-HasSummary@@Tests/CodeInspectorTool.wlt:736,1-741,2"
]

VerificationTest[
    StringContainsQ[ $withIssuesResult, "## Issues" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-HasIssuesSection@@Tests/CodeInspectorTool.wlt:743,1-748,2"
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
    TestID   -> "InspectionsToMarkdown-TruncationReturnsString@@Tests/CodeInspectorTool.wlt:753,1-765,2"
]

VerificationTest[
    StringContainsQ[ $truncatedResult, "Showing 5 of 10 issues" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsTruncationNotice@@Tests/CodeInspectorTool.wlt:767,1-772,2"
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
    TestID   -> "InspectionsToMarkdown-FileSourceReturnsString@@Tests/CodeInspectorTool.wlt:777,1-793,2"
]

VerificationTest[
    StringContainsQ[ $fileSourceResult, "**File:** `/path/to/test.wl`" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsFileHeader@@Tests/CodeInspectorTool.wlt:795,1-800,2"
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
    TestID   -> "FormatCodeActions-EmptyList@@Tests/CodeInspectorTool.wlt:809,1-814,2"
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
    TestID   -> "FormatCodeActions-SingleAction-ReturnsString@@Tests/CodeInspectorTool.wlt:819,1-826,2"
]

VerificationTest[
    StringContainsQ[ $singleActionResult, "**Suggested Fix:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-SingleAction-HasHeader@@Tests/CodeInspectorTool.wlt:828,1-833,2"
]

VerificationTest[
    StringContainsQ[ $singleActionResult, "Delete `,`" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-SingleAction-HasLabel@@Tests/CodeInspectorTool.wlt:835,1-840,2"
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
    TestID   -> "FormatCodeActions-MultipleActions-ReturnsString@@Tests/CodeInspectorTool.wlt:845,1-853,2"
]

VerificationTest[
    StringContainsQ[ $multiActionResult, "**Suggested Fixes:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-MultipleActions-HasPluralHeader@@Tests/CodeInspectorTool.wlt:855,1-860,2"
]

VerificationTest[
    StringCount[ $multiActionResult, "- Insert" ],
    2,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-MultipleActions-HasTwoActions@@Tests/CodeInspectorTool.wlt:862,1-867,2"
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
    TestID   -> "FormatSingleCodeAction-ReplaceNode@@Tests/CodeInspectorTool.wlt:872,1-879,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatSingleCodeAction[
        CodeParser`CodeAction[ "Delete key 1", CodeParser`DeleteNode, <| CodeParser`Source -> { { 1, 1 }, { 1, 5 } } |> ]
    ],
    _String ? (StringContainsQ[ #, "Delete key 1" ] &),
    SameTest -> MatchQ,
    TestID   -> "FormatSingleCodeAction-DeleteNode@@Tests/CodeInspectorTool.wlt:881,1-888,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatSingleCodeAction[ "invalid" ],
    "",
    SameTest -> SameQ,
    TestID   -> "FormatSingleCodeAction-Invalid@@Tests/CodeInspectorTool.wlt:890,1-895,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*codeActionCommandToString*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`ReplaceText ],
    "Replace with",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-ReplaceText@@Tests/CodeInspectorTool.wlt:900,1-905,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`DeleteText ],
    "Delete",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-DeleteText@@Tests/CodeInspectorTool.wlt:907,1-912,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`InsertText ],
    "Insert",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-InsertText@@Tests/CodeInspectorTool.wlt:914,1-919,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`ReplaceNode ],
    "Replace with",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-ReplaceNode@@Tests/CodeInspectorTool.wlt:921,1-926,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`DeleteNode ],
    "Delete",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-DeleteNode@@Tests/CodeInspectorTool.wlt:928,1-933,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`InsertNode ],
    "Insert",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-InsertNode@@Tests/CodeInspectorTool.wlt:935,1-940,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`InsertNodeAfter ],
    "Insert after",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-InsertNodeAfter@@Tests/CodeInspectorTool.wlt:942,1-947,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ UnknownCommand ],
    "UnknownCommand",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-Unknown@@Tests/CodeInspectorTool.wlt:949,1-954,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*cleanLabel*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`cleanLabel[ "Replace with ``StringQ``" ],
    "Replace with `StringQ`",
    SameTest -> SameQ,
    TestID   -> "CleanLabel-SingleBackticks@@Tests/CodeInspectorTool.wlt:959,1-964,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`cleanLabel[ "Insert ``*`` and ``+``" ],
    "Insert `*` and `+`",
    SameTest -> SameQ,
    TestID   -> "CleanLabel-MultipleBackticks@@Tests/CodeInspectorTool.wlt:966,1-971,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`cleanLabel[ "No backticks here" ],
    "No backticks here",
    SameTest -> SameQ,
    TestID   -> "CleanLabel-NoBackticks@@Tests/CodeInspectorTool.wlt:973,1-978,2"
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
                "CodeActions" -> {
                    CodeParser`CodeAction[ "Delete ``,``", CodeParser`DeleteText, <| CodeParser`Source -> { { 1, 5 }, { 1, 6 } } |> ]
                }
            |>
        ],
        1,
        "1+f[,2]"
    ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "FormatInspection-WithCodeActions-ReturnsString@@Tests/CodeInspectorTool.wlt:983,1-1004,2"
]

VerificationTest[
    StringContainsQ[ $inspectionWithActions, "**Suggested Fix:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-WithCodeActions-ShowsSuggestedFix@@Tests/CodeInspectorTool.wlt:1006,1-1011,2"
]

VerificationTest[
    StringContainsQ[ $inspectionWithActions, "Delete `,`" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-WithCodeActions-ShowsActionLabel@@Tests/CodeInspectorTool.wlt:1013,1-1018,2"
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
    TestID   -> "ErrorCase-CreateEmptyDir@@Tests/CodeInspectorTool.wlt:1027,1-1033,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        $emptyDir,
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    _Failure,
    { MCPServer::CodeInspectorNoFilesFound },
    SameTest -> MatchQ,
    TestID   -> "ErrorCase-EmptyDirectory@@Tests/CodeInspectorTool.wlt:1035,1-1044,2"
]

VerificationTest[
    DeleteDirectory[ $emptyDir ];
    ! DirectoryQ @ $emptyDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Cleanup-EmptyDirectory@@Tests/CodeInspectorTool.wlt:1046,1-1052,2"
]

(* :!CodeAnalysis::EndBlock:: *)
