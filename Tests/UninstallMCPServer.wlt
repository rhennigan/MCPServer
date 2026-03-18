(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/UninstallMCPServer.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/UninstallMCPServer.wlt:11,1-16,2"
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

    (* Install a custom server and a built-in server *)
    uninstallTestName = StringJoin["UninstallSingle_", CreateUUID[]];
    uninstallTestServer = CreateMCPServer[
        uninstallTestName,
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "PrimeFinder", { "n" -> "Integer" }, Prime[ #n ] & ] } |>
    ];
    InstallMCPServer[configFile, uninstallTestServer];
    InstallMCPServer[configFile, "WolframLanguage"];

    (* Verify both servers were installed (custom name + "Wolfram") *)
    jsonContent = Import[configFile, "RawJSON"];
    startingServerCount = Length[Keys[jsonContent["mcpServers"]]],

    2,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Setup@@Tests/UninstallMCPServer.wlt:41,1-61,2"
]

VerificationTest[
    (* Uninstall only the built-in server *)
    uninstallResult = UninstallMCPServer[configFile, "WolframLanguage"],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-SingleServer@@Tests/UninstallMCPServer.wlt:63,1-69,2"
]

VerificationTest[
    (* Verify that only the built-in "Wolfram" key was removed, custom server remains *)
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent["mcpServers"], uninstallTestName] &&
    !KeyExistsQ[jsonContent["mcpServers"], "Wolfram"],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-VerifySingleServerRemoval@@Tests/UninstallMCPServer.wlt:71,1-79,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Uninstall Cross-Variant Built-in Server*)
VerificationTest[
    (* Install "WolframLanguage" (config key "Wolfram"), then uninstall using "Wolfram" *)
    crossVariantConfig = testConfigFile[];
    Export[crossVariantConfig, <| "mcpServers" -> <| |> |>, "RawJSON"];
    InstallMCPServer[crossVariantConfig, "WolframLanguage"],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-CrossVariantSetup@@Tests/UninstallMCPServer.wlt:84,1-92,2"
]

VerificationTest[
    (* Uninstall using a different built-in variant name that shares the same config key *)
    UninstallMCPServer[crossVariantConfig, "Wolfram"],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-CrossVariant@@Tests/UninstallMCPServer.wlt:94,1-100,2"
]

VerificationTest[
    (* Verify the "Wolfram" key was removed *)
    crossVariantJSON = Import[crossVariantConfig, "RawJSON"];
    crossVariantJSON["mcpServers"] === <||>,
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-VerifyCrossVariantRemoval@@Tests/UninstallMCPServer.wlt:102,1-109,2"
]

VerificationTest[
    cleanupTestFiles[crossVariantConfig],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-CrossVariantCleanup@@Tests/UninstallMCPServer.wlt:111,1-116,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Uninstall All Servers*)
VerificationTest[
    (* Uninstall all remaining servers *)
    uninstallAllResult = UninstallMCPServer[configFile],
    { ___Success },
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-AllServers@@Tests/UninstallMCPServer.wlt:121,1-127,2"
]

VerificationTest[
    (* Verify that all servers were removed *)
    jsonContent = Import[configFile, "RawJSON"];
    jsonContent["mcpServers"] === <||>,
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-VerifyAllServersRemoval@@Tests/UninstallMCPServer.wlt:129,1-136,2"
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
    TestID   -> "UninstallMCPServer-ServerObjectSetup@@Tests/UninstallMCPServer.wlt:141,1-156,2"
]

VerificationTest[
    (* Uninstall using the server object *)
    uninstallObjectResult = UninstallMCPServer[configFile, server],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-ByObject@@Tests/UninstallMCPServer.wlt:158,1-164,2"
]

VerificationTest[
    (* Verify the server was removed *)
    jsonContent = Import[configFile, "RawJSON"];
    !KeyExistsQ[jsonContent["mcpServers"], name],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-VerifyObjectRemoval@@Tests/UninstallMCPServer.wlt:166,1-173,2"
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
    TestID   -> "UninstallMCPServer-MultipleInstallsSetup@@Tests/UninstallMCPServer.wlt:178,1-198,2"
]

VerificationTest[
    (* Uninstall server from all config files *)
    uninstallAllInstancesResult = UninstallMCPServer[All, server],
    { _Success, _Success },
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-AllInstances@@Tests/UninstallMCPServer.wlt:200,1-206,2"
]

VerificationTest[
    (* Verify removal from all files *)
    jsonContent1 = Import[configFile1, "RawJSON"];
    jsonContent2 = Import[configFile2, "RawJSON"];

    !KeyExistsQ[jsonContent1["mcpServers"], name] &&
    !KeyExistsQ[jsonContent2["mcpServers"], name],

    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-VerifyAllInstancesRemoval@@Tests/UninstallMCPServer.wlt:208,1-219,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup*)
VerificationTest[
    DeleteObject[server];
    Quiet @ DeleteObject[uninstallTestServer];
    cleanupTestFiles[{configFile, configFile1, configFile2}],
    {Null..},
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Cleanup@@Tests/UninstallMCPServer.wlt:224,1-231,2"
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
    TestID   -> "UninstallMCPServer-NonExistentServer@@Tests/UninstallMCPServer.wlt:236,1-244,2"
]

VerificationTest[
    nonExistentFile = File @ FileNameJoin[{$TemporaryDirectory, "non_existent_config.json"}];
    UninstallMCPServer[nonExistentFile, "WolframLanguage"],
    _Missing,
    { },  (* No messages expected since notFoundQ just returns Missing *)
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-NonExistentFile@@Tests/UninstallMCPServer.wlt:246,1-253,2"
]

VerificationTest[
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-ErrorCleanup@@Tests/UninstallMCPServer.wlt:255,1-260,2"
]