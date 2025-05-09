(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    If[ ! TrueQ @ RickHennigan`MCPServerTests`$TestDefinitionsLoaded,
        Get @ FileNameJoin @ { DirectoryName[ $TestFileName ], "Common.wl" }
    ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/UninstallMCPServer.wlt:4,1-11,2"
]

VerificationTest[
    Needs[ "RickHennigan`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/UninstallMCPServer.wlt:13,1-18,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Helper Functions*)

(* Setup a temporary file to use for testing installations *)
testConfigFile = Function[
    File @ FileNameJoin @ { $TemporaryDirectory, StringJoin["mcp_test_config_", CreateUUID[], ".json"] }
];

(* Clean up any test files that might be created *)
cleanupTestFiles = Function[files,
    DeleteFile /@ Select[Flatten[{files}], FileExistsQ]
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Basic Examples*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Uninstall Single Server*)
VerificationTest[
    configFile = testConfigFile[];
    Export[configFile, <| "mcpServers" -> <| |> |>, "RawJSON"];
    
    (* Install two servers first *)
    installResult1 = InstallMCPServer[configFile, "WolframLanguage"];
    installResult2 = InstallMCPServer[configFile, "WolframAlpha"];
    
    (* Verify both servers were installed *)
    jsonContent = Import[configFile, "RawJSON"];
    startingServerCount = Length[Keys[jsonContent["mcpServers"]]],
    
    2,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Setup@@Tests/UninstallMCPServer.wlt:41,1-56,2"
]

VerificationTest[
    (* Uninstall only the WolframLanguage server *)
    uninstallResult = UninstallMCPServer[configFile, "WolframLanguage"],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-SingleServer@@Tests/UninstallMCPServer.wlt:58,1-64,2"
]

VerificationTest[
    (* Verify that only WolframLanguage was removed *)
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent["mcpServers"], "WolframAlpha"] && 
    !KeyExistsQ[jsonContent["mcpServers"], "WolframLanguage"],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-VerifySingleServerRemoval@@Tests/UninstallMCPServer.wlt:66,1-74,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Uninstall All Servers*)
VerificationTest[
    (* Uninstall all remaining servers *)
    uninstallAllResult = UninstallMCPServer[configFile],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-AllServers@@Tests/UninstallMCPServer.wlt:79,1-85,2"
]

VerificationTest[
    (* Verify that all servers were removed *)
    jsonContent = Import[configFile, "RawJSON"];
    jsonContent["mcpServers"] === <||>,
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-VerifyAllServersRemoval@@Tests/UninstallMCPServer.wlt:87,1-94,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Uninstall by Object*)
VerificationTest[
    (* Create a new server and install it *)
    configFile = testConfigFile[];
    Export[configFile, <| "mcpServers" -> <| |> |>, "RawJSON"];
    
    name = StringJoin["UninstallTest_", CreateUUID[]];
    server = CreateMCPServer[
        name,
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "PrimeFinder", { "n" -> "Integer" }, Prime[ #n ] & ] } |>
    ];
    
    installResult = InstallMCPServer[configFile, server],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-ServerObjectSetup@@Tests/UninstallMCPServer.wlt:99,1-114,2"
]

VerificationTest[
    (* Uninstall using the server object *)
    uninstallObjectResult = UninstallMCPServer[configFile, server],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-ByObject@@Tests/UninstallMCPServer.wlt:116,1-122,2"
]

VerificationTest[
    (* Verify the server was removed *)
    jsonContent = Import[configFile, "RawJSON"];
    !KeyExistsQ[jsonContent["mcpServers"], name],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-VerifyObjectRemoval@@Tests/UninstallMCPServer.wlt:124,1-131,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Uninstall All Instances*)
VerificationTest[
    (* Create and install on multiple config files *)
    configFile1 = testConfigFile[];
    configFile2 = testConfigFile[];
    
    Export[configFile1, <| "mcpServers" -> <| |> |>, "RawJSON"];
    Export[configFile2, <| "mcpServers" -> <| |> |>, "RawJSON"];
    
    name = StringJoin["MultipleInstall_", CreateUUID[]];
    server = CreateMCPServer[
        name,
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "Doubler", { "x" -> "Number" }, 2 * #x & ] } |>
    ];
    
    InstallMCPServer[configFile1, server];
    InstallMCPServer[configFile2, server],
    
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-MultipleInstallsSetup@@Tests/UninstallMCPServer.wlt:136,1-156,2"
]

VerificationTest[
    (* Uninstall server from all config files *)
    uninstallAllInstancesResult = UninstallMCPServer[All, server],
    { _Success, _Success },
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-AllInstances@@Tests/UninstallMCPServer.wlt:158,1-164,2"
]

VerificationTest[
    (* Verify removal from all files *)
    jsonContent1 = Import[configFile1, "RawJSON"];
    jsonContent2 = Import[configFile2, "RawJSON"];
    
    !KeyExistsQ[jsonContent1["mcpServers"], name] &&
    !KeyExistsQ[jsonContent2["mcpServers"], name],
    
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-VerifyAllInstancesRemoval@@Tests/UninstallMCPServer.wlt:166,1-177,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup*)
VerificationTest[
    DeleteObject[server];
    cleanupTestFiles[{configFile, configFile1, configFile2}],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Cleanup@@Tests/UninstallMCPServer.wlt:182,1-188,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Cases*)
VerificationTest[
    configFile = testConfigFile[];
    Export[configFile, <| "mcpServers" -> <| |> |>, "RawJSON"];
    UninstallMCPServer[configFile, "NonExistentServer"],
    _Missing,
    {MCPServerObject::MCPServerNotFound},
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-NonExistentServer@@Tests/UninstallMCPServer.wlt:193,1-201,2"
]

VerificationTest[
    nonExistentFile = File @ FileNameJoin[{$TemporaryDirectory, "non_existent_config.json"}];
    UninstallMCPServer[nonExistentFile, "WolframLanguage"],
    _Missing,
    { },  (* No messages expected since notFoundQ just returns Missing *)
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-NonExistentFile@@Tests/UninstallMCPServer.wlt:203,1-210,2"
]

VerificationTest[
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-ErrorCleanup@@Tests/UninstallMCPServer.wlt:212,1-217,2"
]