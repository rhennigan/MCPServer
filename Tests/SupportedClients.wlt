(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/SupportedClients.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/SupportedClients.wlt:11,1-16,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*DetectedMCPClients*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Returns a list of supported client names*)
VerificationTest[
    DetectedMCPClients[ ],
    { ___String },
    SameTest -> MatchQ,
    TestID   -> "DetectedMCPClients-ReturnShape@@Tests/SupportedClients.wlt:25,1-30,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*All detected names are valid supported clients*)
VerificationTest[
    SubsetQ[ Keys @ $SupportedMCPClients, DetectedMCPClients[ ] ],
    True,
    TestID -> "DetectedMCPClients-Subset@@Tests/SupportedClients.wlt:36,1-40,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Result is sorted (since KeySelect preserves $SupportedMCPClients ordering)*)
VerificationTest[
    With[ { detected = DetectedMCPClients[ ] }, detected === Sort @ detected ],
    True,
    TestID -> "DetectedMCPClients-Sorted@@Tests/SupportedClients.wlt:46,1-50,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Invalid arguments*)
VerificationTest[
    DetectedMCPClients[ "bogus" ],
    _Failure,
    { DetectedMCPClients::InvalidArguments },
    SameTest -> MatchQ,
    TestID   -> "DetectedMCPClients-InvalidArguments@@Tests/SupportedClients.wlt:57,1-63,2"
]
