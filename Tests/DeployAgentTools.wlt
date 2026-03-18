(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/DeployAgentTools.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/DeployAgentTools.wlt:11,1-16,2"
]

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Helper Functions*)

$testDeploymentData := <|
    "UUID"          -> CreateUUID[],
    "Version"       -> 1,
    "Timestamp"     -> Now,
    "PacletVersion" -> "1.8.0",
    "CreatedBy"     -> "DeployAgentTools",
    "MCP"           -> <|
        "ClientName" -> "ClaudeDesktop",
        "Target"     -> "ClaudeDesktop",
        "Server"     -> "WolframLanguage",
        "ConfigFile" -> File[ FileNameJoin @ { $TemporaryDirectory, "test_config_" <> CreateUUID[] <> ".json" } ],
        "Options"    -> <|"DevelopmentMode" -> False|>
    |>,
    "Skills"        -> <||>,
    "Hooks"         -> <||>,
    "Meta"          -> <||>
|>;

agentToolsDeploymentQ = Wolfram`MCPServer`DeployAgentTools`Private`agentToolsDeploymentQ;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*AgentToolsDeployment Construction*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Valid Construction*)
VerificationTest[
    dep = AgentToolsDeployment[ $testDeploymentData ],
    _AgentToolsDeployment,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-ValidConstruction@@Tests/DeployAgentTools.wlt:52,1-57,2"
]

VerificationTest[
    agentToolsDeploymentQ @ dep,
    True,
    TestID -> "AgentToolsDeployment-ValidQ@@Tests/DeployAgentTools.wlt:59,1-63,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Invalid Construction*)
VerificationTest[
    AgentToolsDeployment[ "not an association" ],
    _Failure,
    { AgentToolsDeployment::InvalidDeploymentData },
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-InvalidString@@Tests/DeployAgentTools.wlt:68,1-74,2"
]

VerificationTest[
    AgentToolsDeployment[ <|"UUID" -> "test"|> ],
    _Failure,
    { AgentToolsDeployment::InvalidDeploymentData },
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-InvalidIncompleteData@@Tests/DeployAgentTools.wlt:76,1-82,2"
]

VerificationTest[
    AgentToolsDeployment[ <||> ],
    _Failure,
    { AgentToolsDeployment::InvalidDeploymentData },
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-InvalidEmptyAssociation@@Tests/DeployAgentTools.wlt:84,1-90,2"
]

VerificationTest[
    Quiet @ agentToolsDeploymentQ @ AgentToolsDeployment[ <||> ],
    False,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-InvalidNotValidQ@@Tests/DeployAgentTools.wlt:92,1-97,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Property Access*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Top-Level Properties*)
VerificationTest[
    dep[ "UUID" ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-UUID@@Tests/DeployAgentTools.wlt:106,1-111,2"
]

VerificationTest[
    dep[ "Timestamp" ],
    _DateObject,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Timestamp@@Tests/DeployAgentTools.wlt:113,1-118,2"
]

VerificationTest[
    dep[ "PacletVersion" ],
    "1.8.0",
    TestID -> "AgentToolsDeployment-Property-PacletVersion@@Tests/DeployAgentTools.wlt:120,1-124,2"
]

VerificationTest[
    dep[ "CreatedBy" ],
    "DeployAgentTools",
    TestID -> "AgentToolsDeployment-Property-CreatedBy@@Tests/DeployAgentTools.wlt:126,1-130,2"
]

VerificationTest[
    dep[ "Version" ],
    _Missing,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Version-Missing@@Tests/DeployAgentTools.wlt:132,1-137,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*MCP Shortcut Properties*)
VerificationTest[
    dep[ "ClientName" ],
    "ClaudeDesktop",
    TestID -> "AgentToolsDeployment-Property-ClientName@@Tests/DeployAgentTools.wlt:142,1-146,2"
]

VerificationTest[
    dep[ "Target" ],
    "ClaudeDesktop",
    TestID -> "AgentToolsDeployment-Property-Target@@Tests/DeployAgentTools.wlt:148,1-152,2"
]

VerificationTest[
    dep[ "Server" ],
    "WolframLanguage",
    TestID -> "AgentToolsDeployment-Property-Server@@Tests/DeployAgentTools.wlt:154,1-158,2"
]

VerificationTest[
    dep[ "ConfigFile" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-ConfigFile@@Tests/DeployAgentTools.wlt:160,1-165,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Sub-Association Properties*)
VerificationTest[
    dep[ "MCP" ],
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-MCP@@Tests/DeployAgentTools.wlt:170,1-175,2"
]

VerificationTest[
    dep[ "Skills" ],
    <||>,
    TestID -> "AgentToolsDeployment-Property-Skills@@Tests/DeployAgentTools.wlt:177,1-181,2"
]

VerificationTest[
    dep[ "Hooks" ],
    <||>,
    TestID -> "AgentToolsDeployment-Property-Hooks@@Tests/DeployAgentTools.wlt:183,1-187,2"
]

VerificationTest[
    dep[ "Meta" ],
    <||>,
    TestID -> "AgentToolsDeployment-Property-Meta@@Tests/DeployAgentTools.wlt:189,1-193,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Derived Properties*)
VerificationTest[
    dep[ "Data" ],
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Data@@Tests/DeployAgentTools.wlt:198,1-203,2"
]

VerificationTest[
    dep[ "Location" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Location@@Tests/DeployAgentTools.wlt:205,1-210,2"
]

VerificationTest[
    dep[ "Properties" ],
    _List,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Properties@@Tests/DeployAgentTools.wlt:212,1-217,2"
]

VerificationTest[
    MemberQ[ dep[ "Properties" ], "UUID" ],
    True,
    TestID -> "AgentToolsDeployment-Property-PropertiesContainsUUID@@Tests/DeployAgentTools.wlt:219,1-223,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Two-Argument Property Access*)
VerificationTest[
    dep[ "MCP", "Options" ],
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-MCP-Options@@Tests/DeployAgentTools.wlt:228,1-233,2"
]

VerificationTest[
    dep[ "MCP", "Server" ],
    "WolframLanguage",
    TestID -> "AgentToolsDeployment-Property-MCP-Server@@Tests/DeployAgentTools.wlt:235,1-239,2"
]

VerificationTest[
    dep[ "MCP", "ClientName" ],
    "ClaudeDesktop",
    TestID -> "AgentToolsDeployment-Property-MCP-ClientName@@Tests/DeployAgentTools.wlt:241,1-245,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Unknown Property*)
VerificationTest[
    dep[ "NonexistentProperty" ],
    _Missing,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Unknown@@Tests/DeployAgentTools.wlt:250,1-255,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Invalid Property*)
VerificationTest[
    dep[ 42 ],
    _Failure,
    { AgentToolsDeployment::InvalidProperty },
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Invalid@@Tests/DeployAgentTools.wlt:260,1-266,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Formatting*)
VerificationTest[
    With[ { obj = AgentToolsDeployment[ $testDeploymentData ] },
        MakeBoxes[ obj, StandardForm ]
    ],
    _InterpretationBox,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Formatting-MakeBoxes@@Tests/DeployAgentTools.wlt:271,1-278,2"
]

VerificationTest[
    (* Invalid objects should not produce formatted boxes *)
    MakeBoxes[ AgentToolsDeployment[ <||> ], StandardForm ],
    _InterpretationBox,
    SameTest -> Not @* MatchQ,
    TestID   -> "AgentToolsDeployment-Formatting-InvalidNoBoxes@@Tests/DeployAgentTools.wlt:280,1-286,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Validation Edge Cases*)

(* Missing required keys *)
VerificationTest[
    AgentToolsDeployment[ <|
        "UUID"     -> "test-uuid",
        "Version"  -> 1,
        "MCP"      -> <||>
    |> ],
    _Failure,
    { AgentToolsDeployment::InvalidDeploymentData },
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Validation-MissingKeys@@Tests/DeployAgentTools.wlt:293,1-303,2"
]

(* Wrong types for required keys *)
VerificationTest[
    AgentToolsDeployment[ <|
        "UUID"          -> 123,
        "Version"       -> 1,
        "Timestamp"     -> Now,
        "PacletVersion" -> "1.8.0",
        "CreatedBy"     -> "DeployAgentTools",
        "MCP"           -> <|
            "ClientName" -> "Test",
            "Target"     -> "Test",
            "Server"     -> "Test",
            "ConfigFile" -> File[ "/tmp/test.json" ],
            "Options"    -> <||>
        |>,
        "Skills"        -> <||>,
        "Hooks"         -> <||>,
        "Meta"          -> <||>
    |> ],
    _Failure,
    { AgentToolsDeployment::InvalidDeploymentData },
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Validation-WrongUUIDType@@Tests/DeployAgentTools.wlt:306,1-328,2"
]

(* Valid with None ClientName *)
VerificationTest[
    AgentToolsDeployment[ <|
        "UUID"          -> CreateUUID[],
        "Version"       -> 1,
        "Timestamp"     -> Now,
        "PacletVersion" -> "1.8.0",
        "CreatedBy"     -> "DeployAgentTools",
        "MCP"           -> <|
            "ClientName" -> None,
            "Target"     -> File[ "/tmp/test.json" ],
            "Server"     -> "Wolfram",
            "ConfigFile" -> File[ "/tmp/test.json" ],
            "Options"    -> <||>
        |>,
        "Skills"        -> <||>,
        "Hooks"         -> <||>,
        "Meta"          -> <||>
    |> ],
    _AgentToolsDeployment,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Validation-NoneClientName@@Tests/DeployAgentTools.wlt:331,1-352,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Multiple Objects*)
VerificationTest[
    dep1 = AgentToolsDeployment[ $testDeploymentData ];
    dep2 = AgentToolsDeployment[ $testDeploymentData ];
    dep1[ "UUID" ] =!= dep2[ "UUID" ],
    True,
    TestID -> "AgentToolsDeployment-MultipleObjects-UniqueUUIDs@@Tests/DeployAgentTools.wlt:357,1-363,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*DeployAgentTools*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Setup*)
VerificationTest[
    $deployTestDir = CreateDirectory[ ];
    $deployTestConfig = File[ FileNameJoin @ { $deployTestDir, "test_mcp_config.json" } ];
    FileExistsQ @ $deployTestDir,
    True,
    TestID -> "DeployAgentTools-Setup@@Tests/DeployAgentTools.wlt:372,1-378,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Deployment*)
VerificationTest[
    $dep1 = DeployAgentTools[ $deployTestConfig, "Wolfram", "VerifyLLMKit" -> False ],
    _AgentToolsDeployment,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-BasicDeploy@@Tests/DeployAgentTools.wlt:383,1-388,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Returned Object Properties*)
VerificationTest[
    $dep1[ "Server" ],
    "Wolfram",
    TestID -> "DeployAgentTools-Property-Server@@Tests/DeployAgentTools.wlt:393,1-397,2"
]

VerificationTest[
    $dep1[ "ConfigFile" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-ConfigFile@@Tests/DeployAgentTools.wlt:399,1-404,2"
]

VerificationTest[
    $dep1[ "UUID" ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-UUID@@Tests/DeployAgentTools.wlt:406,1-411,2"
]

VerificationTest[
    $dep1[ "Timestamp" ],
    _DateObject,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-Timestamp@@Tests/DeployAgentTools.wlt:413,1-418,2"
]

VerificationTest[
    $dep1[ "CreatedBy" ],
    "DeployAgentTools",
    TestID -> "DeployAgentTools-Property-CreatedBy@@Tests/DeployAgentTools.wlt:420,1-424,2"
]

VerificationTest[
    $dep1[ "PacletVersion" ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-PacletVersion@@Tests/DeployAgentTools.wlt:426,1-431,2"
]

VerificationTest[
    $dep1[ "Target" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-Target@@Tests/DeployAgentTools.wlt:433,1-438,2"
]

VerificationTest[
    $dep1[ "MCP" ],
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-MCP@@Tests/DeployAgentTools.wlt:440,1-445,2"
]

VerificationTest[
    $dep1[ "MCP", "Options" ],
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-MCP-Options@@Tests/DeployAgentTools.wlt:447,1-452,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config File Updated*)
VerificationTest[
    FileExistsQ @ $deployTestConfig,
    True,
    TestID -> "DeployAgentTools-ConfigFileExists@@Tests/DeployAgentTools.wlt:457,1-461,2"
]

VerificationTest[
    Module[ { json },
        json = Developer`ReadRawJSONString @ ReadString @ First @ $deployTestConfig;
        KeyExistsQ[ json, "mcpServers" ] && KeyExistsQ[ json[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    TestID -> "DeployAgentTools-ConfigFileHasServerEntry@@Tests/DeployAgentTools.wlt:463,1-470,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Deployment Record on Disk*)
VerificationTest[
    $dep1[ "Location" ],
    _File? DirectoryQ,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-DeploymentDirExists@@Tests/DeployAgentTools.wlt:475,1-480,2"
]

VerificationTest[
    FileExistsQ @ FileNameJoin @ { First @ $dep1[ "Location" ], "Deployment.wxf" },
    True,
    TestID -> "DeployAgentTools-DeploymentWXFExists@@Tests/DeployAgentTools.wlt:482,1-486,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*OverwriteTarget -> False Fails*)
VerificationTest[
    DeployAgentTools[ $deployTestConfig, "Wolfram", "VerifyLLMKit" -> False ],
    _Failure,
    { DeployAgentTools::DeploymentExists },
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-DuplicateFails@@Tests/DeployAgentTools.wlt:491,1-497,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*OverwriteTarget -> True Replaces*)
VerificationTest[
    $dep2 = DeployAgentTools[
        $deployTestConfig,
        "Wolfram",
        OverwriteTarget  -> True,
        "VerifyLLMKit"   -> False
    ],
    _AgentToolsDeployment,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-OverwriteTrue@@Tests/DeployAgentTools.wlt:502,1-512,2"
]

VerificationTest[
    $dep2[ "UUID" ] =!= $dep1[ "UUID" ],
    True,
    TestID -> "DeployAgentTools-OverwriteNewUUID@@Tests/DeployAgentTools.wlt:514,1-518,2"
]

VerificationTest[
    (* The old deployment directory should have been cleaned up *)
    ! DirectoryQ @ First @ $dep1[ "Location" ],
    True,
    TestID -> "DeployAgentTools-OverwriteOldDirRemoved@@Tests/DeployAgentTools.wlt:520,1-525,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Equivalent Target Forms*)
VerificationTest[
    $deployTestDir2 = CreateDirectory[ ];
    $dep3 = DeployAgentTools[
        { "ClaudeCode", $deployTestDir2 },
        "Wolfram",
        "VerifyLLMKit" -> False
    ],
    _AgentToolsDeployment,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-ProjectDeploy@@Tests/DeployAgentTools.wlt:530,1-540,2"
]

VerificationTest[
    $dep3[ "ClientName" ],
    "ClaudeCode",
    TestID -> "DeployAgentTools-ProjectDeploy-ClientName@@Tests/DeployAgentTools.wlt:542,1-546,2"
]

VerificationTest[
    $dep3[ "Target" ],
    { "ClaudeCode", $deployTestDir2 },
    TestID -> "DeployAgentTools-ProjectDeploy-Target@@Tests/DeployAgentTools.wlt:548,1-552,2"
]

VerificationTest[
    (* Deploy to the same config file via File target — should fail as duplicate *)
    DeployAgentTools[
        File[ FileNameJoin @ { $deployTestDir2, ".mcp.json" } ],
        "Wolfram",
        "VerifyLLMKit" -> False
    ],
    _Failure,
    { DeployAgentTools::DeploymentExists },
    SameTest -> MatchQ,
    TestID   -"DeployAgentTools-EquivalentTargetFails@@Tests/DeployAgentTools.wlt:554,1-565,2"s"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup*)
VerificationTest[
    Quiet[
        catchAlways @ DeleteObject @ $dep2;
        catchAlways @ DeleteObject @ $dep3;
        Quiet @ DeleteDirectory[ $deployTestDir, DeleteContents -> True ];
        Quiet @ DeleteDirectory[ $deployTestDir2, DeleteContents -> True ];
    ];
    True,
    True,
    TestID -"DeployAgentTools-Cleanup@@Tests/DeployAgentTools.wlt:570,1-580,2"p"
]

(* :!CodeAnalysis::EndBlock:: *)
