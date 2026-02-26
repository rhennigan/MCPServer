(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/WolframAlpha-UI.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/WolframAlpha-UI.wlt:11,1-16,2"
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
    Wolfram`MCPServer`Tools`WolframAlpha`Private`toContentList[ "hello" ],
    { <| "type" -> "text", "text" -> "hello" |> },
    SameTest -> MatchQ,
    TestID   -> "toContentList-String@@Tests/WolframAlpha-UI.wlt:28,1-33,2"
]

VerificationTest[
    Wolfram`MCPServer`Tools`WolframAlpha`Private`toContentList[ "" ],
    { <| "type" -> "text", "text" -> "" |> },
    SameTest -> MatchQ,
    TestID   -> "toContentList-EmptyString@@Tests/WolframAlpha-UI.wlt:35,1-40,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*List Input*)
VerificationTest[
    Wolfram`MCPServer`Tools`WolframAlpha`Private`toContentList[ { <| "type" -> "text", "text" -> "a" |> } ],
    { <| "type" -> "text", "text" -> "a" |> },
    SameTest -> MatchQ,
    TestID   -> "toContentList-List@@Tests/WolframAlpha-UI.wlt:45,1-50,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Association with Content Key*)
VerificationTest[
    Wolfram`MCPServer`Tools`WolframAlpha`Private`toContentList[
        <| "Content" -> { <| "type" -> "text", "text" -> "x" |>, <| "type" -> "image", "data" -> "abc" |> } |>
    ],
    { <| "type" -> "text", "text" -> "x" |>, <| "type" -> "image", "data" -> "abc" |> },
    SameTest -> MatchQ,
    TestID   -> "toContentList-AssociationContent@@Tests/WolframAlpha-UI.wlt:55,1-62,2"
]


(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*wolframAlphaToolEvaluate Branching*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Without UI Support*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = False },
        $DefaultMCPTools[ "WolframAlpha" ][ <| "query" -> "2+2" |> ]
    ],
    _String | KeyValuePattern[ "Content" -> { __Association } ],
    SameTest -> MatchQ,
    TestID   -> "wolframAlphaToolEvaluate-NoUI@@Tests/WolframAlpha-UI.wlt:72,1-79,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*With UI Support - Returns Content*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        $waUIResult = $DefaultMCPTools[ "WolframAlpha" ][ <| "query" -> "2+2" |> ]
    ],
    _String | KeyValuePattern[ "Content" -> { __Association } ],
    SameTest -> MatchQ,
    TestID   -> "wolframAlphaToolEvaluate-WithUI@@Tests/WolframAlpha-UI.wlt:84,1-91,2"
]

(* If UI result was returned with Content, verify it has items *)
VerificationTest[
    If[ AssociationQ @ $waUIResult && KeyExistsQ[ $waUIResult, "Content" ],
        Length @ $waUIResult[ "Content" ] > 0,
        (* Plain string result is also acceptable (fallback path) *)
        StringQ @ $waUIResult
    ],
    True,
    TestID -> "wolframAlphaToolEvaluate-WithUI-HasContent@@Tests/WolframAlpha-UI.wlt:94,1-102,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*makeUIResult*)


(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*$deployedNotebookRoot*)
VerificationTest[
    Wolfram`MCPServer`Tools`WolframAlpha`Private`$deployedNotebookRoot,
    _String,
    SameTest -> MatchQ,
    TestID   -> "deployedNotebookRoot-IsString@@Tests/WolframAlpha-UI.wlt:112,1-117,2"
]

(* :!CodeAnalysis::EndBlock:: *)
