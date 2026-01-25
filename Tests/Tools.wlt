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
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/Tools.wlt:11,1-16,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*$DefaultMCPTools*)
VerificationTest[
    $DefaultMCPTools,
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "DefaultMCPTools-IsAssociation@@Tests/Tools.wlt:21,1-26,2"
]

VerificationTest[
    Keys @ $DefaultMCPTools,
    {
        OrderlessPatternSequence[
            "CreateSymbolDoc",
            "EditSymbolDoc",
            "EditSymbolDocExamples",
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
    TestID   -> "DefaultMCPTools-Keys@@Tests/Tools.wlt:28,1-48,2"
]

VerificationTest[
    AllTrue[ Values @ $DefaultMCPTools, MatchQ[ _LLMTool ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "DefaultMCPTools-AllLLMTools@@Tests/Tools.wlt:50,1-55,2"
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
    TestID   -> "ReadNotebook-GetTool@@Tests/Tools.wlt:64,1-69,2"
]

VerificationTest[
    $exampleNotebook = FileNameJoin @ { DirectoryName[ $TestFileName, 2 ], "TestResources", "document.nb" },
    _String? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "ReadNotebook-FindExampleFile@@Tests/Tools.wlt:71,1-76,2"
]

VerificationTest[
    $readNotebookResult = $readNotebookTool[ <| "notebook" -> $exampleNotebook |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "ReadNotebook-BasicRead@@Tests/Tools.wlt:78,1-83,2"
]

VerificationTest[
    (* Check for the presence of a Wolfram Language code block *)
    StringContainsQ[ $readNotebookResult, "\n```wl\n" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ReadNotebook-ContainsExpectedContent@@Tests/Tools.wlt:85,1-91,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Cases*)
VerificationTest[
    $readNotebookTool[ <| "notebook" -> "nonexistent_file_12345.nb" |> ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "ReadNotebook-NonexistentFile@@Tests/Tools.wlt:96,1-101,2"
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
    TestID   -> "WriteNotebook-GetTool@@Tests/Tools.wlt:110,1-115,2"
]

VerificationTest[
    $tempNotebookFile = FileNameJoin[ { $TemporaryDirectory, "MCPServerTest_" <> CreateUUID[ ] <> ".nb" } ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WriteNotebook-CreateTempPath@@Tests/Tools.wlt:117,1-122,2"
]

VerificationTest[
    $writeNotebookResult = $writeNotebookTool[ <|
        "markdown" -> "# Test Notebook\n\nThis is a test paragraph.\n\n```wl\n1 + 1\n```",
        "file" -> $tempNotebookFile,
        "overwrite" -> False
    |> ],
    _String? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "WriteNotebook-BasicWrite@@Tests/Tools.wlt:124,1-133,2"
]

VerificationTest[
    FileExistsQ @ $tempNotebookFile,
    True,
    SameTest -> SameQ,
    TestID   -> "WriteNotebook-FileExists@@Tests/Tools.wlt:135,1-140,2"
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
    TestID   -> "WriteNotebook-NoOverwriteExisting@@Tests/Tools.wlt:145,1-154,2"
]

VerificationTest[
    $writeNotebookTool[ <|
        "markdown" -> "# Overwritten Notebook",
        "file" -> $tempNotebookFile,
        "overwrite" -> True
    |> ],
    _String? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "WriteNotebook-OverwriteExisting@@Tests/Tools.wlt:156,1-165,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup*)
VerificationTest[
    If[ FileExistsQ @ $tempNotebookFile, DeleteFile @ $tempNotebookFile ];
    FileExistsQ @ $tempNotebookFile,
    False,
    SameTest -> SameQ,
    TestID   -> "WriteNotebook-Cleanup@@Tests/Tools.wlt:170,1-176,2"
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
    TestID   -> "WolframLanguageEvaluator-GetTool@@Tests/Tools.wlt:185,1-190,2"
]

VerificationTest[
    $evalResult1 = $evaluatorTool[ <| "code" -> "1 + 1" |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-BasicEval@@Tests/Tools.wlt:192,1-197,2"
]

VerificationTest[
    StringContainsQ[ $evalResult1, "2" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-CorrectResult@@Tests/Tools.wlt:199,1-204,2"
]

VerificationTest[
    StringContainsQ[ $evalResult1, "Out[" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-HasOutLabel@@Tests/Tools.wlt:206,1-211,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Time Constraint*)
VerificationTest[
    $evalResult2 = $evaluatorTool[ <| "code" -> "Range[5]", "timeConstraint" -> 30 |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-WithTimeConstraint@@Tests/Tools.wlt:216,1-221,2"
]

VerificationTest[
    StringContainsQ[ $evalResult2, "{1, 2, 3, 4, 5}" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-RangeResult@@Tests/Tools.wlt:223,1-228,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Complex Expressions*)
VerificationTest[
    $evalResult3 = $evaluatorTool[ <| "code" -> "Table[n^2, {n, 1, 4}]" |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-TableExpression@@Tests/Tools.wlt:233,1-238,2"
]

VerificationTest[
    StringContainsQ[ $evalResult3, "{1, 4, 9, 16}" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-TableResult@@Tests/Tools.wlt:240,1-245,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*String Output*)
VerificationTest[
    $evalResult4 = $evaluatorTool[ <| "code" -> "StringJoin[\"Hello\", \" \", \"World\"]" |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-StringExpression@@Tests/Tools.wlt:250,1-255,2"
]

VerificationTest[
    StringContainsQ[ $evalResult4, "Hello World" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-StringResult@@Tests/Tools.wlt:257,1-262,2"
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
    TestID   -> "WolframAlpha-GetTool@@Tests/Tools.wlt:271,1-276,2"
]

VerificationTest[
    $waResult = $wolframAlphaTool[ <| "query" -> "population of France" |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WolframAlpha-BasicQuery@@Tests/Tools.wlt:278,1-283,2"
]

VerificationTest[
    StringLength[ $waResult ] > 0,
    True,
    SameTest -> SameQ,
    TestID   -> "WolframAlpha-NonEmptyResult@@Tests/Tools.wlt:285,1-290,2"
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
    TestID   -> "WolframLanguageContext-GetTool@@Tests/Tools.wlt:314,1-319,2"
]

VerificationTest[
    $wlContextResult = $wlContextTool[ <| "context" -> "How to create a list of prime numbers in Wolfram Language" |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageContext-BasicQuery@@Tests/Tools.wlt:321,1-326,2"
]

VerificationTest[
    StringLength[ $wlContextResult ] > 0,
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageContext-NonEmptyResult@@Tests/Tools.wlt:328,1-333,2"
]

VerificationTest[
    StringContainsQ[ $wlContextResult, "Prime" | "prime" | "Table" | "Range", IgnoreCase -> True ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageContext-RelevantContent@@Tests/Tools.wlt:335,1-340,2"
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
    TestID   -> "WolframAlphaContext-GetTool@@Tests/Tools.wlt:349,1-354,2"
]

VerificationTest[
    $waContextResult = $waContextTool[ <| "context" -> "What is the distance from Earth to Mars" |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WolframAlphaContext-BasicQuery@@Tests/Tools.wlt:356,1-361,2"
]

VerificationTest[
    StringLength[ $waContextResult ] > 0,
    True,
    SameTest -> SameQ,
    TestID   -> "WolframAlphaContext-NonEmptyResult@@Tests/Tools.wlt:363,1-368,2"
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
    TestID   -> "WolframContext-GetTool@@Tests/Tools.wlt:377,1-382,2"
]

VerificationTest[
    $wolframContextResult = $wolframContextTool[ <| "context" -> "How to compute derivatives symbolically" |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WolframContext-BasicQuery@@Tests/Tools.wlt:384,1-389,2"
]

VerificationTest[
    StringLength[ $wolframContextResult ] > 0,
    True,
    SameTest -> SameQ,
    TestID   -> "WolframContext-NonEmptyResult@@Tests/Tools.wlt:391,1-396,2"
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
    TestID   -> "TestReport-GetTool@@Tests/Tools.wlt:407,1-412,2"
]

VerificationTest[
    $testResourceDirectory = FileNameJoin @ { DirectoryName[ $TestFileName, 2 ], "TestResources" },
    _String? DirectoryQ,
    SameTest -> MatchQ,
    TestID   -> "TestReport-TestResourceDirectory@@Tests/Tools.wlt:414,1-419,2"
]

VerificationTest[
    $testReportResult = $testReportTool @ <|
        "paths" -> FileNameJoin @ { $testResourceDirectory, "TestFile1.wlt" },
        "newKernel" -> $allowExternal
    |>,
    _String? (StringContainsQ[ "# Test Results Summary"~~__~~"TestFile1.wlt" ]),
    SameTest -> MatchQ,
    TestID   -> "TestReport-SingleFile@@Tests/Tools.wlt:421,1-429,2"
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
    TestID   -> "TestReport-MultipleFiles@@Tests/Tools.wlt:431,1-443,2"
]

VerificationTest[
    $testReportResult = $testReportTool @ <|
        "paths" -> $testResourceDirectory,
        "newKernel" -> $allowExternal
    |>,
    _String? (StringContainsQ[ "# Test Results Summary"~~__~~"TestFile1.wlt"~~__~~"TestFile2.wlt" ]),
    SameTest -> MatchQ,
    TestID   -> "TestReport-Directory@@Tests/Tools.wlt:445,1-453,2"
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
    TestID   -> "ToolProperties-AllHaveNames@@Tests/Tools.wlt:462,1-470,2"
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
    TestID   -> "ToolProperties-AllHaveDescriptions@@Tests/Tools.wlt:475,1-483,2"
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
    TestID   -> "ToolProperties-AllHaveParameters@@Tests/Tools.wlt:488,1-496,2"
]
