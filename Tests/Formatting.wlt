(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/Formatting.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/Formatting.wlt:11,1-16,2"
]

VerificationTest[
    $testResourceDirectory = FileNameJoin @ { DirectoryName[ $TestFileName, 2 ], "TestResources" },
    _? DirectoryQ,
    SameTest -> MatchQ,
    TestID   -> "Setup-TestResources@@Tests/Formatting.wlt:18,1-23,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Built-in Server Formatting*)

VerificationTest[
    ToBoxes @ MCPServerObject[ "Wolfram" ],
    _InterpretationBox,
    SameTest -> MatchQ,
    TestID   -> "ToBoxes-Wolfram@@Tests/Formatting.wlt:29,1-34,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Paclet Server Formatting*)

VerificationTest[
    $mockPacletDirectory = FileNameJoin @ { $testResourceDirectory, "MockMCPPacletTest" };
    PacletDirectoryLoad @ $mockPacletDirectory,
    { __String },
    SameTest -> MatchQ,
    TestID   -> "MockPacletDirectory@@Tests/Formatting.wlt:40,1-46,2"
]

VerificationTest[
    server = MCPServerObject[ "MockMCPPacletTest/TestServer" ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "MCPServerObject-Paclet@@Tests/Formatting.wlt:48,1-53,2"
]

VerificationTest[
    ToBoxes @ server,
    _InterpretationBox,
    SameTest -> MatchQ,
    TestID   -> "ToBoxes-Paclet@@Tests/Formatting.wlt:55,1-60,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Unit Tests*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeMCPServerObjectBoxes*)
VerificationTest[
    Wolfram`AgentTools`Common`makeMCPServerObjectBoxes[
        MCPServerObject[ "MockMCPPacletTest/TestServer" ],
        StandardForm
    ],
    _InterpretationBox,
    SameTest -> MatchQ,
    TestID   -> "MakeMCPServerObjectBoxes-Paclet@@Tests/Formatting.wlt:69,1-77,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)

VerificationTest[
    PacletDirectoryUnload @ $mockPacletDirectory,
    { Except[ $mockPacletDirectory ]... },
    SameTest -> MatchQ,
    TestID   -> "MockPacletCleanup@@Tests/Formatting.wlt:83,1-88,2"
]
