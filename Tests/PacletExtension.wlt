(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/PacletExtension.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/PacletExtension.wlt:11,1-16,2"
]

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*pacletQualifiedNameQ*)
VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ "Wolfram/JIRALink/GetIssue" ],
    True,
    TestID -> "pacletQualifiedNameQ-ThreeSegment@@Tests/PacletExtension.wlt:24,1-28,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ "JIRALink/GetIssue" ],
    True,
    TestID -> "pacletQualifiedNameQ-TwoSegment@@Tests/PacletExtension.wlt:30,1-34,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ "WolframAlpha" ],
    False,
    TestID -> "pacletQualifiedNameQ-NoSlash@@Tests/PacletExtension.wlt:36,1-40,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ "" ],
    False,
    TestID -> "pacletQualifiedNameQ-EmptyString@@Tests/PacletExtension.wlt:42,1-46,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ 123 ],
    False,
    TestID -> "pacletQualifiedNameQ-NonString@@Tests/PacletExtension.wlt:48,1-52,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ ],
    False,
    TestID -> "pacletQualifiedNameQ-NoArgs@@Tests/PacletExtension.wlt:54,1-58,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*parsePacletQualifiedName*)
VerificationTest[
    Wolfram`MCPServer`Common`parsePacletQualifiedName[ "JIRALink/GetIssue" ],
    <| "PacletName" -> "JIRALink", "ItemName" -> "GetIssue" |>,
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-TwoSegment@@Tests/PacletExtension.wlt:63,1-68,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`parsePacletQualifiedName[ "Wolfram/JIRALink/GetIssue" ],
    <| "PacletName" -> "Wolfram/JIRALink", "ItemName" -> "GetIssue" |>,
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-ThreeSegment@@Tests/PacletExtension.wlt:70,1-75,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`parsePacletQualifiedName[ "Wolfram/JIRALink/ProjectManagement" ],
    <| "PacletName" -> "Wolfram/JIRALink", "ItemName" -> "ProjectManagement" |>,
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-ThreeSegmentServer@@Tests/PacletExtension.wlt:77,1-82,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`parsePacletQualifiedName[ "MyPaclet/MyTool" ],
    <| "PacletName" -> "MyPaclet", "ItemName" -> "MyTool" |>,
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-SimpleTwoSegment@@Tests/PacletExtension.wlt:84,1-89,2"
]

(* Invalid inputs should produce failures *)
VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`parsePacletQualifiedName[ "NoSlashHere" ],
    _Failure,
    { MCPServer::Internal },
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-NoSlash@@Tests/PacletExtension.wlt:92,1-98,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`parsePacletQualifiedName[ "A/B/C/D" ],
    _Failure,
    { MCPServer::Internal },
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-TooManySegments@@Tests/PacletExtension.wlt:100,1-106,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*findMCPPaclets*)
VerificationTest[
    Wolfram`MCPServer`Common`findMCPPaclets[ ],
    { ___PacletObject },
    SameTest -> MatchQ,
    TestID   -> "findMCPPaclets-ReturnsList@@Tests/PacletExtension.wlt:111,1-116,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Mock Paclet Setup*)

$testResourceDirectory = FileNameJoin @ { DirectoryName[ $TestFileName, 2 ], "TestResources" };

(* Load mock paclet with per-item definition files *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletTest" };
    $mockPacletTest = First @ PacletFind[ "MockMCPPacletTest" ];
    $mockPacletTest[ "Name" ],
    "MockMCPPacletTest",
    SameTest -> MatchQ,
    TestID   -> "MockPacletSetup-PerItem@@Tests/PacletExtension.wlt:125,1-132,2"
]

(* Load mock paclet with combined definition files *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletCombined" };
    $mockPacletCombined = First @ PacletFind[ "MockMCPPacletCombined" ];
    $mockPacletCombined[ "Name" ],
    "MockMCPPacletCombined",
    SameTest -> MatchQ,
    TestID   -> "MockPacletSetup-Combined@@Tests/PacletExtension.wlt:135,1-142,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*getMCPExtension*)
VerificationTest[
    Wolfram`MCPServer`Common`getMCPExtension[ $mockPacletTest ],
    { "MCP", _Association },
    SameTest -> MatchQ,
    TestID   -> "getMCPExtension-Valid@@Tests/PacletExtension.wlt:147,1-152,2"
]

VerificationTest[
    Module[ { nonMCPPaclet },
        nonMCPPaclet = First @ PacletFind[ "PacletTools" ];
        Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`getMCPExtension[ nonMCPPaclet ]
    ],
    _Failure,
    { MCPServer::PacletExtensionNotFound },
    SameTest -> MatchQ,
    TestID   -> "getMCPExtension-NoExtension@@Tests/PacletExtension.wlt:154,1-163,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*getMCPExtensionData*)
VerificationTest[
    Wolfram`MCPServer`Common`getMCPExtensionData[ $mockPacletTest ],
    _Association? (KeyExistsQ[ #, "Tools" ] &),
    SameTest -> MatchQ,
    TestID   -> "getMCPExtensionData-Valid@@Tests/PacletExtension.wlt:168,1-173,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*getMCPExtensionDirectory*)
VerificationTest[
    Wolfram`MCPServer`Common`getMCPExtensionDirectory[ $mockPacletTest ],
    _String? DirectoryQ,
    SameTest -> MatchQ,
    TestID   -> "getMCPExtensionDirectory-Valid@@Tests/PacletExtension.wlt:178,1-183,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*extractItemName*)
VerificationTest[
    Wolfram`MCPServer`PacletExtension`Private`extractItemName[ "MyTool" ],
    "MyTool",
    SameTest -> MatchQ,
    TestID   -> "extractItemName-StringForm@@Tests/PacletExtension.wlt:188,1-193,2"
]

VerificationTest[
    Wolfram`MCPServer`PacletExtension`Private`extractItemName[ { "MyTool", "A description" } ],
    "MyTool",
    SameTest -> MatchQ,
    TestID   -> "extractItemName-ListForm@@Tests/PacletExtension.wlt:195,1-200,2"
]

VerificationTest[
    Wolfram`MCPServer`PacletExtension`Private`extractItemName[ <| "Name" -> "MyTool", "Description" -> "test" |> ],
    "MyTool",
    SameTest -> MatchQ,
    TestID   -> "extractItemName-AssociationForm@@Tests/PacletExtension.wlt:202,1-207,2"
]

VerificationTest[
    Wolfram`MCPServer`PacletExtension`Private`extractItemName[ 123 ],
    $Failed,
    SameTest -> MatchQ,
    TestID   -> "extractItemName-Invalid@@Tests/PacletExtension.wlt:209,1-214,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*getMCPDeclaredItems*)
VerificationTest[
    Wolfram`MCPServer`Common`getMCPDeclaredItems[ $mockPacletTest, "Tools" ],
    { "TestTool", "DescribedTool", "AssocTool" },
    SameTest -> MatchQ,
    TestID   -> "getMCPDeclaredItems-Tools@@Tests/PacletExtension.wlt:219,1-224,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`getMCPDeclaredItems[ $mockPacletTest, "Servers" ],
    { "TestServer" },
    SameTest -> MatchQ,
    TestID   -> "getMCPDeclaredItems-Servers@@Tests/PacletExtension.wlt:226,1-231,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`getMCPDeclaredItems[ $mockPacletTest, "Prompts" ],
    { "TestPrompt" },
    SameTest -> MatchQ,
    TestID   -> "getMCPDeclaredItems-Prompts@@Tests/PacletExtension.wlt:233,1-238,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`getMCPDeclaredItems[ $mockPacletTest, "NonExistentType" ],
    {},
    SameTest -> MatchQ,
    TestID   -> "getMCPDeclaredItems-EmptyType@@Tests/PacletExtension.wlt:240,1-245,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*findInstalledPaclet*)
VerificationTest[
    Wolfram`MCPServer`Common`findInstalledPaclet[ "MockMCPPacletTest" ],
    _PacletObject,
    SameTest -> MatchQ,
    TestID   -> "findInstalledPaclet-Found@@Tests/PacletExtension.wlt:250,1-255,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`findInstalledPaclet[ "CompletelyNonExistentPaclet12345" ],
    $Failed,
    SameTest -> MatchQ,
    TestID   -> "findInstalledPaclet-NotFound@@Tests/PacletExtension.wlt:257,1-262,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*loadPacletDefinitionFile*)

(* Clear cache before testing *)
VerificationTest[
    Wolfram`MCPServer`Common`clearPacletDefinitionCache[ ];
    Wolfram`MCPServer`PacletExtension`Private`$pacletDefinitionCache,
    <||>,
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-ClearCache@@Tests/PacletExtension.wlt:269,1-275,2"
]

(* Per-item tool file *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "Tools", "TestTool" ],
    KeyValuePattern[ { "Name" -> "TestTool", "Description" -> "A test tool" } ],
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-PerItemTool@@Tests/PacletExtension.wlt:278,1-283,2"
]

(* Per-item server file *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "Servers", "TestServer" ],
    _Association? (KeyExistsQ[ #, "LLMEvaluator" ] &),
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-PerItemServer@@Tests/PacletExtension.wlt:286,1-291,2"
]

(* Per-item prompt file *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "Prompts", "TestPrompt" ],
    KeyValuePattern[ { "Name" -> "TestPrompt" } ],
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-PerItemPrompt@@Tests/PacletExtension.wlt:294,1-299,2"
]

(* Combined file *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletCombined, "Tools", "CombTool1" ],
    KeyValuePattern[ { "Name" -> "CombTool1", "Description" -> "Combined tool 1" } ],
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-CombinedFile@@Tests/PacletExtension.wlt:302,1-307,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletCombined, "Tools", "CombTool2" ],
    KeyValuePattern[ { "Name" -> "CombTool2" } ],
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-CombinedFile2@@Tests/PacletExtension.wlt:309,1-314,2"
]

(* Non-existent item returns $Failed *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "Tools", "NonExistent" ],
    $Failed,
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-NotFound@@Tests/PacletExtension.wlt:317,1-322,2"
]

(* Caching: verify cache is populated after load *)
VerificationTest[
    Wolfram`MCPServer`Common`clearPacletDefinitionCache[ ];
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "Tools", "TestTool" ];
    Length @ Wolfram`MCPServer`PacletExtension`Private`$pacletDefinitionCache > 0,
    True,
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-CachePopulated@@Tests/PacletExtension.wlt:325,1-332,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*resolvePacletTool*)
VerificationTest[
    Wolfram`MCPServer`Common`resolvePacletTool[ "MockMCPPacletTest/TestTool" ],
    KeyValuePattern[ { "Name" -> "TestTool", "Description" -> "A test tool" } ],
    SameTest -> MatchQ,
    TestID   -> "resolvePacletTool-Valid@@Tests/PacletExtension.wlt:337,1-342,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`resolvePacletTool[ "MockMCPPacletTest/DescribedTool" ],
    KeyValuePattern[ { "Name" -> "DescribedTool" } ],
    SameTest -> MatchQ,
    TestID   -> "resolvePacletTool-DescribedTool@@Tests/PacletExtension.wlt:344,1-349,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletTool[ "NonExistentPaclet12345/SomeTool" ],
    _Failure,
    { MCPServer::PacletNotInstalled },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletTool-PacletNotInstalled@@Tests/PacletExtension.wlt:351,1-357,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletTool[ "MockMCPPacletTest/NonExistentTool" ],
    _Failure,
    { MCPServer::PacletToolNotFound },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletTool-ToolNotFound@@Tests/PacletExtension.wlt:359,1-365,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*resolvePacletServer*)
VerificationTest[
    Wolfram`MCPServer`Common`resolvePacletServer[ "MockMCPPacletTest/TestServer" ],
    _Association? (KeyExistsQ[ #, "LLMEvaluator" ] &),
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-Valid@@Tests/PacletExtension.wlt:370,1-375,2"
]

(* Verify name pre-qualification: short names become fully qualified *)
VerificationTest[
    Module[ { def },
        def = Wolfram`MCPServer`Common`resolvePacletServer[ "MockMCPPacletTest/TestServer" ];
        def[ "LLMEvaluator", "Tools" ]
    ],
    { "MockMCPPacletTest/TestTool", "MockMCPPacletTest/DescribedTool" },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-QualifiedToolNames@@Tests/PacletExtension.wlt:378,1-386,2"
]

VerificationTest[
    Module[ { def },
        def = Wolfram`MCPServer`Common`resolvePacletServer[ "MockMCPPacletTest/TestServer" ];
        def[ "LLMEvaluator", "MCPPrompts" ]
    ],
    { "MockMCPPacletTest/TestPrompt" },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-QualifiedPromptNames@@Tests/PacletExtension.wlt:388,1-396,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletServer[ "NonExistentPaclet12345/SomeServer" ],
    _Failure,
    { MCPServer::PacletNotInstalled },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-PacletNotInstalled@@Tests/PacletExtension.wlt:398,1-404,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletServer[ "MockMCPPacletTest/NonExistentServer" ],
    _Failure,
    { MCPServer::PacletServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-ServerNotFound@@Tests/PacletExtension.wlt:406,1-412,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*resolvePacletPrompt*)
VerificationTest[
    Wolfram`MCPServer`Common`resolvePacletPrompt[ "MockMCPPacletTest/TestPrompt" ],
    KeyValuePattern[ { "Name" -> "TestPrompt", "Description" -> "A test prompt" } ],
    SameTest -> MatchQ,
    TestID   -> "resolvePacletPrompt-Valid@@Tests/PacletExtension.wlt:417,1-422,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletPrompt[ "NonExistentPaclet12345/SomePrompt" ],
    _Failure,
    { MCPServer::PacletNotInstalled },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletPrompt-PacletNotInstalled@@Tests/PacletExtension.wlt:424,1-430,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletPrompt[ "MockMCPPacletTest/NonExistentPrompt" ],
    _Failure,
    { MCPServer::PacletPromptNotFound },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletPrompt-PromptNotFound@@Tests/PacletExtension.wlt:432,1-438,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Mock Paclet Cleanup*)
VerificationTest[
    PacletDirectoryUnload @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletTest" };
    PacletDirectoryUnload @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletCombined" };
    Wolfram`MCPServer`Common`clearPacletDefinitionCache[ ],
    <| |>,
    SameTest -> MatchQ,
    TestID   -> "MockPacletCleanup@@Tests/PacletExtension.wlt:443,1-450,2"
]

(* :!CodeAnalysis::EndBlock:: *)
