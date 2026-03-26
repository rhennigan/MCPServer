(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/Tools.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/Tools.wlt:11,1-16,2"
]

(* Helper function to extract text from tool results (handles both string and structured content) *)
extractToolText[ str_String ] := str;
extractToolText[ as_Association ] /; KeyExistsQ[ as, "Content" ] :=
    StringJoin @ Cases[ as[ "Content" ], KeyValuePattern[ { "type" -> "text", "text" -> t_String } ] :> t ];
extractToolText[ _ ] := "";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*$DefaultMCPTools*)
VerificationTest[
    $DefaultMCPTools,
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "DefaultMCPTools-IsAssociation@@Tests/Tools.wlt:27,1-32,2"
]

VerificationTest[
    Keys @ $DefaultMCPTools,
    {
        OrderlessPatternSequence[
            "CodeInspector",
            "CreateSymbolDoc",
            "EditSymbolDoc",
            "EditSymbolDocExamples",
            "MCPAppsTest",
            "NotebookViewer",
            "ReadNotebook",
            "SymbolDefinition",
            "TestReport",
            "WolframAlpha",
            "WolframAlphaContext",
            "WolframContext",
            "WolframLanguageContext",
            "WolframLanguageEvaluator",
            "WriteNotebook"
        ]
    },
    SameTest -> MatchQ,
    TestID   -> "DefaultMCPTools-Keys@@Tests/Tools.wlt:34,1-57,2"
]

VerificationTest[
    AllTrue[ Values @ $DefaultMCPTools, MatchQ[ _LLMTool ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "DefaultMCPTools-AllLLMTools@@Tests/Tools.wlt:59,1-64,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*ReadNotebook*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Examples*)
VerificationTest[
    $readNotebookTool = $DefaultMCPTools[ "ReadNotebook" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "ReadNotebook-GetTool@@Tests/Tools.wlt:73,1-78,2"
]

VerificationTest[
    $exampleNotebook = FileNameJoin @ { DirectoryName[ $TestFileName, 2 ], "TestResources", "document.nb" },
    _String? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "ReadNotebook-FindExampleFile@@Tests/Tools.wlt:80,1-85,2"
]

VerificationTest[
    $readNotebookResult = $readNotebookTool[ <| "notebook" -> $exampleNotebook |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "ReadNotebook-BasicRead@@Tests/Tools.wlt:87,1-92,2"
]

VerificationTest[
    (* Check for the presence of a Wolfram Language code block *)
    StringContainsQ[ $readNotebookResult, "\n```wl\n" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ReadNotebook-ContainsExpectedContent@@Tests/Tools.wlt:94,1-100,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Cases*)
VerificationTest[
    $readNotebookTool[ <| "notebook" -> "nonexistent_file_12345.nb" |> ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "ReadNotebook-NonexistentFile@@Tests/Tools.wlt:105,1-110,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*WriteNotebook*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Examples*)
VerificationTest[
    $writeNotebookTool = $DefaultMCPTools[ "WriteNotebook" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "WriteNotebook-GetTool@@Tests/Tools.wlt:119,1-124,2"
]

VerificationTest[
    $tempNotebookFile = FileNameJoin[ { $TemporaryDirectory, "MCPServerTest_" <> CreateUUID[ ] <> ".nb" } ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WriteNotebook-CreateTempPath@@Tests/Tools.wlt:126,1-131,2"
]

VerificationTest[
    $writeNotebookResult = $writeNotebookTool[ <|
        "markdown" -> "# Test Notebook\n\nThis is a test paragraph.\n\n```wl\n1 + 1\n```",
        "file" -> $tempNotebookFile,
        "overwrite" -> False
    |> ],
    _String? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "WriteNotebook-BasicWrite@@Tests/Tools.wlt:133,1-142,2"
]

VerificationTest[
    FileExistsQ @ $tempNotebookFile,
    True,
    SameTest -> SameQ,
    TestID   -> "WriteNotebook-FileExists@@Tests/Tools.wlt:144,1-149,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Overwrite Behavior*)
VerificationTest[
    $writeNotebookTool[ <|
        "markdown" -> "# Another Test",
        "file" -> $tempNotebookFile,
        "overwrite" -> False
    |> ],
    _String? (StringStartsQ[ "File already exists" ]),
    SameTest -> MatchQ,
    TestID   -> "WriteNotebook-NoOverwriteExisting@@Tests/Tools.wlt:154,1-163,2"
]

VerificationTest[
    $writeNotebookTool[ <|
        "markdown" -> "# Overwritten Notebook",
        "file" -> $tempNotebookFile,
        "overwrite" -> True
    |> ],
    _String? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "WriteNotebook-OverwriteExisting@@Tests/Tools.wlt:165,1-174,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup*)
VerificationTest[
    If[ FileExistsQ @ $tempNotebookFile, DeleteFile @ $tempNotebookFile ];
    FileExistsQ @ $tempNotebookFile,
    False,
    SameTest -> SameQ,
    TestID   -> "WriteNotebook-Cleanup@@Tests/Tools.wlt:179,1-185,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*WolframLanguageEvaluator*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Examples*)
VerificationTest[
    $evaluatorTool = $DefaultMCPTools[ "WolframLanguageEvaluator" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-GetTool@@Tests/Tools.wlt:194,1-199,2"
]

VerificationTest[
    $evalResult1 = $evaluatorTool[ <| "code" -> "1 + 1" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-BasicEval@@Tests/Tools.wlt:201,1-206,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResult1, "2" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-CorrectResult@@Tests/Tools.wlt:208,1-213,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResult1, "Out[" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-HasOutLabel@@Tests/Tools.wlt:215,1-220,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Time Constraint*)
VerificationTest[
    $evalResult2 = $evaluatorTool[ <| "code" -> "Range[5]", "timeConstraint" -> 30 |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-WithTimeConstraint@@Tests/Tools.wlt:225,1-230,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResult2, "{1, 2, 3, 4, 5}" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-RangeResult@@Tests/Tools.wlt:232,1-237,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Complex Expressions*)
VerificationTest[
    $evalResult3 = $evaluatorTool[ <| "code" -> "Table[n^2, {n, 1, 4}]" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-TableExpression@@Tests/Tools.wlt:242,1-247,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResult3, "{1, 4, 9, 16}" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-TableResult@@Tests/Tools.wlt:249,1-254,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*String Output*)
VerificationTest[
    $evalResult4 = $evaluatorTool[ <| "code" -> "StringJoin[\"Hello\", \" \", \"World\"]" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-StringExpression@@Tests/Tools.wlt:259,1-264,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResult4, "Hello World" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-StringResult@@Tests/Tools.wlt:266,1-271,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Print Output*)
VerificationTest[
    $evalResultPrint1 = $evaluatorTool[ <| "code" -> "Print[\"Hello from Print\"]; 42" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-PrintBasic@@Tests/Tools.wlt:276,1-281,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResultPrint1, "Hello from Print" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-PrintOutputCaptured@@Tests/Tools.wlt:283,1-288,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResultPrint1, "42" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-PrintResultIncluded@@Tests/Tools.wlt:290,1-295,2"
]

VerificationTest[
    $evalResultPrint2 = $evaluatorTool[ <| "code" -> "Print[\"First\"]; Print[\"Second\"]; Print[\"Third\"]; \"Done\"" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-MultiplePrints@@Tests/Tools.wlt:297,1-302,2"
]

VerificationTest[
    With[ { text = extractToolText @ $evalResultPrint2 },
        StringContainsQ[ text, "First" ] && StringContainsQ[ text, "Second" ] && StringContainsQ[ text, "Third" ]
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-MultiplePrintsCaptured@@Tests/Tools.wlt:304,1-311,2"
]

VerificationTest[
    $evalResultPrint3 = $evaluatorTool[ <| "code" -> "Do[Print[i], {i, 3}]; \"Complete\"" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-PrintInLoop@@Tests/Tools.wlt:313,1-318,2"
]

VerificationTest[
    With[ { text = extractToolText @ $evalResultPrint3 },
        StringContainsQ[ text, "1" ] && StringContainsQ[ text, "2" ] && StringContainsQ[ text, "3" ]
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-PrintInLoopCaptured@@Tests/Tools.wlt:320,1-327,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*WolframAlpha*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Examples*)
VerificationTest[
    $wolframAlphaTool = $DefaultMCPTools[ "WolframAlpha" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "WolframAlpha-GetTool@@Tests/Tools.wlt:336,1-341,2"
]

VerificationTest[
    $waResult = $wolframAlphaTool[ <| "query" -> "population of France" |> ],
    _String? StringQ | KeyValuePattern[ "Content" -> { __Association } ],
    SameTest -> MatchQ,
    TestID   -> "WolframAlpha-BasicQuery@@Tests/Tools.wlt:343,1-348,2"
]

VerificationTest[
    $waResultString =
        If[ StringQ @ $waResult,
            $waResult,
            StringJoin @ Select[ $waResult[[ "Content", All, "text" ]], StringQ ]
        ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WolframAlpha-ResultString@@Tests/Tools.wlt:350,1-359,2"
]

VerificationTest[
    StringLength @ $waResultString > 0,
    True,
    SameTest -> SameQ,
    TestID   -> "WolframAlpha-NonEmptyResult@@Tests/Tools.wlt:361,1-366,2"
]

(* TODO: multiple queries aren't supported until the next Chatbook paclet update *)
(* VerificationTest[
    $waResult = $wolframAlphaTool[ <| "query" -> "population of France\tpopulation of Germany" |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WolframAlpha-MultipleQueries@@Tests/Tools.wlt:279,1-284,2"
]

VerificationTest[
    StringCount[ $waResult, "<result query=" ],
    2,
    SameTest -> SameQ,
    TestID   -> "WolframAlpha-MultipleQueriesResultCount@@Tests/Tools.wlt:286,1-291,2"
] *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*WolframLanguageContext*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Examples*)
VerificationTest[
    $wlContextTool = $DefaultMCPTools[ "WolframLanguageContext" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageContext-GetTool@@Tests/Tools.wlt:390,1-395,2"
]

skipIfGitHubActions @ VerificationTest[
    $wlContextResult = $wlContextTool[ <| "context" -> "How to create a list of prime numbers in Wolfram Language" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageContext-BasicQuery@@Tests/Tools.wlt:397,23-402,2"
]

skipIfGitHubActions @ VerificationTest[
    StringLength[ extractToolText @ $wlContextResult ] > 0,
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageContext-NonEmptyResult@@Tests/Tools.wlt:404,23-409,2"
]

skipIfGitHubActions @ VerificationTest[
    StringContainsQ[ extractToolText @ $wlContextResult, "Prime" | "prime" | "Table" | "Range", IgnoreCase -> True ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageContext-RelevantContent@@Tests/Tools.wlt:411,23-416,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*WolframAlphaContext*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Examples*)
VerificationTest[
    $waContextTool = $DefaultMCPTools[ "WolframAlphaContext" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "WolframAlphaContext-GetTool@@Tests/Tools.wlt:425,1-430,2"
]

skipIfGitHubActions @ VerificationTest[
    $waContextResult = $waContextTool[ <| "context" -> "What is the distance from Earth to Mars" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframAlphaContext-BasicQuery@@Tests/Tools.wlt:432,23-437,2"
]

skipIfGitHubActions @ VerificationTest[
    StringLength[ extractToolText @ $waContextResult ] > 0,
    True,
    SameTest -> SameQ,
    TestID   -> "WolframAlphaContext-NonEmptyResult@@Tests/Tools.wlt:439,23-444,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*WolframContext*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Examples*)
VerificationTest[
    $wolframContextTool = $DefaultMCPTools[ "WolframContext" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "WolframContext-GetTool@@Tests/Tools.wlt:453,1-458,2"
]

skipIfGitHubActions @ VerificationTest[
    $wolframContextResult = $wolframContextTool[ <| "context" -> "How to compute derivatives symbolically" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframContext-BasicQuery@@Tests/Tools.wlt:460,23-465,2"
]

skipIfGitHubActions @ VerificationTest[
    StringLength[ extractToolText @ $wolframContextResult ] > 0,
    True,
    SameTest -> SameQ,
    TestID   -> "WolframContext-NonEmptyResult@@Tests/Tools.wlt:467,23-472,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*TestReport*)

$allowExternal = ! StringQ @ Environment[ "GITHUB_ACTIONS" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Examples*)
VerificationTest[
    $testReportTool = $DefaultMCPTools[ "TestReport" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "TestReport-GetTool@@Tests/Tools.wlt:483,1-488,2"
]

VerificationTest[
    $testResourceDirectory = FileNameJoin @ { DirectoryName[ $TestFileName, 2 ], "TestResources" },
    _String? DirectoryQ,
    SameTest -> MatchQ,
    TestID   -> "TestReport-TestResourceDirectory@@Tests/Tools.wlt:490,1-495,2"
]

VerificationTest[
    $testReportResult = $testReportTool @ <|
        "paths" -> FileNameJoin @ { $testResourceDirectory, "TestFile1.wlt" },
        "newKernel" -> $allowExternal
    |>,
    _String? (StringContainsQ[ "# Test Results Summary"~~__~~"TestFile1.wlt" ]),
    SameTest -> MatchQ,
    TestID   -> "TestReport-SingleFile@@Tests/Tools.wlt:497,1-505,2"
]

VerificationTest[
    $testReportResult = $testReportTool @ <|
        "paths" -> StringJoin[
            FileNameJoin @ { $testResourceDirectory, "TestFile1.wlt" },
            ", ",
            FileNameJoin @ { $testResourceDirectory, "TestFile2.wlt" }
        ],
        "newKernel" -> $allowExternal
    |>,
    _String? (StringContainsQ[ "# Test Results Summary"~~__~~"TestFile1.wlt"~~__~~"TestFile2.wlt" ]),
    SameTest -> MatchQ,
    TestID   -> "TestReport-MultipleFiles@@Tests/Tools.wlt:507,1-519,2"
]

VerificationTest[
    $testReportResult = $testReportTool @ <|
        "paths" -> $testResourceDirectory,
        "newKernel" -> $allowExternal
    |>,
    _String? (StringContainsQ[ "# Test Results Summary"~~__~~"TestFile1.wlt"~~__~~"TestFile2.wlt" ]),
    SameTest -> MatchQ,
    TestID   -> "TestReport-Directory@@Tests/Tools.wlt:521,1-529,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Cases*)

(* GH#65: Nonexistent path should produce TestFileNotFound, not an internal failure *)
VerificationTest[
    $testReportTool[ <| "paths" -> CreateUUID[] <> "/does/not/exist.wlt" |> ],
    Failure[ "AgentTools::TestFileNotFound", _Association ],
    { AgentTools::TestFileNotFound },
    SameTest -> MatchQ,
    TestID   -> "TestReport-NonexistentFile-GH#65@@Tests/Tools.wlt:536,1-542,2"
]

VerificationTest[
    $testReportTool[ <| "paths" -> CreateUUID[] <> "/does/not/exist.wlt" |> ],
    _? (FreeQ[ "AgentTools::Internal" ]),
    { AgentTools::TestFileNotFound },
    SameTest -> MatchQ,
    TestID   -> "TestReport-NoInternalFailure-GH#65@@Tests/Tools.wlt:544,1-550,2"
]

VerificationTest[
    $testReportTool @ <|
        "paths" -> StringJoin[
            FileNameJoin @ { $testResourceDirectory, "TestFile1.wlt" },
            ", " <> CreateUUID[] <> "/does/not/exist.wlt"
        ]
    |>,
    _? (FreeQ[ "AgentTools::Internal" ]),
    { AgentTools::TestFileNotFound },
    SameTest -> MatchQ,
    TestID   -> "TestReport-MixedValidInvalidPaths-GH#65@@Tests/Tools.wlt:552,1-563,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Properties*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tool Names*)
VerificationTest[
    AllTrue[
        $DefaultMCPTools,
        Function[ tool, StringQ @ tool[ "Name" ] ]
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "ToolProperties-AllHaveNames@@Tests/Tools.wlt:572,1-580,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tool Descriptions*)
VerificationTest[
    AllTrue[
        $DefaultMCPTools,
        Function[ tool, StringQ @ tool[ "Description" ] ]
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "ToolProperties-AllHaveDescriptions@@Tests/Tools.wlt:585,1-593,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tool Parameters*)
VerificationTest[
    AllTrue[
        $DefaultMCPTools,
        Function[ tool, ListQ @ tool[ "Parameters" ] ]
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "ToolProperties-AllHaveParameters@@Tests/Tools.wlt:598,1-606,2"
]
