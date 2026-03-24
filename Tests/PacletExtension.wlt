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

VerificationTest[
    $testResourceDirectory = FileNameJoin @ { DirectoryName[ $TestFileName, 2 ], "TestResources" },
    _? DirectoryQ,
    SameTest -> MatchQ,
    TestID   -> "TestResourcesDirectory@@Tests/PacletExtension.wlt:18,1-23,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Mock Paclet Setup*)
(* Load mock paclet with per-item definition files *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletTest" };
    $mockPacletTest = PacletObject[ "MockMCPPacletTest" ];
    $mockPacletTest[ "Name" ],
    "MockMCPPacletTest",
    SameTest -> MatchQ,
    TestID   -> "MockPacletSetup-PerItem@@Tests/PacletExtension.wlt:29,1-36,2"
]

(* Load mock paclet with combined definition files *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletCombined" };
    $mockPacletCombined = PacletObject[ "MockMCPPacletCombined" ];
    $mockPacletCombined[ "Name" ],
    "MockMCPPacletCombined",
    SameTest -> MatchQ,
    TestID   -> "MockPacletSetup-Combined@@Tests/PacletExtension.wlt:39,1-46,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Resolve MCPServerObject*)
VerificationTest[
    obj = MCPServerObject[ "MockMCPPacletTest/TestServer" ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "ResolveMCPServerObject-Valid@@Tests/PacletExtension.wlt:51,1-56,2"
]

VerificationTest[
    tools = obj[ "Tools" ],
    { __LLMTool },
    SameTest -> MatchQ,
    TestID   -> "ResolveMCPServerObject-Tools@@Tests/PacletExtension.wlt:58,1-63,2"
]

VerificationTest[
    #[ "Name" ] & /@ tools,
    { "TestTool", "DescribedTool", "LLMToolTest" },
    SameTest -> MatchQ,
    TestID   -> "ResolveMCPServerObject-Tools-Names@@Tests/PacletExtension.wlt:65,1-70,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Unit Tests*)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*pacletQualifiedNameQ*)
VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ "Wolfram/JIRALink/GetIssue" ],
    True,
    TestID -> "pacletQualifiedNameQ-ThreeSegment@@Tests/PacletExtension.wlt:82,1-86,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ "JIRALink/GetIssue" ],
    True,
    TestID -> "pacletQualifiedNameQ-TwoSegment@@Tests/PacletExtension.wlt:88,1-92,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ "WolframAlpha" ],
    False,
    TestID -> "pacletQualifiedNameQ-NoSlash@@Tests/PacletExtension.wlt:94,1-98,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ "" ],
    False,
    TestID -> "pacletQualifiedNameQ-EmptyString@@Tests/PacletExtension.wlt:100,1-104,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ 123 ],
    False,
    TestID -> "pacletQualifiedNameQ-NonString@@Tests/PacletExtension.wlt:106,1-110,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`pacletQualifiedNameQ[ ],
    False,
    TestID -> "pacletQualifiedNameQ-NoArgs@@Tests/PacletExtension.wlt:112,1-116,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parsePacletQualifiedName*)
VerificationTest[
    Wolfram`MCPServer`Common`parsePacletQualifiedName[ "JIRALink/GetIssue" ],
    <| "PacletName" -> "JIRALink", "ItemName" -> "GetIssue" |>,
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-TwoSegment@@Tests/PacletExtension.wlt:121,1-126,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`parsePacletQualifiedName[ "Wolfram/JIRALink/GetIssue" ],
    <| "PacletName" -> "Wolfram/JIRALink", "ItemName" -> "GetIssue" |>,
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-ThreeSegment@@Tests/PacletExtension.wlt:128,1-133,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`parsePacletQualifiedName[ "Wolfram/JIRALink/ProjectManagement" ],
    <| "PacletName" -> "Wolfram/JIRALink", "ItemName" -> "ProjectManagement" |>,
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-ThreeSegmentServer@@Tests/PacletExtension.wlt:135,1-140,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`parsePacletQualifiedName[ "MyPaclet/MyTool" ],
    <| "PacletName" -> "MyPaclet", "ItemName" -> "MyTool" |>,
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-SimpleTwoSegment@@Tests/PacletExtension.wlt:142,1-147,2"
]

(* Invalid inputs should produce failures *)
VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`parsePacletQualifiedName[ "NoSlashHere" ],
    _Failure,
    { MCPServer::Internal },
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-NoSlash@@Tests/PacletExtension.wlt:150,1-156,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`parsePacletQualifiedName[ "A/B/C/D" ],
    _Failure,
    { MCPServer::Internal },
    SameTest -> MatchQ,
    TestID   -> "parsePacletQualifiedName-TooManySegments@@Tests/PacletExtension.wlt:158,1-164,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*findAgentToolsPaclets*)
VerificationTest[
    Wolfram`MCPServer`Common`findAgentToolsPaclets[ ],
    { ___PacletObject },
    SameTest -> MatchQ,
    TestID   -> "findAgentToolsPaclets-ReturnsList@@Tests/PacletExtension.wlt:169,1-174,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getAgentToolsExtension*)
VerificationTest[
    Wolfram`MCPServer`Common`getAgentToolsExtension[ $mockPacletTest ],
    { "AgentTools", _Association },
    SameTest -> MatchQ,
    TestID   -> "getAgentToolsExtension-Valid@@Tests/PacletExtension.wlt:179,1-184,2"
]

VerificationTest[
    Module[ { nonMCPPaclet },
        nonMCPPaclet = First @ PacletFind[ "PacletTools" ];
        Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`getAgentToolsExtension[ nonMCPPaclet ]
    ],
    _Failure,
    { MCPServer::PacletExtensionNotFound },
    SameTest -> MatchQ,
    TestID   -> "getAgentToolsExtension-NoExtension@@Tests/PacletExtension.wlt:186,1-195,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getAgentToolsExtensionData*)
VerificationTest[
    Wolfram`MCPServer`Common`getAgentToolsExtensionData[ $mockPacletTest ],
    _Association? (KeyExistsQ[ #, "Tools" ] &),
    SameTest -> MatchQ,
    TestID   -> "getAgentToolsExtensionData-Valid@@Tests/PacletExtension.wlt:200,1-205,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getAgentToolsExtensionDirectory*)
VerificationTest[
    Wolfram`MCPServer`Common`getAgentToolsExtensionDirectory[ $mockPacletTest ],
    _String? DirectoryQ,
    SameTest -> MatchQ,
    TestID   -> "getAgentToolsExtensionDirectory-Valid@@Tests/PacletExtension.wlt:210,1-215,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*extractItemName*)
VerificationTest[
    Wolfram`MCPServer`PacletExtension`Private`extractItemName[ "MyTool" ],
    "MyTool",
    SameTest -> MatchQ,
    TestID   -> "extractItemName-StringForm@@Tests/PacletExtension.wlt:220,1-225,2"
]

VerificationTest[
    Wolfram`MCPServer`PacletExtension`Private`extractItemName[ { "MyTool", "A description" } ],
    "MyTool",
    SameTest -> MatchQ,
    TestID   -> "extractItemName-ListForm@@Tests/PacletExtension.wlt:227,1-232,2"
]

VerificationTest[
    Wolfram`MCPServer`PacletExtension`Private`extractItemName[ <| "Name" -> "MyTool", "Description" -> "test" |> ],
    "MyTool",
    SameTest -> MatchQ,
    TestID   -> "extractItemName-AssociationForm@@Tests/PacletExtension.wlt:234,1-239,2"
]

VerificationTest[
    Wolfram`MCPServer`PacletExtension`Private`extractItemName[ 123 ],
    $Failed,
    SameTest -> MatchQ,
    TestID   -> "extractItemName-Invalid@@Tests/PacletExtension.wlt:241,1-246,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getAgentToolsDeclaredItems*)
VerificationTest[
    Wolfram`MCPServer`Common`getAgentToolsDeclaredItems[ $mockPacletTest, "Tools" ],
    { "TestTool", "DescribedTool", "AssocTool", "LLMToolTest" },
    SameTest -> MatchQ,
    TestID   -> "getAgentToolsDeclaredItems-Tools@@Tests/PacletExtension.wlt:251,1-256,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`getAgentToolsDeclaredItems[ $mockPacletTest, "MCPServers" ],
    { "TestServer" },
    SameTest -> MatchQ,
    TestID   -> "getAgentToolsDeclaredItems-MCPServers@@Tests/PacletExtension.wlt:258,1-263,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`getAgentToolsDeclaredItems[ $mockPacletTest, "MCPPrompts" ],
    { "TestPrompt" },
    SameTest -> MatchQ,
    TestID   -> "getAgentToolsDeclaredItems-MCPPrompts@@Tests/PacletExtension.wlt:265,1-270,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`getAgentToolsDeclaredItems[ $mockPacletTest, "NonExistentType" ],
    { },
    SameTest -> MatchQ,
    TestID   -> "getAgentToolsDeclaredItems-EmptyType@@Tests/PacletExtension.wlt:272,1-277,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*findInstalledPaclet*)
VerificationTest[
    Wolfram`MCPServer`Common`findInstalledPaclet[ "MockMCPPacletTest" ],
    _PacletObject,
    SameTest -> MatchQ,
    TestID   -> "findInstalledPaclet-Found@@Tests/PacletExtension.wlt:282,1-287,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`findInstalledPaclet[ "CompletelyNonExistentPaclet12345" ],
    _Failure,
    SameTest -> MatchQ,
    TestID   -> "findInstalledPaclet-NotFound@@Tests/PacletExtension.wlt:289,1-294,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*loadPacletDefinitionFile*)

(* Clear cache before testing *)
VerificationTest[
    Wolfram`MCPServer`Common`clearPacletDefinitionCache[ ];
    Wolfram`MCPServer`PacletExtension`Private`$pacletDefinitionCache,
    <| |>,
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-ClearCache@@Tests/PacletExtension.wlt:301,1-307,2"
]

(* Per-item tool file *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "Tools", "TestTool" ],
    KeyValuePattern[ { "Name" -> "TestTool", "Description" -> "A test tool" } ],
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-PerItemTool@@Tests/PacletExtension.wlt:310,1-315,2"
]

(* Per-item server file *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "MCPServers", "TestServer" ],
    _Association? (KeyExistsQ[ #, "LLMEvaluator" ] &),
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-PerItemServer@@Tests/PacletExtension.wlt:318,1-323,2"
]

(* Per-item prompt file *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "MCPPrompts", "TestPrompt" ],
    KeyValuePattern[ { "Name" -> "TestPrompt" } ],
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-PerItemPrompt@@Tests/PacletExtension.wlt:326,1-331,2"
]

(* Combined file *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletCombined, "Tools", "CombTool1" ],
    KeyValuePattern[ { "Name" -> "CombTool1", "Description" -> "Combined tool 1" } ],
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-CombinedFile@@Tests/PacletExtension.wlt:334,1-339,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletCombined, "Tools", "CombTool2" ],
    KeyValuePattern[ { "Name" -> "CombTool2" } ],
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-CombinedFile2@@Tests/PacletExtension.wlt:341,1-346,2"
]

(* Non-existent item returns $Failed *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "Tools", "NonExistent" ],
    $Failed,
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-NotFound@@Tests/PacletExtension.wlt:349,1-354,2"
]

(* Caching: verify cache is populated after load *)
VerificationTest[
    Wolfram`MCPServer`Common`clearPacletDefinitionCache[ ];
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "Tools", "TestTool" ];
    Length @ Wolfram`MCPServer`PacletExtension`Private`$pacletDefinitionCache > 0,
    True,
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-CachePopulated@@Tests/PacletExtension.wlt:357,1-364,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*resolvePacletTool*)
VerificationTest[
    Wolfram`MCPServer`Common`resolvePacletTool[ "MockMCPPacletTest/TestTool" ],
    KeyValuePattern[ { "Name" -> "TestTool", "Description" -> "A test tool" } ],
    SameTest -> MatchQ,
    TestID   -> "resolvePacletTool-Valid@@Tests/PacletExtension.wlt:369,1-374,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`resolvePacletTool[ "MockMCPPacletTest/DescribedTool" ],
    KeyValuePattern[ { "Name" -> "DescribedTool" } ],
    SameTest -> MatchQ,
    TestID   -> "resolvePacletTool-DescribedTool@@Tests/PacletExtension.wlt:376,1-381,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletTool[ "NonExistentPaclet12345/SomeTool" ],
    _Failure,
    { MCPServer::PacletNotInstalled },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletTool-PacletNotInstalled@@Tests/PacletExtension.wlt:383,1-389,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletTool[ "MockMCPPacletTest/NonExistentTool" ],
    _Failure,
    { MCPServer::PacletToolNotFound },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletTool-ToolNotFound@@Tests/PacletExtension.wlt:391,1-397,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*resolvePacletServer*)
VerificationTest[
    Wolfram`MCPServer`Common`resolvePacletServer[ "MockMCPPacletTest/TestServer" ],
    _Association? (KeyExistsQ[ #, "LLMEvaluator" ] &),
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-Valid@@Tests/PacletExtension.wlt:402,1-407,2"
]

(* Verify name pre-qualification: short names become fully qualified *)
VerificationTest[
    Module[ { def },
        def = Wolfram`MCPServer`Common`resolvePacletServer[ "MockMCPPacletTest/TestServer" ];
        def[ "LLMEvaluator", "Tools" ]
    ],
    { "MockMCPPacletTest/TestTool", "MockMCPPacletTest/DescribedTool", "MockMCPPacletTest/LLMToolTest" },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-QualifiedToolNames@@Tests/PacletExtension.wlt:410,1-418,2"
]

VerificationTest[
    Module[ { def },
        def = Wolfram`MCPServer`Common`resolvePacletServer[ "MockMCPPacletTest/TestServer" ];
        def[ "LLMEvaluator", "MCPPrompts" ]
    ],
    { "MockMCPPacletTest/TestPrompt" },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-QualifiedPromptNames@@Tests/PacletExtension.wlt:420,1-428,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletServer[ "NonExistentPaclet12345/SomeServer" ],
    _Failure,
    { MCPServer::PacletNotInstalled },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-PacletNotInstalled@@Tests/PacletExtension.wlt:430,1-436,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletServer[ "MockMCPPacletTest/NonExistentServer" ],
    _Failure,
    { MCPServer::PacletServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-ServerNotFound@@Tests/PacletExtension.wlt:438,1-444,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*resolvePacletPrompt*)
VerificationTest[
    Wolfram`MCPServer`Common`resolvePacletPrompt[ "MockMCPPacletTest/TestPrompt" ],
    KeyValuePattern[ { "Name" -> "TestPrompt", "Description" -> "A test prompt" } ],
    SameTest -> MatchQ,
    TestID   -> "resolvePacletPrompt-Valid@@Tests/PacletExtension.wlt:449,1-454,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletPrompt[ "NonExistentPaclet12345/SomePrompt" ],
    _Failure,
    { MCPServer::PacletNotInstalled },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletPrompt-PacletNotInstalled@@Tests/PacletExtension.wlt:456,1-462,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletPrompt[ "MockMCPPacletTest/NonExistentPrompt" ],
    _Failure,
    { MCPServer::PacletPromptNotFound },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletPrompt-PromptNotFound@@Tests/PacletExtension.wlt:464,1-470,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Remote Paclet Fallback*)

(* Use the real remote paclet from the Paclet Repository *)
VerificationTest[
    $remotePaclet = First @ Replace[
        PacletFindRemote[ "SamplePublisher/SamplePaclet", <| "Extension" -> "AgentTools" |> ],
        { } :> PacletFindRemote[
            "SamplePublisher/SamplePaclet",
            <| "Extension" -> "AgentTools" |>,
            UpdatePacletSites -> True
        ]
    ];
    PacletObjectQ @ $remotePaclet,
    True,
    SameTest -> MatchQ,
    TestID -> "RemotePacletFallback-Setup@@Tests/PacletExtension.wlt:477,1-490,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`getAgentToolsDeclaredItems[ $remotePaclet, "MCPServers" ],
    { "SampleServer" },
    SameTest -> MatchQ,
    TestID -> "RemotePacletFallback-MCPServers@@Tests/PacletExtension.wlt:492,1-497,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`getAgentToolsDeclaredItems[ $remotePaclet, "Tools" ],
    { "Identity", "PrimeFinder" },
    SameTest -> MatchQ,
    TestID -> "RemotePacletFallback-Tools@@Tests/PacletExtension.wlt:499,1-504,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`getAgentToolsDeclaredItems[ $remotePaclet, "MCPPrompts" ],
    { },
    SameTest -> MatchQ,
    TestID -> "RemotePacletFallback-EmptyPrompts@@Tests/PacletExtension.wlt:506,1-511,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Remote Server Resolution*)

VerificationTest[
    $remoteServer = MCPServerObject[ "SamplePublisher/SamplePaclet/SampleServer" ];
    Head @ $remoteServer,
    MCPServerObject,
    SameTest -> MatchQ,
    TestID -> "RemoteServerResolution-NoFailure@@Tests/PacletExtension.wlt:517,1-523,2"
]

VerificationTest[
    $remoteServer[ "ToolNames" ],
    { "SamplePublisher/SamplePaclet/Identity", "SamplePublisher/SamplePaclet/PrimeFinder" },
    SameTest -> MatchQ,
    TestID -> "RemoteServerResolution-ToolNames@@Tests/PacletExtension.wlt:525,1-530,2"
]

(* If paclet is installed, we get a list of LLMTools, otherwise we should get a Failure *)
VerificationTest[
    Quiet[ $remoteServer[ "Tools" ], MCPServerObject::PacletNotInstalled ],
    If[ Quiet @ PacletObjectQ @ PacletObject[ "SamplePublisher/SamplePaclet" ],
        { __LLMTool },
        Failure[ "MCPServerObject::PacletNotInstalled", _ ]
    ],
    SameTest -> MatchQ,
    TestID -> "RemoteServerResolution-Tools@@Tests/PacletExtension.wlt:533,1-541,2"
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
    TestID   -> "MockPacletCleanup@@Tests/PacletExtension.wlt:546,1-553,2"
]

(* :!CodeAnalysis::EndBlock:: *)
