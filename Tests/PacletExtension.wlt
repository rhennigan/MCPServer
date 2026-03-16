(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext"
]

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*pacletQualifiedNameQ*)
VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ "Wolfram/JIRALink/GetIssue" ],
    True,
    TestID -> "pacletQualifiedNameQ-ThreeSegment"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ "JIRALink/GetIssue" ],
    True,
    TestID -> "pacletQualifiedNameQ-TwoSegment"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ "WolframAlpha" ],
    False,
    TestID -> "pacletQualifiedNameQ-NoSlash"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ "" ],
    False,
    TestID -> "pacletQualifiedNameQ-EmptyString"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ 123 ],
    False,
    TestID -> "pacletQualifiedNameQ-NonString"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ ],
    False,
    TestID -> "pacletQualifiedNameQ-NoArgs"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*parsePacletQualifiedName*)
VerificationTest[
    Wolfram`MCPServer`Common`parsePacletQualifiedName[ "JIRALink/GetIssue" ],
    <| "PacletName" -> "JIRALink", "ItemName" -> "GetIssue" |>,
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-TwoSegment"
]

VerificationTest[
    Wolfram`MCPServer`Common`parsePacletQualifiedName[ "Wolfram/JIRALink/GetIssue" ],
    <| "PacletName" -> "Wolfram/JIRALink", "ItemName" -> "GetIssue" |>,
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-ThreeSegment"
]

VerificationTest[
    Wolfram`MCPServer`Common`parsePacletQualifiedName[ "Wolfram/JIRALink/ProjectManagement" ],
    <| "PacletName" -> "Wolfram/JIRALink", "ItemName" -> "ProjectManagement" |>,
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-ThreeSegmentServer"
]

VerificationTest[
    Wolfram`MCPServer`Common`parsePacletQualifiedName[ "MyPaclet/MyTool" ],
    <| "PacletName" -> "MyPaclet", "ItemName" -> "MyTool" |>,
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-SimpleTwoSegment"
]

(* Invalid inputs should produce failures *)
VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`parsePacletQualifiedName[ "NoSlashHere" ],
    _Failure,
    { MCPServer::Internal },
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-NoSlash"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`parsePacletQualifiedName[ "A/B/C/D" ],
    _Failure,
    { MCPServer::Internal },
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-TooManySegments"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*findMCPPaclets*)
VerificationTest[
    Wolfram`MCPServer`Common`findMCPPaclets[ ],
    { ___PacletObject },
    SameTest -> MatchQ,
    TestID   -> "findMCPPaclets-ReturnsList"
]

(* :!CodeAnalysis::EndBlock:: *)
