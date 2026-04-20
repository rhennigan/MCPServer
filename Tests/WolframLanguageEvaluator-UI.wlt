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
    Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`$outputSizeLimit,
    _Integer?Positive,
    SameTest -> MatchQ,
    TestID   -> "outputSizeLimit-IsPositiveInteger@@Tests/WolframLanguageEvaluator-UI.wlt:84,1-89,2"
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
    TestID   -> "evaluateWolframLanguage-NoUI@@Tests/WolframLanguageEvaluator-UI.wlt:98,1-105,2"
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
    TestID   -> "evaluateWolframLanguage-WithUI@@Tests/WolframLanguageEvaluator-UI.wlt:110,1-117,2"
]

VerificationTest[
    If[ AssociationQ @ $evalUIResult && KeyExistsQ[ $evalUIResult, "Content" ],
        Length @ $evalUIResult[ "Content" ] > 0,
        (* Plain string result is also acceptable (fallback path) *)
        StringQ @ $evalUIResult
    ],
    True,
    TestID -> "evaluateWolframLanguage-WithUI-HasContent@@Tests/WolframLanguageEvaluator-UI.wlt:119,1-127,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*UI Support But Cloud Deployment Disabled - Falls Back*)
VerificationTest[
    Block[ {
        Wolfram`AgentTools`Common`$clientSupportsUI    = True,
        Wolfram`AgentTools`Common`$deployCloudNotebooks = False
    },
        $DefaultMCPTools[ "WolframLanguageEvaluator" ][ <| "code" -> "1+1", "timeConstraint" -> 30 |> ]
    ],
    _String | KeyValuePattern[ "Content" -> { __Association } ],
    SameTest -> MatchQ,
    TestID   -> "evaluateWolframLanguage-NoDeploy@@Tests/WolframLanguageEvaluator-UI.wlt:132,1-142,2"
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
    TestID   -> "makeEvaluatorUIResult-PlainStringFails@@Tests/WolframLanguageEvaluator-UI.wlt:151,1-156,2"
]

VerificationTest[
    Quiet @ Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`makeEvaluatorUIResult[ "1+1", $Failed ],
    $Failed | _Failure,
    SameTest -> MatchQ,
    TestID   -> "makeEvaluatorUIResult-FailedInput@@Tests/WolframLanguageEvaluator-UI.wlt:158,1-163,2"
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
    TestID   -> "makeEvaluatorUIResult-MissingResultKey@@Tests/WolframLanguageEvaluator-UI.wlt:168,1-176,2"
]

VerificationTest[
    Quiet @ Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`makeEvaluatorUIResult[
        "1+1",
        <| "Result" -> HoldForm[ 2 ] |>
    ],
    $Failed | _Failure,
    SameTest -> MatchQ,
    TestID   -> "makeEvaluatorUIResult-MissingStringKey@@Tests/WolframLanguageEvaluator-UI.wlt:178,1-186,2"
]

(* :!CodeAnalysis::EndBlock:: *)
