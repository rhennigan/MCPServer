(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
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
            "BuildPaclet",
            "CheckPaclet",
            "CodeInspector",
            "CreateSymbolDoc",
            "EditSymbolDoc",
            "EditSymbolDocExamples",
            "MCPAppsTest",
            "NotebookViewer",
            "ReadNotebook",
            "SubmitPaclet",
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
    TestID   -> "DefaultMCPTools-Keys@@Tests/Tools.wlt:34,1-60,2"
]

VerificationTest[
    AllTrue[ Values @ $DefaultMCPTools, MatchQ[ _LLMTool ] ],
    True,
    SameTest -> SameQ,
    TestID   -> "DefaultMCPTools-AllLLMTools@@Tests/Tools.wlt:62,1-67,2"
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
    TestID   -> "ReadNotebook-GetTool@@Tests/Tools.wlt:76,1-81,2"
]

VerificationTest[
    $exampleNotebook = FileNameJoin @ { DirectoryName[ $TestFileName, 2 ], "TestResources", "document.nb" },
    _String? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "ReadNotebook-FindExampleFile@@Tests/Tools.wlt:83,1-88,2"
]

VerificationTest[
    $readNotebookResult = $readNotebookTool[ <| "notebook" -> $exampleNotebook |> ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "ReadNotebook-BasicRead@@Tests/Tools.wlt:90,1-95,2"
]

VerificationTest[
    (* Check for the presence of a Wolfram Language code block *)
    StringContainsQ[ $readNotebookResult, "\n```wl\n" ],
    True,
    SameTest -> SameQ,
    TestID   -> "ReadNotebook-ContainsExpectedContent@@Tests/Tools.wlt:97,1-103,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Cases*)
VerificationTest[
    $readNotebookTool[ <| "notebook" -> "nonexistent_file_12345.nb" |> ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "ReadNotebook-NonexistentFile@@Tests/Tools.wlt:108,1-113,2"
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
    TestID   -> "WriteNotebook-GetTool@@Tests/Tools.wlt:122,1-127,2"
]

VerificationTest[
    $tempNotebookFile = FileNameJoin[ { $TemporaryDirectory, "AgentToolsTest_" <> CreateUUID[ ] <> ".nb" } ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WriteNotebook-CreateTempPath@@Tests/Tools.wlt:129,1-134,2"
]

VerificationTest[
    $writeNotebookResult = $writeNotebookTool[ <|
        "markdown" -> "# Test Notebook\n\nThis is a test paragraph.\n\n```wl\n1 + 1\n```",
        "file" -> $tempNotebookFile,
        "overwrite" -> False
    |> ],
    _String? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "WriteNotebook-BasicWrite@@Tests/Tools.wlt:136,1-145,2"
]

VerificationTest[
    FileExistsQ @ $tempNotebookFile,
    True,
    SameTest -> SameQ,
    TestID   -> "WriteNotebook-FileExists@@Tests/Tools.wlt:147,1-152,2"
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
    TestID   -> "WriteNotebook-NoOverwriteExisting@@Tests/Tools.wlt:157,1-166,2"
]

VerificationTest[
    $writeNotebookTool[ <|
        "markdown" -> "# Overwritten Notebook",
        "file" -> $tempNotebookFile,
        "overwrite" -> True
    |> ],
    _String? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "WriteNotebook-OverwriteExisting@@Tests/Tools.wlt:168,1-177,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Missing Directories*)

(* Writing to a path whose parent directories do not exist should create the
   intermediate directories rather than failing with an internal error (GH#200). *)
VerificationTest[
    $missingDirRoot         = FileNameJoin @ { $TemporaryDirectory, "AgentToolsMissingDir_" <> CreateUUID[ ] };
    $missingDirNotebookFile = FileNameJoin @ { $missingDirRoot, "nested", "test.nb" };
    { DirectoryQ @ $missingDirRoot, StringQ @ $missingDirNotebookFile },
    { False, True },
    SameTest -> MatchQ,
    TestID   -> "WriteNotebook-MissingDirectory-Setup-GH#200@@Tests/Tools.wlt:185,1-192,2"
]

VerificationTest[
    $writeNotebookTool[ <|
        "markdown"  -> "# Created In New Directory",
        "file"      -> $missingDirNotebookFile,
        "overwrite" -> False
    |> ],
    _String? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "WriteNotebook-MissingDirectory-CreatesPath-GH#200@@Tests/Tools.wlt:194,1-203,2"
]

VerificationTest[
    FileExistsQ @ $missingDirNotebookFile,
    True,
    SameTest -> SameQ,
    TestID   -> "WriteNotebook-MissingDirectory-FileExists-GH#200@@Tests/Tools.wlt:205,1-210,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup*)
VerificationTest[
    If[ FileExistsQ @ $tempNotebookFile, DeleteFile @ $tempNotebookFile ];
    If[ DirectoryQ @ $missingDirRoot, DeleteDirectory[ $missingDirRoot, DeleteContents -> True ] ];
    { FileExistsQ @ $tempNotebookFile, DirectoryQ @ $missingDirRoot },
    { False, False },
    SameTest -> SameQ,
    TestID   -> "WriteNotebook-Cleanup@@Tests/Tools.wlt:215,1-222,2"
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
    TestID   -> "WolframLanguageEvaluator-GetTool@@Tests/Tools.wlt:231,1-236,2"
]

VerificationTest[
    $evalResult1 = $evaluatorTool[ <| "code" -> "1 + 1" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-BasicEval@@Tests/Tools.wlt:238,1-243,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResult1, "2" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-CorrectResult@@Tests/Tools.wlt:245,1-250,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResult1, "Out[" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-HasOutLabel@@Tests/Tools.wlt:252,1-257,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Time Constraint*)
VerificationTest[
    $evalResult2 = $evaluatorTool[ <| "code" -> "Range[5]", "timeConstraint" -> 30 |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-WithTimeConstraint@@Tests/Tools.wlt:262,1-267,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResult2, "{1, 2, 3, 4, 5}" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-RangeResult@@Tests/Tools.wlt:269,1-274,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Complex Expressions*)
VerificationTest[
    $evalResult3 = $evaluatorTool[ <| "code" -> "Table[n^2, {n, 1, 4}]" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-TableExpression@@Tests/Tools.wlt:279,1-284,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResult3, "{1, 4, 9, 16}" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-TableResult@@Tests/Tools.wlt:286,1-291,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*String Output*)
VerificationTest[
    $evalResult4 = $evaluatorTool[ <| "code" -> "StringJoin[\"Hello\", \" \", \"World\"]" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-StringExpression@@Tests/Tools.wlt:296,1-301,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResult4, "Hello World" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-StringResult@@Tests/Tools.wlt:303,1-308,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Print Output*)
VerificationTest[
    $evalResultPrint1 = $evaluatorTool[ <| "code" -> "Print[\"Hello from Print\"]; 42" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-PrintBasic@@Tests/Tools.wlt:313,1-318,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResultPrint1, "Hello from Print" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-PrintOutputCaptured@@Tests/Tools.wlt:320,1-325,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResultPrint1, "42" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-PrintResultIncluded@@Tests/Tools.wlt:327,1-332,2"
]

VerificationTest[
    $evalResultPrint2 = $evaluatorTool[ <| "code" -> "Print[\"First\"]; Print[\"Second\"]; Print[\"Third\"]; \"Done\"" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-MultiplePrints@@Tests/Tools.wlt:334,1-339,2"
]

VerificationTest[
    With[ { text = extractToolText @ $evalResultPrint2 },
        StringContainsQ[ text, "First" ] && StringContainsQ[ text, "Second" ] && StringContainsQ[ text, "Third" ]
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-MultiplePrintsCaptured@@Tests/Tools.wlt:341,1-348,2"
]

VerificationTest[
    $evalResultPrint3 = $evaluatorTool[ <| "code" -> "Do[Print[i], {i, 3}]; \"Complete\"" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-PrintInLoop@@Tests/Tools.wlt:350,1-355,2"
]

VerificationTest[
    With[ { text = extractToolText @ $evalResultPrint3 },
        StringContainsQ[ text, "1" ] && StringContainsQ[ text, "2" ] && StringContainsQ[ text, "3" ]
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-PrintInLoopCaptured@@Tests/Tools.wlt:357,1-364,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Messages*)

(* Messages issued during evaluation are captured in the tool result text. With "PropagateMessages" -> True,
   they also fire normally at top level (where StartMCPServer handles them when running as a server), which
   is why this test declares First::nofirst as an expected message. *)
VerificationTest[
    $evalResultMsg1 = $evaluatorTool[ <| "code" -> "First[{}]" |> ],
    _String | _Association,
    { First::nofirst },
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-GenuineMessage@@Tests/Tools.wlt:373,1-379,2"
]

VerificationTest[
    StringContainsQ[ extractToolText @ $evalResultMsg1, "First::nofirst" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-GenuineMessageCaptured@@Tests/Tools.wlt:381,1-386,2"
]

(* Messages quieted by the evaluated code do not appear in the tool result: *)
VerificationTest[
    StringFreeQ[ extractToolText @ $evaluatorTool[ <| "code" -> "Quiet[First[{}]]" |> ], "First::nofirst" ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-QuietedMessageNotReported@@Tests/Tools.wlt:389,1-394,2"
]

(* Messages suppressed by kernel-internal mechanisms do not appear in the tool result: *)
VerificationTest[
    StringFreeQ[
        extractToolText @ $evaluatorTool[ <| "code" -> "Internal`DeactivateMessages[First[{}], First::nofirst]" |> ],
        "First::nofirst"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-DeactivatedMessageNotReported@@Tests/Tools.wlt:397,1-405,2"
]

(* Messages that internal kernel code issues and suppresses during evaluation (e.g. inside FullSimplify)
   were previously misreported in tool results as false "-- Message text not found --" entries.
   "PropagateMessages" -> True makes the sandbox report only messages that actually surface: *)
VerificationTest[
    $evalResultMsg2 = extractToolText @ $evaluatorTool[
        <|
            "code"           -> "FullSimplify[Integrate[a + b Log[c Log[d x^n]^p], x], {d>0, x>0, n!=0}]",
            "timeConstraint" -> 120
        |>
    ],
    _String? (StringContainsQ[ "ExpIntegralEi" ]),
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-InternallySuppressedMessages@@Tests/Tools.wlt:410,1-420,2"
]

VerificationTest[
    StringFreeQ[ $evalResultMsg2, { "Message text not found", "::ivar", "General::messages" } ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-InternallySuppressedMessagesNotReported@@Tests/Tools.wlt:422,1-427,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*UI Evaluation Path*)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* The UI path passes WolframLanguageToolEvaluate options (e.g. "PropagateMessages") that require the
   minimum Chatbook version, and older Chatbook versions silently ignore unknown options, so it must run
   the same version check as the non-UI path. Downstream functions are mocked so no front end, cloud
   deployment, or sandbox evaluation is involved. *)
VerificationTest[
    Module[ { checked = False },
        Block[
            {
                Wolfram`AgentTools`Common`chatbookVersionCheck =
                    Function[ checked = True; True ],
                Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`evaluateWolframLanguageForUI =
                    Function[ <| "String" -> "Out[1]= 2", "Result" -> HoldForm[ 2 ] |> ],
                Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`makeEvaluatorUIResult =
                    Function[ <| "Content" -> { <| "type" -> "text", "text" -> "ok" |> } |> ],
                UsingFrontEnd = # &
            },
            {
                Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`evaluateWolframLanguageUI[ "1 + 1", 10 ],
                checked
            }
        ]
    ],
    { KeyValuePattern[ "Content" -> { __Association } ], True },
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageEvaluator-UIPathVersionCheck@@Tests/Tools.wlt:440,1-461,2"
]

(* A failing version check aborts the UI path before any evaluation is attempted: *)
VerificationTest[
    Module[ { evaluated = False, result },
        result = Quiet @ Wolfram`AgentTools`Common`catchAlways @ Block[
            {
                Wolfram`AgentTools`Common`chatbookVersionCheck = Function[ $Failed ],
                Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`evaluateWolframLanguageForUI =
                    Function[ evaluated = True; <| "String" -> "Out[1]= 2", "Result" -> HoldForm[ 2 ] |> ]
            },
            Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`evaluateWolframLanguageUI[ "1 + 1", 10 ]
        ];
        { FailureQ @ result, evaluated }
    ],
    { True, False },
    SameTest -> SameQ,
    TestID   -> "WolframLanguageEvaluator-UIPathVersionCheckFailure@@Tests/Tools.wlt:464,1-479,2"
]

(* :!CodeAnalysis::EndBlock:: *)

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
    TestID   -> "WolframAlpha-GetTool@@Tests/Tools.wlt:490,1-495,2"
]

VerificationTest[
    $waResult = $wolframAlphaTool[ <| "query" -> "population of France" |> ],
    _String? StringQ | KeyValuePattern[ "Content" -> { __Association } ],
    SameTest -> MatchQ,
    TestID   -> "WolframAlpha-BasicQuery@@Tests/Tools.wlt:497,1-502,2"
]

VerificationTest[
    $waResultString =
        If[ StringQ @ $waResult,
            $waResult,
            StringJoin @ Select[ $waResult[[ "Content", All, "text" ]], StringQ ]
        ],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "WolframAlpha-ResultString@@Tests/Tools.wlt:504,1-513,2"
]

VerificationTest[
    StringLength @ $waResultString > 0,
    True,
    SameTest -> SameQ,
    TestID   -> "WolframAlpha-NonEmptyResult@@Tests/Tools.wlt:515,1-520,2"
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
    TestID   -> "WolframLanguageContext-GetTool@@Tests/Tools.wlt:544,1-549,2"
]

skipIfGitHubActions @ VerificationTest[
    $wlContextResult = $wlContextTool[ <| "context" -> "How to create a list of prime numbers in Wolfram Language" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageContext-BasicQuery@@Tests/Tools.wlt:551,23-556,2"
]

skipIfGitHubActions @ VerificationTest[
    StringLength[ extractToolText @ $wlContextResult ] > 0,
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageContext-NonEmptyResult@@Tests/Tools.wlt:558,23-563,2"
]

skipIfGitHubActions @ VerificationTest[
    StringContainsQ[ extractToolText @ $wlContextResult, "Prime" | "prime" | "Table" | "Range", IgnoreCase -> True ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageContext-RelevantContent@@Tests/Tools.wlt:565,23-570,2"
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
    TestID   -> "WolframAlphaContext-GetTool@@Tests/Tools.wlt:579,1-584,2"
]

skipIfGitHubActions @ VerificationTest[
    $waContextResult = $waContextTool[ <| "context" -> "What is the distance from Earth to Mars" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframAlphaContext-BasicQuery@@Tests/Tools.wlt:586,23-591,2"
]

skipIfGitHubActions @ VerificationTest[
    StringLength[ extractToolText @ $waContextResult ] > 0,
    True,
    SameTest -> SameQ,
    TestID   -> "WolframAlphaContext-NonEmptyResult@@Tests/Tools.wlt:593,23-598,2"
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
    TestID   -> "WolframContext-GetTool@@Tests/Tools.wlt:607,1-612,2"
]

skipIfGitHubActions @ VerificationTest[
    $wolframContextResult = $wolframContextTool[ <| "context" -> "How to compute derivatives symbolically" |> ],
    _String | _Association,
    SameTest -> MatchQ,
    TestID   -> "WolframContext-BasicQuery@@Tests/Tools.wlt:614,23-619,2"
]

skipIfGitHubActions @ VerificationTest[
    StringLength[ extractToolText @ $wolframContextResult ] > 0,
    True,
    SameTest -> SameQ,
    TestID   -> "WolframContext-NonEmptyResult@@Tests/Tools.wlt:621,23-626,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*LLMKit Usage Limit Handling*)

(* These tests mock the Chatbook calls so they exercise the over-limit code path without a live service. *)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* The Failure that RelatedWolframAlphaResults / RelatedDocumentation return when the user has exceeded
   their monthly LLMKit credit allotment (HTTP 429). *)
$usageLimitFailure = Failure[ "APIError", <|
    "MessageTemplate"   -> "The service returned the following error message: `1`.",
    "MessageParameters" -> { "credits-per-month-limit-exceeded - User has exceeded credits limit." },
    "StatusCode"        -> 429,
    "Body"              -> <|
        "success" -> False,
        "error"   -> <|
            "code"    -> "credits-per-month-limit-exceeded",
            "message" -> "credits-per-month-limit-exceeded - User has exceeded credits limit."
        |>
    |>
|> ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*RelatedWolframAlphaResults*)

(* An over-limit Failure becomes a useful, actionable message instead of an opaque internal failure. *)
VerificationTest[
    $waUsageLimitResult = Block[
        {
            Wolfram`AgentTools`Common`chatbookVersionCheck      = ( True & ),
            Wolfram`Chatbook`RelatedWolframAlphaResults         = ( $usageLimitFailure & )
        },
        Wolfram`AgentTools`Common`relatedWolframAlphaResults[ "Print Hello in Wolfram Language", "Error" ]
    ],
    _String? (StringContainsQ[ "usage limit" ]),
    SameTest -> MatchQ,
    TestID   -> "RelatedWolframAlphaResults-UsageLimitMessage@@Tests/Tools.wlt:657,1-668,2"
]

(* The service's own error message is surfaced to the agent. *)
VerificationTest[
    StringContainsQ[ $waUsageLimitResult, "credits-per-month-limit-exceeded" ],
    True,
    SameTest -> SameQ,
    TestID   -> "RelatedWolframAlphaResults-UsageLimitIncludesServiceMessage@@Tests/Tools.wlt:671,1-676,2"
]

(* It is NOT a Failure, so the MCP layer will not flag it as an error or emit a bug report. *)
VerificationTest[
    FailureQ @ $waUsageLimitResult,
    False,
    SameTest -> SameQ,
    TestID   -> "RelatedWolframAlphaResults-UsageLimitNotFailure@@Tests/Tools.wlt:679,1-684,2"
]

(* The caller's message level (e.g. "Warning" from the combined WolframContext tool) is honored. *)
VerificationTest[
    StringStartsQ[
        Block[
            {
                Wolfram`AgentTools`Common`chatbookVersionCheck = ( True & ),
                Wolfram`Chatbook`RelatedWolframAlphaResults    = ( $usageLimitFailure & )
            },
            Wolfram`AgentTools`Common`relatedWolframAlphaResults[ "Print Hello in Wolfram Language", "Warning" ]
        ],
        "Warning:"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "RelatedWolframAlphaResults-UsageLimitLevel@@Tests/Tools.wlt:687,1-701,2"
]

(* A genuine string result is still returned unchanged (regression guard). *)
VerificationTest[
    Block[
        {
            Wolfram`AgentTools`Common`chatbookVersionCheck = ( True & ),
            Wolfram`Chatbook`RelatedWolframAlphaResults    = ( "Some Wolfram|Alpha context." & )
        },
        Wolfram`AgentTools`Common`relatedWolframAlphaResults[ "population of France", "Error" ]
    ],
    "Some Wolfram|Alpha context.",
    SameTest -> SameQ,
    TestID   -> "RelatedWolframAlphaResults-NormalResultUnchanged@@Tests/Tools.wlt:704,1-715,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*RelatedDocumentation*)

VerificationTest[
    $docUsageLimitResult = Block[
        {
            Wolfram`AgentTools`Common`chatbookVersionCheck = ( True & ),
            Wolfram`AgentTools`Common`llmKitSubscribedQ    = ( False & ),
            Wolfram`Chatbook`RelatedDocumentation          = ( $usageLimitFailure & )
        },
        Wolfram`AgentTools`Common`relatedDocumentation[ "Print Hello in Wolfram Language" ]
    ],
    _String? (StringContainsQ[ "usage limit" ]),
    SameTest -> MatchQ,
    TestID   -> "RelatedDocumentation-UsageLimitMessage@@Tests/Tools.wlt:721,1-733,2"
]

VerificationTest[
    FailureQ @ $docUsageLimitResult,
    False,
    SameTest -> SameQ,
    TestID   -> "RelatedDocumentation-UsageLimitNotFailure@@Tests/Tools.wlt:735,1-740,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframContext (combined)*)

(* The combined tool calls both sub-tools; a subscribed user who is over their limit still gets a useful
   message rather than an internal failure. *)
VerificationTest[
    $wcUsageLimitResult = Block[
        {
            Wolfram`AgentTools`Common`chatbookVersionCheck = ( True & ),
            Wolfram`AgentTools`Common`llmKitSubscribedQ    = ( True & ),
            Wolfram`Chatbook`RelatedWolframAlphaResults    = ( $usageLimitFailure & ),
            Wolfram`Chatbook`RelatedDocumentation          = ( $usageLimitFailure & )
        },
        Wolfram`AgentTools`Common`relatedWolframContext[ "Print Hello in Wolfram Language" ]
    ],
    _String? (StringContainsQ[ "usage limit" ]),
    SameTest -> MatchQ,
    TestID   -> "RelatedWolframContext-UsageLimitMessage@@Tests/Tools.wlt:748,1-761,2"
]

VerificationTest[
    FailureQ @ $wcUsageLimitResult,
    False,
    SameTest -> SameQ,
    TestID   -> "RelatedWolframContext-UsageLimitNotFailure@@Tests/Tools.wlt:763,1-768,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*EnableLLMKit -> False (LLMKIT_ENABLED)*)

(* With LLMKit disabled, the combined WolframContext tool behaves as if the user is unsubscribed --
   it returns the Wolfram Language documentation but suppresses the Wolfram|Alpha section entirely,
   with NO "subscribe to LLMKit" warning injected. *)
VerificationTest[
    Module[ { result },
        result = environmentBlock[ "LLMKIT_ENABLED" -> "false",
            Block[
                {
                    Wolfram`AgentTools`Common`chatbookVersionCheck = ( True & ),
                    Wolfram`Chatbook`RelatedDocumentation          = ( "Some documentation." & )
                },
                Wolfram`AgentTools`Common`relatedWolframContext[ "population of France" ]
            ]
        ];
        {
            StringQ @ result,
            StringContainsQ[ result, "subscri", IgnoreCase -> True ],
            StringContainsQ[ result, "Some documentation." ]
        }
    ],
    { True, False, True },
    SameTest -> SameQ,
    TestID   -> "RelatedWolframContext-LLMKitDisabledNoWarning@@Tests/Tools.wlt:777,1-797,2"
]

(* Regression guard: a genuinely unsubscribed user (LLMKit still enabled) DOES get the subscription
   warning with the buy-now URL, so disabling must not be conflated with lacking a subscription. *)
(* cspell: ignore subscri *)
VerificationTest[
    Module[ { result },
        result = environmentBlock[ "LLMKIT_ENABLED" -> None,
            Block[
                {
                    Wolfram`AgentTools`Common`chatbookVersionCheck = ( True & ),
                    Wolfram`Chatbook`RelatedDocumentation          = ( "Some documentation." & ),
                    Wolfram`AgentTools`Common`getLLMKitInfo        =
                        ( <| "connected" -> True, "userHasSubscription" -> False, "buyNowUrl" -> "https://example.com/buy" |> & )
                },
                Wolfram`AgentTools`Common`relatedWolframContext[ "population of France" ]
            ]
        ];
        {
            StringQ @ result,
            StringContainsQ[ result, "subscri", IgnoreCase -> True ],
            StringContainsQ[ result, "https://example.com/buy" ]
        }
    ],
    { True, True, True },
    SameTest -> SameQ,
    TestID   -> "RelatedWolframContext-UnsubscribedStillWarns@@Tests/Tools.wlt:802,1-824,2"
]

(* :!CodeAnalysis::EndBlock:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*DocumentationProvided Option*)

(* Chatbook 2.7.2+ supports a "DocumentationProvided" option for RelatedWolframAlphaResults indicating that
   RelatedDocumentation results are provided separately. AgentTools only requires Chatbook 2.7.0, so the
   option must only be passed when the loaded Chatbook actually supports it, and only from the combined
   WolframContext tool, where documentation results actually accompany the Wolfram|Alpha results. *)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*documentationProvidedAvailableQ*)

(* The probe reports support when the option is present in the function's Options: *)
VerificationTest[
    Options[ mockRelatedWAResultsNew ] = { "DocumentationProvided" -> False, "MaxItems" -> Automatic };
    Wolfram`AgentTools`Common`documentationProvidedAvailableQ @ mockRelatedWAResultsNew,
    True,
    SameTest -> SameQ,
    TestID   -> "DocumentationProvidedAvailableQ-Supported@@Tests/Tools.wlt:845,1-851,2"
]

(* An older Chatbook without the option is reported as unsupported: *)
VerificationTest[
    Options[ mockRelatedWAResultsOld ] = { "MaxItems" -> Automatic };
    Wolfram`AgentTools`Common`documentationProvidedAvailableQ @ mockRelatedWAResultsOld,
    False,
    SameTest -> SameQ,
    TestID   -> "DocumentationProvidedAvailableQ-Unsupported@@Tests/Tools.wlt:854,1-860,2"
]

(* A Block-mocked RelatedWolframAlphaResults (as used elsewhere in this file) evaluates to a Function;
   the probe must safely report it as unsupported rather than leaking messages or errors: *)
VerificationTest[
    Wolfram`AgentTools`Common`documentationProvidedAvailableQ[ "mocked" & ],
    False,
    SameTest -> SameQ,
    TestID   -> "DocumentationProvidedAvailableQ-NonSymbol@@Tests/Tools.wlt:864,1-869,2"
]

(* The zero-argument form probes the Chatbook in use and returns a definite boolean: *)
VerificationTest[
    BooleanQ @ Wolfram`AgentTools`Common`documentationProvidedAvailableQ[ ],
    True,
    SameTest -> SameQ,
    TestID   -> "DocumentationProvidedAvailableQ-Boolean@@Tests/Tools.wlt:872,1-877,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*documentationProvidedOptions*)

(* Outside the combined WolframContext tool, no option is passed regardless of Chatbook support: *)
VerificationTest[
    Block[ { Wolfram`AgentTools`Common`documentationProvidedAvailableQ = ( True & ) },
        Wolfram`AgentTools`Common`documentationProvidedOptions[ False ]
    ],
    { },
    SameTest -> SameQ,
    TestID   -> "DocumentationProvidedOptions-NotProvided@@Tests/Tools.wlt:884,1-891,2"
]

(* From the combined tool with a supporting Chatbook, the option is included: *)
VerificationTest[
    Block[ { Wolfram`AgentTools`Common`documentationProvidedAvailableQ = ( True & ) },
        Wolfram`AgentTools`Common`documentationProvidedOptions[ True ]
    ],
    { "DocumentationProvided" -> True },
    SameTest -> SameQ,
    TestID   -> "DocumentationProvidedOptions-Supported@@Tests/Tools.wlt:894,1-901,2"
]

(* From the combined tool with an older Chatbook, the option is omitted: *)
VerificationTest[
    Block[ { Wolfram`AgentTools`Common`documentationProvidedAvailableQ = ( False & ) },
        Wolfram`AgentTools`Common`documentationProvidedOptions[ True ]
    ],
    { },
    SameTest -> SameQ,
    TestID   -> "DocumentationProvidedOptions-Unsupported@@Tests/Tools.wlt:904,1-911,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Option Passing*)

(* The standalone WolframAlphaContext path provides no documentation, so even a supporting Chatbook
   must not receive the option there: *)
VerificationTest[
    $capturedWAArguments = Missing[ "NotCalled" ];
    Block[
        {
            Wolfram`AgentTools`Common`chatbookVersionCheck            = ( True & ),
            Wolfram`AgentTools`Common`documentationProvidedAvailableQ = ( True & ),
            Wolfram`Chatbook`RelatedWolframAlphaResults               =
                Function[ $capturedWAArguments = { ## }; "Some Wolfram|Alpha context." ]
        },
        Wolfram`AgentTools`Common`relatedWolframAlphaResults[ "population of France", "Error" ]
    ],
    "Some Wolfram|Alpha context.",
    SameTest -> SameQ,
    TestID   -> "DocumentationProvided-StandaloneResultUnchanged@@Tests/Tools.wlt:919,1-933,2"
]

VerificationTest[
    MemberQ[ $capturedWAArguments, "DocumentationProvided" -> _ ],
    False,
    SameTest -> SameQ,
    TestID   -> "DocumentationProvided-NotPassedStandalone@@Tests/Tools.wlt:935,1-940,2"
]

(* The combined WolframContext tool passes the option when the loaded Chatbook supports it: *)
VerificationTest[
    $capturedWAArguments = Missing[ "NotCalled" ];
    Block[
        {
            Wolfram`AgentTools`Common`chatbookVersionCheck            = ( True & ),
            Wolfram`AgentTools`Common`llmKitSubscribedQ               = ( True & ),
            Wolfram`AgentTools`Common`documentationProvidedAvailableQ = ( True & ),
            Wolfram`Chatbook`RelatedDocumentation                     = ( "Some documentation." & ),
            Wolfram`Chatbook`RelatedWolframAlphaResults               =
                Function[ $capturedWAArguments = { ## }; "Some Wolfram|Alpha context." ]
        },
        Wolfram`AgentTools`Common`relatedWolframContext[ "population of France" ]
    ],
    _String? (StringContainsQ[ "Some Wolfram|Alpha context." ]),
    SameTest -> MatchQ,
    TestID   -> "DocumentationProvided-CombinedResult@@Tests/Tools.wlt:943,1-959,2"
]

VerificationTest[
    MemberQ[ $capturedWAArguments, "DocumentationProvided" -> True ],
    True,
    SameTest -> SameQ,
    TestID   -> "DocumentationProvided-PassedFromCombined@@Tests/Tools.wlt:961,1-966,2"
]

(* The combined tool must not pass the option to an older Chatbook that does not support it: *)
VerificationTest[
    $capturedWAArguments = Missing[ "NotCalled" ];
    Block[
        {
            Wolfram`AgentTools`Common`chatbookVersionCheck            = ( True & ),
            Wolfram`AgentTools`Common`llmKitSubscribedQ               = ( True & ),
            Wolfram`AgentTools`Common`documentationProvidedAvailableQ = ( False & ),
            Wolfram`Chatbook`RelatedDocumentation                     = ( "Some documentation." & ),
            Wolfram`Chatbook`RelatedWolframAlphaResults               =
                Function[ $capturedWAArguments = { ## }; "Some Wolfram|Alpha context." ]
        },
        Wolfram`AgentTools`Common`relatedWolframContext[ "population of France" ]
    ];
    MemberQ[ $capturedWAArguments, "DocumentationProvided" -> _ ],
    False,
    SameTest -> SameQ,
    TestID   -> "DocumentationProvided-NotPassedUnsupported@@Tests/Tools.wlt:969,1-986,2"
]

(* :!CodeAnalysis::EndBlock:: *)

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
    TestID   -> "TestReport-GetTool@@Tests/Tools.wlt:999,1-1004,2"
]

VerificationTest[
    $testResourceDirectory = FileNameJoin @ { DirectoryName[ $TestFileName, 2 ], "TestResources" },
    _String? DirectoryQ,
    SameTest -> MatchQ,
    TestID   -> "TestReport-TestResourceDirectory@@Tests/Tools.wlt:1006,1-1011,2"
]

VerificationTest[
    $testReportResult = $testReportTool @ <|
        "paths" -> FileNameJoin @ { $testResourceDirectory, "TestFile1.wlt" },
        "newKernel" -> $allowExternal
    |>,
    _String? (StringContainsQ[ "# Test Results Summary"~~__~~"TestFile1.wlt" ]),
    SameTest -> MatchQ,
    TestID   -> "TestReport-SingleFile@@Tests/Tools.wlt:1013,1-1021,2"
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
    TestID   -> "TestReport-MultipleFiles@@Tests/Tools.wlt:1023,1-1035,2"
]

VerificationTest[
    $testReportResult = $testReportTool @ <|
        "paths" -> $testResourceDirectory,
        "newKernel" -> $allowExternal
    |>,
    _String? (StringContainsQ[ "# Test Results Summary"~~__~~"TestFile1.wlt"~~__~~"TestFile2.wlt" ]),
    SameTest -> MatchQ,
    TestID   -> "TestReport-Directory@@Tests/Tools.wlt:1037,1-1045,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$mcpRoot*)

(* The subprocess started by the external RunProcess path runs in $mcpRoot. The .wlt
   file uses a relative path (FileExistsQ["marker.txt"]) that only resolves when the
   subprocess's CWD is the temporary root, which exercises the ProcessDirectory plumbing. *)
skipIfGitHubActions @ VerificationTest[
    Module[ { tmpDir, savedRoot, testFile, result, ok },
        tmpDir    = CreateDirectory[ ];
        savedRoot = Wolfram`AgentTools`Common`$mcpRoot;
        testFile  = FileNameJoin @ { tmpDir, "MarkerTest.wlt" };
        WithCleanup[
            Export[ FileNameJoin @ { tmpDir, "marker.txt" }, "ok", "Text" ];
            Export[
                testFile,
                "VerificationTest[ FileExistsQ[ \"marker.txt\" ], True, TestID -> \"MarkerFound\" ]",
                "Text"
            ];
            Wolfram`AgentTools`Common`$mcpRoot = tmpDir;
            result = $testReportTool @ <|
                "paths"     -> testFile,
                "newKernel" -> True
            |>;
            ok = StringQ @ result &&
                 StringContainsQ[ result, "**Overall Result** | Success" ],
            Wolfram`AgentTools`Common`$mcpRoot = savedRoot;
            DeleteDirectory[ tmpDir, DeleteContents -> True ]
        ];
        ok
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "TestReport-McpRootRelativePath@@Tests/Tools.wlt:1054,23-1081,2"
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
    TestID   -> "TestReport-NonexistentFile-GH#65@@Tests/Tools.wlt:1088,1-1094,2"
]

VerificationTest[
    $testReportTool[ <| "paths" -> CreateUUID[] <> "/does/not/exist.wlt" |> ],
    _? (FreeQ[ "AgentTools::Internal" ]),
    { AgentTools::TestFileNotFound },
    SameTest -> MatchQ,
    TestID   -> "TestReport-NoInternalFailure-GH#65@@Tests/Tools.wlt:1096,1-1102,2"
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
    TestID   -> "TestReport-MixedValidInvalidPaths-GH#65@@Tests/Tools.wlt:1104,1-1115,2"
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
    TestID   -> "ToolProperties-AllHaveNames@@Tests/Tools.wlt:1124,1-1132,2"
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
    TestID   -> "ToolProperties-AllHaveDescriptions@@Tests/Tools.wlt:1137,1-1145,2"
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
    TestID   -> "ToolProperties-AllHaveParameters@@Tests/Tools.wlt:1150,1-1158,2"
]
