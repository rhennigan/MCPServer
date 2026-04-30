(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/PreferencesContent.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/PreferencesContent.wlt:11,1-16,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*CreatePreferencesContent*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Smoke test*)
VerificationTest[
    CreatePreferencesContent[ ],
    Deploy[ _Pane ],
    SameTest -> MatchQ,
    TestID   -> "CreatePreferencesContent-SmokeTest@@Tests/PreferencesContent.wlt:25,1-30,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Invalid Arguments*)
VerificationTest[
    CreatePreferencesContent[ "bogus" ],
    _Failure,
    { CreatePreferencesContent::InvalidArguments },
    SameTest -> MatchQ,
    TestID   -> "CreatePreferencesContent-InvalidArguments@@Tests/PreferencesContent.wlt:35,1-41,2"
]
