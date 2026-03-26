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
    Needs[ "Wolfram`AgentTools`" ],
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

agentToolsDeploymentQ = Wolfram`AgentTools`DeployAgentTools`Private`agentToolsDeploymentQ;
configFilesEqual = Wolfram`AgentTools`DeployAgentTools`Private`configFilesEqual;
$deploymentsPath = Wolfram`AgentTools`Common`$deploymentsPath;

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
    AgentToolsDeployment[ "not-a-real-uuid" ],
    _Failure,
    { AgentToolsDeployment::DeploymentNotFound },
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-InvalidUUID@@Tests/DeployAgentTools.wlt:70,1-76,2"
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
    dep[ "Scope" ],
    "Global",
    TestID -> "AgentToolsDeployment-Property-Scope-Global@@Tests/DeployAgentTools.wlt:248,1-252,2"
]

VerificationTest[
    SubsetQ[ dep[ "Properties" ], { "MCPServerObject", "Tools", "LLMConfiguration" } ],
    True,
    TestID -> "AgentToolsDeployment-Property-PropertiesContainsNewDerived@@Tests/DeployAgentTools.wlt:254,1-258,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Two-Argument Property Access*)
VerificationTest[
    dep[ "MCP", "Options" ],
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-MCP-Options@@Tests/DeployAgentTools.wlt:263,1-268,2"
]

VerificationTest[
    dep[ "MCP", "Server" ],
    "WolframLanguage",
    TestID -> "AgentToolsDeployment-Property-MCP-Server@@Tests/DeployAgentTools.wlt:270,1-274,2"
]

VerificationTest[
    dep[ "MCP", "ClientName" ],
    "ClaudeDesktop",
    TestID -> "AgentToolsDeployment-Property-MCP-ClientName@@Tests/DeployAgentTools.wlt:276,1-280,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Unknown Property*)
VerificationTest[
    dep[ "NonexistentProperty" ],
    _Missing,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Unknown@@Tests/DeployAgentTools.wlt:285,1-290,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Invalid Property*)
VerificationTest[
    dep[ 42 ],
    _Failure,
    { AgentToolsDeployment::InvalidProperty },
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-Property-Invalid@@Tests/DeployAgentTools.wlt:295,1-301,2"
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
    TestID   -> "AgentToolsDeployment-Formatting-MakeBoxes@@Tests/DeployAgentTools.wlt:306,1-313,2"
]

VerificationTest[
    (* Invalid objects should not produce formatted boxes *)
    MakeBoxes[ AgentToolsDeployment[ <||> ], StandardForm ],
    _InterpretationBox,
    SameTest -> Not @* MatchQ,
    TestID   -> "AgentToolsDeployment-Formatting-InvalidNoBoxes@@Tests/DeployAgentTools.wlt:315,1-321,2"
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
    TestID   -> "AgentToolsDeployment-Validation-MissingKeys@@Tests/DeployAgentTools.wlt:328,1-338,2"
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
    TestID   -> "AgentToolsDeployment-Validation-WrongUUIDType@@Tests/DeployAgentTools.wlt:341,1-363,2"
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
    TestID   -> "AgentToolsDeployment-Validation-NoneClientName@@Tests/DeployAgentTools.wlt:366,1-387,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Multiple Objects*)
VerificationTest[
    dep1 = AgentToolsDeployment[ $testDeploymentData ];
    dep2 = AgentToolsDeployment[ $testDeploymentData ];
    dep1[ "UUID" ] =!= dep2[ "UUID" ],
    True,
    TestID -> "AgentToolsDeployment-MultipleObjects-UniqueUUIDs@@Tests/DeployAgentTools.wlt:392,1-398,2"
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
    TestID -> "DeployAgentTools-Setup@@Tests/DeployAgentTools.wlt:407,1-413,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Deployment*)
VerificationTest[
    $dep1 = DeployAgentTools[ $deployTestConfig, "Wolfram", "VerifyLLMKit" -> False ],
    _AgentToolsDeployment,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-BasicDeploy@@Tests/DeployAgentTools.wlt:418,1-423,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Returned Object Properties*)
VerificationTest[
    $dep1[ "Server" ],
    "Wolfram",
    TestID -> "DeployAgentTools-Property-Server@@Tests/DeployAgentTools.wlt:428,1-432,2"
]

VerificationTest[
    $dep1[ "ConfigFile" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-ConfigFile@@Tests/DeployAgentTools.wlt:434,1-439,2"
]

VerificationTest[
    $dep1[ "UUID" ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-UUID@@Tests/DeployAgentTools.wlt:441,1-446,2"
]

VerificationTest[
    $dep1[ "Timestamp" ],
    _DateObject,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-Timestamp@@Tests/DeployAgentTools.wlt:448,1-453,2"
]

VerificationTest[
    $dep1[ "CreatedBy" ],
    "DeployAgentTools",
    TestID -> "DeployAgentTools-Property-CreatedBy@@Tests/DeployAgentTools.wlt:455,1-459,2"
]

VerificationTest[
    $dep1[ "PacletVersion" ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-PacletVersion@@Tests/DeployAgentTools.wlt:461,1-466,2"
]

VerificationTest[
    $dep1[ "Target" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-Target@@Tests/DeployAgentTools.wlt:468,1-473,2"
]

VerificationTest[
    $dep1[ "MCP" ],
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-MCP@@Tests/DeployAgentTools.wlt:475,1-480,2"
]

VerificationTest[
    $dep1[ "MCP", "Options" ],
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-MCP-Options@@Tests/DeployAgentTools.wlt:482,1-487,2"
]

VerificationTest[
    $dep1[ "MCPServerObject" ],
    _MCPServerObject,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-MCPServerObject@@Tests/DeployAgentTools.wlt:489,1-494,2"
]

VerificationTest[
    $dep1[ "Tools" ],
    { __LLMTool },
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-Tools@@Tests/DeployAgentTools.wlt:496,1-501,2"
]

VerificationTest[
    $dep1[ "LLMConfiguration" ],
    _LLMConfiguration,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-LLMConfiguration@@Tests/DeployAgentTools.wlt:503,1-508,2"
]

VerificationTest[
    $dep1[ "Scope" ],
    _Missing,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-Property-Scope-FileTarget@@Tests/DeployAgentTools.wlt:510,1-515,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config File Updated*)
VerificationTest[
    FileExistsQ @ $deployTestConfig,
    True,
    TestID -> "DeployAgentTools-ConfigFileExists@@Tests/DeployAgentTools.wlt:520,1-524,2"
]

VerificationTest[
    Module[ { json },
        json = Developer`ReadRawJSONString @ ReadString @ First @ $deployTestConfig;
        KeyExistsQ[ json, "mcpServers" ] && KeyExistsQ[ json[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    TestID -> "DeployAgentTools-ConfigFileHasServerEntry@@Tests/DeployAgentTools.wlt:526,1-533,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Deployment Record on Disk*)
VerificationTest[
    $dep1[ "Location" ],
    _File? DirectoryQ,
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-DeploymentDirExists@@Tests/DeployAgentTools.wlt:538,1-543,2"
]

VerificationTest[
    FileExistsQ @ FileNameJoin @ { First @ $dep1[ "Location" ], "Deployment.wxf" },
    True,
    TestID -> "DeployAgentTools-DeploymentWXFExists@@Tests/DeployAgentTools.wlt:545,1-549,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*UUID Lookup*)
VerificationTest[
    $dep1Lookup = AgentToolsDeployment[ $dep1[ "UUID" ] ],
    _AgentToolsDeployment,
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-UUIDLookup@@Tests/DeployAgentTools.wlt:554,1-559,2"
]

VerificationTest[
    $dep1Lookup[ "UUID" ] === $dep1[ "UUID" ],
    True,
    TestID -> "AgentToolsDeployment-UUIDLookup-SameUUID@@Tests/DeployAgentTools.wlt:561,1-565,2"
]

VerificationTest[
    $dep1Lookup[ "Server" ] === $dep1[ "Server" ],
    True,
    TestID -> "AgentToolsDeployment-UUIDLookup-SameServer@@Tests/DeployAgentTools.wlt:567,1-571,2"
]

VerificationTest[
    AgentToolsDeployment[ "nonexistent-uuid-00000000" ],
    _Failure,
    { AgentToolsDeployment::DeploymentNotFound },
    SameTest -> MatchQ,
    TestID   -> "AgentToolsDeployment-UUIDLookup-NotFound@@Tests/DeployAgentTools.wlt:573,1-579,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Invalid Project Directory*)
VerificationTest[
    DeployAgentTools[ { "ClaudeCode", Symbol[ "xyz" ] } ],
    _Failure,
    { DeployAgentTools::InvalidProjectDirectory },
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-InvalidProjectDirectory@@Tests/DeployAgentTools.wlt:584,1-590,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Invalid Deploy Target*)
VerificationTest[
    DeployAgentTools[ 123, "Wolfram", "VerifyLLMKit" -> False ],
    _Failure,
    { DeployAgentTools::InvalidDeployTarget },
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-InvalidDeployTarget-Integer@@Tests/DeployAgentTools.wlt:595,1-601,2"
]

VerificationTest[
    DeployAgentTools[ <|"a" -> 1|>, "Wolfram", "VerifyLLMKit" -> False ],
    _Failure,
    { DeployAgentTools::InvalidDeployTarget },
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-InvalidDeployTarget-Association@@Tests/DeployAgentTools.wlt:603,1-609,2"
]

VerificationTest[
    DeployAgentTools[ {1, 2, 3}, "Wolfram", "VerifyLLMKit" -> False ],
    _Failure,
    { DeployAgentTools::InvalidDeployTarget },
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-InvalidDeployTarget-List@@Tests/DeployAgentTools.wlt:611,1-617,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Invalid ApplicationName with File Target*)
VerificationTest[
    DeployAgentTools[
        File[ FileNameJoin @ { $deployTestDir, "appname_test.json" } ],
        "Wolfram",
        ApplicationName -> 123,
        "VerifyLLMKit"  -> False
    ],
    _Failure,
    { DeployAgentTools::InvalidApplicationName },
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-InvalidApplicationName-Integer@@Tests/DeployAgentTools.wlt:622,1-633,2"
]

VerificationTest[
    DeployAgentTools[
        File[ FileNameJoin @ { $deployTestDir, "appname_test.json" } ],
        "Wolfram",
        ApplicationName -> { "foo" },
        "VerifyLLMKit"  -> False
    ],
    _Failure,
    { DeployAgentTools::InvalidApplicationName },
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-InvalidApplicationName-List@@Tests/DeployAgentTools.wlt:635,1-646,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*OverwriteTarget -> False Fails*)
VerificationTest[
    DeployAgentTools[ $deployTestConfig, "Wolfram", "VerifyLLMKit" -> False ],
    _Failure,
    { DeployAgentTools::DeploymentExists },
    SameTest -> MatchQ,
    TestID   -> "DeployAgentTools-DuplicateFails@@Tests/DeployAgentTools.wlt:651,1-657,2"
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
    TestID   -> "DeployAgentTools-OverwriteTrue@@Tests/DeployAgentTools.wlt:662,1-672,2"
]

VerificationTest[
    $dep2[ "UUID" ] =!= $dep1[ "UUID" ],
    True,
    TestID -> "DeployAgentTools-OverwriteNewUUID@@Tests/DeployAgentTools.wlt:674,1-678,2"
]

VerificationTest[
    (* The old deployment directory should have been cleaned up *)
    ! DirectoryQ @ First @ $dep1[ "Location" ],
    True,
    TestID -> "DeployAgentTools-OverwriteOldDirRemoved@@Tests/DeployAgentTools.wlt:680,1-685,2"
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
    TestID   -> "DeployAgentTools-ProjectDeploy@@Tests/DeployAgentTools.wlt:690,1-700,2"
]

VerificationTest[
    $dep3[ "ClientName" ],
    "ClaudeCode",
    TestID -> "DeployAgentTools-ProjectDeploy-ClientName@@Tests/DeployAgentTools.wlt:702,1-706,2"
]

VerificationTest[
    $dep3[ "Target" ],
    { "ClaudeCode", File[ $deployTestDir2 ] },
    TestID -> "DeployAgentTools-ProjectDeploy-Target@@Tests/DeployAgentTools.wlt:708,1-712,2"
]

VerificationTest[
    $dep3[ "Scope" ],
    File[ $deployTestDir2 ],
    TestID -> "DeployAgentTools-ProjectDeploy-Scope@@Tests/DeployAgentTools.wlt:714,1-718,2"
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
    TestID   -> "DeployAgentTools-EquivalentTargetFails@@Tests/DeployAgentTools.wlt:720,1-731,2"
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
    TestID   -> "DeployedAgentTools-ListAll@@Tests/DeployAgentTools.wlt:740,1-745,2"
]

VerificationTest[
    AllTrue[ $allDeps, agentToolsDeploymentQ ],
    True,
    TestID -> "DeployedAgentTools-ListAll-AllValid@@Tests/DeployAgentTools.wlt:747,1-751,2"
]

VerificationTest[
    (* The two existing deployments ($dep2 and $dep3) should be in the list *)
    MemberQ[ $allDeps, _? (configFilesEqual[ #[ "ConfigFile" ], $dep2[ "ConfigFile" ] ] &) ] &&
    MemberQ[ $allDeps, _? (configFilesEqual[ #[ "ConfigFile" ], $dep3[ "ConfigFile" ] ] &) ],
    True,
    TestID -> "DeployedAgentTools-ListAll-ContainsDeployments@@Tests/DeployAgentTools.wlt:753,1-759,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Filter By Client Name*)
VerificationTest[
    $ccDeps = DeployedAgentTools[ "ClaudeCode" ],
    _List,
    SameTest -> MatchQ,
    TestID   -> "DeployedAgentTools-FilterClaudeCode@@Tests/DeployAgentTools.wlt:764,1-769,2"
]

VerificationTest[
    MemberQ[ $ccDeps, _? (#[ "UUID" ] === $dep3[ "UUID" ] &) ],
    True,
    TestID -> "DeployedAgentTools-FilterClaudeCode-ContainsDep3@@Tests/DeployAgentTools.wlt:771,1-775,2"
]

VerificationTest[
    (* $dep2 is a File target - should NOT be in the ClaudeCode list *)
    NoneTrue[ $ccDeps, #[ "UUID" ] === $dep2[ "UUID" ] & ],
    True,
    TestID -> "DeployedAgentTools-FilterClaudeCode-ExcludesDep2@@Tests/DeployAgentTools.wlt:777,1-782,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Alias Resolution*)
VerificationTest[
    (* "Claude" is an alias for "ClaudeDesktop" - should return the same result *)
    DeployedAgentTools[ "Claude" ] === DeployedAgentTools[ "ClaudeDesktop" ],
    True,
    TestID -> "DeployedAgentTools-AliasResolution@@Tests/DeployAgentTools.wlt:787,1-792,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Non-Existent Client*)
VerificationTest[
    DeployedAgentTools[ "NonExistentClient" ],
    { },
    TestID -> "DeployedAgentTools-NonExistentClient@@Tests/DeployAgentTools.wlt:797,1-801,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Empty Deployments Path*)
VerificationTest[
    (* With no deployments directory at all, should return empty list *)
    Block[ { Wolfram`AgentTools`Common`$deploymentsPath = FileNameJoin @ { $TemporaryDirectory, "nonexistent_deployments_" <> CreateUUID[ ] } },
        DeployedAgentTools[ ]
    ],
    { },
    TestID -> "DeployedAgentTools-EmptyPath@@Tests/DeployAgentTools.wlt:806,1-813,2"
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
    TestID -> "DeployedAgentTools-CorruptedRecordFiltered@@Tests/DeployAgentTools.wlt:818,1-837,2"
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
    TestID   -> "DeleteObject-Setup-Deploy@@Tests/DeployAgentTools.wlt:846,1-853,2"
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
    TestID -> "DeleteObject-ConfigHasEntry@@Tests/DeployAgentTools.wlt:858,1-866,2"
]

VerificationTest[
    $deleteDepDir = $deleteDep[ "Location" ];
    DirectoryQ @ $deleteDepDir,
    True,
    TestID -> "DeleteObject-DeploymentDirExists@@Tests/DeployAgentTools.wlt:868,1-873,2"
]

VerificationTest[
    MemberQ[ DeployedAgentTools[ ], _? (#[ "UUID" ] === $deleteDep[ "UUID" ] &) ],
    True,
    TestID -> "DeleteObject-InListing@@Tests/DeployAgentTools.wlt:875,1-879,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Delete*)
VerificationTest[
    DeleteObject[ $deleteDep ],
    Null,
    TestID -> "DeleteObject-Delete@@Tests/DeployAgentTools.wlt:884,1-888,2"
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
    TestID -> "DeleteObject-ConfigEntryRemoved@@Tests/DeployAgentTools.wlt:893,1-901,2"
]

VerificationTest[
    ! DirectoryQ @ $deleteDepDir,
    True,
    TestID -> "DeleteObject-DeploymentDirRemoved@@Tests/DeployAgentTools.wlt:903,1-907,2"
]

VerificationTest[
    NoneTrue[ DeployedAgentTools[ ], #[ "UUID" ] === $deleteDep[ "UUID" ] & ],
    True,
    TestID -> "DeleteObject-NotInListing@@Tests/DeployAgentTools.wlt:909,1-913,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Delete Again Fails*)
VerificationTest[
    DeleteObject[ $deleteDep ],
    _Failure,
    { AgentToolsDeployment::DeploymentNotFound },
    SameTest -> MatchQ,
    TestID   -> "DeleteObject-DeleteAgainFails@@Tests/DeployAgentTools.wlt:918,1-924,2"
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
    TestID -> "DeleteObject-RoundTrip@@Tests/DeployAgentTools.wlt:929,1-962,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup*)
VerificationTest[
    Quiet @ DeleteDirectory[ $deleteTestDir, DeleteContents -> True ];
    True,
    True,
    TestID -> "DeleteObject-Cleanup@@Tests/DeployAgentTools.wlt:967,1-972,2"
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
    TestID -> "DeployAgentTools-Cleanup@@Tests/DeployAgentTools.wlt:981,1-991,2"
]

(* :!CodeAnalysis::EndBlock:: *)
