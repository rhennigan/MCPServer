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

If[ StringQ @ Environment[ "GITHUB_ACTIONS" ], SetOptions[ InstallMCPServer, "VerifyLLMKit" -> False ] ];

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
    TestID   -> "UninstallMCPServer-Setup@@Tests/UninstallMCPServer.wlt:43,1-58,2"
]

VerificationTest[
    (* Uninstall only the WolframLanguage server *)
    uninstallResult = UninstallMCPServer[configFile, "WolframLanguage"],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-SingleServer@@Tests/UninstallMCPServer.wlt:60,1-66,2"
]

VerificationTest[
    (* Verify that only WolframLanguage was removed *)
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent["mcpServers"], "WolframAlpha"] &&
    !KeyExistsQ[jsonContent["mcpServers"], "WolframLanguage"],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-VerifySingleServerRemoval@@Tests/UninstallMCPServer.wlt:68,1-76,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Uninstall All Servers*)
VerificationTest[
    (* Uninstall all remaining servers *)
    uninstallAllResult = UninstallMCPServer[configFile],
    { ___Success },
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-AllServers@@Tests/UninstallMCPServer.wlt:81,1-87,2"
]

VerificationTest[
    (* Verify that all servers were removed *)
    jsonContent = Import[configFile, "RawJSON"];
    jsonContent["mcpServers"] === <||>,
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-VerifyAllServersRemoval@@Tests/UninstallMCPServer.wlt:89,1-96,2"
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
    TestID   -> "UninstallMCPServer-ServerObjectSetup@@Tests/UninstallMCPServer.wlt:101,1-116,2"
]

VerificationTest[
    (* Uninstall using the server object *)
    uninstallObjectResult = UninstallMCPServer[configFile, server],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-ByObject@@Tests/UninstallMCPServer.wlt:118,1-124,2"
]

VerificationTest[
    (* Verify the server was removed *)
    jsonContent = Import[configFile, "RawJSON"];
    !KeyExistsQ[jsonContent["mcpServers"], name],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-VerifyObjectRemoval@@Tests/UninstallMCPServer.wlt:126,1-133,2"
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
    TestID   -> "UninstallMCPServer-MultipleInstallsSetup@@Tests/UninstallMCPServer.wlt:138,1-158,2"
]

VerificationTest[
    (* Uninstall server from all config files *)
    uninstallAllInstancesResult = UninstallMCPServer[All, server],
    { _Success, _Success },
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-AllInstances@@Tests/UninstallMCPServer.wlt:160,1-166,2"
]

VerificationTest[
    (* Verify removal from all files *)
    jsonContent1 = Import[configFile1, "RawJSON"];
    jsonContent2 = Import[configFile2, "RawJSON"];

    !KeyExistsQ[jsonContent1["mcpServers"], name] &&
    !KeyExistsQ[jsonContent2["mcpServers"], name],

    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-VerifyAllInstancesRemoval@@Tests/UninstallMCPServer.wlt:168,1-179,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup*)
VerificationTest[
    DeleteObject[server];
    cleanupTestFiles[{configFile, configFile1, configFile2}],
    {Null..},
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Cleanup@@Tests/UninstallMCPServer.wlt:184,1-190,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Cases*)
VerificationTest[
    configFile = testConfigFile[];
    Export[configFile, <| "mcpServers" -> <| |> |>, "RawJSON"];
    UninstallMCPServer[configFile, "NonExistentServer"],
    _Failure,
    {UninstallMCPServer::MCPServerNotFound},
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-NonExistentServer@@Tests/UninstallMCPServer.wlt:195,1-203,2"
]

VerificationTest[
    nonExistentFile = File @ FileNameJoin[{$TemporaryDirectory, "non_existent_config.json"}];
    UninstallMCPServer[nonExistentFile, "WolframLanguage"],
    _Missing,
    { },  (* No messages expected since notFoundQ just returns Missing *)
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-NonExistentFile@@Tests/UninstallMCPServer.wlt:205,1-212,2"
]

VerificationTest[
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-ErrorCleanup@@Tests/UninstallMCPServer.wlt:214,1-219,2"
]