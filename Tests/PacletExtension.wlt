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
    TestID   -> "MockPacletSetup-PerItem"
]

(* Load mock paclet with combined definition files *)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletCombined" };
    $mockPacletCombined = First @ PacletFind[ "MockMCPPacletCombined" ];
    $mockPacletCombined[ "Name" ],
    "MockMCPPacletCombined",
    SameTest -> MatchQ,
    TestID   -> "MockPacletSetup-Combined"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*getMCPExtension*)
VerificationTest[
    Wolfram`MCPServer`Common`getMCPExtension[ $mockPacletTest ],
    { "MCP", _Association },
    SameTest -> MatchQ,
    TestID   -> "getMCPExtension-Valid"
]

VerificationTest[
    Module[ { nonMCPPaclet },
        nonMCPPaclet = First @ PacletFind[ "PacletTools" ];
        Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`getMCPExtension[ nonMCPPaclet ]
    ],
    _Failure,
    { MCPServer::PacletExtensionNotFound },
    SameTest -> MatchQ,
    TestID   -> "getMCPExtension-NoExtension"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*getMCPExtensionData*)
VerificationTest[
    Wolfram`MCPServer`Common`getMCPExtensionData[ $mockPacletTest ],
    _Association? (KeyExistsQ[ #, "Tools" ] &),
    SameTest -> MatchQ,
    TestID   -> "getMCPExtensionData-Valid"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*getMCPExtensionDirectory*)
VerificationTest[
    Wolfram`MCPServer`Common`getMCPExtensionDirectory[ $mockPacletTest ],
    _String? DirectoryQ,
    SameTest -> MatchQ,
    TestID   -> "getMCPExtensionDirectory-Valid"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*extractItemName*)
VerificationTest[
    Wolfram`MCPServer`PacletExtension`Private`extractItemName[ "MyTool" ],
    "MyTool",
    SameTest -> MatchQ,
    TestID   -> "extractItemName-StringForm"
]

VerificationTest[
    Wolfram`MCPServer`PacletExtension`Private`extractItemName[ { "MyTool", "A description" } ],
    "MyTool",
    SameTest -> MatchQ,
    TestID   -> "extractItemName-ListForm"
]

VerificationTest[
    Wolfram`MCPServer`PacletExtension`Private`extractItemName[ <| "Name" -> "MyTool", "Description" -> "test" |> ],
    "MyTool",
    SameTest -> MatchQ,
    TestID   -> "extractItemName-AssociationForm"
]

VerificationTest[
    Wolfram`MCPServer`PacletExtension`Private`extractItemName[ 123 ],
    $Failed,
    SameTest -> MatchQ,
    TestID   -> "extractItemName-Invalid"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*getMCPDeclaredItems*)
VerificationTest[
    Wolfram`MCPServer`Common`getMCPDeclaredItems[ $mockPacletTest, "Tools" ],
    { "TestTool", "DescribedTool", "AssocTool" },
    SameTest -> MatchQ,
    TestID   -> "getMCPDeclaredItems-Tools"
]

VerificationTest[
    Wolfram`MCPServer`Common`getMCPDeclaredItems[ $mockPacletTest, "Servers" ],
    { "TestServer" },
    SameTest -> MatchQ,
    TestID   -> "getMCPDeclaredItems-Servers"
]

VerificationTest[
    Wolfram`MCPServer`Common`getMCPDeclaredItems[ $mockPacletTest, "Prompts" ],
    { "TestPrompt" },
    SameTest -> MatchQ,
    TestID   -> "getMCPDeclaredItems-Prompts"
]

VerificationTest[
    Wolfram`MCPServer`Common`getMCPDeclaredItems[ $mockPacletTest, "NonExistentType" ],
    {},
    SameTest -> MatchQ,
    TestID   -> "getMCPDeclaredItems-EmptyType"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*findInstalledPaclet*)
VerificationTest[
    Wolfram`MCPServer`Common`findInstalledPaclet[ "MockMCPPacletTest" ],
    _PacletObject,
    SameTest -> MatchQ,
    TestID   -> "findInstalledPaclet-Found"
]

VerificationTest[
    Wolfram`MCPServer`Common`findInstalledPaclet[ "CompletelyNonExistentPaclet12345" ],
    $Failed,
    SameTest -> MatchQ,
    TestID   -> "findInstalledPaclet-NotFound"
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
    TestID   -> "loadPacletDefinitionFile-ClearCache"
]

(* Per-item tool file *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "Tools", "TestTool" ],
    KeyValuePattern[ { "Name" -> "TestTool", "Description" -> "A test tool" } ],
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-PerItemTool"
]

(* Per-item server file *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "Servers", "TestServer" ],
    _Association? (KeyExistsQ[ #, "LLMEvaluator" ] &),
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-PerItemServer"
]

(* Per-item prompt file *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "Prompts", "TestPrompt" ],
    KeyValuePattern[ { "Name" -> "TestPrompt" } ],
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-PerItemPrompt"
]

(* Combined file *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletCombined, "Tools", "CombTool1" ],
    KeyValuePattern[ { "Name" -> "CombTool1", "Description" -> "Combined tool 1" } ],
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-CombinedFile"
]

VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletCombined, "Tools", "CombTool2" ],
    KeyValuePattern[ { "Name" -> "CombTool2" } ],
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-CombinedFile2"
]

(* Non-existent item returns $Failed *)
VerificationTest[
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "Tools", "NonExistent" ],
    $Failed,
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-NotFound"
]

(* Caching: verify cache is populated after load *)
VerificationTest[
    Wolfram`MCPServer`Common`clearPacletDefinitionCache[ ];
    Wolfram`MCPServer`Common`loadPacletDefinitionFile[ $mockPacletTest, "Tools", "TestTool" ];
    Length @ Wolfram`MCPServer`PacletExtension`Private`$pacletDefinitionCache > 0,
    True,
    SameTest -> MatchQ,
    TestID   -> "loadPacletDefinitionFile-CachePopulated"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*resolvePacletTool*)
VerificationTest[
    Wolfram`MCPServer`Common`resolvePacletTool[ "MockMCPPacletTest/TestTool" ],
    KeyValuePattern[ { "Name" -> "TestTool", "Description" -> "A test tool" } ],
    SameTest -> MatchQ,
    TestID   -> "resolvePacletTool-Valid"
]

VerificationTest[
    Wolfram`MCPServer`Common`resolvePacletTool[ "MockMCPPacletTest/DescribedTool" ],
    KeyValuePattern[ { "Name" -> "DescribedTool" } ],
    SameTest -> MatchQ,
    TestID   -> "resolvePacletTool-DescribedTool"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletTool[ "NonExistentPaclet12345/SomeTool" ],
    _Failure,
    { MCPServer::PacletNotInstalled },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletTool-PacletNotInstalled"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletTool[ "MockMCPPacletTest/NonExistentTool" ],
    _Failure,
    { MCPServer::PacletToolNotFound },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletTool-ToolNotFound"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*resolvePacletServer*)
VerificationTest[
    Wolfram`MCPServer`Common`resolvePacletServer[ "MockMCPPacletTest/TestServer" ],
    _Association? (KeyExistsQ[ #, "LLMEvaluator" ] &),
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-Valid"
]

(* Verify name pre-qualification: short names become fully qualified *)
VerificationTest[
    Module[ { def },
        def = Wolfram`MCPServer`Common`resolvePacletServer[ "MockMCPPacletTest/TestServer" ];
        def[ "LLMEvaluator", "Tools" ]
    ],
    { "MockMCPPacletTest/TestTool", "MockMCPPacletTest/DescribedTool" },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-QualifiedToolNames"
]

VerificationTest[
    Module[ { def },
        def = Wolfram`MCPServer`Common`resolvePacletServer[ "MockMCPPacletTest/TestServer" ];
        def[ "LLMEvaluator", "MCPPrompts" ]
    ],
    { "MockMCPPacletTest/TestPrompt" },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-QualifiedPromptNames"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletServer[ "NonExistentPaclet12345/SomeServer" ],
    _Failure,
    { MCPServer::PacletNotInstalled },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-PacletNotInstalled"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletServer[ "MockMCPPacletTest/NonExistentServer" ],
    _Failure,
    { MCPServer::PacletServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletServer-ServerNotFound"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*resolvePacletPrompt*)
VerificationTest[
    Wolfram`MCPServer`Common`resolvePacletPrompt[ "MockMCPPacletTest/TestPrompt" ],
    KeyValuePattern[ { "Name" -> "TestPrompt", "Description" -> "A test prompt" } ],
    SameTest -> MatchQ,
    TestID   -> "resolvePacletPrompt-Valid"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletPrompt[ "NonExistentPaclet12345/SomePrompt" ],
    _Failure,
    { MCPServer::PacletNotInstalled },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletPrompt-PacletNotInstalled"
]

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @ Wolfram`MCPServer`Common`resolvePacletPrompt[ "MockMCPPacletTest/NonExistentPrompt" ],
    _Failure,
    { MCPServer::PacletPromptNotFound },
    SameTest -> MatchQ,
    TestID   -> "resolvePacletPrompt-PromptNotFound"
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
    TestID   -> "MockPacletCleanup"
]

(* :!CodeAnalysis::EndBlock:: *)
