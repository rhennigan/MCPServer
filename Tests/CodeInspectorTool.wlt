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

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseExclusions[ "", { "A", "B" } ],
    { },
    SameTest -> MatchQ,
    TestID   -> "ParseExclusions-EmptyWithDefault@@Tests/CodeInspectorTool.wlt:122,1-127,2"
]

(* ::**************************************************************************************************************:: *)
(*parseConfidenceLevel*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ Missing[ "KeyAbsent" ] ],
    0.75,
    SameTest -> SameQ,
    TestID   -> "ParseConfidenceLevel-Missing@@Tests/CodeInspectorTool.wlt:131,1-136,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ 0.5 ],
    0.5,
    SameTest -> SameQ,
    TestID   -> "ParseConfidenceLevel-Valid@@Tests/CodeInspectorTool.wlt:138,1-143,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ 0 ],
    0.0,
    SameTest -> SameQ,
    TestID   -> "ParseConfidenceLevel-IntegerValue@@Tests/CodeInspectorTool.wlt:145,1-150,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Tools`CodeInspector`Private`parseConfidenceLevel[ 1.5 ],
    _Failure,
    { MCPServer::CodeInspectorInvalidConfidence },
    SameTest -> MatchQ,
    TestID   -> "ParseConfidenceLevel-OutOfRange@@Tests/CodeInspectorTool.wlt:152,1-158,2"
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
    TestID   -> "RunInspection-CodeString@@Tests/CodeInspectorTool.wlt:245,1-253,2"
]

VerificationTest[
    (* The code "If[a, b, b]" should produce at least one DuplicateClauses inspection *)
    MemberQ[ $codeResult, InspectionObject[ "DuplicateClauses", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "RunInspection-FindsDuplicateClauses@@Tests/CodeInspectorTool.wlt:255,1-261,2"
]

VerificationTest[
    (* Clean code should return empty list *)
    Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "f[x_] := x + 1",
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    { },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-CleanCode@@Tests/CodeInspectorTool.wlt:263,1-272,2"
]

VerificationTest[
    (* Test with severity exclusions *)
    $filteredResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "If[a, b, b]",
        <| "tagExclusions" -> { }, "severityExclusions" -> { "Warning", "Error" }, "confidenceLevel" -> 0.5 |>
    ],
    { },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-WithSeverityExclusions@@Tests/CodeInspectorTool.wlt:274,1-283,2"
]

VerificationTest[
    (* Test with tag exclusions *)
    $tagFilteredResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        "If[a, b, b]",
        <| "tagExclusions" -> { "DuplicateClauses::If" }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    { },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-WithTagExclusions@@Tests/CodeInspectorTool.wlt:285,1-294,2"
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
    TestID   -> "RunInspection-CreateTestFile@@Tests/CodeInspectorTool.wlt:299,1-308,2"
]

VerificationTest[
    $fileResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        File[ $testWLFile ],
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    { _InspectionObject .. },
    SameTest -> MatchQ,
    TestID   -> "RunInspection-File@@Tests/CodeInspectorTool.wlt:310,1-318,2"
]

VerificationTest[
    MemberQ[ $fileResult, InspectionObject[ "DuplicateClauses", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "RunInspection-FileFindsIssues@@Tests/CodeInspectorTool.wlt:320,1-325,2"
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
    TestID   -> "RunInspection-CreateSecondTestFile@@Tests/CodeInspectorTool.wlt:330,1-338,2"
]

VerificationTest[
    $dirResult = Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        $tempDir,
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    _Association,
    SameTest -> MatchQ,
    TestID   -> "RunInspection-DirectoryReturnsAssociation@@Tests/CodeInspectorTool.wlt:340,1-348,2"
]

VerificationTest[
    Length @ Keys @ $dirResult,
    2,
    SameTest -> SameQ,
    TestID   -> "RunInspection-DirectoryFindsAllFiles@@Tests/CodeInspectorTool.wlt:350,1-355,2"
]

VerificationTest[
    AllTrue[ Values @ $dirResult, MatchQ[ { ___InspectionObject } ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "RunInspection-DirectoryAllInspectionObjects@@Tests/CodeInspectorTool.wlt:357,1-362,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup Test Files*)
VerificationTest[
    DeleteDirectory[ $tempDir, DeleteContents -> True ];
    ! DirectoryQ @ $tempDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Cleanup-TempDirectory@@Tests/CodeInspectorTool.wlt:367,1-373,2"
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
    TestID   -> "SummaryTable-ReturnsString@@Tests/CodeInspectorTool.wlt:382,1-391,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "## Summary" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-HasHeader@@Tests/CodeInspectorTool.wlt:393,1-398,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "| Error | 2 |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-CountsErrors@@Tests/CodeInspectorTool.wlt:400,1-405,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "| Warning | 1 |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-CountsWarnings@@Tests/CodeInspectorTool.wlt:407,1-412,2"
]

VerificationTest[
    StringContainsQ[ $summaryTableResult, "| **Total** | **3** |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "SummaryTable-ShowsTotal@@Tests/CodeInspectorTool.wlt:414,1-419,2"
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
    TestID   -> "FormatLocation-CodeStringRange@@Tests/CodeInspectorTool.wlt:424,1-432,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatLocation[
        "x",
        { { 1, 1 }, { 1, 1 } }
    ],
    "Line 1, Column 1",
    SameTest -> SameQ,
    TestID   -> "FormatLocation-CodeStringSinglePoint@@Tests/CodeInspectorTool.wlt:434,1-442,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatLocation[
        File[ "/path/to/file.wl" ],
        { { 42, 7 }, { 42, 15 } }
    ],
    "`file.wl:42:7`",
    SameTest -> SameQ,
    TestID   -> "FormatLocation-File@@Tests/CodeInspectorTool.wlt:444,1-452,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatLocation[
        "code",
        Missing[ "NotAvailable" ]
    ],
    "Unknown",
    SameTest -> SameQ,
    TestID   -> "FormatLocation-Missing@@Tests/CodeInspectorTool.wlt:454,1-462,2"
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
    TestID   -> "ExtractCodeSnippet-ReturnsString@@Tests/CodeInspectorTool.wlt:467,1-476,2"
]

VerificationTest[
    StringContainsQ[ $snippetResult, "**Code:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-HasCodeHeader@@Tests/CodeInspectorTool.wlt:478,1-483,2"
]

VerificationTest[
    StringContainsQ[ $snippetResult, "```wl" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-HasCodeBlock@@Tests/CodeInspectorTool.wlt:485,1-490,2"
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
    TestID   -> "ExtractCodeSnippet-ShowsContextBefore@@Tests/CodeInspectorTool.wlt:492,1-503,2"
]

VerificationTest[
    StringContainsQ[ $multiLineSnippet, "4 | line4" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-ShowsContextAfter@@Tests/CodeInspectorTool.wlt:505,1-510,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`extractCodeSnippet[
        "code",
        Missing[ "NotAvailable" ],
        1
    ],
    "",
    SameTest -> SameQ,
    TestID   -> "ExtractCodeSnippet-MissingLocationReturnsEmpty@@Tests/CodeInspectorTool.wlt:512,1-521,2"
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
    TestID   -> "FormatInspection-ReturnsString@@Tests/CodeInspectorTool.wlt:526,1-540,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "### Issue 1: DuplicateClauses" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-HasHeader@@Tests/CodeInspectorTool.wlt:542,1-547,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "(Error, 95%)" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-ShowsSeverityAndConfidence@@Tests/CodeInspectorTool.wlt:549,1-554,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "**Location:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-HasLocation@@Tests/CodeInspectorTool.wlt:556,1-561,2"
]

VerificationTest[
    StringContainsQ[ $formattedInspection, "**Description:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-HasDescription@@Tests/CodeInspectorTool.wlt:563,1-568,2"
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
    TestID   -> "InspectionsToMarkdown-NoIssuesReturnsString@@Tests/CodeInspectorTool.wlt:573,1-582,2"
]

VerificationTest[
    StringContainsQ[ $noIssuesResult, "No issues found matching the specified criteria." ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-NoIssuesMessage@@Tests/CodeInspectorTool.wlt:584,1-589,2"
]

VerificationTest[
    StringContainsQ[ $noIssuesResult, "Confidence Level: 0.75" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsConfidenceLevel@@Tests/CodeInspectorTool.wlt:591,1-596,2"
]

VerificationTest[
    StringContainsQ[ $noIssuesResult, "Severity Exclusions: Formatting" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsSeverityExclusions@@Tests/CodeInspectorTool.wlt:598,1-603,2"
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
    TestID   -> "InspectionsToMarkdown-WithIssuesReturnsString@@Tests/CodeInspectorTool.wlt:608,1-624,2"
]

VerificationTest[
    StringContainsQ[ $withIssuesResult, "# Code Inspection Results" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-HasMainHeader@@Tests/CodeInspectorTool.wlt:626,1-631,2"
]

VerificationTest[
    StringContainsQ[ $withIssuesResult, "## Summary" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-HasSummary@@Tests/CodeInspectorTool.wlt:633,1-638,2"
]

VerificationTest[
    StringContainsQ[ $withIssuesResult, "## Issues" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-HasIssuesSection@@Tests/CodeInspectorTool.wlt:640,1-645,2"
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
    TestID   -> "InspectionsToMarkdown-TruncationReturnsString@@Tests/CodeInspectorTool.wlt:650,1-662,2"
]

VerificationTest[
    StringContainsQ[ $truncatedResult, "Showing 5 of 10 issues" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsTruncationNotice@@Tests/CodeInspectorTool.wlt:664,1-669,2"
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
    TestID   -> "InspectionsToMarkdown-FileSourceReturnsString@@Tests/CodeInspectorTool.wlt:674,1-690,2"
]

VerificationTest[
    StringContainsQ[ $fileSourceResult, "**File:** `/path/to/test.wl`" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InspectionsToMarkdown-ShowsFileHeader@@Tests/CodeInspectorTool.wlt:692,1-697,2"
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
    TestID   -> "FormatCodeActions-EmptyList@@Tests/CodeInspectorTool.wlt:706,1-711,2"
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
    TestID   -> "FormatCodeActions-SingleAction-ReturnsString@@Tests/CodeInspectorTool.wlt:716,1-723,2"
]

VerificationTest[
    StringContainsQ[ $singleActionResult, "**Suggested Fix:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-SingleAction-HasHeader@@Tests/CodeInspectorTool.wlt:725,1-730,2"
]

VerificationTest[
    StringContainsQ[ $singleActionResult, "Delete `,`" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-SingleAction-HasLabel@@Tests/CodeInspectorTool.wlt:732,1-737,2"
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
    TestID   -> "FormatCodeActions-MultipleActions-ReturnsString@@Tests/CodeInspectorTool.wlt:742,1-750,2"
]

VerificationTest[
    StringContainsQ[ $multiActionResult, "**Suggested Fixes:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-MultipleActions-HasPluralHeader@@Tests/CodeInspectorTool.wlt:752,1-757,2"
]

VerificationTest[
    StringCount[ $multiActionResult, "- Insert" ],
    2,
    SameTest -> SameQ,
    TestID   -> "FormatCodeActions-MultipleActions-HasTwoActions@@Tests/CodeInspectorTool.wlt:759,1-764,2"
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
    TestID   -> "FormatSingleCodeAction-ReplaceNode@@Tests/CodeInspectorTool.wlt:769,1-776,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatSingleCodeAction[
        CodeParser`CodeAction[ "Delete key 1", CodeParser`DeleteNode, <| CodeParser`Source -> { { 1, 1 }, { 1, 5 } } |> ]
    ],
    _String ? (StringContainsQ[ #, "Delete key 1" ] &),
    SameTest -> MatchQ,
    TestID   -> "FormatSingleCodeAction-DeleteNode@@Tests/CodeInspectorTool.wlt:778,1-785,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`formatSingleCodeAction[ "invalid" ],
    "",
    SameTest -> SameQ,
    TestID   -> "FormatSingleCodeAction-Invalid@@Tests/CodeInspectorTool.wlt:787,1-792,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*codeActionCommandToString*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`ReplaceText ],
    "Replace with",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-ReplaceText@@Tests/CodeInspectorTool.wlt:797,1-802,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`DeleteText ],
    "Delete",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-DeleteText@@Tests/CodeInspectorTool.wlt:804,1-809,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`InsertText ],
    "Insert",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-InsertText@@Tests/CodeInspectorTool.wlt:811,1-816,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`ReplaceNode ],
    "Replace with",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-ReplaceNode@@Tests/CodeInspectorTool.wlt:818,1-823,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`DeleteNode ],
    "Delete",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-DeleteNode@@Tests/CodeInspectorTool.wlt:825,1-830,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`InsertNode ],
    "Insert",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-InsertNode@@Tests/CodeInspectorTool.wlt:832,1-837,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ CodeParser`InsertNodeAfter ],
    "Insert after",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-InsertNodeAfter@@Tests/CodeInspectorTool.wlt:839,1-844,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`codeActionCommandToString[ UnknownCommand ],
    "UnknownCommand",
    SameTest -> SameQ,
    TestID   -> "CodeActionCommandToString-Unknown@@Tests/CodeInspectorTool.wlt:846,1-851,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*cleanLabel*)
VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`cleanLabel[ "Replace with ``StringQ``" ],
    "Replace with `StringQ`",
    SameTest -> SameQ,
    TestID   -> "CleanLabel-SingleBackticks@@Tests/CodeInspectorTool.wlt:856,1-861,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`cleanLabel[ "Insert ``*`` and ``+``" ],
    "Insert `*` and `+`",
    SameTest -> SameQ,
    TestID   -> "CleanLabel-MultipleBackticks@@Tests/CodeInspectorTool.wlt:863,1-868,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`cleanLabel[ "No backticks here" ],
    "No backticks here",
    SameTest -> SameQ,
    TestID   -> "CleanLabel-NoBackticks@@Tests/CodeInspectorTool.wlt:870,1-875,2"
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
    TestID   -> "FormatInspection-WithCodeActions-ReturnsString@@Tests/CodeInspectorTool.wlt:880,1-901,2"
]

VerificationTest[
    StringContainsQ[ $inspectionWithActions, "**Suggested Fix:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-WithCodeActions-ShowsSuggestedFix@@Tests/CodeInspectorTool.wlt:903,1-908,2"
]

VerificationTest[
    StringContainsQ[ $inspectionWithActions, "Delete `,`" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatInspection-WithCodeActions-ShowsActionLabel@@Tests/CodeInspectorTool.wlt:910,1-915,2"
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
    TestID   -> "ErrorCase-CreateEmptyDir@@Tests/CodeInspectorTool.wlt:924,1-930,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`CodeInspector`Private`runInspection[
        $emptyDir,
        <| "tagExclusions" -> { }, "severityExclusions" -> { }, "confidenceLevel" -> 0.5 |>
    ],
    _Failure,
    { MCPServer::CodeInspectorNoFilesFound },
    SameTest -> MatchQ,
    TestID   -> "ErrorCase-EmptyDirectory@@Tests/CodeInspectorTool.wlt:932,1-941,2"
]

VerificationTest[
    DeleteDirectory[ $emptyDir ];
    ! DirectoryQ @ $emptyDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Cleanup-EmptyDirectory@@Tests/CodeInspectorTool.wlt:943,1-949,2"
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
    TestID   -> "Integration-CodeStringWithIssues-ReturnsString@@Tests/CodeInspectorTool.wlt:958,1-966,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "# Code Inspection Results" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CodeStringWithIssues-HasHeader@@Tests/CodeInspectorTool.wlt:968,1-973,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "DuplicateClauses" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CodeStringWithIssues-FindsDuplicateClauses@@Tests/CodeInspectorTool.wlt:975,1-980,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "## Summary" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CodeStringWithIssues-HasSummary@@Tests/CodeInspectorTool.wlt:982,1-987,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "## Issues" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CodeStringWithIssues-HasIssuesSection@@Tests/CodeInspectorTool.wlt:989,1-994,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Clean Code Returns No Issues Found*)
VerificationTest[
    $integrationCleanResult = CodeInspectorToolFunction @ <| "code" -> "f[x_] := x + 1" |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-CleanCode-ReturnsString@@Tests/CodeInspectorTool.wlt:999,1-1004,2"
]

VerificationTest[
    StringContainsQ[ $integrationCleanResult, "No issues found matching the specified criteria." ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CleanCode-ShowsNoIssuesMessage@@Tests/CodeInspectorTool.wlt:1006,1-1011,2"
]

VerificationTest[
    StringContainsQ[ $integrationCleanResult, "**Settings:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-CleanCode-ShowsSettings@@Tests/CodeInspectorTool.wlt:1013,1-1018,2"
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
    TestID   -> "Integration-SingleFile-CreateTestFile@@Tests/CodeInspectorTool.wlt:1023,1-1031,2"
]

VerificationTest[
    $integrationFileResult = CodeInspectorToolFunction @ <|
        "file"               -> $integrationTestFile,
        "severityExclusions" -> ""
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-SingleFile-ReturnsString@@Tests/CodeInspectorTool.wlt:1033,1-1041,2"
]

VerificationTest[
    StringContainsQ[ $integrationFileResult, "**File:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-SingleFile-ShowsFileHeader@@Tests/CodeInspectorTool.wlt:1043,1-1048,2"
]

VerificationTest[
    StringContainsQ[ $integrationFileResult, "DuplicateClauses" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-SingleFile-FindsIssues@@Tests/CodeInspectorTool.wlt:1050,1-1055,2"
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
    TestID   -> "Integration-Directory-CreateSecondTestFile@@Tests/CodeInspectorTool.wlt:1060,1-1067,2"
]

VerificationTest[
    $integrationDirResult = CodeInspectorToolFunction @ <|
        "file"               -> $integrationTempDir,
        "severityExclusions" -> ""
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "Integration-Directory-ReturnsString@@Tests/CodeInspectorTool.wlt:1069,1-1077,2"
]

VerificationTest[
    StringContainsQ[ $integrationDirResult, "**Directory:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Directory-ShowsDirectoryHeader@@Tests/CodeInspectorTool.wlt:1079,1-1084,2"
]

VerificationTest[
    StringContainsQ[ $integrationDirResult, "**Files inspected:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Directory-ShowsFileCount@@Tests/CodeInspectorTool.wlt:1086,1-1091,2"
]

VerificationTest[
    StringContainsQ[ $integrationDirResult, "testfile.wl" ] && StringContainsQ[ $integrationDirResult, "testfile2.wl" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Directory-ShowsBothFiles@@Tests/CodeInspectorTool.wlt:1093,1-1098,2"
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
    TestID   -> "Integration-TagExclusions-ReturnsString@@Tests/CodeInspectorTool.wlt:1107,1-1117,2"
]

VerificationTest[
    (* When DuplicateClauses is excluded, we should see "No issues found" for this code *)
    StringContainsQ[ $integrationTagExcludeResult, "No issues found matching the specified criteria." ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-TagExclusions-ExcludesDuplicateClauses@@Tests/CodeInspectorTool.wlt:1119,1-1125,2"
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
    TestID   -> "Integration-SeverityExclusions-ReturnsString@@Tests/CodeInspectorTool.wlt:1130,1-1139,2"
]

VerificationTest[
    (* DuplicateClauses is typically Warning or Error, so excluding both should filter it out *)
    StringContainsQ[ $integrationSeverityExcludeResult, "No issues found matching the specified criteria." ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-SeverityExclusions-FiltersCorrectly@@Tests/CodeInspectorTool.wlt:1141,1-1147,2"
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
    TestID   -> "Integration-ConfidenceLevel-HighThreshold-ReturnsString@@Tests/CodeInspectorTool.wlt:1152,1-1162,2"
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
    TestID   -> "Integration-ConfidenceLevel-LowThreshold-ReturnsString@@Tests/CodeInspectorTool.wlt:1164,1-1174,2"
]

VerificationTest[
    StringContainsQ[ $integrationLowConfResult, "DuplicateClauses" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-ConfidenceLevel-LowThreshold-FindsIssues@@Tests/CodeInspectorTool.wlt:1176,1-1181,2"
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
    TestID   -> "Integration-Limit-ReturnsString@@Tests/CodeInspectorTool.wlt:1186,1-1197,2"
]

VerificationTest[
    (* Should have "Issue 1" but not "Issue 2" (due to limit) *)
    StringContainsQ[ $integrationLimitResult, "### Issue 1:" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Limit-ShowsFirstIssue@@Tests/CodeInspectorTool.wlt:1199,1-1205,2"
]

VerificationTest[
    (* Should show truncation notice *)
    StringContainsQ[ $integrationLimitResult, "Showing 1 of" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Limit-ShowsTruncationNotice@@Tests/CodeInspectorTool.wlt:1207,1-1213,2"
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
    TestID   -> "Integration-Error-NoInput@@Tests/CodeInspectorTool.wlt:1222,1-1228,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error When Both code and file Provided*)
VerificationTest[
    CodeInspectorToolFunction @ <| "code" -> "f[x_] := x", "file" -> $integrationTestFile |>,
    _Failure,
    { CodeInspectorToolFunction::CodeInspectorAmbiguousInput },
    SameTest -> MatchQ,
    TestID   -> "Integration-Error-BothInputs@@Tests/CodeInspectorTool.wlt:1233,1-1239,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error For Non-Existent File*)
VerificationTest[
    CodeInspectorToolFunction @ <| "file" -> "/nonexistent/path/to/file.wl" |>,
    _Failure,
    { CodeInspectorToolFunction::CodeInspectorFileNotFound },
    SameTest -> MatchQ,
    TestID   -> "Integration-Error-FileNotFound@@Tests/CodeInspectorTool.wlt:1244,1-1250,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error For Directory With No Matching Files*)
VerificationTest[
    $integrationEmptyDir = CreateDirectory[ ];
    DirectoryQ @ $integrationEmptyDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Error-CreateEmptyDir@@Tests/CodeInspectorTool.wlt:1255,1-1261,2"
]

VerificationTest[
    CodeInspectorToolFunction @ <| "file" -> $integrationEmptyDir |>,
    _Failure,
    { CodeInspectorToolFunction::CodeInspectorNoFilesFound },
    SameTest -> MatchQ,
    TestID   -> "Integration-Error-EmptyDirectory@@Tests/CodeInspectorTool.wlt:1263,1-1269,2"
]

VerificationTest[
    DeleteDirectory[ $integrationEmptyDir ];
    ! DirectoryQ @ $integrationEmptyDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Cleanup-EmptyDir@@Tests/CodeInspectorTool.wlt:1271,1-1277,2"
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
    TestID   -> "Integration-OutOfRangeConfidence-ReturnsFailure@@Tests/CodeInspectorTool.wlt:1282,1-1289,2"
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
    TestID   -> "Integration-OutputFormat-SummaryTableHeaders@@Tests/CodeInspectorTool.wlt:1298,1-1304,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "|----------|-------|" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-SummaryTableSeparator@@Tests/CodeInspectorTool.wlt:1306,1-1311,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "| **Total** |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-SummaryTableTotal@@Tests/CodeInspectorTool.wlt:1313,1-1318,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Issue Markdown Structure Is Correct*)
VerificationTest[
    (* Issue should have proper header format *)
    StringMatchQ[ $integrationCodeResult, ___ ~~ "### Issue " ~~ DigitCharacter ~~ ": " ~~ ___ ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-IssueHeader@@Tests/CodeInspectorTool.wlt:1323,1-1329,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "**Location:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-IssueLocation@@Tests/CodeInspectorTool.wlt:1331,1-1336,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "**Description:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-IssueDescription@@Tests/CodeInspectorTool.wlt:1338,1-1343,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Code Snippets Include Line Numbers and Context*)
VerificationTest[
    StringContainsQ[ $integrationCodeResult, "**Code:**" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-CodeHeader@@Tests/CodeInspectorTool.wlt:1348,1-1353,2"
]

VerificationTest[
    StringContainsQ[ $integrationCodeResult, "```wl" ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-CodeBlockStart@@Tests/CodeInspectorTool.wlt:1355,1-1360,2"
]

VerificationTest[
    (* Line number format: "1 | " *)
    StringMatchQ[ $integrationCodeResult, ___ ~~ DigitCharacter ~~ " | " ~~ ___ ],
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-OutputFormat-LineNumbers@@Tests/CodeInspectorTool.wlt:1362,1-1368,2"
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
    TestID   -> "Integration-OutputFormat-CodeActionsReturnsString@@Tests/CodeInspectorTool.wlt:1373,1-1383,2"
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
    TestID   -> "Integration-OutputFormat-SuggestedFix@@Tests/CodeInspectorTool.wlt:1385,1-1396,2"
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
    TestID   -> "NegatedDateObject-FileDate-ReturnsString@@Tests/CodeInspectorTool.wlt:1405,1-1414,2"
]

VerificationTest[
    StringContainsQ[ $negatedDateResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-FileDate-HasTag@@Tests/CodeInspectorTool.wlt:1416,1-1421,2"
]

VerificationTest[
    StringContainsQ[ $negatedDateResult, "Negating a ``DateObject`` does not produce a meaningful result" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-FileDate-HasDescription@@Tests/CodeInspectorTool.wlt:1423,1-1428,2"
]

VerificationTest[
    StringContainsQ[ $negatedDateResult, "(Error" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-FileDate-IsError@@Tests/CodeInspectorTool.wlt:1430,1-1435,2"
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
    TestID   -> "NegatedDateObject-Now-ReturnsString@@Tests/CodeInspectorTool.wlt:1440,1-1449,2"
]

VerificationTest[
    StringContainsQ[ $negatedNowResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-Now-HasTag@@Tests/CodeInspectorTool.wlt:1451,1-1456,2"
]

VerificationTest[
    $negatedTodayResult = CodeInspectorToolFunction @ <|
        "code"               -> "y = -Today",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NegatedDateObject-Today-ReturnsString@@Tests/CodeInspectorTool.wlt:1458,1-1467,2"
]

VerificationTest[
    StringContainsQ[ $negatedTodayResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-Today-HasTag@@Tests/CodeInspectorTool.wlt:1469,1-1474,2"
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
    TestID   -> "NegatedDateObject-DateObject-ReturnsString@@Tests/CodeInspectorTool.wlt:1479,1-1488,2"
]

VerificationTest[
    StringContainsQ[ $negatedDateObjectResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-DateObject-HasTag@@Tests/CodeInspectorTool.wlt:1490,1-1495,2"
]

VerificationTest[
    $negatedRandomDateResult = CodeInspectorToolFunction @ <|
        "code"               -> "w = -RandomDate[]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "NegatedDateObject-RandomDate-ReturnsString@@Tests/CodeInspectorTool.wlt:1497,1-1506,2"
]

VerificationTest[
    StringContainsQ[ $negatedRandomDateResult, "NegatedDateObject" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-RandomDate-HasTag@@Tests/CodeInspectorTool.wlt:1508,1-1513,2"
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
    TestID   -> "NegatedDateObject-Multiple-ReturnsString@@Tests/CodeInspectorTool.wlt:1518,1-1527,2"
]

VerificationTest[
    StringCount[ $multipleNegatedResult, "NegatedDateObject" ],
    4,
    SameTest -> SameQ,
    TestID   -> "NegatedDateObject-Multiple-FindsAllFour@@Tests/CodeInspectorTool.wlt:1529,1-1534,2"
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
    TestID   -> "ReadStringCharacterEncoding-Basic-ReturnsString@@Tests/CodeInspectorTool.wlt:1543,1-1552,2"
]

VerificationTest[
    StringContainsQ[ $readStringResult, "ReadStringCharacterEncoding" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ReadStringCharacterEncoding-Basic-HasTag@@Tests/CodeInspectorTool.wlt:1554,1-1559,2"
]

VerificationTest[
    StringContainsQ[ $readStringResult, "``ReadString`` does not support the ``CharacterEncoding`` option" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ReadStringCharacterEncoding-Basic-HasDescription@@Tests/CodeInspectorTool.wlt:1561,1-1566,2"
]

VerificationTest[
    StringContainsQ[ $readStringResult, "(Error" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ReadStringCharacterEncoding-Basic-IsError@@Tests/CodeInspectorTool.wlt:1568,1-1573,2"
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
    TestID   -> "ReadStringCharacterEncoding-NoFalsePositive-ReturnsString@@Tests/CodeInspectorTool.wlt:1578,1-1587,2"
]

VerificationTest[
    StringContainsQ[ $readStringCleanResult, "ReadStringCharacterEncoding" ],
    False,
    SameTest -> SameQ,
    TestID   -> "ReadStringCharacterEncoding-NoFalsePositive-NoTag@@Tests/CodeInspectorTool.wlt:1589,1-1594,2"
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
    TestID   -> "ExcessiveLineLength-Detected-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1603,1-1612,2"
]

VerificationTest[
    MemberQ[ $longLineInspections, InspectionObject[ "ExcessiveLineLength", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExcessiveLineLength-Detected-HasTag@@Tests/CodeInspectorTool.wlt:1614,1-1619,2"
]

VerificationTest[
    MemberQ[ $longLineInspections, InspectionObject[ "ExcessiveLineLength", _, "Formatting", _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExcessiveLineLength-Detected-IsFormatting@@Tests/CodeInspectorTool.wlt:1621,1-1626,2"
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
    TestID   -> "ExcessiveLineLength-ExactLimit-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1631,1-1639,2"
]

VerificationTest[
    MemberQ[ $exactLineInspections, InspectionObject[ "ExcessiveLineLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "ExcessiveLineLength-ExactLimit-NotDetected@@Tests/CodeInspectorTool.wlt:1641,1-1646,2"
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
    TestID   -> "ExcessiveLineLength-ShortLines-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1651,1-1659,2"
]

VerificationTest[
    MemberQ[ $shortLineInspections, InspectionObject[ "ExcessiveLineLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "ExcessiveLineLength-ShortLines-NotDetected@@Tests/CodeInspectorTool.wlt:1661,1-1666,2"
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
    TestID   -> "ExcessiveFileLength-Detected-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1675,1-1684,2"
]

VerificationTest[
    MemberQ[ $longFileInspections, InspectionObject[ "ExcessiveFileLength", _, _, _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExcessiveFileLength-Detected-HasTag@@Tests/CodeInspectorTool.wlt:1686,1-1691,2"
]

VerificationTest[
    MemberQ[ $longFileInspections, InspectionObject[ "ExcessiveFileLength", _, "Formatting", _ ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "ExcessiveFileLength-Detected-IsFormatting@@Tests/CodeInspectorTool.wlt:1693,1-1698,2"
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
    TestID   -> "ExcessiveFileLength-ShortFile-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1703,1-1711,2"
]

VerificationTest[
    MemberQ[ $shortFileInspections, InspectionObject[ "ExcessiveFileLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "ExcessiveFileLength-ShortFile-NotDetected@@Tests/CodeInspectorTool.wlt:1713,1-1718,2"
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
    TestID   -> "FormattingExclusion-ReturnsInspections@@Tests/CodeInspectorTool.wlt:1723,1-1731,2"
]

VerificationTest[
    MemberQ[ $formattingExcludedInspections, InspectionObject[ "ExcessiveLineLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "FormattingExclusion-SuppressesLineLength@@Tests/CodeInspectorTool.wlt:1733,1-1738,2"
]

VerificationTest[
    MemberQ[ $formattingExcludedInspections, InspectionObject[ "ExcessiveFileLength", _, _, _ ] ],
    False,
    SameTest -> SameQ,
    TestID   -> "FormattingExclusion-SuppressesFileLength@@Tests/CodeInspectorTool.wlt:1740,1-1745,2"
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
    TestID   -> "NothingValueInAssociation-Basic-ReturnsString@@Tests/CodeInspectorTool.wlt:1754,1-1763,2"
]

VerificationTest[
    StringCount[ $nothingAssocResult, "Issue " ~~ DigitCharacter.. ~~ ": NothingValueInAssociation" ],
    1,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-Basic-HasTag@@Tests/CodeInspectorTool.wlt:1765,1-1770,2"
]

VerificationTest[
    StringContainsQ[ $nothingAssocResult, "``Nothing`` used as a value in an ``Association`` is not automatically removed" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-Basic-HasDescription@@Tests/CodeInspectorTool.wlt:1772,1-1777,2"
]

VerificationTest[
    StringContainsQ[ $nothingAssocResult, "(Warning" ],
    True,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-Basic-HasSeverity@@Tests/CodeInspectorTool.wlt:1779,1-1784,2"
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
    TestID   -> "NothingValueInAssociation-RuleDelayed-ReturnsString@@Tests/CodeInspectorTool.wlt:1789,1-1798,2"
]

VerificationTest[
    StringCount[ $nothingAssocDelayedResult, "Issue " ~~ DigitCharacter.. ~~ ": NothingValueInAssociation" ],
    1,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-RuleDelayed-HasTag@@Tests/CodeInspectorTool.wlt:1800,1-1805,2"
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
    TestID   -> "NothingValueInAssociation-Multiple-ReturnsString@@Tests/CodeInspectorTool.wlt:1810,1-1819,2"
]

VerificationTest[
    StringCount[ $nothingAssocMultiResult, "Issue " ~~ DigitCharacter.. ~~ ": NothingValueInAssociation" ],
    3,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-Multiple-FindsAllThree@@Tests/CodeInspectorTool.wlt:1821,1-1826,2"
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
    TestID   -> "NothingValueInAssociation-NoFalsePositive-Clean-ReturnsString@@Tests/CodeInspectorTool.wlt:1831,1-1840,2"
]

VerificationTest[
    StringContainsQ[ $nothingAssocCleanResult, "NothingValueInAssociation" ],
    False,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-NoFalsePositive-Clean-NoTag@@Tests/CodeInspectorTool.wlt:1842,1-1847,2"
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
    TestID   -> "NothingValueInAssociation-NoFalsePositive-Standalone-ReturnsString@@Tests/CodeInspectorTool.wlt:1850,1-1859,2"
]

VerificationTest[
    StringContainsQ[ $nothingStandaloneResult, "NothingValueInAssociation" ],
    False,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-NoFalsePositive-Standalone-NoTag@@Tests/CodeInspectorTool.wlt:1861,1-1866,2"
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
    TestID   -> "NothingValueInAssociation-NoFalsePositive-ListRule-ReturnsString@@Tests/CodeInspectorTool.wlt:1869,1-1878,2"
]

VerificationTest[
    StringContainsQ[ $nothingListRuleResult, "NothingValueInAssociation" ],
    False,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-NoFalsePositive-ListRule-NoTag@@Tests/CodeInspectorTool.wlt:1880,1-1885,2"
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
    TestID   -> "NothingValueInAssociation-NoFalsePositive-AsArgument-ReturnsString@@Tests/CodeInspectorTool.wlt:1888,1-1897,2"
]

VerificationTest[
    StringContainsQ[ $nothingArgResult, "NothingValueInAssociation" ],
    False,
    SameTest -> SameQ,
    TestID   -> "NothingValueInAssociation-NoFalsePositive-AsArgument-NoTag@@Tests/CodeInspectorTool.wlt:1899,1-1904,2"
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
    TestID   -> "KeyExistsQNestedKeyPath-Basic-ReturnsString@@Tests/CodeInspectorTool.wlt:1913,1-1922,2"
]

VerificationTest[
    StringCount[ $keyExistsQResult, "Issue " ~~ DigitCharacter.. ~~ ": KeyExistsQNestedKeyPath" ],
    1,
    SameTest -> SameQ,
    TestID   -> "KeyExistsQNestedKeyPath-Basic-HasTag@@Tests/CodeInspectorTool.wlt:1924,1-1929,2"
]

VerificationTest[
    StringContainsQ[ $keyExistsQResult, "``KeyExistsQ`` with a ``List`` as its second argument checks for a literal list key" ],
    True,
    SameTest -> SameQ,
    TestID   -> "KeyExistsQNestedKeyPath-Basic-HasDescription@@Tests/CodeInspectorTool.wlt:1931,1-1936,2"
]

VerificationTest[
    StringContainsQ[ $keyExistsQResult, "(Warning" ],
    True,
    SameTest -> SameQ,
    TestID   -> "KeyExistsQNestedKeyPath-Basic-HasSeverity@@Tests/CodeInspectorTool.wlt:1938,1-1943,2"
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
    TestID   -> "KeyExistsQNestedKeyPath-SingleKey-ReturnsString@@Tests/CodeInspectorTool.wlt:1948,1-1957,2"
]

VerificationTest[
    StringCount[ $keyExistsQSingleResult, "Issue " ~~ DigitCharacter.. ~~ ": KeyExistsQNestedKeyPath" ],
    1,
    SameTest -> SameQ,
    TestID   -> "KeyExistsQNestedKeyPath-SingleKey-HasTag@@Tests/CodeInspectorTool.wlt:1959,1-1964,2"
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
    TestID   -> "KeyExistsQNestedKeyPath-NoFalsePositive-StringKey-ReturnsString@@Tests/CodeInspectorTool.wlt:1971,1-1980,2"
]

VerificationTest[
    StringContainsQ[ $keyExistsQCleanResult, "KeyExistsQNestedKeyPath" ],
    False,
    SameTest -> SameQ,
    TestID   -> "KeyExistsQNestedKeyPath-NoFalsePositive-StringKey-NoTag@@Tests/CodeInspectorTool.wlt:1982,1-1987,2"
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
    TestID   -> "KeyExistsQNestedKeyPath-NoFalsePositive-SymbolKey-ReturnsString@@Tests/CodeInspectorTool.wlt:1990,1-1999,2"
]

VerificationTest[
    StringContainsQ[ $keyExistsQSymbolResult, "KeyExistsQNestedKeyPath" ],
    False,
    SameTest -> SameQ,
    TestID   -> "KeyExistsQNestedKeyPath-NoFalsePositive-SymbolKey-NoTag@@Tests/CodeInspectorTool.wlt:2001,1-2006,2"
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
    TestID   -> "UnreachableConditionalDefinition-OwnValue-ReturnsString@@Tests/CodeInspectorTool.wlt:2015,1-2024,2"
]

VerificationTest[
    StringCount[ $ownValueCondResult, "Issue " ~~ DigitCharacter.. ~~ ": UnreachableConditionalDefinition" ],
    1,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-OwnValue-HasTag@@Tests/CodeInspectorTool.wlt:2026,1-2031,2"
]

VerificationTest[
    StringContainsQ[ $ownValueCondResult, "conditional definition of" ],
    True,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-OwnValue-HasDescription@@Tests/CodeInspectorTool.wlt:2033,1-2038,2"
]

VerificationTest[
    StringContainsQ[ $ownValueCondResult, "(Warning" ],
    True,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-OwnValue-HasSeverity@@Tests/CodeInspectorTool.wlt:2040,1-2045,2"
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
    TestID   -> "UnreachableConditionalDefinition-DownValue-ReturnsString@@Tests/CodeInspectorTool.wlt:2050,1-2057,2"
]

VerificationTest[
    StringCount[ $downValueCondResult, "Issue " ~~ DigitCharacter.. ~~ ": UnreachableConditionalDefinition" ],
    1,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-DownValue-HasTag@@Tests/CodeInspectorTool.wlt:2059,1-2064,2"
]

VerificationTest[
    StringContainsQ[ $downValueCondResult, "conditional definition of" ],
    True,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-DownValue-HasDescription@@Tests/CodeInspectorTool.wlt:2066,1-2071,2"
]

VerificationTest[
    StringContainsQ[ $downValueCondResult, "(Warning" ],
    True,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-DownValue-HasSeverity@@Tests/CodeInspectorTool.wlt:2073,1-2078,2"
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
    TestID   -> "UnreachableConditionalDefinition-BetweenDefs-ReturnsString@@Tests/CodeInspectorTool.wlt:2083,1-2090,2"
]

VerificationTest[
    StringCount[ $betweenDefsResult, "Issue " ~~ DigitCharacter.. ~~ ": UnreachableConditionalDefinition" ],
    1,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-BetweenDefs-HasTag@@Tests/CodeInspectorTool.wlt:2092,1-2097,2"
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
    TestID   -> "UnreachableConditionalDefinition-Standalone-ReturnsString@@Tests/CodeInspectorTool.wlt:2104,1-2111,2"
]

VerificationTest[
    StringContainsQ[ $standaloneCondResult, "UnreachableConditionalDefinition" ],
    False,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-Standalone-NoTag@@Tests/CodeInspectorTool.wlt:2113,1-2118,2"
]

(* All-conditional definitions should not trigger *)
VerificationTest[
    $allCondResult = CodeInspectorToolFunction @ <|
        "code" -> "g[] /; True := 1;\ng[] /; False := 2"
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "UnreachableConditionalDefinition-AllConditional-ReturnsString@@Tests/CodeInspectorTool.wlt:2121,1-2128,2"
]

VerificationTest[
    StringContainsQ[ $allCondResult, "UnreachableConditionalDefinition" ],
    False,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-AllConditional-NoTag@@Tests/CodeInspectorTool.wlt:2130,1-2135,2"
]

(* Definitions with patterns in arguments should not trigger *)
VerificationTest[
    $patternArgsResult = CodeInspectorToolFunction @ <|
        "code" -> "h[_] /; True := 1;\nh[_] := 2"
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "UnreachableConditionalDefinition-PatternArgs-ReturnsString@@Tests/CodeInspectorTool.wlt:2138,1-2145,2"
]

VerificationTest[
    StringContainsQ[ $patternArgsResult, "UnreachableConditionalDefinition" ],
    False,
    SameTest -> SameQ,
    TestID   -> "UnreachableConditionalDefinition-PatternArgs-NoTag@@Tests/CodeInspectorTool.wlt:2147,1-2152,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Custom Rules - AmbiguousMapPrecedence*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectAmbiguousMapPrecedence - Basic Detection*)
VerificationTest[
    $ambiguousMapResult = CodeInspectorToolFunction @ <|
        "code"               -> "f @ g /@ x",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "AmbiguousMapPrecedence-Basic-ReturnsString@@Tests/CodeInspectorTool.wlt:2161,1-2170,2"
]

VerificationTest[
    StringContainsQ[ $ambiguousMapResult, "AmbiguousMapPrecedence" ],
    True,
    SameTest -> SameQ,
    TestID   -> "AmbiguousMapPrecedence-Basic-HasTag@@Tests/CodeInspectorTool.wlt:2172,1-2177,2"
]

VerificationTest[
    StringContainsQ[ $ambiguousMapResult, "(Warning" ],
    True,
    SameTest -> SameQ,
    TestID   -> "AmbiguousMapPrecedence-Basic-IsWarning@@Tests/CodeInspectorTool.wlt:2179,1-2184,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectAmbiguousMapPrecedence - Motivating Example*)
VerificationTest[
    $ambiguousMapQuietResult = CodeInspectorToolFunction @ <|
        "code"               -> "Quiet @ DeleteFile /@ files",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "AmbiguousMapPrecedence-QuietDeleteFile-ReturnsString@@Tests/CodeInspectorTool.wlt:2189,1-2198,2"
]

VerificationTest[
    StringContainsQ[ $ambiguousMapQuietResult, "AmbiguousMapPrecedence" ],
    True,
    SameTest -> SameQ,
    TestID   -> "AmbiguousMapPrecedence-QuietDeleteFile-HasTag@@Tests/CodeInspectorTool.wlt:2200,1-2205,2"
]

VerificationTest[
    StringContainsQ[ $ambiguousMapQuietResult, "Quiet" ] && StringContainsQ[ $ambiguousMapQuietResult, "DeleteFile" ],
    True,
    SameTest -> SameQ,
    TestID   -> "AmbiguousMapPrecedence-QuietDeleteFile-HasSymbolNames@@Tests/CodeInspectorTool.wlt:2207,1-2212,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectAmbiguousMapPrecedence - No False Positives*)

(* Bracket application should not trigger *)
VerificationTest[
    $ambiguousMapBracketResult = CodeInspectorToolFunction @ <|
        "code"               -> "f[g /@ x]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "AmbiguousMapPrecedence-BracketApp-ReturnsString@@Tests/CodeInspectorTool.wlt:2219,1-2228,2"
]

VerificationTest[
    StringContainsQ[ $ambiguousMapBracketResult, "AmbiguousMapPrecedence" ],
    False,
    SameTest -> SameQ,
    TestID   -> "AmbiguousMapPrecedence-BracketApp-NoTag@@Tests/CodeInspectorTool.wlt:2230,1-2235,2"
]

(* Explicit Map should not trigger *)
VerificationTest[
    $ambiguousMapExplicitResult = CodeInspectorToolFunction @ <|
        "code"               -> "Map[f @ g, x]",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "AmbiguousMapPrecedence-ExplicitMap-ReturnsString@@Tests/CodeInspectorTool.wlt:2238,1-2247,2"
]

VerificationTest[
    StringContainsQ[ $ambiguousMapExplicitResult, "AmbiguousMapPrecedence" ],
    False,
    SameTest -> SameQ,
    TestID   -> "AmbiguousMapPrecedence-ExplicitMap-NoTag@@Tests/CodeInspectorTool.wlt:2249,1-2254,2"
]

(* Plain prefix application without Map should not trigger *)
VerificationTest[
    $ambiguousMapNoMapResult = CodeInspectorToolFunction @ <|
        "code"               -> "f @ g",
        "severityExclusions" -> "",
        "confidenceLevel"    -> 0.0
    |>,
    _String,
    SameTest -> MatchQ,
    TestID   -> "AmbiguousMapPrecedence-NoMap-ReturnsString@@Tests/CodeInspectorTool.wlt:2257,1-2266,2"
]

VerificationTest[
    StringContainsQ[ $ambiguousMapNoMapResult, "AmbiguousMapPrecedence" ],
    False,
    SameTest -> SameQ,
    TestID   -> "AmbiguousMapPrecedence-NoMap-NoTag@@Tests/CodeInspectorTool.wlt:2268,1-2273,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Regression Tests*)
VerificationTest[
    CodeInspectorToolFunction @ <| "code" -> "f @ g /@ h[x]" |>,
    _String? (StringContainsQ[ "AmbiguousMapPrecedence" ]),
    SameTest -> MatchQ,
    TestID   -> "AmbiguousMapPrecedence-NonLeafNode@@Tests/CodeInspectorTool.wlt:2278,1-2283,2"
]

VerificationTest[
    CodeInspectorToolFunction @ <| "code" -> "f@   g\t/@\nx" |>,
    _String? (StringContainsQ[ "AmbiguousMapPrecedence" ]),
    SameTest -> MatchQ,
    TestID   -> "AmbiguousMapPrecedence-Whitespace@@Tests/CodeInspectorTool.wlt:2285,1-2290,2"
]

(* List RHS: f @ g /@ {x} should trigger *)
VerificationTest[
    CodeInspectorToolFunction @ <| "code" -> "f @ g /@ {x}" |>,
    _String? (StringContainsQ[ "AmbiguousMapPrecedence" ]),
    SameTest -> MatchQ,
    TestID   -> "AmbiguousMapPrecedence-ListRHS@@Tests/CodeInspectorTool.wlt:2293,1-2298,2"
]

(* Parenthesized RHS: f @ g /@ (x + y) should trigger *)
VerificationTest[
    CodeInspectorToolFunction @ <| "code" -> "f @ g /@ (x + y)" |>,
    _String? (StringContainsQ[ "AmbiguousMapPrecedence" ]),
    SameTest -> MatchQ,
    TestID   -> "AmbiguousMapPrecedence-ParenRHS@@Tests/CodeInspectorTool.wlt:2301,1-2306,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Integration Tests - Cleanup*)
VerificationTest[
    DeleteDirectory[ $integrationTempDir, DeleteContents -> True ];
    ! DirectoryQ @ $integrationTempDir,
    True,
    SameTest -> SameQ,
    TestID   -> "Integration-Cleanup-TempDirectory@@Tests/CodeInspectorTool.wlt:2311,1-2317,2"
]

(* :!CodeAnalysis::EndBlock:: *)
