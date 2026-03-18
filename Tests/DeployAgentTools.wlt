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
configFilesEqual = Wolfram`MCPServer`DeployAgentTools`Private`configFilesEqual;
$deploymentsPath = Wolfram`MCPServer`Common`$deploymentsPath;

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
    TestID   -> "AgentToolsDeployment-ValidConstruction@@Tests/DeployAgentTools.wlt:54,1-59,2"
]

VerificationTest[
    agentToolsDeploymentQ @ dep,
    True,
    TestID -> "AgentToolsDeployment-ValidQ@@Tests/DeployAgentTools.wlt:61,1-65,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Invalid Construction*)
VerificationTest[
    AgentToolsDeployment[ "not an association" ],
    _Failure,
    { AgentToolsDeployment::InvalidDeploymentData },
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-InvalidString@@Tests/DeployAgentTools.wlt:70,1-76,2"
]

VerificationTest[
    AgentToolsDeployment[ <|"UUID" -> "test"|> ],
    _Failure,
    { AgentToolsDeployment::InvalidDeploymentData },
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-InvalidIncompleteData@@Tests/DeployAgentTools.wlt:78,1-84,2"
]

VerificationTest[
    AgentToolsDeployment[ <||> ],
    _Failure,
    { AgentToolsDeployment::InvalidDeploymentData },
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-InvalidEmptyAssociation@@Tests/DeployAgentTools.wlt:86,1-92,2"
]

VerificationTest[
    Quiet @ agentToolsDeploymentQ @ AgentToolsDeployment[ <||> ],
    False,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-InvalidNotValidQ@@Tests/DeployAgentTools.wlt:94,1-99,2"
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
    TestID   -> "AgentToolsDeployment-Property-UUID@@Tests/DeployAgentTools.wlt:108,1-113,2"
]

VerificationTest[
    dep[ "Timestamp" ],
    _DateObject,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Timestamp@@Tests/DeployAgentTools.wlt:115,1-120,2"
]

VerificationTest[
    dep[ "PacletVersion" ],
    "1.8.0",
    TestID -> "AgentToolsDeployment-Property-PacletVersion@@Tests/DeployAgentTools.wlt:122,1-126,2"
]

VerificationTest[
    dep[ "CreatedBy" ],
    "DeployAgentTools",
    TestID -> "AgentToolsDeployment-Property-CreatedBy@@Tests/DeployAgentTools.wlt:128,1-132,2"
]

VerificationTest[
    dep[ "Version" ],
    _Missing,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Version-Missing@@Tests/DeployAgentTools.wlt:134,1-139,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*MCP Shortcut Properties*)
VerificationTest[
    dep[ "ClientName" ],
    "ClaudeDesktop",
    TestID -> "AgentToolsDeployment-Property-ClientName@@Tests/DeployAgentTools.wlt:144,1-148,2"
]

VerificationTest[
    dep[ "Target" ],
    "ClaudeDesktop",
    TestID -> "AgentToolsDeployment-Property-Target@@Tests/DeployAgentTools.wlt:150,1-154,2"
]

VerificationTest[
    dep[ "Server" ],
    "WolframLanguage",
    TestID -> "AgentToolsDeployment-Property-Server@@Tests/DeployAgentTools.wlt:156,1-160,2"
]

VerificationTest[
    dep[ "ConfigFile" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-ConfigFile@@Tests/DeployAgentTools.wlt:162,1-167,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Sub-Association Properties*)
VerificationTest[
    dep[ "MCP" ],
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-MCP@@Tests/DeployAgentTools.wlt:172,1-177,2"
]

VerificationTest[
    dep[ "Skills" ],
    <||>,
    TestID -> "AgentToolsDeployment-Property-Skills@@Tests/DeployAgentTools.wlt:179,1-183,2"
]

VerificationTest[
    dep[ "Hooks" ],
    <||>,
    TestID -> "AgentToolsDeployment-Property-Hooks@@Tests/DeployAgentTools.wlt:185,1-189,2"
]

VerificationTest[
    dep[ "Meta" ],
    <||>,
    TestID -> "AgentToolsDeployment-Property-Meta@@Tests/DeployAgentTools.wlt:191,1-195,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Derived Properties*)
VerificationTest[
    dep[ "Data" ],
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Data@@Tests/DeployAgentTools.wlt:200,1-205,2"
]

VerificationTest[
    dep[ "Location" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Location@@Tests/DeployAgentTools.wlt:207,1-212,2"
]

VerificationTest[
    dep[ "Properties" ],
    _List,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Properties@@Tests/DeployAgentTools.wlt:214,1-219,2"
]

VerificationTest[
    MemberQ[ dep[ "Properties" ], "UUID" ],
    True,
    TestID -> "AgentToolsDeployment-Property-PropertiesContainsUUID@@Tests/DeployAgentTools.wlt:221,1-225,2"
]

VerificationTest[
    dep[ "MCPServerObject" ],
    _MCPServerObject,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-MCPServerObject@@Tests/DeployAgentTools.wlt:227,1-232,2"
]

VerificationTest[
    dep[ "Tools" ],
    { ___LLMTool },
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Tools@@Tests/DeployAgentTools.wlt:234,1-239,2"
]

VerificationTest[
    dep[ "LLMConfiguration" ],
    _LLMConfiguration,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-LLMConfiguration@@Tests/DeployAgentTools.wlt:241,1-246,2"
]

VerificationTest[
    SubsetQ[ dep[ "Properties" ], { "MCPServerObject", "Tools", "LLMConfiguration" } ],
    True,
    TestID -> "AgentToolsDeployment-Property-PropertiesContainsNewDerived@@Tests/DeployAgentTools.wlt:248,1-252,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Two-Argument Property Access*)
VerificationTest[
    dep[ "MCP", "Options" ],
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-MCP-Options@@Tests/DeployAgentTools.wlt:257,1-262,2"
]

VerificationTest[
    dep[ "MCP", "Server" ],
    "WolframLanguage",
    TestID -> "AgentToolsDeployment-Property-MCP-Server@@Tests/DeployAgentTools.wlt:264,1-268,2"
]

VerificationTest[
    dep[ "MCP", "ClientName" ],
    "ClaudeDesktop",
    TestID -> "AgentToolsDeployment-Property-MCP-ClientName@@Tests/DeployAgentTools.wlt:270,1-274,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Unknown Property*)
VerificationTest[
    dep[ "NonexistentProperty" ],
    _Missing,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Unknown@@Tests/DeployAgentTools.wlt:279,1-284,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Invalid Property*)
VerificationTest[
    dep[ 42 ],
    _Failure,
    { AgentToolsDeployment::InvalidProperty },
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Invalid@@Tests/DeployAgentTools.wlt:289,1-295,2"
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
    TestID   -> "AgentToolsDeployment-Formatting-MakeBoxes@@Tests/DeployAgentTools.wlt:300,1-307,2"
]

VerificationTest[
    (* Invalid objects should not produce formatted boxes *)
    MakeBoxes[ AgentToolsDeployment[ <||> ], StandardForm ],
    _InterpretationBox,
    SameTest -> Not @* MatchQ,
    TestID   -> "AgentToolsDeployment-Formatting-InvalidNoBoxes@@Tests/DeployAgentTools.wlt:309,1-315,2"
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
    TestID   -> "AgentToolsDeployment-Validation-MissingKeys@@Tests/DeployAgentTools.wlt:322,1-332,2"
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
    TestID   -> "AgentToolsDeployment-Validation-WrongUUIDType@@Tests/DeployAgentTools.wlt:335,1-357,2"
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
    TestID   -> "AgentToolsDeployment-Validation-NoneClientName@@Tests/DeployAgentTools.wlt:360,1-381,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Multiple Objects*)
VerificationTest[
    dep1 = AgentToolsDeployment[ $testDeploymentData ];
    dep2 = AgentToolsDeployment[ $testDeploymentData ];
    dep1[ "UUID" ] =!= dep2[ "UUID" ],
    True,
    TestID -> "AgentToolsDeployment-MultipleObjects-UniqueUUIDs@@Tests/DeployAgentTools.wlt:386,1-392,2"
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
    TestID -> "DeployAgentTools-Setup@@Tests/DeployAgentTools.wlt:401,1-407,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Deployment*)
VerificationTest[
    $dep1 = DeployAgentTools[ $deployTestConfig, "Wolfram", "VerifyLLMKit" -> False ],
    _AgentToolsDeployment,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-BasicDeploy@@Tests/DeployAgentTools.wlt:412,1-417,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Returned Object Properties*)
VerificationTest[
    $dep1[ "Server" ],
    "Wolfram",
    TestID -> "DeployAgentTools-Property-Server@@Tests/DeployAgentTools.wlt:422,1-426,2"
]

VerificationTest[
    $dep1[ "ConfigFile" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-ConfigFile@@Tests/DeployAgentTools.wlt:428,1-433,2"
]

VerificationTest[
    $dep1[ "UUID" ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-UUID@@Tests/DeployAgentTools.wlt:435,1-440,2"
]

VerificationTest[
    $dep1[ "Timestamp" ],
    _DateObject,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-Timestamp@@Tests/DeployAgentTools.wlt:442,1-447,2"
]

VerificationTest[
    $dep1[ "CreatedBy" ],
    "DeployAgentTools",
    TestID -> "DeployAgentTools-Property-CreatedBy@@Tests/DeployAgentTools.wlt:449,1-453,2"
]

VerificationTest[
    $dep1[ "PacletVersion" ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-PacletVersion@@Tests/DeployAgentTools.wlt:455,1-460,2"
]

VerificationTest[
    $dep1[ "Target" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-Target@@Tests/DeployAgentTools.wlt:462,1-467,2"
]

VerificationTest[
    $dep1[ "MCP" ],
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-MCP@@Tests/DeployAgentTools.wlt:469,1-474,2"
]

VerificationTest[
    $dep1[ "MCP", "Options" ],
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-MCP-Options@@Tests/DeployAgentTools.wlt:476,1-481,2"
]

VerificationTest[
    $dep1[ "MCPServerObject" ],
    _MCPServerObject,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-MCPServerObject@@Tests/DeployAgentTools.wlt:483,1-488,2"
]

VerificationTest[
    $dep1[ "Tools" ],
    { __LLMTool },
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-Tools@@Tests/DeployAgentTools.wlt:490,1-495,2"
]

VerificationTest[
    $dep1[ "LLMConfiguration" ],
    _LLMConfiguration,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-LLMConfiguration@@Tests/DeployAgentTools.wlt:497,1-502,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config File Updated*)
VerificationTest[
    FileExistsQ @ $deployTestConfig,
    True,
    TestID -> "DeployAgentTools-ConfigFileExists@@Tests/DeployAgentTools.wlt:507,1-511,2"
]

VerificationTest[
    Module[ { json },
        json = Developer`ReadRawJSONString @ ReadString @ First @ $deployTestConfig;
        KeyExistsQ[ json, "mcpServers" ] && KeyExistsQ[ json[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    TestID -> "DeployAgentTools-ConfigFileHasServerEntry@@Tests/DeployAgentTools.wlt:513,1-520,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Deployment Record on Disk*)
VerificationTest[
    $dep1[ "Location" ],
    _File? DirectoryQ,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-DeploymentDirExists@@Tests/DeployAgentTools.wlt:525,1-530,2"
]

VerificationTest[
    FileExistsQ @ FileNameJoin @ { First @ $dep1[ "Location" ], "Deployment.wxf" },
    True,
    TestID -> "DeployAgentTools-DeploymentWXFExists@@Tests/DeployAgentTools.wlt:532,1-536,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*OverwriteTarget -> False Fails*)
VerificationTest[
    DeployAgentTools[ $deployTestConfig, "Wolfram", "VerifyLLMKit" -> False ],
    _Failure,
    { DeployAgentTools::DeploymentExists },
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-DuplicateFails@@Tests/DeployAgentTools.wlt:541,1-547,2"
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
    TestID   -> "DeployAgentTools-OverwriteTrue@@Tests/DeployAgentTools.wlt:552,1-562,2"
]

VerificationTest[
    $dep2[ "UUID" ] =!= $dep1[ "UUID" ],
    True,
    TestID -> "DeployAgentTools-OverwriteNewUUID@@Tests/DeployAgentTools.wlt:564,1-568,2"
]

VerificationTest[
    (* The old deployment directory should have been cleaned up *)
    ! DirectoryQ @ First @ $dep1[ "Location" ],
    True,
    TestID -> "DeployAgentTools-OverwriteOldDirRemoved@@Tests/DeployAgentTools.wlt:570,1-575,2"
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
    TestID   -> "DeployAgentTools-ProjectDeploy@@Tests/DeployAgentTools.wlt:580,1-590,2"
]

VerificationTest[
    $dep3[ "ClientName" ],
    "ClaudeCode",
    TestID -> "DeployAgentTools-ProjectDeploy-ClientName@@Tests/DeployAgentTools.wlt:592,1-596,2"
]

VerificationTest[
    $dep3[ "Target" ],
    { "ClaudeCode", $deployTestDir2 },
    TestID -> "DeployAgentTools-ProjectDeploy-Target@@Tests/DeployAgentTools.wlt:598,1-602,2"
]

VerificationTest[
    (* Deploy to the same config file via File target - should fail as duplicate *)
    DeployAgentTools[
        File[ FileNameJoin @ { $deployTestDir2, ".mcp.json" } ],
        "Wolfram",
        "VerifyLLMKit" -> False
    ],
    _Failure,
    { DeployAgentTools::DeploymentExists },
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-EquivalentTargetFails@@Tests/DeployAgentTools.wlt:604,1-615,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*DeployedAgentTools*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*List All Deployments*)
VerificationTest[
    $allDeps = DeployedAgentTools[ ],
    _List,
    SameTest -> MatchQ,
    TestID   -> "DeployedAgentTools-ListAll@@Tests/DeployAgentTools.wlt:624,1-629,2"
]

VerificationTest[
    AllTrue[ $allDeps, agentToolsDeploymentQ ],
    True,
    TestID -> "DeployedAgentTools-ListAll-AllValid@@Tests/DeployAgentTools.wlt:631,1-635,2"
]

VerificationTest[
    (* The two existing deployments ($dep2 and $dep3) should be in the list *)
    MemberQ[ $allDeps, _? (configFilesEqual[ #[ "ConfigFile" ], $dep2[ "ConfigFile" ] ] &) ] &&
    MemberQ[ $allDeps, _? (configFilesEqual[ #[ "ConfigFile" ], $dep3[ "ConfigFile" ] ] &) ],
    True,
    TestID -> "DeployedAgentTools-ListAll-ContainsDeployments@@Tests/DeployAgentTools.wlt:637,1-643,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Filter By Client Name*)
VerificationTest[
    $ccDeps = DeployedAgentTools[ "ClaudeCode" ],
    _List,
    SameTest -> MatchQ,
    TestID   -> "DeployedAgentTools-FilterClaudeCode@@Tests/DeployAgentTools.wlt:648,1-653,2"
]

VerificationTest[
    MemberQ[ $ccDeps, _? (#[ "UUID" ] === $dep3[ "UUID" ] &) ],
    True,
    TestID -> "DeployedAgentTools-FilterClaudeCode-ContainsDep3@@Tests/DeployAgentTools.wlt:655,1-659,2"
]

VerificationTest[
    (* $dep2 is a File target - should NOT be in the ClaudeCode list *)
    NoneTrue[ $ccDeps, #[ "UUID" ] === $dep2[ "UUID" ] & ],
    True,
    TestID -> "DeployedAgentTools-FilterClaudeCode-ExcludesDep2@@Tests/DeployAgentTools.wlt:661,1-666,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Alias Resolution*)
VerificationTest[
    (* "Claude" is an alias for "ClaudeDesktop" - should return the same result *)
    DeployedAgentTools[ "Claude" ] === DeployedAgentTools[ "ClaudeDesktop" ],
    True,
    TestID -> "DeployedAgentTools-AliasResolution@@Tests/DeployAgentTools.wlt:671,1-676,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Non-Existent Client*)
VerificationTest[
    DeployedAgentTools[ "NonExistentClient" ],
    { },
    TestID -> "DeployedAgentTools-NonExistentClient@@Tests/DeployAgentTools.wlt:681,1-685,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Empty Deployments Path*)
VerificationTest[
    (* With no deployments directory at all, should return empty list *)
    Block[ { Wolfram`MCPServer`Common`$deploymentsPath = FileNameJoin @ { $TemporaryDirectory, "nonexistent_deployments_" <> CreateUUID[ ] } },
        DeployedAgentTools[ ]
    ],
    { },
    TestID -> "DeployedAgentTools-EmptyPath@@Tests/DeployAgentTools.wlt:690,1-697,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Corrupted Records Filtered Out*)
VerificationTest[
    Module[ { corruptDir, corruptFile },
        (* Create a corrupted deployment record *)
        corruptDir = FileNameJoin @ {
            $deploymentsPath,
            $dep3[ "ClientName" ],
            "corrupted-" <> CreateUUID[ ]
        };
        CreateDirectory[ corruptDir ];
        corruptFile = FileNameJoin @ { corruptDir, "Deployment.wxf" };
        BinaryWrite[ corruptFile, "not valid wxf data" ];
        Close @ corruptFile;
        (* Should still return valid deployments, skipping the corrupted one *)
        $ccDeps2 = DeployedAgentTools[ "ClaudeCode" ];
        Quiet @ DeleteDirectory[ corruptDir, DeleteContents -> True ];
        AllTrue[ $ccDeps2, agentToolsDeploymentQ ]
    ],
    True,
    TestID -> "DeployedAgentTools-CorruptedRecordFiltered@@Tests/DeployAgentTools.wlt:702,1-721,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*DeleteObject End-to-End*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Setup*)
VerificationTest[
    $deleteTestDir = CreateDirectory[ ];
    $deleteTestConfig = File[ FileNameJoin @ { $deleteTestDir, "delete_test_config.json" } ];
    $deleteDep = DeployAgentTools[ $deleteTestConfig, "Wolfram", "VerifyLLMKit" -> False ],
    _AgentToolsDeployment,
    SameTest -> MatchQ,
    TestID   -> "DeleteObject-Setup-Deploy@@Tests/DeployAgentTools.wlt:730,1-737,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Verify Pre-Delete State*)
VerificationTest[
    (* Config file should have the server entry *)
    Module[ { json },
        json = Developer`ReadRawJSONString @ ReadString @ First @ $deleteTestConfig;
        KeyExistsQ[ json, "mcpServers" ] && KeyExistsQ[ json[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    TestID -> "DeleteObject-ConfigHasEntry@@Tests/DeployAgentTools.wlt:742,1-750,2"
]

VerificationTest[
    $deleteDepDir = $deleteDep[ "Location" ];
    DirectoryQ @ $deleteDepDir,
    True,
    TestID -> "DeleteObject-DeploymentDirExists@@Tests/DeployAgentTools.wlt:752,1-757,2"
]

VerificationTest[
    MemberQ[ DeployedAgentTools[ ], _? (#[ "UUID" ] === $deleteDep[ "UUID" ] &) ],
    True,
    TestID -> "DeleteObject-InListing@@Tests/DeployAgentTools.wlt:759,1-763,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Delete*)
VerificationTest[
    DeleteObject[ $deleteDep ],
    Null,
    TestID -> "DeleteObject-Delete@@Tests/DeployAgentTools.wlt:768,1-772,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Verify Post-Delete State*)
VerificationTest[
    (* Config file should no longer have the server entry *)
    Module[ { json },
        json = Developer`ReadRawJSONString @ ReadString @ First @ $deleteTestConfig;
        ! KeyExistsQ[ json[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    TestID -> "DeleteObject-ConfigEntryRemoved@@Tests/DeployAgentTools.wlt:777,1-785,2"
]

VerificationTest[
    ! DirectoryQ @ $deleteDepDir,
    True,
    TestID -> "DeleteObject-DeploymentDirRemoved@@Tests/DeployAgentTools.wlt:787,1-791,2"
]

VerificationTest[
    NoneTrue[ DeployedAgentTools[ ], #[ "UUID" ] === $deleteDep[ "UUID" ] & ],
    True,
    TestID -> "DeleteObject-NotInListing@@Tests/DeployAgentTools.wlt:793,1-797,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Delete Again Fails*)
VerificationTest[
    DeleteObject[ $deleteDep ],
    _Failure,
    { AgentToolsDeployment::DeploymentNotFound },
    SameTest -> MatchQ,
    TestID   -> "DeleteObject-DeleteAgainFails@@Tests/DeployAgentTools.wlt:802,1-808,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Round-Trip: Deploy -> List -> Delete -> Verify Gone*)
VerificationTest[
    Module[ { dir, config, dep, uuid, listed, listedAfter, json },
        dir = CreateDirectory[ ];
        config = File[ FileNameJoin @ { dir, "roundtrip_config.json" } ];

        (* Deploy *)
        dep = DeployAgentTools[ config, "Wolfram", "VerifyLLMKit" -> False ];
        uuid = dep[ "UUID" ];

        (* Verify in listing *)
        listed = DeployedAgentTools[ ];
        If[ ! MemberQ[ listed, _? (#[ "UUID" ] === uuid &) ],
            Quiet @ DeleteDirectory[ dir, DeleteContents -> True ];
            Return[ False, Module ]
        ];

        (* Delete *)
        DeleteObject[ dep ];

        (* Verify gone from listing *)
        listedAfter = DeployedAgentTools[ ];
        If[ MemberQ[ listedAfter, _? (#[ "UUID" ] === uuid &) ],
            Quiet @ DeleteDirectory[ dir, DeleteContents -> True ];
            Return[ False, Module ]
        ];

        (* Verify config entry removed *)
        json = Developer`ReadRawJSONString @ ReadString @ First @ config;
        Quiet @ DeleteDirectory[ dir, DeleteContents -> True ];
        ! KeyExistsQ[ json[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    TestID -> "DeleteObject-RoundTrip@@Tests/DeployAgentTools.wlt:813,1-846,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup*)
VerificationTest[
    Quiet @ DeleteDirectory[ $deleteTestDir, DeleteContents -> True ];
    True,
    True,
    TestID -> "DeleteObject-Cleanup@@Tests/DeployAgentTools.wlt:851,1-856,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)

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
    TestID -> "DeployAgentTools-Cleanup@@Tests/DeployAgentTools.wlt:865,1-875,2"
]

(* :!CodeAnalysis::EndBlock:: *)
