(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/WolframLanguageEvaluator-UI.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/WolframLanguageEvaluator-UI.wlt:11,1-16,2"
]

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*toContentList*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*String Input*)
VerificationTest[
    Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`toContentList[ "hello" ],
    { <| "type" -> "text", "text" -> "hello" |> },
    SameTest -> MatchQ,
    TestID   -> "toContentList-String@@Tests/WolframLanguageEvaluator-UI.wlt:28,1-33,2"
]

VerificationTest[
    Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`toContentList[ "" ],
    { <| "type" -> "text", "text" -> "" |> },
    SameTest -> MatchQ,
    TestID   -> "toContentList-EmptyString@@Tests/WolframLanguageEvaluator-UI.wlt:35,1-40,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*List Input*)
VerificationTest[
    Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`toContentList[ { <| "type" -> "text", "text" -> "a" |> } ],
    { <| "type" -> "text", "text" -> "a" |> },
    SameTest -> MatchQ,
    TestID   -> "toContentList-List@@Tests/WolframLanguageEvaluator-UI.wlt:45,1-50,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Association with Content Key*)
VerificationTest[
    Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`toContentList[
        <| "Content" -> { <| "type" -> "text", "text" -> "x" |>, <| "type" -> "image", "data" -> "abc" |> } |>
    ],
    { <| "type" -> "text", "text" -> "x" |>, <| "type" -> "image", "data" -> "abc" |> },
    SameTest -> MatchQ,
    TestID   -> "toContentList-AssociationContent@@Tests/WolframLanguageEvaluator-UI.wlt:55,1-62,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*toOutputBoxes*)
VerificationTest[
    Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`toOutputBoxes[ HoldForm[ 1 + 1 ] ],
    _,
    SameTest -> MatchQ,
    TestID   -> "toOutputBoxes-HoldForm@@Tests/WolframLanguageEvaluator-UI.wlt:67,1-72,2"
]

VerificationTest[
    Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`toOutputBoxes[ HoldCompleteForm[ {1, 2, 3} ] ],
    _,
    SameTest -> MatchQ,
    TestID   -> "toOutputBoxes-HoldCompleteForm@@Tests/WolframLanguageEvaluator-UI.wlt:74,1-79,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config Constants*)
VerificationTest[
    Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`$deployedNotebookRoot,
    _String,
    SameTest -> MatchQ,
    TestID   -> "deployedNotebookRoot-IsString@@Tests/WolframLanguageEvaluator-UI.wlt:84,1-89,2"
]

VerificationTest[
    Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`$outputSizeLimit,
    _Integer?Positive,
    SameTest -> MatchQ,
    TestID   -> "outputSizeLimit-IsPositiveInteger@@Tests/WolframLanguageEvaluator-UI.wlt:91,1-96,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*evaluateWolframLanguage Branching*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Without UI Support*)
VerificationTest[
    Block[ { Wolfram`AgentTools`Common`$clientSupportsUI = False },
        $DefaultMCPTools[ "WolframLanguageEvaluator" ][ <| "code" -> "1+1", "timeConstraint" -> 30 |> ]
    ],
    _String | KeyValuePattern[ "Content" -> { __Association } ],
    SameTest -> MatchQ,
    TestID   -> "evaluateWolframLanguage-NoUI@@Tests/WolframLanguageEvaluator-UI.wlt:105,1-112,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*With UI Support - Returns Content*)
VerificationTest[
    Block[ { Wolfram`AgentTools`Common`$clientSupportsUI = True },
        $evalUIResult = $DefaultMCPTools[ "WolframLanguageEvaluator" ][ <| "code" -> "1+1", "timeConstraint" -> 30 |> ]
    ],
    _String | KeyValuePattern[ "Content" -> { __Association } ],
    SameTest -> MatchQ,
    TestID   -> "evaluateWolframLanguage-WithUI@@Tests/WolframLanguageEvaluator-UI.wlt:117,1-124,2"
]

VerificationTest[
    If[ AssociationQ @ $evalUIResult && KeyExistsQ[ $evalUIResult, "Content" ],
        Length @ $evalUIResult[ "Content" ] > 0,
        (* Plain string result is also acceptable (fallback path) *)
        StringQ @ $evalUIResult
    ],
    True,
    TestID -> "evaluateWolframLanguage-WithUI-HasContent@@Tests/WolframLanguageEvaluator-UI.wlt:126,1-134,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*CloudDeploy Failure Fallback*)

(* Regression test: when CloudDeploy fails, evaluateWolframLanguageUI must fall back gracefully
   instead of surfacing an internal AgentTools error (previously threw $catchTopTag through Quiet) *)
VerificationTest[
    Block[
        { Wolfram`AgentTools`Common`$clientSupportsUI = True, CloudDeploy = ($Failed &) },
        $DefaultMCPTools[ "WolframLanguageEvaluator" ][ <| "code" -> "1+1", "timeConstraint" -> 30 |> ]
    ],
    _String | KeyValuePattern[ "Content" -> { __Association } ],
    SameTest -> MatchQ,
    TestID   -> "evaluateWolframLanguage-CloudDeployFallback@@Tests/WolframLanguageEvaluator-UI.wlt:136,1-144,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*makeEvaluatorUIResult*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Returns $Failed for Non-Matching Input*)
VerificationTest[
    Quiet @ Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`makeEvaluatorUIResult[ "1+1", "plain string" ],
    $Failed | _Failure,
    SameTest -> MatchQ,
    TestID   -> "makeEvaluatorUIResult-PlainStringFails@@Tests/WolframLanguageEvaluator-UI.wlt:143,1-148,2"
]

VerificationTest[
    Quiet @ Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`makeEvaluatorUIResult[ "1+1", $Failed ],
    $Failed | _Failure,
    SameTest -> MatchQ,
    TestID   -> "makeEvaluatorUIResult-FailedInput@@Tests/WolframLanguageEvaluator-UI.wlt:150,1-155,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Returns $Failed When Missing Keys*)
VerificationTest[
    Quiet @ Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`makeEvaluatorUIResult[
        "1+1",
        <| "String" -> "text only" |>
    ],
    $Failed | _Failure,
    SameTest -> MatchQ,
    TestID   -> "makeEvaluatorUIResult-MissingResultKey@@Tests/WolframLanguageEvaluator-UI.wlt:160,1-168,2"
]

VerificationTest[
    Quiet @ Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`makeEvaluatorUIResult[
        "1+1",
        <| "Result" -> HoldForm[ 2 ] |>
    ],
    $Failed | _Failure,
    SameTest -> MatchQ,
    TestID   -> "makeEvaluatorUIResult-MissingStringKey@@Tests/WolframLanguageEvaluator-UI.wlt:170,1-178,2"
]

(* :!CodeAnalysis::EndBlock:: *)
