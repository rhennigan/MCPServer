(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/InstallMCPServer.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/InstallMCPServer.wlt:11,1-16,2"
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
(*Install and Uninstall Custom Server*)
VerificationTest[
    configFile = testConfigFile[];
    name = StringJoin["TestServer_", CreateUUID[]];
    server = CreateMCPServer[
        name,
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "PrimeFinder", { "n" -> "Integer" }, Prime[ #n ] & ] } |>
    ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CreateTestServer@@Tests/InstallMCPServer.wlt:41,1-51,2"
]

VerificationTest[
    result = InstallMCPServer[configFile, server],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-FileLocation@@Tests/InstallMCPServer.wlt:53,1-58,2"
]

VerificationTest[
    FileExistsQ[configFile],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-ConfigFileExists@@Tests/InstallMCPServer.wlt:60,1-65,2"
]

VerificationTest[
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent, "mcpServers"] && KeyExistsQ[jsonContent["mcpServers"], name],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-VerifyConfigContent@@Tests/InstallMCPServer.wlt:67,1-73,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[configFile, server],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Uninstall@@Tests/InstallMCPServer.wlt:75,1-80,2"
]

VerificationTest[
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent, "mcpServers"] && !KeyExistsQ[jsonContent["mcpServers"], name],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-VerifyUninstall@@Tests/InstallMCPServer.wlt:82,1-88,2"
]

VerificationTest[
    DeleteObject[server];
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupTestServer@@Tests/InstallMCPServer.wlt:90,1-96,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install with Relative File Path*)
VerificationTest[
    WithCleanup[
        SetDirectory[ $TemporaryDirectory ],
        Module[ { file },
            file = "mcp_test_relative_" <> CreateUUID[] <> ".json";
            WithCleanup[
                Quiet @ InstallMCPServer[ File[ file ], "WolframLanguage", "VerifyLLMKit" -> False ],
                If[ FileExistsQ @ ExpandFileName @ file, DeleteFile @ ExpandFileName @ file ]
            ]
        ],
        ResetDirectory[]
    ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-RelativeFilePath-GH#108@@Tests/InstallMCPServer.wlt:101,1-116,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install into Empty Config File*)
VerificationTest[
    Module[ { file },
        file = FileNameJoin @ { $TemporaryDirectory, "mcp_test_empty_" <> CreateUUID[] <> ".json" };
        WithCleanup[
            CreateFile @ file;
            InstallMCPServer[ File[ file ], "WolframLanguage", "VerifyLLMKit" -> False ],
            Quiet @ DeleteFile @ file
        ]
    ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-EmptyConfigFile@@Tests/InstallMCPServer.wlt:121,1-133,2"
]

(* Files with only whitespace should be treated as empty *)
VerificationTest[
    Module[ { whitespace, file },
        whitespace = StringJoin @ RandomChoice[ { "\t", "\n", "\r", " " }, RandomInteger @ { 1, 10 } ];
        WithCleanup[
            file = Export[ CreateFile[ ], whitespace, "String" ];
            InstallMCPServer[ File[ file ], "WolframLanguage", "VerifyLLMKit" -> False ],
            Quiet @ DeleteFile @ file
        ]
    ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-EmptyConfigFile-Whitespace@@Tests/InstallMCPServer.wlt:136,1-148,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Predefined Server by Name*)
VerificationTest[
    configFile = testConfigFile[];
    installResult = InstallMCPServer[configFile, "WolframLanguage"],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-PredefinedServer@@Tests/InstallMCPServer.wlt:153,1-159,2"
]

VerificationTest[
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent, "mcpServers"] && KeyExistsQ[jsonContent["mcpServers"], "Wolfram"],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-VerifyPredefinedServer@@Tests/InstallMCPServer.wlt:161,1-167,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[configFile, "WolframLanguage"],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-UninstallPredefinedServer@@Tests/InstallMCPServer.wlt:169,1-174,2"
]

VerificationTest[
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupPredefinedServer@@Tests/InstallMCPServer.wlt:176,1-181,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Multiple Server Installations*)
VerificationTest[
    configFile = testConfigFile[];
    installAlpha = InstallMCPServer[configFile, "WolframAlpha"];
    installLang = InstallMCPServer[configFile, "WolframLanguage"],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-MultipleServers@@Tests/InstallMCPServer.wlt:186,1-193,2"
]

VerificationTest[
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent["mcpServers"], "Wolfram"] &&
    Length[Keys[jsonContent["mcpServers"]]] === 1,
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-VerifyMultipleBuiltInServersShareKey@@Tests/InstallMCPServer.wlt:195,1-202,2"
]

VerificationTest[
    UninstallMCPServer[configFile];
    jsonContent = Import[configFile, "RawJSON"];
    jsonContent["mcpServers"] === <| |>,
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-UninstallAll@@Tests/InstallMCPServer.wlt:204,1-211,2"
]

VerificationTest[
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupMultipleServers@@Tests/InstallMCPServer.wlt:213,1-218,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Environment Variables*)
VerificationTest[
    configFile = testConfigFile[];
    installResult = InstallMCPServer[
        configFile,
        "WolframLanguage",
        ProcessEnvironment -> <|"TEST_VAR" -> "test_value"|>
    ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-WithEnvironment@@Tests/InstallMCPServer.wlt:223,1-233,2"
]

VerificationTest[
    jsonContent = Import[configFile, "RawJSON"];
    envVars = jsonContent["mcpServers"]["Wolfram"]["env"];
    KeyExistsQ[envVars, "TEST_VAR"] && envVars["TEST_VAR"] === "test_value",
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-VerifyEnvironmentVars@@Tests/InstallMCPServer.wlt:235,1-242,2"
]

VerificationTest[
    UninstallMCPServer[configFile, "WolframLanguage"];
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupEnvironment@@Tests/InstallMCPServer.wlt:244,1-250,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*EnableLLMKit Option*)

(* "EnableLLMKit" -> False injects LLMKIT_ENABLED=false into the server's env block. The server then
   runs the context tools as if the user has no LLMKit subscription, but without any subscription
   warnings. Mirrors the "EnableMCPApps" / MCP_APPS_ENABLED pattern. *)
installLLMKitEnv[ opts___ ] := Module[ { configFile, name, server, env },
    configFile = File @ FileNameJoin @ { $TemporaryDirectory, StringJoin[ "mcp_llmkit_", CreateUUID[], ".json" ] };
    name       = StringJoin[ "TestServer_LLMKit_", CreateUUID[] ];
    server     = CreateMCPServer[
        name,
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "PrimeFinder", { "n" -> "Integer" }, Prime[ #n ] & ] } |>
    ];
    InstallMCPServer[ configFile, server, opts, "VerifyLLMKit" -> False ];
    env = Developer`ReadRawJSONString[ ReadString @ First @ configFile ][ "mcpServers", name, "env" ];
    Quiet @ DeleteFile @ First @ configFile;
    DeleteObject[ server ];
    Lookup[ env, "LLMKIT_ENABLED", Missing[ "Absent" ] ]
];

VerificationTest[
    installLLMKitEnv[ "EnableLLMKit" -> False ],
    "false",
    SameTest -> SameQ,
    TestID   -> "InstallMCPServer-EnableLLMKitFalseInjectsEnv@@Tests/InstallMCPServer.wlt:273,1-278,2"
]

(* Default is Automatic (equivalent to True): no LLMKIT_ENABLED variable is injected, so LLMKit
   stays enabled and existing installations are unaffected. *)
VerificationTest[
    installLLMKitEnv[ ],
    Missing[ "Absent" ],
    SameTest -> SameQ,
    TestID   -> "InstallMCPServer-EnableLLMKitDefaultAbsent@@Tests/InstallMCPServer.wlt:282,1-287,2"
]

VerificationTest[
    installLLMKitEnv[ "EnableLLMKit" -> True ],
    Missing[ "Absent" ],
    SameTest -> SameQ,
    TestID   -> "InstallMCPServer-EnableLLMKitTrueAbsent@@Tests/InstallMCPServer.wlt:289,1-294,2"
]

VerificationTest[
    installLLMKitEnv[ "EnableLLMKit" -> Automatic ],
    Missing[ "Absent" ],
    SameTest -> SameQ,
    TestID   -> "InstallMCPServer-EnableLLMKitAutomaticAbsent@@Tests/InstallMCPServer.wlt:296,1-301,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*SubmitUsageData Option*)

(* "SubmitUsageData" -> True/False injects SUBMIT_USAGE_DATA into the server's env block, which takes precedence
   over the server's "EnableUsageData" property at startup (see docs/usage-data.md). The default, Automatic, adds
   nothing, so the property decides: built-in servers track anonymous usage data, custom servers do not. *)
installUsageDataEnv[ server_MCPServerObject, opts___ ] := Module[ { configFile, configName, env },
    configFile = File @ FileNameJoin @ { $TemporaryDirectory, StringJoin[ "mcp_usage_", CreateUUID[], ".json" ] };
    configName = Replace[ server[ "MCPServerName" ], Except[ _String ] :> server[ "Name" ] ];
    InstallMCPServer[ configFile, server, opts, "VerifyLLMKit" -> False ];
    env = Developer`ReadRawJSONString[ ReadString @ First @ configFile ][ "mcpServers", configName, "env" ];
    Quiet @ DeleteFile @ First @ configFile;
    Lookup[ env, "SUBMIT_USAGE_DATA", Missing[ "Absent" ] ]
];

installUsageDataEnv[ opts___ ] := Module[ { server, result },
    server = CreateMCPServer[
        StringJoin[ "TestServer_UsageData_", CreateUUID[] ],
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "PrimeFinder", { "n" -> "Integer" }, Prime[ #n ] & ] } |>
    ];
    result = installUsageDataEnv[ server, opts ];
    DeleteObject[ server ];
    result
];

VerificationTest[
    MemberQ[ Keys @ Options @ InstallMCPServer, "SubmitUsageData" ],
    True,
    SameTest -> SameQ,
    TestID   -> "InstallMCPServer-SubmitUsageDataOptionExists@@Tests/InstallMCPServer.wlt:329,1-334,2"
]

VerificationTest[
    OptionValue[ InstallMCPServer, "SubmitUsageData" ],
    Automatic,
    SameTest -> SameQ,
    TestID   -> "InstallMCPServer-SubmitUsageDataDefaultAutomatic@@Tests/InstallMCPServer.wlt:336,1-341,2"
]

VerificationTest[
    installUsageDataEnv[ "SubmitUsageData" -> False ],
    "false",
    SameTest -> SameQ,
    TestID   -> "InstallMCPServer-SubmitUsageDataFalseInjectsEnv@@Tests/InstallMCPServer.wlt:343,1-348,2"
]

VerificationTest[
    installUsageDataEnv[ "SubmitUsageData" -> True ],
    "true",
    SameTest -> SameQ,
    TestID   -> "InstallMCPServer-SubmitUsageDataTrueInjectsEnv@@Tests/InstallMCPServer.wlt:350,1-355,2"
]

VerificationTest[
    installUsageDataEnv[ ],
    Missing[ "Absent" ],
    SameTest -> SameQ,
    TestID   -> "InstallMCPServer-SubmitUsageDataDefaultAbsent@@Tests/InstallMCPServer.wlt:357,1-362,2"
]

VerificationTest[
    installUsageDataEnv[ "SubmitUsageData" -> Automatic ],
    Missing[ "Absent" ],
    SameTest -> SameQ,
    TestID   -> "InstallMCPServer-SubmitUsageDataAutomaticAbsent@@Tests/InstallMCPServer.wlt:364,1-369,2"
]

(* Built-in servers go through the same path: an opt-out lands in the config, the default adds nothing *)
VerificationTest[
    installUsageDataEnv[ MCPServerObject[ "WolframLanguage" ], "SubmitUsageData" -> False ],
    "false",
    SameTest -> SameQ,
    TestID   -> "InstallMCPServer-SubmitUsageDataFalseBuiltIn@@Tests/InstallMCPServer.wlt:372,1-377,2"
]

VerificationTest[
    installUsageDataEnv[ MCPServerObject[ "WolframLanguage" ] ],
    Missing[ "Absent" ],
    SameTest -> SameQ,
    TestID   -> "InstallMCPServer-SubmitUsageDataDefaultBuiltInAbsent@@Tests/InstallMCPServer.wlt:379,1-384,2"
]

VerificationTest[
    Module[ { configFile, result },
        configFile = File @ FileNameJoin @ { $TemporaryDirectory, StringJoin[ "mcp_usage_", CreateUUID[], ".json" ] };
        result = InstallMCPServer[ configFile, "WolframLanguage", "SubmitUsageData" -> "yes", "VerifyLLMKit" -> False ];
        Quiet @ DeleteFile @ First @ configFile;
        result
    ],
    _Failure,
    { InstallMCPServer::InvalidSubmitUsageData },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-SubmitUsageDataInvalidValue@@Tests/InstallMCPServer.wlt:386,1-397,2"
]

(* DeployAgentTools forwards the option and records it with the deployment *)
VerificationTest[
    Module[ { configFile, dep, env, options },
        configFile = File @ FileNameJoin @ { $TemporaryDirectory, StringJoin[ "mcp_usage_deploy_", CreateUUID[], ".json" ] };
        dep = DeployAgentTools[ configFile, "WolframLanguage", "ApplicationName" -> "ClaudeCode", "SubmitUsageData" -> False, "VerifyLLMKit" -> False ];
        env = Developer`ReadRawJSONString[ ReadString @ First @ configFile ][ "mcpServers", "Wolfram", "env" ];
        options = dep[ "MCP", "Options" ];
        DeleteObject[ dep ];
        Quiet @ DeleteFile @ First @ configFile;
        { Lookup[ env, "SUBMIT_USAGE_DATA", Missing[ "Absent" ] ], Lookup[ options, "SubmitUsageData", Missing[ "Absent" ] ] }
    ],
    { "false", False },
    SameTest -> SameQ,
    TestID   -> "DeployAgentTools-SubmitUsageDataForwarded@@Tests/InstallMCPServer.wlt:400,1-413,2"
]

(* "EnableLLMKit" -> False must also skip the install-time LLMKit requirement check, so a server with
   an LLMKit-required tool installs without a subscription failure and without consulting the
   subscription status. Verified at the unit level: the guard returns None before llmKitSubscribedQ
   is ever called. *)
(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)
VerificationTest[
    Module[ { name, server, called = False, result },
        name   = StringJoin[ "TestServer_LLMKitGuard_", CreateUUID[] ];
        server = CreateMCPServer[
            name,
            LLMConfiguration @ <| "Tools" -> { $DefaultMCPTools[ "WolframAlphaContext" ] } |>
        ];
        result = Block[
            {
                Wolfram`AgentTools`InstallMCPServer`Private`$enableLLMKit = False,
                Wolfram`AgentTools`Common`llmKitSubscribedQ = Function[ called = True; False ]
            },
            Wolfram`AgentTools`InstallMCPServer`Private`checkLLMKitRequirements[ server ]
        ];
        DeleteObject[ server ];
        { result, called }
    ],
    { None, False },
    SameTest -> SameQ,
    TestID   -> "CheckLLMKitRequirements-DisabledSkipsCheck@@Tests/InstallMCPServer.wlt:421,1-441,2"
]
(* :!CodeAnalysis::EndBlock:: *)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install from Association*)
VerificationTest[
    configFile = testConfigFile[];
    name = CreateUUID[];
    config = <| "Tools" -> { LLMTool[ "SquareNumber", { "x" -> "Number" }, #x^2 & ] } |>;
    server = CreateMCPServer[name, config];
    installResult = InstallMCPServer[configFile, server],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-FromAssociation@@Tests/InstallMCPServer.wlt:447,1-456,2"
]

VerificationTest[
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent, "mcpServers"] && KeyExistsQ[jsonContent["mcpServers"], name],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-VerifyAssociationServer@@Tests/InstallMCPServer.wlt:458,1-464,2"
]

VerificationTest[
    UninstallMCPServer[configFile, name];
    DeleteObject[server];
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupAssociation@@Tests/InstallMCPServer.wlt:466,1-473,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Named Client Installations*)
VerificationTest[
    (* Create a temporary .claude.json-like file with existing data *)
    configFile = testConfigFile[];
    Export[configFile, <|"numStartups" -> 1, "mcpServers" -> <| |>|>, "JSON"];
    installResult = InstallMCPServer[configFile, "WolframLanguage"],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-ClaudeCodeLike@@Tests/InstallMCPServer.wlt:478,1-486,2"
]

VerificationTest[
    (* Verify the server was added and other data preserved *)
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent, "mcpServers"] &&
    KeyExistsQ[jsonContent["mcpServers"], "Wolfram"] &&
    KeyExistsQ[jsonContent, "numStartups"] &&
    jsonContent["numStartups"] === 1,
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-PreservesOtherData@@Tests/InstallMCPServer.wlt:488,1-498,2"
]

VerificationTest[
    (* Install a second server to verify multiple installations work *)
    installResult2 = InstallMCPServer[configFile, "WolframAlpha"];
    jsonContent = Import[configFile, "RawJSON"];
    Length[Keys[jsonContent["mcpServers"]]] === 1 &&
    KeyExistsQ[jsonContent["mcpServers"], "Wolfram"],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-MultipleBuiltInOverwrite@@Tests/InstallMCPServer.wlt:500,1-509,2"
]

VerificationTest[
    UninstallMCPServer[configFile];
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupClaudeCodeLike@@Tests/InstallMCPServer.wlt:511,1-517,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Cases*)
VerificationTest[
    configFile = testConfigFile[];
    Export[configFile, "{\"invalidJSON\":true", "String"];
    InstallMCPServer[configFile, "WolframLanguage"],
    _Failure,
    {InstallMCPServer::InvalidMCPConfiguration},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-InvalidJSON@@Tests/InstallMCPServer.wlt:522,1-530,2"
]

VerificationTest[
    configFile = testConfigFile[];
    Export[configFile, "{}", "JSON"];
    InstallMCPServer[configFile, "NonExistentServer"],
    _Failure,
    {InstallMCPServer::MCPServerNotFound},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-NonExistentServer@@Tests/InstallMCPServer.wlt:532,1-540,2"
]

VerificationTest[
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupErrorTests@@Tests/InstallMCPServer.wlt:542,1-547,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Install Location Resolution*)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Antigravity", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Antigravity-Windows@@Tests/InstallMCPServer.wlt:556,1-561,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Antigravity", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Antigravity-MacOSX@@Tests/InstallMCPServer.wlt:563,1-568,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Antigravity", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Antigravity-Unix@@Tests/InstallMCPServer.wlt:570,1-575,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Antigravity" ],
    "Antigravity",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Antigravity@@Tests/InstallMCPServer.wlt:577,1-582,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "GoogleAntigravity" ],
    "Antigravity",
    SameTest -> Equal,
    TestID   -> "ToInstallName-GoogleAntigravity@@Tests/InstallMCPServer.wlt:584,1-589,2"
]

(* Antigravity install path detection: when the 2.0 installer migrates a pre-2.0 IDE
   forward it drops ~/.gemini/config/.migrated; the helper must route to ~/.gemini/config/
   in that case and to the historical ~/.gemini/antigravity/ otherwise. We exercise both
   branches by stubbing FileExistsQ for the duration of the test. *)
VerificationTest[
    Module[ { migrated, fresh },
        Block[
            { FileExistsQ },
            FileExistsQ[ p_ ] := StringEndsQ[ p, ".migrated" ];
            migrated = Wolfram`AgentTools`SupportedClients`Private`antigravityInstallLocation[ ];
            FileExistsQ[ p_ ] := False;
            fresh = Wolfram`AgentTools`SupportedClients`Private`antigravityInstallLocation[ ]
        ];
        { Last @ migrated, FileNameTake[ FileNameJoin @ migrated, -2 ],
          Last @ fresh,    FileNameTake[ FileNameJoin @ fresh, -2 ] }
    ],
    {
        "mcp_config.json", FileNameJoin @ { "config",      "mcp_config.json" },
        "mcp_config.json", FileNameJoin @ { "antigravity", "mcp_config.json" }
    },
    SameTest -> Equal,
    TestID   -> "AntigravityInstallLocation-MigratedVsFresh@@Tests/InstallMCPServer.wlt:595,1-613,2"
]

(* "AntigravityCLI" and "GoogleAntigravityCLI" are aliases of the unified "Antigravity"
   client, not separate entries -- the CLI and IDE share one global config file, so two
   entries would collide in DeployAgentTools/DeleteObject. Resolution must canonicalize to
   "Antigravity". *)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "AntigravityCLI" ],
    "Antigravity",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AntigravityCLI@@Tests/InstallMCPServer.wlt:619,1-624,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "GoogleAntigravityCLI" ],
    "Antigravity",
    SameTest -> Equal,
    TestID   -> "ToInstallName-GoogleAntigravityCLI@@Tests/InstallMCPServer.wlt:626,1-631,2"
]

(* installLocation alias-resolves internally, so the CLI alias yields the same _File as
   the canonical "Antigravity" entry. *)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AntigravityCLI", "Windows" ] ===
        Wolfram`AgentTools`Common`installLocation[ "Antigravity", "Windows" ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallLocation-AntigravityCLI-AliasMatchesCanonical@@Tests/InstallMCPServer.wlt:635,1-641,2"
]

(* The unified entry has project support (the CLI's workspace path .agents/mcp_config.json),
   reachable via the alias. *)
VerificationTest[
    TrueQ @ $SupportedMCPClients[ "Antigravity", "ProjectSupport" ],
    True,
    SameTest -> Equal,
    TestID   -> "Antigravity-HasProjectSupport@@Tests/InstallMCPServer.wlt:645,1-650,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*projectInstallLocation*)

(* Tests for project-scoped install locations *)
VerificationTest[
    Module[ { path, result },
        path = FileNameJoin @ { $TemporaryDirectory, "TestProject" };
        result = Wolfram`AgentTools`Common`projectInstallLocation[ "ClaudeCode", path ];
        FileNameTake[ First @ result, -1 ]
    ],
    ".mcp.json",
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-ClaudeCode@@Tests/InstallMCPServer.wlt:657,1-666,2"
]

VerificationTest[
    Module[ { result },
        result = Wolfram`AgentTools`Common`projectInstallLocation[ "ClaudeCode", File[ "AgentTools" ] ];
        FileNameTake[ First @ result, -1 ]
    ],
    ".mcp.json",
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-ClaudeCode-FileWrapper@@Tests/InstallMCPServer.wlt:668,1-676,2"
]

VerificationTest[
    Module[ { path, result },
        path = FileNameJoin @ { $TemporaryDirectory, "TestProject" };
        result = Wolfram`AgentTools`Common`projectInstallLocation[ "OpenCode", path ];
        FileNameTake[ First @ result, -1 ]
    ],
    "opencode.json",
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-OpenCode@@Tests/InstallMCPServer.wlt:678,1-687,2"
]

VerificationTest[
    Module[ { path, result },
        path = FileNameJoin @ { $TemporaryDirectory, "TestProject" };
        result = Wolfram`AgentTools`Common`projectInstallLocation[ "Codex", path ];
        FileNameTake[ First @ result, -2 ]
    ],
    FileNameJoin @ { ".codex", "config.toml" },
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-Codex@@Tests/InstallMCPServer.wlt:689,1-698,2"
]

(* Workspace install for the unified Antigravity entry goes to .agents/mcp_config.json
   (the CLI's project path). projectInstallLocation is always called with the canonical
   name -- InstallMCPServer[{"AntigravityCLI", dir}] canonicalizes via toInstallName first
   -- so we test the canonical "Antigravity" here. *)
VerificationTest[
    Module[ { path, result },
        path = FileNameJoin @ { $TemporaryDirectory, "TestProject" };
        result = Wolfram`AgentTools`Common`projectInstallLocation[ "Antigravity", path ];
        FileNameTake[ First @ result, -2 ]
    ],
    FileNameJoin @ { ".agents", "mcp_config.json" },
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-Antigravity@@Tests/InstallMCPServer.wlt:704,1-713,2"
]

VerificationTest[
    Module[ { path, result },
        path = FileNameJoin @ { $TemporaryDirectory, "TestProject" };
        result = Wolfram`AgentTools`Common`projectInstallLocation[ "VisualStudioCode", path ];
        FileNameTake[ First @ result, -2 ]
    ],
    FileNameJoin @ { ".vscode", "mcp.json" },
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-VisualStudioCode@@Tests/InstallMCPServer.wlt:715,1-724,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`catchAlways[
        Wolfram`AgentTools`Common`projectInstallLocation[ "ClaudeCode", Symbol[ "xyz" ] ]
    ],
    _Failure,
    { AgentTools::InvalidProjectDirectory },
    SameTest -> MatchQ,
    TestID   -> "ProjectInstallLocation-InvalidDirectory-Symbol@@Tests/InstallMCPServer.wlt:726,1-734,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`catchAlways[
        Wolfram`AgentTools`Common`projectInstallLocation[ "ClaudeCode", 123 ]
    ],
    _Failure,
    { AgentTools::InvalidProjectDirectory },
    SameTest -> MatchQ,
    TestID   -> "ProjectInstallLocation-InvalidDirectory-Integer@@Tests/InstallMCPServer.wlt:736,1-744,2"
]

VerificationTest[
    InstallMCPServer[ { "ClaudeCode", Symbol[ "xyz" ] } ],
    _Failure,
    { InstallMCPServer::InvalidProjectDirectory },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-InvalidProjectDirectory@@Tests/InstallMCPServer.wlt:746,1-752,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeDevelopmentArgs*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`makeDevelopmentArgs[ DirectoryName[ $TestFileName, 2 ] ],
    { "-script", _String? FileExistsQ, "-noinit", "-noprompt" },
    SameTest -> MatchQ,
    TestID   -> "MakeDevelopmentArgs-ValidPath@@Tests/InstallMCPServer.wlt:757,1-762,2"
]

VerificationTest[
    configFile = testConfigFile[];
    invalidPath = FileNameJoin @ { $TemporaryDirectory, CreateUUID[ "InvalidPath-" ] };
    InstallMCPServer[ configFile, "DevelopmentMode" -> invalidPath, "VerifyLLMKit" -> False ],
    Failure[ "InstallMCPServer::DevelopmentModeUnavailable", _ ],
    { InstallMCPServer::DevelopmentModeUnavailable },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-InvalidPath@@Tests/InstallMCPServer.wlt:764,1-772,2"
]

VerificationTest[
    configFile = testConfigFile[];
    InstallMCPServer[ configFile, "DevelopmentMode" -> InvalidValue, "VerifyLLMKit" -> False ],
    Failure[ "InstallMCPServer::InvalidDevelopmentMode", _ ],
    { InstallMCPServer::InvalidDevelopmentMode },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-InvalidValue@@Tests/InstallMCPServer.wlt:774,1-781,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*DevelopmentMode Option*)
VerificationTest[
    MemberQ[ Keys @ Options @ InstallMCPServer, "DevelopmentMode" ],
    True,
    TestID -> "DevelopmentMode-OptionExists@@Tests/InstallMCPServer.wlt:786,1-790,2"
]

VerificationTest[
    configFile = testConfigFile[];
    InstallMCPServer[ configFile, "DevelopmentMode" -> DirectoryName[ $TestFileName, 2 ], "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-Success@@Tests/InstallMCPServer.wlt:792,1-798,2"
]

VerificationTest[
    json = Developer`ReadRawJSONFile @ First @ configFile;
    json[ "mcpServers", "Wolfram", "args" ],
    { "-script", _String, "-noinit", "-noprompt" },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-Args@@Tests/InstallMCPServer.wlt:800,1-806,2"
]

VerificationTest[
    cleanupTestFiles[ configFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-Cleanup@@Tests/InstallMCPServer.wlt:808,1-813,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Codex (TOML) Support*)

(* Helper function for TOML test files *)
testTOMLFile = Function[
    File @ FileNameJoin @ { $TemporaryDirectory, StringJoin["mcp_test_config_", CreateUUID[], ".toml"] }
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for Codex*)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Codex", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Codex-Windows@@Tests/InstallMCPServer.wlt:827,1-832,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Codex", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Codex-MacOSX@@Tests/InstallMCPServer.wlt:834,1-839,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Codex", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Codex-Unix@@Tests/InstallMCPServer.wlt:841,1-846,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "OpenAICodex" ],
    "Codex",
    SameTest -> Equal,
    TestID   -> "ToInstallName-OpenAICodex@@Tests/InstallMCPServer.wlt:851,1-856,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Codex" ],
    "Codex",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Codex@@Tests/InstallMCPServer.wlt:858,1-863,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Codex" ],
    "Codex CLI",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Codex@@Tests/InstallMCPServer.wlt:865,1-870,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*TOML Parsing and Writing*)
VerificationTest[
    toml = Wolfram`AgentTools`Common`readTOMLFile @ FileNameJoin @ { $TemporaryDirectory, "nonexistent.toml" };
    toml[ "Data" ],
    <| |>,
    SameTest -> Equal,
    TestID   -> "ReadTOMLFile-NonExistent@@Tests/InstallMCPServer.wlt:875,1-881,2"
]

VerificationTest[
    Module[ { tempFile, content },
        tempFile = First @ testTOMLFile[];
        content = "[section]\nkey = \"value\"\nnumber = 42\nenabled = true\n";
        WriteString[ tempFile, content ];
        Close @ tempFile;
        toml = Wolfram`AgentTools`Common`readTOMLFile @ tempFile;
        DeleteFile @ tempFile;
        toml[ "Data", "section" ]
    ],
    <| "key" -> "value", "number" -> 42, "enabled" -> True |>,
    SameTest -> Equal,
    TestID   -> "ReadTOMLFile-BasicParsing@@Tests/InstallMCPServer.wlt:883,1-896,2"
]

VerificationTest[
    Module[ { tempFile, content },
        tempFile = First @ testTOMLFile[];
        content = "[mcp_servers.TestServer]\ncommand = \"wolfram\"\nargs = [\"-run\", \"test\"]\nenv = { KEY = \"value\" }\nenabled = true\n";
        WriteString[ tempFile, content ];
        Close @ tempFile;
        toml = Wolfram`AgentTools`Common`readTOMLFile @ tempFile;
        DeleteFile @ tempFile;
        toml[ "Data", "mcp_servers", "TestServer" ]
    ],
    <|
        "command" -> "wolfram",
        "args" -> { "-run", "test" },
        "env" -> <| "KEY" -> "value" |>,
        "enabled" -> True
    |>,
    SameTest -> Equal,
    TestID   -> "ReadTOMLFile-MCPServerSection@@Tests/InstallMCPServer.wlt:898,1-916,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Codex Install/Uninstall*)
VerificationTest[
    codexConfigFile = testTOMLFile[];
    (* Use file-based install - TOML format is auto-detected from .toml extension *)
    installResult = InstallMCPServer[ codexConfigFile, "WolframLanguage", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-Basic@@Tests/InstallMCPServer.wlt:921,1-928,2"
]

VerificationTest[
    FileExistsQ[ codexConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-FileExists@@Tests/InstallMCPServer.wlt:930,1-935,2"
]

VerificationTest[
    Module[ { content, toml },
        content = ReadString @ codexConfigFile;
        toml = Wolfram`AgentTools`Common`readTOMLFile @ codexConfigFile;
        KeyExistsQ[ toml[ "Data", "mcp_servers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-VerifyContent@@Tests/InstallMCPServer.wlt:937,1-946,2"
]

VerificationTest[
    Module[ { content },
        content = ReadString @ codexConfigFile;
        StringContainsQ[ content, "[mcp_servers.Wolfram]" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-VerifySectionFormat@@Tests/InstallMCPServer.wlt:948,1-956,2"
]

VerificationTest[
    (* Use file-based uninstall - TOML format is auto-detected from .toml extension *)
    uninstallResult = UninstallMCPServer[ codexConfigFile, "WolframLanguage" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Codex-Basic@@Tests/InstallMCPServer.wlt:958,1-964,2"
]

VerificationTest[
    Module[ { toml },
        toml = Wolfram`AgentTools`Common`readTOMLFile @ codexConfigFile;
        ! KeyExistsQ[ Lookup[ toml[ "Data" ], "mcp_servers", <| |> ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Codex-VerifyRemoval@@Tests/InstallMCPServer.wlt:966,1-974,2"
]

VerificationTest[
    cleanupTestFiles[ codexConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-Cleanup@@Tests/InstallMCPServer.wlt:976,1-981,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Multiple Server Installations (Codex)*)
VerificationTest[
    codexConfigFile = testTOMLFile[];
    (* File-based install with TOML auto-detection *)
    InstallMCPServer[ codexConfigFile, "WolframAlpha", "VerifyLLMKit" -> False ];
    InstallMCPServer[ codexConfigFile, "WolframLanguage", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-MultipleServers@@Tests/InstallMCPServer.wlt:986,1-994,2"
]

VerificationTest[
    Module[ { toml, mcpServers },
        toml = Wolfram`AgentTools`Common`readTOMLFile @ codexConfigFile;
        mcpServers = Lookup[ toml[ "Data" ], "mcp_servers", <| |> ];
        KeyExistsQ[ mcpServers, "Wolfram" ] && Length[ Keys @ mcpServers ] === 1
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-VerifyMultipleBuiltInShareKey@@Tests/InstallMCPServer.wlt:996,1-1005,2"
]

VerificationTest[
    cleanupTestFiles[ codexConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-MultipleServers-Cleanup@@Tests/InstallMCPServer.wlt:1007,1-1012,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Preserve Existing Config (Codex)*)
VerificationTest[
    codexConfigFile = testTOMLFile[];
    Module[ { stream },
        stream = OpenWrite[ First @ codexConfigFile ];
        WriteString[ stream, "# User configuration\nmodel = \"gpt-4\"\nhistory_size = 100\n\n" ];
        Close @ stream
    ];
    (* File-based install with TOML auto-detection *)
    InstallMCPServer[ codexConfigFile, "WolframLanguage", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-PreserveExisting@@Tests/InstallMCPServer.wlt:1017,1-1029,2"
]

VerificationTest[
    Module[ { content },
        content = ReadString @ codexConfigFile;
        StringContainsQ[ content, "model = \"gpt-4\"" ] &&
        StringContainsQ[ content, "history_size = 100" ] &&
        StringContainsQ[ content, "[mcp_servers.Wolfram]" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-VerifyPreserved@@Tests/InstallMCPServer.wlt:1031,1-1041,2"
]

VerificationTest[
    cleanupTestFiles[ codexConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-PreserveExisting-Cleanup@@Tests/InstallMCPServer.wlt:1043,1-1048,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*convertToCodexFormat*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`convertToCodexFormat @ <|
        "command" -> "wolfram",
        "args" -> { "-run", "test" },
        "env" -> <| "KEY" -> "value" |>
    |>,
    <|
        "command" -> "wolfram",
        "args" -> { "-run", "test" },
        "env" -> <| "KEY" -> "value" |>,
        "enabled" -> True
    |>,
    SameTest -> Equal,
    TestID   -> "ConvertToCodexFormat-Basic@@Tests/InstallMCPServer.wlt:1053,1-1067,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`convertToCodexFormat @ <|
        "command" -> "wolfram"
    |>,
    <| "command" -> "wolfram", "enabled" -> True |>,
    SameTest -> Equal,
    TestID   -> "ConvertToCodexFormat-MinimalConfig@@Tests/InstallMCPServer.wlt:1069,1-1076,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Project-Level Codex Install/Uninstall*)
VerificationTest[
    codexProjectDir = FileNameJoin @ { $TemporaryDirectory, "mcp_codex_project_" <> CreateUUID[] };
    codexProjectConfigFile = File @ FileNameJoin @ { codexProjectDir, ".codex", "config.toml" };
    installResult = InstallMCPServer[
        { "Codex", codexProjectDir },
        "WolframLanguage",
        "VerifyLLMKit" -> False
    ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-ProjectInstall@@Tests/InstallMCPServer.wlt:1081,1-1092,2"
]

VerificationTest[
    FileExistsQ @ codexProjectConfigFile,
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-ProjectConfigExists@@Tests/InstallMCPServer.wlt:1094,1-1099,2"
]

VerificationTest[
    Module[ { toml },
        toml = Wolfram`AgentTools`Common`readTOMLFile @ codexProjectConfigFile;
        KeyExistsQ[ Lookup[ toml[ "Data" ], "mcp_servers", <| |> ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-ProjectVerifyContent@@Tests/InstallMCPServer.wlt:1101,1-1109,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ { "Codex", codexProjectDir }, "WolframLanguage" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Codex-ProjectInstall@@Tests/InstallMCPServer.wlt:1111,1-1116,2"
]

VerificationTest[
    Module[ { toml },
        toml = Wolfram`AgentTools`Common`readTOMLFile @ codexProjectConfigFile;
        ! KeyExistsQ[ Lookup[ toml[ "Data" ], "mcp_servers", <| |> ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Codex-ProjectVerifyRemoval@@Tests/InstallMCPServer.wlt:1118,1-1126,2"
]

VerificationTest[
    cleanupTestFiles[ codexProjectConfigFile ];
    If[ DirectoryQ @ FileNameJoin @ { codexProjectDir, ".codex" },
        DeleteDirectory[ FileNameJoin @ { codexProjectDir, ".codex" } ]
    ];
    If[ DirectoryQ @ codexProjectDir,
        DeleteDirectory @ codexProjectDir
    ];
    Null,
    Null,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-ProjectCleanup@@Tests/InstallMCPServer.wlt:1128,1-1140,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Goose (YAML) Support*)

(* Helper function for YAML test files *)
testYAMLFile = Function[
    File @ FileNameJoin @ { $TemporaryDirectory, StringJoin[ "mcp_test_config_", CreateUUID[ ], ".yaml" ] }
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for Goose*)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Goose", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Goose-Windows@@Tests/InstallMCPServer.wlt:1154,1-1159,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Goose", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Goose-MacOSX@@Tests/InstallMCPServer.wlt:1161,1-1166,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Goose", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Goose-Unix@@Tests/InstallMCPServer.wlt:1168,1-1173,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Display Name*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Goose" ],
    "Goose",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Goose@@Tests/InstallMCPServer.wlt:1178,1-1183,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*convertToGooseFormat*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`convertToGooseFormat @ <|
        "command" -> "wolfram",
        "args"    -> { "-run", "test" },
        "env"     -> <| "K" -> "v" |>
    |>,
    <|
        "cmd"     -> "wolfram",
        "args"    -> { "-run", "test" },
        "enabled" -> True,
        "envs"    -> <| "K" -> "v" |>,
        "type"    -> "stdio",
        "timeout" -> 300
    |>,
    SameTest -> Equal,
    TestID   -> "ConvertToGooseFormat-Basic@@Tests/InstallMCPServer.wlt:1188,1-1204,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`convertToGooseFormat @ <|
        "command" -> "wolfram"
    |>,
    <|
        "cmd"     -> "wolfram",
        "enabled" -> True,
        "type"    -> "stdio",
        "timeout" -> 300
    |>,
    SameTest -> Equal,
    TestID   -> "ConvertToGooseFormat-MinimalConfig@@Tests/InstallMCPServer.wlt:1206,1-1218,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Goose Install/Uninstall*)
VerificationTest[
    gooseConfigFile = testYAMLFile[ ];
    installResult = InstallMCPServer[ gooseConfigFile, "WolframLanguage", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Goose-Basic@@Tests/InstallMCPServer.wlt:1223,1-1229,2"
]

VerificationTest[
    FileExistsQ @ gooseConfigFile,
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Goose-FileExists@@Tests/InstallMCPServer.wlt:1231,1-1236,2"
]

VerificationTest[
    Module[ { yaml },
        yaml = Wolfram`AgentTools`Common`importYAML @ gooseConfigFile;
        AssociationQ @ yaml &&
            AssociationQ @ Lookup[ yaml, "extensions" ] &&
            KeyExistsQ[ yaml[ "extensions" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Goose-VerifyContent@@Tests/InstallMCPServer.wlt:1238,1-1248,2"
]

VerificationTest[
    Module[ { yaml, server },
        yaml = Wolfram`AgentTools`Common`importYAML @ gooseConfigFile;
        server = yaml[ "extensions", "Wolfram" ];
        AllTrue[
            { "name", "cmd", "args", "enabled", "envs", "type", "timeout" },
            KeyExistsQ[ server, # ] &
        ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Goose-VerifyAllFields@@Tests/InstallMCPServer.wlt:1250,1-1262,2"
]

VerificationTest[
    Module[ { yaml, server },
        yaml = Wolfram`AgentTools`Common`importYAML @ gooseConfigFile;
        server = yaml[ "extensions", "Wolfram" ];
        server[ "enabled" ] === True &&
            server[ "type" ] === "stdio" &&
            server[ "timeout" ] === 300 &&
            server[ "name" ] === "Wolfram"
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Goose-VerifyFieldValues@@Tests/InstallMCPServer.wlt:1264,1-1276,2"
]

VerificationTest[
    Module[ { content },
        content = ReadString @ gooseConfigFile;
        StringContainsQ[ content, "extensions:" ] &&
            StringContainsQ[ content, "cmd:" ] &&
            StringContainsQ[ content, "type: stdio" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Goose-VerifyLiteralYAML@@Tests/InstallMCPServer.wlt:1278,1-1288,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ gooseConfigFile, "WolframLanguage" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Goose-Basic@@Tests/InstallMCPServer.wlt:1290,1-1295,2"
]

VerificationTest[
    Module[ { yaml },
        yaml = Wolfram`AgentTools`Common`importYAML @ gooseConfigFile;
        ! KeyExistsQ[ Lookup[ yaml, "extensions", <| |> ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Goose-VerifyRemoval@@Tests/InstallMCPServer.wlt:1297,1-1305,2"
]

VerificationTest[
    cleanupTestFiles[ gooseConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Goose-Cleanup@@Tests/InstallMCPServer.wlt:1307,1-1312,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Multiple Server Installations (Goose)*)
VerificationTest[
    gooseConfigFile = testYAMLFile[ ];
    InstallMCPServer[ gooseConfigFile, "WolframAlpha", "VerifyLLMKit" -> False ];
    InstallMCPServer[ gooseConfigFile, "WolframLanguage", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Goose-MultipleServers@@Tests/InstallMCPServer.wlt:1317,1-1324,2"
]

VerificationTest[
    Module[ { yaml, extensions },
        yaml = Wolfram`AgentTools`Common`importYAML @ gooseConfigFile;
        extensions = Lookup[ yaml, "extensions", <| |> ];
        KeyExistsQ[ extensions, "Wolfram" ] && Length[ Keys @ extensions ] === 1
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Goose-VerifyMultipleBuiltInShareKey@@Tests/InstallMCPServer.wlt:1326,1-1335,2"
]

VerificationTest[
    cleanupTestFiles[ gooseConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Goose-MultipleServers-Cleanup@@Tests/InstallMCPServer.wlt:1337,1-1342,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Preserve Existing Extension (Goose)*)
VerificationTest[
    gooseConfigFile = testYAMLFile[ ];
    Module[ { stream },
        stream = OpenWrite[ First @ gooseConfigFile ];
        WriteString[
            stream,
            "extensions:\n  other:\n    cmd: foo\n    enabled: true\n    type: stdio\n    timeout: 60\n"
        ];
        Close @ stream
    ];
    InstallMCPServer[ gooseConfigFile, "WolframLanguage", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Goose-PreserveExisting@@Tests/InstallMCPServer.wlt:1347,1-1361,2"
]

VerificationTest[
    Module[ { yaml, extensions },
        yaml = Wolfram`AgentTools`Common`importYAML @ gooseConfigFile;
        extensions = Lookup[ yaml, "extensions", <| |> ];
        KeyExistsQ[ extensions, "other" ] && KeyExistsQ[ extensions, "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Goose-VerifyPreserved@@Tests/InstallMCPServer.wlt:1363,1-1372,2"
]

VerificationTest[
    cleanupTestFiles[ gooseConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Goose-PreserveExisting-Cleanup@@Tests/InstallMCPServer.wlt:1374,1-1379,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Refuse to Overwrite Unparseable YAML (Goose)*)
VerificationTest[
    gooseConfigFile = testYAMLFile[ ];
    (* A file that is just plausible enough to be hand-edited but malformed enough to fail parsing *)
    Module[ { stream },
        stream = OpenWrite @ First @ gooseConfigFile;
        WriteString[ stream, "extensions:\n  Wolfram:\n    cmd: wolfram\n     name: bad-indent\n" ];
        Close @ stream
    ];
    InstallMCPServer[ gooseConfigFile, "WolframLanguage", "VerifyLLMKit" -> False ],
    _Failure,
    { InstallMCPServer::InvalidMCPConfiguration },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Goose-RefusesUnparseableYAML@@Tests/InstallMCPServer.wlt:1384,1-1397,2"
]

VerificationTest[
    Module[ { content },
        content = ReadString @ First @ gooseConfigFile;
        (* The file must NOT have been overwritten *)
        StringContainsQ[ content, "bad-indent" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Goose-PreservesUnparseableYAML@@Tests/InstallMCPServer.wlt:1399,1-1408,2"
]

VerificationTest[
    cleanupTestFiles[ gooseConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Goose-RefusesUnparseableYAML-Cleanup@@Tests/InstallMCPServer.wlt:1410,1-1415,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Refuse to Overwrite Unparseable YAML on Uninstall (Goose)*)
VerificationTest[
    gooseConfigFile = testYAMLFile[ ];
    Module[ { stream },
        stream = OpenWrite @ First @ gooseConfigFile;
        WriteString[ stream, "extensions:\n  Wolfram:\n    cmd: wolfram\n     name: bad-indent\n" ];
        Close @ stream
    ];
    UninstallMCPServer[ gooseConfigFile, "WolframLanguage" ],
    _Failure,
    { UninstallMCPServer::InvalidMCPConfiguration },
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Goose-RefusesUnparseableYAML@@Tests/InstallMCPServer.wlt:1420,1-1432,2"
]

VerificationTest[
    Module[ { content },
        content = ReadString @ First @ gooseConfigFile;
        (* The file must NOT have been overwritten *)
        StringContainsQ[ content, "bad-indent" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Goose-PreservesUnparseableYAML@@Tests/InstallMCPServer.wlt:1434,1-1443,2"
]

VerificationTest[
    cleanupTestFiles[ gooseConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Goose-RefusesUnparseableYAML-Cleanup@@Tests/InstallMCPServer.wlt:1445,1-1450,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*No Project Support*)
VerificationTest[
    Wolfram`AgentTools`Common`catchTop @ InstallMCPServer[
        { "Goose", $TemporaryDirectory },
        "WolframLanguage",
        "VerifyLLMKit" -> False
    ],
    _Failure,
    { AgentTools::UnsupportedMCPClientProject },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Goose-NoProjectSupport@@Tests/InstallMCPServer.wlt:1455,1-1465,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Continue (YAML) Support*)

(* Helper for Continue YAML test files *)
testContinueFile = Function[
    File @ FileNameJoin @ { $TemporaryDirectory, StringJoin[ "continue_test_", CreateUUID[ ], ".yaml" ] }
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for Continue*)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Continue", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Continue-Windows@@Tests/InstallMCPServer.wlt:1479,1-1484,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Continue", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Continue-MacOSX@@Tests/InstallMCPServer.wlt:1486,1-1491,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Continue", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Continue-Unix@@Tests/InstallMCPServer.wlt:1493,1-1498,2"
]

(* Continue's user-scope path is .continue/config.yaml under $HomeDirectory on every OS *)
VerificationTest[
    Module[ { file, split },
        file = Wolfram`AgentTools`Common`installLocation[ "Continue", $OperatingSystem ];
        split = FileNameSplit @ First @ file;
        Take[ split, -2 ]
    ],
    { ".continue", "config.yaml" },
    SameTest -> Equal,
    TestID   -> "InstallLocation-Continue-PathShape@@Tests/InstallMCPServer.wlt:1501,1-1510,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Continue" ],
    "Continue",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Continue@@Tests/InstallMCPServer.wlt:1515,1-1520,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Continue" ],
    "Continue",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Continue@@Tests/InstallMCPServer.wlt:1522,1-1527,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*convertToContinueFormat*)

(* Drops "type" key, keeps command/args/env; omits empty args/env *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToContinueFormat @ <|
        "type" -> "stdio",
        "command" -> "wolfram",
        "args" -> { "-run", "test" },
        "env" -> <| "KEY" -> "value" |>
    |>,
    <|
        "command" -> "wolfram",
        "args" -> { "-run", "test" },
        "env" -> <| "KEY" -> "value" |>
    |>,
    SameTest -> Equal,
    TestID   -> "ConvertToContinueFormat-Basic@@Tests/InstallMCPServer.wlt:1534,1-1548,2"
]

(* Empty args and env are omitted *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToContinueFormat @ <|
        "command" -> "wolfram",
        "args" -> { },
        "env" -> <| |>
    |>,
    <| "command" -> "wolfram" |>,
    SameTest -> Equal,
    TestID   -> "ConvertToContinueFormat-OmitsEmpty@@Tests/InstallMCPServer.wlt:1551,1-1560,2"
]

(* Converter does NOT set the "name" field -- the install flow prepends it after conversion *)
VerificationTest[
    KeyExistsQ[
        Wolfram`AgentTools`SupportedClients`Private`convertToContinueFormat @ <| "command" -> "/tmp/wolfram" |>,
        "name"
    ],
    False,
    SameTest -> Equal,
    TestID   -> "ConvertToContinueFormat-NoNameField@@Tests/InstallMCPServer.wlt:1563,1-1571,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readExistingContinueConfig*)

(* Non-existent file returns empty mapping *)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`readExistingContinueConfig @ File @
        FileNameJoin @ { $TemporaryDirectory, "continue_noexist_" <> CreateUUID[] <> ".yaml" },
    <| |>,
    SameTest -> Equal,
    TestID   -> "ReadExistingContinueConfig-NonExistent@@Tests/InstallMCPServer.wlt:1578,1-1584,2"
]

(* Valid YAML with mcpServers array is returned as an Association *)
VerificationTest[
    Module[ { file, result },
        file = File @ FileNameJoin @ { $TemporaryDirectory, "continue_valid_" <> CreateUUID[] <> ".yaml" };
        WithCleanup[
            Wolfram`AgentTools`Common`exportYAML[
                file,
                <| "mcpServers" -> { <| "name" -> "X", "command" -> "y" |> } |>
            ];
            result = Wolfram`AgentTools`InstallMCPServer`Private`readExistingContinueConfig @ file,
            Quiet @ DeleteFile @ First @ file
        ];
        AssociationQ @ result && ListQ @ result[ "mcpServers" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "ReadExistingContinueConfig-ValidYAML@@Tests/InstallMCPServer.wlt:1587,1-1603,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Continue Install and Uninstall (Global Scope)*)
VerificationTest[
    continueConfigFile = testContinueFile[ ];
    installResult = InstallMCPServer[
        continueConfigFile,
        "WolframLanguage",
        "VerifyLLMKit" -> False,
        "ApplicationName" -> "Continue"
    ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Continue-Basic@@Tests/InstallMCPServer.wlt:1608,1-1619,2"
]

VerificationTest[
    FileExistsQ[ continueConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Continue-FileExists@@Tests/InstallMCPServer.wlt:1621,1-1626,2"
]

(* Root is an Association with mcpServers as an array *)
VerificationTest[
    Module[ { content },
        content = Wolfram`AgentTools`Common`importYAML @ continueConfigFile;
        AssociationQ @ content &&
        ListQ @ content[ "mcpServers" ] &&
        Length @ content[ "mcpServers" ] === 1
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Continue-RootShape@@Tests/InstallMCPServer.wlt:1629,1-1639,2"
]

(* The single entry has inline name + command + args + env *)
VerificationTest[
    Module[ { content, entry },
        content = Wolfram`AgentTools`Common`importYAML @ continueConfigFile;
        entry = First @ content[ "mcpServers" ];
        AssociationQ @ entry &&
        entry[ "name" ] === "Wolfram" &&
        StringQ @ entry[ "command" ] &&
        ListQ @ Lookup[ entry, "args", { } ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Continue-EntryShape@@Tests/InstallMCPServer.wlt:1642,1-1654,2"
]

(* Continue REQUIRES name / version / schema at the top of every config.yaml -- including
   the global one. A file missing any of these fails Continue's schema validation and
   is silently ignored. *)
VerificationTest[
    Module[ { content },
        content = Wolfram`AgentTools`Common`importYAML @ continueConfigFile;
        StringQ @ content[ "name" ] &&
        StringQ @ content[ "version" ] &&
        content[ "schema" ] === "v1"
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Continue-Global-RequiredMetadata@@Tests/InstallMCPServer.wlt:1659,1-1669,2"
]

(* Continue uses the standard server fields -- no Cline disabled/autoApprove, no Copilot tools *)
VerificationTest[
    Module[ { content, entry },
        content = Wolfram`AgentTools`Common`importYAML @ continueConfigFile;
        entry = First @ content[ "mcpServers" ];
        ! KeyExistsQ[ entry, "disabled" ] &&
        ! KeyExistsQ[ entry, "autoApprove" ] &&
        ! KeyExistsQ[ entry, "tools" ] &&
        ! KeyExistsQ[ entry, "type" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Continue-StandardFormat@@Tests/InstallMCPServer.wlt:1672,1-1684,2"
]

(* Idempotent re-install: array stays length 1 *)
VerificationTest[
    InstallMCPServer[ continueConfigFile, "WolframLanguage",
        "VerifyLLMKit" -> False, "ApplicationName" -> "Continue" ];
    Module[ { content },
        content = Wolfram`AgentTools`Common`importYAML @ continueConfigFile;
        Length @ Cases[ content[ "mcpServers" ], KeyValuePattern @ { "name" -> "Wolfram" } ]
    ],
    1,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Continue-Idempotent@@Tests/InstallMCPServer.wlt:1687,1-1697,2"
]

(* Second, differently-named server is appended, not replaced *)
VerificationTest[
    InstallMCPServer[ continueConfigFile, "WolframAlpha",
        "VerifyLLMKit" -> False, "ApplicationName" -> "Continue", "MCPServerName" -> "WolframAlphaExtra" ];
    Module[ { content, names },
        content = Wolfram`AgentTools`Common`importYAML @ continueConfigFile;
        names = Sort @ Cases[ content[ "mcpServers" ], KeyValuePattern @ { "name" -> n_String } :> n ];
        names
    ],
    { "Wolfram", "WolframAlphaExtra" },
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Continue-MultiServer@@Tests/InstallMCPServer.wlt:1700,1-1711,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ continueConfigFile, "WolframLanguage", "ApplicationName" -> "Continue" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Continue-Basic@@Tests/InstallMCPServer.wlt:1713,1-1718,2"
]

(* After removing WolframLanguage, only WolframAlphaExtra remains *)
VerificationTest[
    Module[ { content, names },
        content = Wolfram`AgentTools`Common`importYAML @ continueConfigFile;
        names = Cases[ content[ "mcpServers" ], KeyValuePattern @ { "name" -> n_String } :> n ];
        names
    ],
    { "WolframAlphaExtra" },
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Continue-VerifyRemoval@@Tests/InstallMCPServer.wlt:1721,1-1730,2"
]

(* Uninstalling a name that isn't in the array returns NotInstalled *)
VerificationTest[
    UninstallMCPServer[ continueConfigFile, "WolframLanguage", "ApplicationName" -> "Continue" ],
    Missing[ "NotInstalled", _ ],
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Continue-NotInstalled@@Tests/InstallMCPServer.wlt:1733,1-1738,2"
]

VerificationTest[
    cleanupTestFiles[ continueConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Continue-Cleanup@@Tests/InstallMCPServer.wlt:1740,1-1745,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Continue Project-Level Install (Standalone Block File)*)

(* Project-scope writes a standalone block file in .continue/mcpServers/ with required metadata *)
VerificationTest[
    Module[ { dir, projectFile, content, result },
        dir = FileNameJoin @ { $TemporaryDirectory, "continue_proj_" <> CreateUUID[] };
        CreateDirectory @ dir;
        WithCleanup[
            result = InstallMCPServer[
                { "Continue", dir },
                "WolframLanguage",
                "VerifyLLMKit" -> False
            ];
            projectFile = FileNameJoin @ { dir, ".continue", "mcpServers", "wolfram.yaml" };
            content = If[ FileExistsQ @ projectFile,
                Wolfram`AgentTools`Common`importYAML @ File @ projectFile,
                Missing[ ]
            ];
            {
                MatchQ[ result, _Success ],
                FileExistsQ @ projectFile,
                AssociationQ @ content,
                content[ "name" ],
                StringQ @ content[ "version" ],
                content[ "schema" ],
                ListQ @ content[ "mcpServers" ],
                Length @ content[ "mcpServers" ]
            },
            Quiet @ DeleteDirectory[ dir, DeleteContents -> True ]
        ]
    ],
    { True, True, True, "Wolfram", True, "v1", True, 1 },
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Continue-ProjectLevel@@Tests/InstallMCPServer.wlt:1752,1-1783,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Continue Preserves Unrelated Top-Level Keys*)

(* Continue's config.yaml may contain unrelated top-level sections (models:, rules:, etc.)
   and a user-chosen `name`. InstallMCPServer must preserve those -- only the mcpServers
   section may change. The required top-level `version` and `schema` should be added
   if missing, but a pre-existing `name` must not be overwritten. *)
VerificationTest[
    Module[ { file, content },
        file = testContinueFile[ ];
        WithCleanup[
            (* Seed the file with unrelated top-level keys and a user-chosen name *)
            Wolfram`AgentTools`Common`exportYAML[
                file,
                <|
                    "name"   -> "My Continue Config",
                    "models" -> { <| "name" -> "gpt-4", "provider" -> "openai" |> },
                    "rules"  -> { "Be concise." }
                |>
            ];
            InstallMCPServer[ file, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "Continue" ];
            content = Wolfram`AgentTools`Common`importYAML @ file,
            cleanupTestFiles @ file
        ];
        {
            content[ "name" ],
            content[ "models" ],
            content[ "rules" ],
            ListQ @ content[ "mcpServers" ],
            Length @ content[ "mcpServers" ],
            (* Version and schema must be added when missing *)
            StringQ @ content[ "version" ],
            content[ "schema" ]
        }
    ],
    { "My Continue Config", { <| "name" -> "gpt-4", "provider" -> "openai" |> }, { "Be concise." }, True, 1, True, "v1" },
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Continue-PreservesUnrelatedKeys@@Tests/InstallMCPServer.wlt:1793,1-1824,2"
]

(* Fresh global config.yaml (no pre-existing user keys) gets the "Local Config" default
   name rather than the project-scope "Wolfram" name. *)
VerificationTest[
    Module[ { file, content },
        file = testContinueFile[ ];
        WithCleanup[
            InstallMCPServer[ file, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "Continue" ];
            content = Wolfram`AgentTools`Common`importYAML @ file,
            cleanupTestFiles @ file
        ];
        content[ "name" ]
    ],
    "Local Config",
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Continue-Global-DefaultName@@Tests/InstallMCPServer.wlt:1828,1-1841,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Auto-Detection from Path*)

(* File at .continue/config.yaml is auto-detected as Continue when installing without ApplicationName *)
VerificationTest[
    Module[ { dir, file, content },
        dir = FileNameJoin @ { $TemporaryDirectory, "continue_auto_" <> CreateUUID[], ".continue" };
        CreateDirectory[ dir, CreateIntermediateDirectories -> True ];
        file = FileNameJoin @ { dir, "config.yaml" };
        WithCleanup[
            InstallMCPServer[ File @ file, "WolframLanguage", "VerifyLLMKit" -> False ];
            content = Wolfram`AgentTools`Common`importYAML @ File @ file,
            Quiet @ DeleteDirectory[ DirectoryName @ dir, DeleteContents -> True ]
        ];
        AssociationQ @ content && ListQ @ content[ "mcpServers" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "GuessClientName-Continue-GlobalPath@@Tests/InstallMCPServer.wlt:1848,1-1863,2"
]

(* File at .continue/mcpServers/<X>.yaml is auto-detected as Continue *)
VerificationTest[
    Module[ { dir, file, content },
        dir = FileNameJoin @ { $TemporaryDirectory, "continue_auto_proj_" <> CreateUUID[], ".continue", "mcpServers" };
        CreateDirectory[ dir, CreateIntermediateDirectories -> True ];
        file = FileNameJoin @ { dir, "wolfram.yaml" };
        WithCleanup[
            InstallMCPServer[ File @ file, "WolframLanguage", "VerifyLLMKit" -> False ];
            content = Wolfram`AgentTools`Common`importYAML @ File @ file,
            Quiet @ DeleteDirectory[ DirectoryName @ dir, DeleteContents -> True ];
            Quiet @ DeleteDirectory[ DirectoryName[ dir, 2 ] ]
        ];
        AssociationQ @ content &&
        content[ "schema" ] === "v1" &&
        ListQ @ content[ "mcpServers" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "GuessClientName-Continue-ProjectPath@@Tests/InstallMCPServer.wlt:1866,1-1884,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$SupportedMCPClients metadata for Continue*)
VerificationTest[
    $SupportedMCPClients[ "Continue", "DisplayName" ],
    "Continue",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ContinueDisplayName@@Tests/InstallMCPServer.wlt:1889,1-1894,2"
]

VerificationTest[
    $SupportedMCPClients[ "Continue", "ConfigFormat" ],
    "YAML",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ContinueConfigFormat@@Tests/InstallMCPServer.wlt:1896,1-1901,2"
]

VerificationTest[
    $SupportedMCPClients[ "Continue", "ConfigKey" ],
    { "mcpServers" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ContinueConfigKey@@Tests/InstallMCPServer.wlt:1903,1-1908,2"
]

VerificationTest[
    $SupportedMCPClients[ "Continue", "ProjectSupport" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ContinueProjectSupport@@Tests/InstallMCPServer.wlt:1910,1-1915,2"
]

VerificationTest[
    $SupportedMCPClients[ "Continue", "DefaultToolset" ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ContinueDefaultToolset@@Tests/InstallMCPServer.wlt:1917,1-1922,2"
]

VerificationTest[
    StringStartsQ[ $SupportedMCPClients[ "Continue", "URL" ], "https://" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ContinueURL@@Tests/InstallMCPServer.wlt:1924,1-1929,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Copilot CLI Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for Copilot CLI*)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "CopilotCLI", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-CopilotCLI-Windows@@Tests/InstallMCPServer.wlt:1938,1-1943,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "CopilotCLI", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-CopilotCLI-MacOSX@@Tests/InstallMCPServer.wlt:1945,1-1950,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "CopilotCLI", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-CopilotCLI-Unix@@Tests/InstallMCPServer.wlt:1952,1-1957,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Copilot" ],
    "CopilotCLI",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Copilot@@Tests/InstallMCPServer.wlt:1962,1-1967,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "CopilotCLI" ],
    "CopilotCLI",
    SameTest -> Equal,
    TestID   -> "ToInstallName-CopilotCLI@@Tests/InstallMCPServer.wlt:1969,1-1974,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "CopilotCLI" ],
    "Copilot CLI",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-CopilotCLI@@Tests/InstallMCPServer.wlt:1976,1-1981,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*convertToCopilotCLIFormat*)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToCopilotCLIFormat @ <|
        "command" -> "wolfram",
        "args" -> { "-run", "test" },
        "env" -> <| "KEY" -> "value" |>
    |>,
    <|
        "command" -> "wolfram",
        "args" -> { "-run", "test" },
        "env" -> <| "KEY" -> "value" |>,
        "tools" -> { "*" }
    |>,
    SameTest -> Equal,
    TestID   -> "ConvertToCopilotCLIFormat-Basic@@Tests/InstallMCPServer.wlt:1986,1-2000,2"
]

VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToCopilotCLIFormat @ <|
        "command" -> "wolfram"
    |>,
    <| "command" -> "wolfram", "tools" -> { "*" } |>,
    SameTest -> Equal,
    TestID   -> "ConvertToCopilotCLIFormat-MinimalConfig@@Tests/InstallMCPServer.wlt:2002,1-2009,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Windsurf Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for Windsurf*)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Windsurf", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Windsurf-Windows@@Tests/InstallMCPServer.wlt:2018,1-2023,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Windsurf", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Windsurf-MacOSX@@Tests/InstallMCPServer.wlt:2025,1-2030,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Windsurf", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Windsurf-Unix@@Tests/InstallMCPServer.wlt:2032,1-2037,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Codeium" ],
    "Windsurf",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Codeium@@Tests/InstallMCPServer.wlt:2042,1-2047,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Windsurf" ],
    "Windsurf",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Windsurf@@Tests/InstallMCPServer.wlt:2049,1-2054,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Windsurf" ],
    "Windsurf",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Windsurf@@Tests/InstallMCPServer.wlt:2056,1-2061,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cline Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for Cline*)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Cline", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Cline-Windows@@Tests/InstallMCPServer.wlt:2070,1-2075,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Cline", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Cline-MacOSX@@Tests/InstallMCPServer.wlt:2077,1-2082,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Cline", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Cline-Unix@@Tests/InstallMCPServer.wlt:2084,1-2089,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Cline" ],
    "Cline",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Cline@@Tests/InstallMCPServer.wlt:2094,1-2099,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Cline" ],
    "Cline",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Cline@@Tests/InstallMCPServer.wlt:2101,1-2106,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*convertToClineFormat*)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToClineFormat @ <|
        "command" -> "wolfram",
        "args" -> { "-run", "test" },
        "env" -> <| "KEY" -> "value" |>
    |>,
    <|
        "command" -> "wolfram",
        "args" -> { "-run", "test" },
        "env" -> <| "KEY" -> "value" |>,
        "disabled" -> False,
        "autoApprove" -> { }
    |>,
    SameTest -> Equal,
    TestID   -> "ConvertToClineFormat-Basic@@Tests/InstallMCPServer.wlt:2111,1-2126,2"
]

VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToClineFormat @ <|
        "command" -> "wolfram"
    |>,
    <| "command" -> "wolfram", "disabled" -> False, "autoApprove" -> { } |>,
    SameTest -> Equal,
    TestID   -> "ConvertToClineFormat-MinimalConfig@@Tests/InstallMCPServer.wlt:2128,1-2135,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cline Install and Uninstall*)
VerificationTest[
    clineConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ clineConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "Cline" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Cline-Basic@@Tests/InstallMCPServer.wlt:2140,1-2146,2"
]

VerificationTest[
    FileExistsQ[ clineConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Cline-FileExists@@Tests/InstallMCPServer.wlt:2148,1-2153,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ clineConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Cline-VerifyContent@@Tests/InstallMCPServer.wlt:2155,1-2163,2"
]

VerificationTest[
    Module[ { content, server },
        content = Import[ clineConfigFile, "RawJSON" ];
        server = content[ "mcpServers", "Wolfram" ];
        KeyExistsQ[ server, "disabled" ] && server[ "disabled" ] === False &&
        KeyExistsQ[ server, "autoApprove" ] && server[ "autoApprove" ] === { }
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Cline-VerifyClineFields@@Tests/InstallMCPServer.wlt:2165,1-2175,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ clineConfigFile, "WolframLanguage", "ApplicationName" -> "Cline" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Cline-Basic@@Tests/InstallMCPServer.wlt:2177,1-2182,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ clineConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && ! KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Cline-VerifyRemoval@@Tests/InstallMCPServer.wlt:2184,1-2192,2"
]

VerificationTest[
    cleanupTestFiles[ clineConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Cline-Cleanup@@Tests/InstallMCPServer.wlt:2194,1-2199,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Windsurf Install and Uninstall*)
VerificationTest[
    windsurfConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ windsurfConfigFile, "WolframLanguage", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Windsurf-Basic@@Tests/InstallMCPServer.wlt:2204,1-2210,2"
]

VerificationTest[
    FileExistsQ[ windsurfConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Windsurf-FileExists@@Tests/InstallMCPServer.wlt:2212,1-2217,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ windsurfConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Windsurf-VerifyContent@@Tests/InstallMCPServer.wlt:2219,1-2227,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ windsurfConfigFile, "WolframLanguage" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Windsurf-Basic@@Tests/InstallMCPServer.wlt:2229,1-2234,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ windsurfConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && ! KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Windsurf-VerifyRemoval@@Tests/InstallMCPServer.wlt:2236,1-2244,2"
]

VerificationTest[
    cleanupTestFiles[ windsurfConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Windsurf-Cleanup@@Tests/InstallMCPServer.wlt:2246,1-2251,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Augment Code Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for AugmentCode*)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AugmentCode", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AugmentCode-Windows@@Tests/InstallMCPServer.wlt:2260,1-2265,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AugmentCode", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AugmentCode-MacOSX@@Tests/InstallMCPServer.wlt:2267,1-2272,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AugmentCode", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AugmentCode-Unix@@Tests/InstallMCPServer.wlt:2274,1-2279,2"
]

(* Install location path must end with .augment/settings.json on all platforms *)
VerificationTest[
    Module[ { file, split },
        file = Wolfram`AgentTools`Common`installLocation[ "AugmentCode", $OperatingSystem ];
        split = FileNameSplit @ First @ file;
        Take[ split, -2 ]
    ],
    { ".augment", "settings.json" },
    SameTest -> Equal,
    TestID   -> "InstallLocation-AugmentCode-PathShape@@Tests/InstallMCPServer.wlt:2282,1-2291,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "AugmentCode" ],
    "AugmentCode",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AugmentCode@@Tests/InstallMCPServer.wlt:2296,1-2301,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Auggie" ],
    "AugmentCode",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Auggie@@Tests/InstallMCPServer.wlt:2303,1-2308,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Augment" ],
    "AugmentCode",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Augment@@Tests/InstallMCPServer.wlt:2310,1-2315,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "AugmentCode" ],
    "Augment Code",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-AugmentCode@@Tests/InstallMCPServer.wlt:2317,1-2322,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*AugmentCode Install and Uninstall*)
VerificationTest[
    augmentConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ augmentConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "AugmentCode" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AugmentCode-Basic@@Tests/InstallMCPServer.wlt:2327,1-2333,2"
]

VerificationTest[
    FileExistsQ[ augmentConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AugmentCode-FileExists@@Tests/InstallMCPServer.wlt:2335,1-2340,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ augmentConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AugmentCode-VerifyContent@@Tests/InstallMCPServer.wlt:2342,1-2350,2"
]

(* AugmentCode uses the standard mcpServers format: no Cline-style disabled/autoApprove fields
   and no Copilot-style tools field should be added *)
VerificationTest[
    Module[ { content, server },
        content = Import[ augmentConfigFile, "RawJSON" ];
        server = content[ "mcpServers", "Wolfram" ];
        KeyExistsQ[ server, "command" ] &&
        ! KeyExistsQ[ server, "disabled" ] &&
        ! KeyExistsQ[ server, "autoApprove" ] &&
        ! KeyExistsQ[ server, "tools" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AugmentCode-StandardFormat@@Tests/InstallMCPServer.wlt:2354,1-2366,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ augmentConfigFile, "WolframLanguage", "ApplicationName" -> "AugmentCode" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-AugmentCode-Basic@@Tests/InstallMCPServer.wlt:2368,1-2373,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ augmentConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && ! KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-AugmentCode-VerifyRemoval@@Tests/InstallMCPServer.wlt:2375,1-2383,2"
]

VerificationTest[
    cleanupTestFiles[ augmentConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AugmentCode-Cleanup@@Tests/InstallMCPServer.wlt:2385,1-2390,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*convertToAugmentCodeFormat*)

(* Non-Windows: converter returns the entry unchanged regardless of the command path *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToAugmentCodeFormat[
        <|
            "command" -> "/usr/local/bin/wolfram",
            "args" -> { "-run", "test" },
            "env" -> <| "KEY" -> "value" |>
        |>,
        "Unix"
    ],
    <|
        "command" -> "/usr/local/bin/wolfram",
        "args" -> { "-run", "test" },
        "env" -> <| "KEY" -> "value" |>
    |>,
    SameTest -> Equal,
    TestID   -> "ConvertToAugmentCodeFormat-NonWindows@@Tests/InstallMCPServer.wlt:2397,1-2413,2"
]

(* Non-Windows with a space-containing command: still unchanged *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToAugmentCodeFormat[
        <| "command" -> "/Applications/Wolfram Desktop.app/Contents/MacOS/wolfram" |>,
        "MacOSX"
    ],
    <| "command" -> "/Applications/Wolfram Desktop.app/Contents/MacOS/wolfram" |>,
    SameTest -> Equal,
    TestID   -> "ConvertToAugmentCodeFormat-NonWindows-WithSpaces@@Tests/InstallMCPServer.wlt:2416,1-2424,2"
]

(* Windows with a space-free command: unchanged (no short-path lookup needed) *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToAugmentCodeFormat[
        <|
            "command" -> "C:\\Wolfram\\wolfram.exe",
            "args" -> { "-run", "test" }
        |>,
        "Windows"
    ],
    <|
        "command" -> "C:\\Wolfram\\wolfram.exe",
        "args" -> { "-run", "test" }
    |>,
    SameTest -> Equal,
    TestID   -> "ConvertToAugmentCodeFormat-Windows-NoSpaces@@Tests/InstallMCPServer.wlt:2427,1-2441,2"
]

(* Missing command: converter should not error *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToAugmentCodeFormat[
        <| "args" -> { "-run", "test" } |>,
        "Windows"
    ],
    <| "args" -> { "-run", "test" } |>,
    SameTest -> Equal,
    TestID   -> "ConvertToAugmentCodeFormat-MissingCommand@@Tests/InstallMCPServer.wlt:2444,1-2452,2"
]

(* Windows with a space-containing path to a non-existent file: falls back to the
   original path (toWindowsShortPath returns unchanged when the file does not exist) *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToAugmentCodeFormat[
        <| "command" -> "C:\\Does Not Exist\\wolfram.exe" |>,
        "Windows"
    ],
    <| "command" -> "C:\\Does Not Exist\\wolfram.exe" |>,
    SameTest -> Equal,
    TestID   -> "ConvertToAugmentCodeFormat-Windows-NonExistentPath@@Tests/InstallMCPServer.wlt:2456,1-2464,2"
]

(* 1-arg form dispatches to 2-arg form using $OperatingSystem *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToAugmentCodeFormat @ <|
        "command" -> "/no/spaces/here"
    |>,
    <| "command" -> "/no/spaces/here" |>,
    SameTest -> Equal,
    TestID   -> "ConvertToAugmentCodeFormat-OneArgForm@@Tests/InstallMCPServer.wlt:2467,1-2474,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Augment Code IDE Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for AugmentCodeIDE*)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AugmentCodeIDE", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AugmentCodeIDE-Windows@@Tests/InstallMCPServer.wlt:2483,1-2488,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AugmentCodeIDE", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AugmentCodeIDE-MacOSX@@Tests/InstallMCPServer.wlt:2490,1-2495,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AugmentCodeIDE", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AugmentCodeIDE-Unix@@Tests/InstallMCPServer.wlt:2497,1-2502,2"
]

(* Install location must end with augment.vscode-augment/augment-global-state/mcpServers.json on all platforms *)
VerificationTest[
    Module[ { file, split },
        file = Wolfram`AgentTools`Common`installLocation[ "AugmentCodeIDE", $OperatingSystem ];
        split = FileNameSplit @ First @ file;
        Take[ split, -3 ]
    ],
    { "augment.vscode-augment", "augment-global-state", "mcpServers.json" },
    SameTest -> Equal,
    TestID   -> "InstallLocation-AugmentCodeIDE-PathShape@@Tests/InstallMCPServer.wlt:2505,1-2514,2"
]

(* Install locations for AugmentCode (CLI) and AugmentCodeIDE must differ *)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AugmentCode", $OperatingSystem ] =!=
        Wolfram`AgentTools`Common`installLocation[ "AugmentCodeIDE", $OperatingSystem ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallLocation-AugmentCode-vs-AugmentCodeIDE-Distinct@@Tests/InstallMCPServer.wlt:2517,1-2523,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "AugmentCodeIDE" ],
    "AugmentCodeIDE",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AugmentCodeIDE@@Tests/InstallMCPServer.wlt:2528,1-2533,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "AugmentIDE" ],
    "AugmentCodeIDE",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AugmentIDE@@Tests/InstallMCPServer.wlt:2535,1-2540,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "AuggieIDE" ],
    "AugmentCodeIDE",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AuggieIDE@@Tests/InstallMCPServer.wlt:2542,1-2547,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "AugmentCodeIDE" ],
    "Augment Code IDE",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-AugmentCodeIDE@@Tests/InstallMCPServer.wlt:2549,1-2554,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*AugmentCodeIDE Install and Uninstall*)
VerificationTest[
    augmentIDEConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ augmentIDEConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "AugmentCodeIDE" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AugmentCodeIDE-Basic@@Tests/InstallMCPServer.wlt:2559,1-2565,2"
]

VerificationTest[
    FileExistsQ[ augmentIDEConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AugmentCodeIDE-FileExists@@Tests/InstallMCPServer.wlt:2567,1-2572,2"
]

(* The file root is a JSON array, not an object *)
VerificationTest[
    Module[ { content },
        content = Import[ augmentIDEConfigFile, "RawJSON" ];
        ListQ @ content
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AugmentCodeIDE-RootIsArray@@Tests/InstallMCPServer.wlt:2575,1-2583,2"
]

(* Verify the Wolfram server entry is present with the required array-entry fields *)
VerificationTest[
    Module[ { content, entry },
        content = Import[ augmentIDEConfigFile, "RawJSON" ];
        entry = SelectFirst[ content, MatchQ[ #, KeyValuePattern @ { "name" -> "Wolfram" } ] &, Missing[ ] ];
        AssociationQ @ entry &&
        entry[ "type" ] === "stdio" &&
        entry[ "name" ] === "Wolfram" &&
        StringQ @ entry[ "command" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AugmentCodeIDE-EntryShape@@Tests/InstallMCPServer.wlt:2586,1-2598,2"
]

(* Installing the same server a second time should upsert (not duplicate) *)
VerificationTest[
    InstallMCPServer[ augmentIDEConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "AugmentCodeIDE" ];
    Module[ { content, matches },
        content = Import[ augmentIDEConfigFile, "RawJSON" ];
        matches = Select[ content, MatchQ[ #, KeyValuePattern @ { "name" -> "Wolfram" } ] & ];
        Length @ matches
    ],
    1,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AugmentCodeIDE-Idempotent@@Tests/InstallMCPServer.wlt:2601,1-2611,2"
]

(* A second, differently-named server is appended (not replaced) *)
VerificationTest[
    InstallMCPServer[ augmentIDEConfigFile, "WolframAlpha", "VerifyLLMKit" -> False, "ApplicationName" -> "AugmentCodeIDE", "MCPServerName" -> "WolframAlphaExtra" ];
    Module[ { content, names },
        content = Import[ augmentIDEConfigFile, "RawJSON" ];
        names = Sort @ DeleteDuplicates @ Cases[ content, KeyValuePattern @ { "name" -> n_String } :> n ];
        names
    ],
    { "Wolfram", "WolframAlphaExtra" },
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AugmentCodeIDE-MultiServer@@Tests/InstallMCPServer.wlt:2614,1-2624,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ augmentIDEConfigFile, "WolframLanguage", "ApplicationName" -> "AugmentCodeIDE" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-AugmentCodeIDE-Basic@@Tests/InstallMCPServer.wlt:2626,1-2631,2"
]

VerificationTest[
    Module[ { content, matches },
        content = Import[ augmentIDEConfigFile, "RawJSON" ];
        matches = Select[ content, MatchQ[ #, KeyValuePattern @ { "name" -> "Wolfram" } ] & ];
        Length @ matches
    ],
    0,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-AugmentCodeIDE-VerifyRemoval@@Tests/InstallMCPServer.wlt:2633,1-2642,2"
]

(* Uninstalling the other entry as well leaves an empty array, not a removed file *)
VerificationTest[
    UninstallMCPServer[ augmentIDEConfigFile, "WolframAlpha", "ApplicationName" -> "AugmentCodeIDE", "MCPServerName" -> "WolframAlphaExtra" ];
    Import[ augmentIDEConfigFile, "RawJSON" ],
    { },
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-AugmentCodeIDE-EmptiesToArray@@Tests/InstallMCPServer.wlt:2645,1-2651,2"
]

(* Uninstalling a server that isn't installed returns NotInstalled, not an error *)
VerificationTest[
    UninstallMCPServer[ augmentIDEConfigFile, "WolframLanguage", "ApplicationName" -> "AugmentCodeIDE" ],
    Missing[ "NotInstalled", _ ],
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-AugmentCodeIDE-NotInstalled@@Tests/InstallMCPServer.wlt:2654,1-2659,2"
]

VerificationTest[
    cleanupTestFiles[ augmentIDEConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AugmentCodeIDE-Cleanup@@Tests/InstallMCPServer.wlt:2661,1-2666,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*convertToAugmentCodeIDEFormat*)

(* Basic shape transform: adds "type" -> "stdio", preserves command/args/env *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToAugmentCodeIDEFormat[
        <|
            "command" -> "/usr/local/bin/wolfram",
            "args" -> { "-run", "test" },
            "env" -> <| "KEY" -> "value" |>
        |>,
        "Unix"
    ],
    <|
        "type" -> "stdio",
        "command" -> "/usr/local/bin/wolfram",
        "args" -> { "-run", "test" },
        "env" -> <| "KEY" -> "value" |>
    |>,
    SameTest -> Equal,
    TestID   -> "ConvertToAugmentCodeIDEFormat-Basic@@Tests/InstallMCPServer.wlt:2673,1-2690,2"
]

(* Non-Windows with a space-containing path: does NOT apply short-path coercion *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToAugmentCodeIDEFormat[
        <| "command" -> "/Applications/Wolfram Desktop.app/Contents/MacOS/wolfram" |>,
        "MacOSX"
    ],
    <|
        "type" -> "stdio",
        "command" -> "/Applications/Wolfram Desktop.app/Contents/MacOS/wolfram"
    |>,
    SameTest -> Equal,
    TestID   -> "ConvertToAugmentCodeIDEFormat-NonWindows-WithSpaces@@Tests/InstallMCPServer.wlt:2693,1-2704,2"
]

(* Windows with a space-free command: unchanged *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToAugmentCodeIDEFormat[
        <| "command" -> "C:\\Wolfram\\wolfram.exe", "args" -> { "-run" } |>,
        "Windows"
    ],
    <|
        "type" -> "stdio",
        "command" -> "C:\\Wolfram\\wolfram.exe",
        "args" -> { "-run" }
    |>,
    SameTest -> Equal,
    TestID   -> "ConvertToAugmentCodeIDEFormat-Windows-NoSpaces@@Tests/InstallMCPServer.wlt:2707,1-2719,2"
]

(* Missing command: converter should not error, just omit "command" *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToAugmentCodeIDEFormat[
        <| "args" -> { "-run" } |>,
        "Windows"
    ],
    <|
        "type" -> "stdio",
        "args" -> { "-run" }
    |>,
    SameTest -> Equal,
    TestID   -> "ConvertToAugmentCodeIDEFormat-MissingCommand@@Tests/InstallMCPServer.wlt:2722,1-2733,2"
]

(* Converter does NOT set the "name" field - the install flow prepends it after conversion *)
VerificationTest[
    KeyExistsQ[
        Wolfram`AgentTools`SupportedClients`Private`convertToAugmentCodeIDEFormat[
            <| "command" -> "/tmp/wolfram" |>,
            "Unix"
        ],
        "name"
    ],
    False,
    SameTest -> Equal,
    TestID   -> "ConvertToAugmentCodeIDEFormat-NoNameField@@Tests/InstallMCPServer.wlt:2736,1-2747,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readExistingAugmentCodeIDEConfig*)

(* Non-existent file returns empty list *)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`readExistingAugmentCodeIDEConfig @ File @
        FileNameJoin @ { $TemporaryDirectory, "ide_noexist_" <> CreateUUID[] <> ".json" },
    { },
    SameTest -> Equal,
    TestID   -> "ReadExistingAugmentCodeIDEConfig-NonExistent@@Tests/InstallMCPServer.wlt:2754,1-2760,2"
]

(* Empty file returns empty list *)
VerificationTest[
    Module[ { file },
        file = File @ FileNameJoin @ { $TemporaryDirectory, "ide_empty_" <> CreateUUID[] <> ".json" };
        WithCleanup[
            CreateFile[ First @ file ];
            Wolfram`AgentTools`InstallMCPServer`Private`readExistingAugmentCodeIDEConfig @ file,
            Quiet @ DeleteFile @ First @ file
        ]
    ],
    { },
    SameTest -> Equal,
    TestID   -> "ReadExistingAugmentCodeIDEConfig-EmptyFile@@Tests/InstallMCPServer.wlt:2763,1-2775,2"
]

(* File with a valid array is returned as-is *)
VerificationTest[
    Module[ { file, result },
        file = File @ FileNameJoin @ { $TemporaryDirectory, "ide_array_" <> CreateUUID[] <> ".json" };
        WithCleanup[
            Developer`WriteRawJSONFile[ First @ file, { <| "name" -> "X", "type" -> "stdio" |> } ];
            result = Wolfram`AgentTools`InstallMCPServer`Private`readExistingAugmentCodeIDEConfig @ file,
            Quiet @ DeleteFile @ First @ file
        ];
        result
    ],
    { <| "name" -> "X", "type" -> "stdio" |> },
    SameTest -> Equal,
    TestID   -> "ReadExistingAugmentCodeIDEConfig-ValidArray@@Tests/InstallMCPServer.wlt:2778,1-2791,2"
]

(* File with a non-list top level issues InvalidMCPConfiguration when installing.
   (Calling readExistingAugmentCodeIDEConfig directly returns the data because
   throwFailure only throws inside the catchMine wrapper used by InstallMCPServer.) *)
VerificationTest[
    Module[ { file },
        file = FileNameJoin @ { $TemporaryDirectory, "ide_obj_" <> CreateUUID[] <> ".json" };
        WithCleanup[
            Developer`WriteRawJSONFile[ file, <| "mcpServers" -> <| |> |> ];
            Quiet @ InstallMCPServer[ File @ file, "WolframLanguage",
                "VerifyLLMKit" -> False, "ApplicationName" -> "AugmentCodeIDE" ],
            Quiet @ DeleteFile @ file
        ]
    ],
    _Failure,
    SameTest -> MatchQ,
    TestID   -> "ReadExistingAugmentCodeIDEConfig-NonListRoot@@Tests/InstallMCPServer.wlt:2796,1-2809,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Client Detection from File Path*)

(* File at the VS Code extension's settings location is auto-detected as AugmentCodeIDE
   when installing without an explicit "ApplicationName" - the resulting file is an
   array (AugmentCodeIDE format), not an object (AugmentCode/CLI format). *)
VerificationTest[
    Module[ { dir, file, result },
        dir = FileNameJoin @ { $TemporaryDirectory,
            "guess_" <> CreateUUID[], "augment.vscode-augment", "augment-global-state" };
        CreateDirectory[ dir, CreateIntermediateDirectories -> True ];
        file = FileNameJoin @ { dir, "mcpServers.json" };
        WithCleanup[
            InstallMCPServer[ File @ file, "WolframLanguage", "VerifyLLMKit" -> False ];
            result = Import[ file, "RawJSON" ],
            Quiet @ DeleteDirectory[ dir, DeleteContents -> True ];
            Quiet @ DeleteDirectory[ DirectoryName @ dir ]
        ];
        ListQ @ result &&
        AnyTrue[ result, MatchQ[ #, KeyValuePattern @ { "name" -> _String, "type" -> "stdio" } ] & ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "GuessClientName-AugmentCodeIDE-PathMatch@@Tests/InstallMCPServer.wlt:2818,1-2836,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$SupportedMCPClients metadata for AugmentCodeIDE*)
VerificationTest[
    $SupportedMCPClients[ "AugmentCodeIDE", "DisplayName" ],
    "Augment Code IDE",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeIDEDisplayName@@Tests/InstallMCPServer.wlt:2841,1-2846,2"
]

VerificationTest[
    Sort @ $SupportedMCPClients[ "AugmentCodeIDE", "Aliases" ],
    Sort @ { "AugmentIDE", "AuggieIDE" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeIDEAliases@@Tests/InstallMCPServer.wlt:2848,1-2853,2"
]

VerificationTest[
    $SupportedMCPClients[ "AugmentCodeIDE", "ConfigFormat" ],
    "JSON",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeIDEConfigFormat@@Tests/InstallMCPServer.wlt:2855,1-2860,2"
]

(* Empty ConfigKey signals the root of the file is an array, not a keyed object *)
VerificationTest[
    $SupportedMCPClients[ "AugmentCodeIDE", "ConfigKey" ],
    { },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeIDEConfigKey@@Tests/InstallMCPServer.wlt:2863,1-2868,2"
]

VerificationTest[
    $SupportedMCPClients[ "AugmentCodeIDE", "ProjectSupport" ],
    False,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeIDEProjectSupport@@Tests/InstallMCPServer.wlt:2870,1-2875,2"
]

VerificationTest[
    StringStartsQ[ $SupportedMCPClients[ "AugmentCodeIDE", "URL" ], "https://" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeIDEURL@@Tests/InstallMCPServer.wlt:2877,1-2882,2"
]

(* AugmentCode (CLI) and AugmentCodeIDE (VS Code) must be distinct entries with distinct display names *)
VerificationTest[
    $SupportedMCPClients[ "AugmentCode", "DisplayName" ] =!=
        $SupportedMCPClients[ "AugmentCodeIDE", "DisplayName" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCode-vs-AugmentCodeIDE-Distinct@@Tests/InstallMCPServer.wlt:2885,1-2891,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toWindowsShortPath*)

(* Non-existent path: returns the input unchanged *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`toWindowsShortPath[
        "C:\\__this_path_does_not_exist_" <> CreateUUID[] <> "__\\wolfram.exe"
    ],
    _String? (! StringContainsQ[ #, "~" ] &),
    SameTest -> MatchQ,
    TestID   -> "ToWindowsShortPath-NonExistent@@Tests/InstallMCPServer.wlt:2898,1-2905,2"
]

(* Space-free existing path on Windows: result equals the input (no short form needed).
   On non-Windows, the file probably exists and the function still returns a string. *)
VerificationTest[
    With[ { result = Wolfram`AgentTools`SupportedClients`Private`toWindowsShortPath @ $TemporaryDirectory },
        StringQ @ result
    ],
    True,
    SameTest -> Equal,
    TestID   -> "ToWindowsShortPath-ReturnsString@@Tests/InstallMCPServer.wlt:2909,1-2916,2"
]

(* Windows-only: the wolfram.exe short path should not contain spaces when the
   original is in "Program Files" *)
If[ $OperatingSystem === "Windows",
    VerificationTest[
        Module[ { candidate, shortPath },
            candidate = "C:\\Program Files\\Wolfram Research\\Wolfram\\15.0\\wolfram.exe";
            If[ ! FileExistsQ @ candidate, Return[ True, Module ] ];
            shortPath = Wolfram`AgentTools`SupportedClients`Private`toWindowsShortPath @ candidate;
            StringQ @ shortPath && ! StringContainsQ[ shortPath, " " ]
        ],
        True,
        SameTest -> Equal,
        TestID   -> "ToWindowsShortPath-WolframExe@@Tests/InstallMCPServer.wlt:2921,5-2931,6"
    ]
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$SupportedMCPClients metadata for AugmentCode*)
VerificationTest[
    $SupportedMCPClients[ "AugmentCode", "DisplayName" ],
    "Augment Code",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeDisplayName@@Tests/InstallMCPServer.wlt:2937,1-2942,2"
]

VerificationTest[
    Sort @ $SupportedMCPClients[ "AugmentCode", "Aliases" ],
    Sort @ { "Auggie", "Augment" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeAliases@@Tests/InstallMCPServer.wlt:2944,1-2949,2"
]

VerificationTest[
    $SupportedMCPClients[ "AugmentCode", "ConfigFormat" ],
    "JSON",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeConfigFormat@@Tests/InstallMCPServer.wlt:2951,1-2956,2"
]

VerificationTest[
    $SupportedMCPClients[ "AugmentCode", "ConfigKey" ],
    { "mcpServers" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeConfigKey@@Tests/InstallMCPServer.wlt:2958,1-2963,2"
]

VerificationTest[
    $SupportedMCPClients[ "AugmentCode", "ProjectSupport" ],
    False,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeProjectSupport@@Tests/InstallMCPServer.wlt:2965,1-2970,2"
]

VerificationTest[
    StringStartsQ[ $SupportedMCPClients[ "AugmentCode", "URL" ], "https://" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeURL@@Tests/InstallMCPServer.wlt:2972,1-2977,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Zed Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for Zed*)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Zed", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Zed-Windows@@Tests/InstallMCPServer.wlt:2986,1-2991,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Zed", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Zed-MacOSX@@Tests/InstallMCPServer.wlt:2993,1-2998,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Zed", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Zed-Unix@@Tests/InstallMCPServer.wlt:3000,1-3005,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Zed" ],
    "Zed",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Zed@@Tests/InstallMCPServer.wlt:3010,1-3015,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Zed" ],
    "Zed",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Zed@@Tests/InstallMCPServer.wlt:3017,1-3022,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Project Install Location*)
VerificationTest[
    Module[ { path, result },
        path = FileNameJoin @ { $TemporaryDirectory, "TestProject" };
        result = Wolfram`AgentTools`Common`projectInstallLocation[ "Zed", path ];
        FileNameTake[ First @ result, -2 ]
    ],
    FileNameJoin @ { ".zed", "settings.json" },
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-Zed@@Tests/InstallMCPServer.wlt:3027,1-3036,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Zed Install and Uninstall*)
VerificationTest[
    zedConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ zedConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "Zed" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Zed-Basic@@Tests/InstallMCPServer.wlt:3041,1-3047,2"
]

VerificationTest[
    FileExistsQ[ zedConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Zed-FileExists@@Tests/InstallMCPServer.wlt:3049,1-3054,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ zedConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "context_servers" ] && KeyExistsQ[ content[ "context_servers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Zed-VerifyContent@@Tests/InstallMCPServer.wlt:3056,1-3064,2"
]

VerificationTest[
    Module[ { content, server },
        content = Import[ zedConfigFile, "RawJSON" ];
        server = content[ "context_servers", "Wolfram" ];
        KeyExistsQ[ server, "command" ] && KeyExistsQ[ server, "args" ] && KeyExistsQ[ server, "env" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Zed-VerifyServerFields@@Tests/InstallMCPServer.wlt:3066,1-3075,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ zedConfigFile, "WolframLanguage", "ApplicationName" -> "Zed" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Zed-Basic@@Tests/InstallMCPServer.wlt:3077,1-3082,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ zedConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "context_servers" ] && ! KeyExistsQ[ content[ "context_servers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Zed-VerifyRemoval@@Tests/InstallMCPServer.wlt:3084,1-3092,2"
]

VerificationTest[
    cleanupTestFiles[ zedConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Zed-Cleanup@@Tests/InstallMCPServer.wlt:3094,1-3099,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Zed Preserves Existing Config*)
VerificationTest[
    zedConfigFile = testConfigFile[];
    Export[ zedConfigFile, <| "theme" -> "One Dark", "context_servers" -> <| |> |>, "JSON" ];
    installResult = InstallMCPServer[ zedConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "Zed" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Zed-PreserveExisting@@Tests/InstallMCPServer.wlt:3104,1-3111,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ zedConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "theme" ] && content[ "theme" ] === "One Dark" &&
        KeyExistsQ[ content[ "context_servers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Zed-VerifyPreserved@@Tests/InstallMCPServer.wlt:3113,1-3122,2"
]

VerificationTest[
    cleanupTestFiles[ zedConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Zed-PreserveExisting-Cleanup@@Tests/InstallMCPServer.wlt:3124,1-3129,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Junie Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for Junie*)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Junie", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Junie-Windows@@Tests/InstallMCPServer.wlt:3138,1-3143,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Junie", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Junie-MacOSX@@Tests/InstallMCPServer.wlt:3145,1-3150,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Junie", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Junie-Unix@@Tests/InstallMCPServer.wlt:3152,1-3157,2"
]

(* Junie's user-scope path is .junie/mcp/mcp.json under $HomeDirectory on every OS *)
VerificationTest[
    Module[ { file, split },
        file = Wolfram`AgentTools`Common`installLocation[ "Junie", $OperatingSystem ];
        split = FileNameSplit @ First @ file;
        Take[ split, -3 ]
    ],
    { ".junie", "mcp", "mcp.json" },
    SameTest -> Equal,
    TestID   -> "InstallLocation-Junie-PathShape@@Tests/InstallMCPServer.wlt:3160,1-3169,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Junie" ],
    "Junie",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Junie@@Tests/InstallMCPServer.wlt:3174,1-3179,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "JetBrainsJunie" ],
    "Junie",
    SameTest -> Equal,
    TestID   -> "ToInstallName-JetBrainsJunie@@Tests/InstallMCPServer.wlt:3181,1-3186,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Junie" ],
    "Junie",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Junie@@Tests/InstallMCPServer.wlt:3188,1-3193,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Junie Install and Uninstall*)
VerificationTest[
    junieConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ junieConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "Junie" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Junie-Basic@@Tests/InstallMCPServer.wlt:3198,1-3204,2"
]

VerificationTest[
    FileExistsQ[ junieConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Junie-FileExists@@Tests/InstallMCPServer.wlt:3206,1-3211,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ junieConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Junie-VerifyContent@@Tests/InstallMCPServer.wlt:3213,1-3221,2"
]

(* Junie uses the standard mcpServers format: no Cline-style disabled/autoApprove fields,
   no Copilot-style tools field, no OpenCode-style top-level "mcp" key *)
VerificationTest[
    Module[ { content, server },
        content = Import[ junieConfigFile, "RawJSON" ];
        server = content[ "mcpServers", "Wolfram" ];
        AssociationQ @ server &&
        KeyExistsQ[ server, "command" ] &&
        ! KeyExistsQ[ server, "disabled" ] &&
        ! KeyExistsQ[ server, "autoApprove" ] &&
        ! KeyExistsQ[ server, "tools" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Junie-StandardFormat@@Tests/InstallMCPServer.wlt:3225,1-3238,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ junieConfigFile, "WolframLanguage", "ApplicationName" -> "Junie" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Junie-Basic@@Tests/InstallMCPServer.wlt:3240,1-3245,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ junieConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && ! KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Junie-VerifyRemoval@@Tests/InstallMCPServer.wlt:3247,1-3255,2"
]

VerificationTest[
    cleanupTestFiles[ junieConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Junie-Cleanup@@Tests/InstallMCPServer.wlt:3257,1-3262,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Junie Project-Level Install*)
VerificationTest[
    Module[ { dir, projectFile, result },
        dir = FileNameJoin @ { $TemporaryDirectory, "junie_proj_" <> CreateUUID[] };
        CreateDirectory @ dir;
        WithCleanup[
            result = InstallMCPServer[ { "Junie", dir }, "WolframLanguage", "VerifyLLMKit" -> False ];
            projectFile = FileNameJoin @ { dir, ".junie", "mcp", "mcp.json" };
            { MatchQ[ result, _Success ], FileExistsQ @ projectFile },
            Quiet @ DeleteDirectory[ dir, DeleteContents -> True ]
        ]
    ],
    { True, True },
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Junie-ProjectLevel@@Tests/InstallMCPServer.wlt:3267,1-3281,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Auto-Detection from Path*)

(* File at .junie/mcp/mcp.json under any directory should be detected as Junie when
   installing without an explicit ApplicationName. *)
VerificationTest[
    Module[ { dir, file, result },
        dir = FileNameJoin @ { $TemporaryDirectory, "junie_guess_" <> CreateUUID[], ".junie", "mcp" };
        CreateDirectory[ dir, CreateIntermediateDirectories -> True ];
        file = FileNameJoin @ { dir, "mcp.json" };
        WithCleanup[
            InstallMCPServer[ File @ file, "WolframLanguage", "VerifyLLMKit" -> False ];
            result = Import[ file, "RawJSON" ],
            Quiet @ DeleteDirectory[ dir, DeleteContents -> True ];
            Quiet @ DeleteDirectory[ DirectoryName[ dir, 2 ], DeleteContents -> True ]
        ];
        AssociationQ @ result && KeyExistsQ[ result, "mcpServers" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "GuessClientName-Junie-PathMatch@@Tests/InstallMCPServer.wlt:3289,1-3305,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$SupportedMCPClients metadata for Junie*)
VerificationTest[
    $SupportedMCPClients[ "Junie", "DisplayName" ],
    "Junie",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-JunieDisplayName@@Tests/InstallMCPServer.wlt:3310,1-3315,2"
]

VerificationTest[
    $SupportedMCPClients[ "Junie", "Aliases" ],
    { "JetBrainsJunie" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-JunieAliases@@Tests/InstallMCPServer.wlt:3317,1-3322,2"
]

VerificationTest[
    $SupportedMCPClients[ "Junie", "ConfigFormat" ],
    "JSON",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-JunieConfigFormat@@Tests/InstallMCPServer.wlt:3324,1-3329,2"
]

VerificationTest[
    $SupportedMCPClients[ "Junie", "ConfigKey" ],
    { "mcpServers" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-JunieConfigKey@@Tests/InstallMCPServer.wlt:3331,1-3336,2"
]

VerificationTest[
    $SupportedMCPClients[ "Junie", "ProjectSupport" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-JunieProjectSupport@@Tests/InstallMCPServer.wlt:3338,1-3343,2"
]

VerificationTest[
    StringStartsQ[ $SupportedMCPClients[ "Junie", "URL" ], "https://" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-JunieURL@@Tests/InstallMCPServer.wlt:3345,1-3350,2"
]

(* Junie is a coding agent - default toolset is WolframLanguage (matches Cursor, ClaudeCode, etc.) *)
VerificationTest[
    $SupportedMCPClients[ "Junie", "DefaultToolset" ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-JunieDefaultToolset@@Tests/InstallMCPServer.wlt:3353,1-3358,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Kimi Code Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Auto-Detection from Path*)

(* A path ending in .kimi/mcp.json maps to KimiCode (the file does not need to exist) *)
VerificationTest[
    Wolfram`AgentTools`Common`guessClientName[
        File @ FileNameJoin @ { $TemporaryDirectory, "kimi_guess_" <> CreateUUID[ ], ".kimi", "mcp.json" }
    ],
    "KimiCode",
    SameTest -> Equal,
    TestID   -> "GuessClientName-KimiCode-Direct@@Tests/InstallMCPServer.wlt:3369,1-3376,2"
]

(* File at .kimi/mcp.json under any directory should be detected as Kimi Code when
   installing without an explicit ApplicationName. *)
VerificationTest[
    Module[ { dir, file, result },
        dir = FileNameJoin @ { $TemporaryDirectory, "kimi_guess_" <> CreateUUID[ ], ".kimi" };
        CreateDirectory[ dir, CreateIntermediateDirectories -> True ];
        file = FileNameJoin @ { dir, "mcp.json" };
        WithCleanup[
            InstallMCPServer[ File @ file, "WolframLanguage", "VerifyLLMKit" -> False ];
            result = Import[ file, "RawJSON" ],
            Quiet @ DeleteDirectory[ DirectoryName @ dir, DeleteContents -> True ]
        ];
        AssociationQ @ result && KeyExistsQ[ result, "mcpServers" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "GuessClientName-KimiCode-PathMatch@@Tests/InstallMCPServer.wlt:3380,1-3395,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Kiro Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for Kiro*)

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Kiro", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Kiro-Windows@@Tests/InstallMCPServer.wlt:3405,1-3410,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Kiro", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Kiro-MacOSX@@Tests/InstallMCPServer.wlt:3412,1-3417,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Kiro", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Kiro-Unix@@Tests/InstallMCPServer.wlt:3419,1-3424,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Kiro" ],
    "Kiro",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Kiro@@Tests/InstallMCPServer.wlt:3426,1-3431,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Kiro" ],
    "Kiro",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Kiro@@Tests/InstallMCPServer.wlt:3433,1-3438,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Project Install Location*)
VerificationTest[
    Module[ { path, result },
        path = FileNameJoin @ { $TemporaryDirectory, "TestProject" };
        result = Wolfram`AgentTools`Common`projectInstallLocation[ "Kiro", path ];
        FileNameTake[ First @ result, -3 ]
    ],
    FileNameJoin @ { ".kiro", "settings", "mcp.json" },
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-Kiro@@Tests/InstallMCPServer.wlt:3443,1-3452,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Kiro Install and Uninstall*)
VerificationTest[
    kiroConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ kiroConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "Kiro" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Kiro-Basic@@Tests/InstallMCPServer.wlt:3457,1-3463,2"
]

VerificationTest[
    FileExistsQ[ kiroConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Kiro-FileExists@@Tests/InstallMCPServer.wlt:3465,1-3470,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ kiroConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Kiro-VerifyContent@@Tests/InstallMCPServer.wlt:3472,1-3480,2"
]

VerificationTest[
    Module[ { content, server },
        content = Import[ kiroConfigFile, "RawJSON" ];
        server = content[ "mcpServers", "Wolfram" ];
        KeyExistsQ[ server, "disabled" ] && server[ "disabled" ] === False &&
        KeyExistsQ[ server, "autoApprove" ] && server[ "autoApprove" ] === { }
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Kiro-VerifyKiroFields@@Tests/InstallMCPServer.wlt:3482,1-3492,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ kiroConfigFile, "WolframLanguage", "ApplicationName" -> "Kiro" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Kiro-Basic@@Tests/InstallMCPServer.wlt:3494,1-3499,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ kiroConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && ! KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Kiro-VerifyRemoval@@Tests/InstallMCPServer.wlt:3501,1-3509,2"
]

VerificationTest[
    cleanupTestFiles[ kiroConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Kiro-Cleanup@@Tests/InstallMCPServer.wlt:3511,1-3516,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Kiro Preserves Existing Config*)
VerificationTest[
    kiroConfigFile = testConfigFile[];
    Export[ kiroConfigFile, <| "customSetting" -> True, "mcpServers" -> <| |> |>, "JSON" ];
    installResult = InstallMCPServer[ kiroConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "Kiro" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Kiro-PreserveExisting@@Tests/InstallMCPServer.wlt:3521,1-3528,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ kiroConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "customSetting" ] && content[ "customSetting" ] === True &&
        KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Kiro-VerifyPreserved@@Tests/InstallMCPServer.wlt:3530,1-3539,2"
]

VerificationTest[
    cleanupTestFiles[ kiroConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Kiro-PreserveExisting-Cleanup@@Tests/InstallMCPServer.wlt:3541,1-3546,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*LM Studio Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for LM Studio*)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "LMStudio", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-LMStudio-Windows@@Tests/InstallMCPServer.wlt:3555,1-3560,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "LMStudio", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-LMStudio-MacOSX@@Tests/InstallMCPServer.wlt:3562,1-3567,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "LMStudio", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-LMStudio-Unix@@Tests/InstallMCPServer.wlt:3569,1-3574,2"
]

(* LM Studio's path is .lmstudio/mcp.json under $HomeDirectory on every OS *)
VerificationTest[
    Module[ { file, split },
        file = Wolfram`AgentTools`Common`installLocation[ "LMStudio", $OperatingSystem ];
        split = FileNameSplit @ First @ file;
        Take[ split, -2 ]
    ],
    { ".lmstudio", "mcp.json" },
    SameTest -> Equal,
    TestID   -> "InstallLocation-LMStudio-PathShape@@Tests/InstallMCPServer.wlt:3577,1-3586,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "LMStudio" ],
    "LMStudio",
    SameTest -> Equal,
    TestID   -> "ToInstallName-LMStudio@@Tests/InstallMCPServer.wlt:3591,1-3596,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "LMStudio" ],
    "LM Studio",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-LMStudio@@Tests/InstallMCPServer.wlt:3598,1-3603,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*LM Studio Install and Uninstall*)
VerificationTest[
    lmStudioConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ lmStudioConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "LMStudio" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-LMStudio-Basic@@Tests/InstallMCPServer.wlt:3608,1-3614,2"
]

VerificationTest[
    FileExistsQ[ lmStudioConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-LMStudio-FileExists@@Tests/InstallMCPServer.wlt:3616,1-3621,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ lmStudioConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-LMStudio-VerifyContent@@Tests/InstallMCPServer.wlt:3623,1-3631,2"
]

(* LM Studio uses the standard mcpServers format (Cursor notation): no Cline-style
   disabled/autoApprove fields, no Copilot-style tools field, no OpenCode-style top-level "mcp" key *)
VerificationTest[
    Module[ { content, server },
        content = Import[ lmStudioConfigFile, "RawJSON" ];
        server = content[ "mcpServers", "Wolfram" ];
        AssociationQ @ server &&
        KeyExistsQ[ server, "command" ] &&
        ! KeyExistsQ[ server, "disabled" ] &&
        ! KeyExistsQ[ server, "autoApprove" ] &&
        ! KeyExistsQ[ server, "tools" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-LMStudio-StandardFormat@@Tests/InstallMCPServer.wlt:3635,1-3648,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ lmStudioConfigFile, "WolframLanguage", "ApplicationName" -> "LMStudio" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-LMStudio-Basic@@Tests/InstallMCPServer.wlt:3650,1-3655,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ lmStudioConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && ! KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-LMStudio-VerifyRemoval@@Tests/InstallMCPServer.wlt:3657,1-3665,2"
]

VerificationTest[
    cleanupTestFiles[ lmStudioConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-LMStudio-Cleanup@@Tests/InstallMCPServer.wlt:3667,1-3672,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*LM Studio Preserves Existing Config*)

(* The mcp.json may contain other servers and unrelated keys; install must preserve them *)
VerificationTest[
    lmStudioPreserveFile = testConfigFile[];
    Export[ lmStudioPreserveFile, <| "mcpServers" -> <| "ExistingServer" -> <| "command" -> "foo" |> |> |>, "JSON" ];
    InstallMCPServer[ lmStudioPreserveFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "LMStudio" ];
    Module[ { content },
        content = Import[ lmStudioPreserveFile, "RawJSON" ];
        KeyExistsQ[ content[ "mcpServers" ], "ExistingServer" ] &&
        KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-LMStudio-PreserveExisting@@Tests/InstallMCPServer.wlt:3679,1-3691,2"
]

VerificationTest[
    cleanupTestFiles[ lmStudioPreserveFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-LMStudio-PreserveExisting-Cleanup@@Tests/InstallMCPServer.wlt:3693,1-3698,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Auto-Detection from Path*)

(* File at .lmstudio/mcp.json is auto-detected as LMStudio when installing without ApplicationName *)
VerificationTest[
    Module[ { dir, file, content },
        dir = FileNameJoin @ { $TemporaryDirectory, "lmstudio_auto_" <> CreateUUID[], ".lmstudio" };
        CreateDirectory[ dir, CreateIntermediateDirectories -> True ];
        file = FileNameJoin @ { dir, "mcp.json" };
        WithCleanup[
            InstallMCPServer[ File @ file, "WolframLanguage", "VerifyLLMKit" -> False ];
            content = Import[ file, "RawJSON" ],
            Quiet @ DeleteDirectory[ DirectoryName @ dir, DeleteContents -> True ]
        ];
        AssociationQ @ content && KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "GuessClientName-LMStudio-PathMatch@@Tests/InstallMCPServer.wlt:3705,1-3720,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$SupportedMCPClients metadata for LM Studio*)
VerificationTest[
    $SupportedMCPClients[ "LMStudio", "DisplayName" ],
    "LM Studio",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-LMStudioDisplayName@@Tests/InstallMCPServer.wlt:3725,1-3730,2"
]

VerificationTest[
    $SupportedMCPClients[ "LMStudio", "ConfigFormat" ],
    "JSON",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-LMStudioConfigFormat@@Tests/InstallMCPServer.wlt:3732,1-3737,2"
]

VerificationTest[
    $SupportedMCPClients[ "LMStudio", "ConfigKey" ],
    { "mcpServers" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-LMStudioConfigKey@@Tests/InstallMCPServer.wlt:3739,1-3744,2"
]

VerificationTest[
    $SupportedMCPClients[ "LMStudio", "ProjectSupport" ],
    False,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-LMStudioProjectSupport@@Tests/InstallMCPServer.wlt:3746,1-3751,2"
]

(* LM Studio is a chat-first client, so its default toolset is "Wolfram" (like Claude Desktop / Goose) *)
VerificationTest[
    $SupportedMCPClients[ "LMStudio", "DefaultToolset" ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-LMStudioDefaultToolset@@Tests/InstallMCPServer.wlt:3754,1-3759,2"
]

VerificationTest[
    StringStartsQ[ $SupportedMCPClients[ "LMStudio", "URL" ], "https://" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-LMStudioURL@@Tests/InstallMCPServer.wlt:3761,1-3766,2"
]

(* Confirm the chat-client default flows through defaultToolsetForTarget *)
VerificationTest[
    Wolfram`AgentTools`Common`defaultToolsetForTarget[ "LMStudio" ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-LMStudio@@Tests/InstallMCPServer.wlt:3769,1-3774,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Amazon Q Developer Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for Amazon Q Developer*)

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AmazonQ", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AmazonQ-Windows@@Tests/InstallMCPServer.wlt:3784,1-3789,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AmazonQ", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AmazonQ-MacOSX@@Tests/InstallMCPServer.wlt:3791,1-3796,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AmazonQ", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AmazonQ-Unix@@Tests/InstallMCPServer.wlt:3798,1-3803,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "AmazonQ" ],
    "Amazon Q Developer",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-AmazonQ@@Tests/InstallMCPServer.wlt:3805,1-3810,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "AmazonQ" ],
    "AmazonQ",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AmazonQ@@Tests/InstallMCPServer.wlt:3812,1-3817,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "AmazonQDeveloper" ],
    "AmazonQ",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AmazonQ-Alias-AmazonQDeveloper@@Tests/InstallMCPServer.wlt:3819,1-3824,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Q" ],
    "AmazonQ",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AmazonQ-Alias-Q@@Tests/InstallMCPServer.wlt:3826,1-3831,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "QDeveloper" ],
    "AmazonQ",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AmazonQ-Alias-QDeveloper@@Tests/InstallMCPServer.wlt:3833,1-3838,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Project Install Location*)
VerificationTest[
    Module[ { path, result },
        path = FileNameJoin @ { $TemporaryDirectory, "TestProject" };
        result = Wolfram`AgentTools`Common`projectInstallLocation[ "AmazonQ", path ];
        FileNameTake[ First @ result, -2 ]
    ],
    FileNameJoin @ { ".amazonq", "mcp.json" },
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-AmazonQ@@Tests/InstallMCPServer.wlt:3843,1-3852,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Amazon Q Install and Uninstall*)
VerificationTest[
    amazonQConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ amazonQConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "AmazonQ" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AmazonQ-Basic@@Tests/InstallMCPServer.wlt:3857,1-3863,2"
]

VerificationTest[
    FileExistsQ[ amazonQConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AmazonQ-FileExists@@Tests/InstallMCPServer.wlt:3865,1-3870,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ amazonQConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AmazonQ-VerifyContent@@Tests/InstallMCPServer.wlt:3872,1-3880,2"
]

VerificationTest[
    Module[ { content, server },
        content = Import[ amazonQConfigFile, "RawJSON" ];
        server = content[ "mcpServers", "Wolfram" ];
        KeyExistsQ[ server, "command" ] &&
        ! KeyExistsQ[ server, "disabled" ] &&
        ! KeyExistsQ[ server, "autoApprove" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AmazonQ-VerifyFields@@Tests/InstallMCPServer.wlt:3882,1-3893,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ amazonQConfigFile, "WolframLanguage", "ApplicationName" -> "AmazonQ" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-AmazonQ-Basic@@Tests/InstallMCPServer.wlt:3895,1-3900,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ amazonQConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && ! KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-AmazonQ-VerifyRemoval@@Tests/InstallMCPServer.wlt:3902,1-3910,2"
]

VerificationTest[
    cleanupTestFiles[ amazonQConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AmazonQ-Cleanup@@Tests/InstallMCPServer.wlt:3912,1-3917,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Amazon Q Preserves Existing Config*)
VerificationTest[
    amazonQConfigFile = testConfigFile[];
    Export[ amazonQConfigFile, <| "customSetting" -> True, "mcpServers" -> <| |> |>, "JSON" ];
    installResult = InstallMCPServer[ amazonQConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "AmazonQ" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AmazonQ-PreserveExisting@@Tests/InstallMCPServer.wlt:3922,1-3929,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ amazonQConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "customSetting" ] && content[ "customSetting" ] === True &&
        KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AmazonQ-VerifyPreserved@@Tests/InstallMCPServer.wlt:3931,1-3940,2"
]

VerificationTest[
    cleanupTestFiles[ amazonQConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AmazonQ-PreserveExisting-Cleanup@@Tests/InstallMCPServer.wlt:3942,1-3947,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Amazon Q Path Auto-Detection*)
VerificationTest[
    Module[ { dir, file, result },
        dir = CreateDirectory @ FileNameJoin @ { $TemporaryDirectory, CreateUUID[ "amzq-" ], ".amazonq" };
        file = File @ FileNameJoin @ { dir, "mcp.json" };
        result = InstallMCPServer[ file, "WolframLanguage", "VerifyLLMKit" -> False ];
        cleanupTestFiles[ file ];
        result
    ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AmazonQ-AutoDetect-Project@@Tests/InstallMCPServer.wlt:3952,1-3963,2"
]

VerificationTest[
    Module[ { dir, file, result },
        dir = CreateDirectory @ FileNameJoin @ { $TemporaryDirectory, CreateUUID[ "amzq-" ], ".aws", "amazonq" };
        file = File @ FileNameJoin @ { dir, "mcp.json" };
        result = InstallMCPServer[ file, "WolframLanguage", "VerifyLLMKit" -> False ];
        cleanupTestFiles[ file ];
        result
    ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AmazonQ-AutoDetect-Global@@Tests/InstallMCPServer.wlt:3965,1-3976,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*$SupportedMCPClients*)
VerificationTest[
    $SupportedMCPClients,
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "SupportedMCPClients-ReturnsAssociation@@Tests/InstallMCPServer.wlt:3981,1-3986,2"
]

VerificationTest[
    Length @ $SupportedMCPClients,
    22,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-Has22Clients@@Tests/InstallMCPServer.wlt:3988,1-3993,2"
]

VerificationTest[
    Keys @ $SupportedMCPClients,
    { "AmazonQ", "Antigravity", "AugmentCode", "AugmentCodeIDE", "ClaudeCode", "ClaudeDesktop", "Cline", "Codex", "Continue", "CopilotCLI", "Cursor", "GeminiCLI", "Goose", "Junie", "KimiCode", "Kiro", "LMStudio", "OpenCode", "QwenCode", "VisualStudioCode", "Windsurf", "Zed" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-KeysSorted@@Tests/InstallMCPServer.wlt:3995,1-4000,2"
]

VerificationTest[
    AllTrue[
        Values @ $SupportedMCPClients,
        Function[ meta,
            KeyExistsQ[ meta, "Name" ] &&
            KeyExistsQ[ meta, "DisplayName" ] &&
            KeyExistsQ[ meta, "Aliases" ] &&
            KeyExistsQ[ meta, "ConfigFormat" ] &&
            KeyExistsQ[ meta, "ProjectSupport" ] &&
            KeyExistsQ[ meta, "ConfigKey" ] &&
            MatchQ[ meta[ "ConfigKey" ], { ___String } ] &&
            KeyExistsQ[ meta, "URL" ]
        ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AllHaveRequiredKeys@@Tests/InstallMCPServer.wlt:4002,1-4019,2"
]

VerificationTest[
    $SupportedMCPClients[ "ClaudeDesktop", "DisplayName" ],
    "Claude Desktop",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ClaudeDesktopDisplayName@@Tests/InstallMCPServer.wlt:4021,1-4026,2"
]

VerificationTest[
    $SupportedMCPClients[ "ClaudeDesktop", "Aliases" ],
    { "Claude" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ClaudeDesktopAliases@@Tests/InstallMCPServer.wlt:4028,1-4033,2"
]

VerificationTest[
    $SupportedMCPClients[ "Codex", "ConfigFormat" ],
    "TOML",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-CodexConfigFormat@@Tests/InstallMCPServer.wlt:4035,1-4040,2"
]

VerificationTest[
    $SupportedMCPClients[ "Codex", "ProjectSupport" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-CodexProjectSupport@@Tests/InstallMCPServer.wlt:4042,1-4047,2"
]

VerificationTest[
    $SupportedMCPClients[ "ClaudeCode", "ProjectSupport" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ClaudeCodeProjectSupport@@Tests/InstallMCPServer.wlt:4049,1-4054,2"
]

VerificationTest[
    $SupportedMCPClients[ "Zed", "ConfigKey" ],
    { "context_servers" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ZedConfigKey@@Tests/InstallMCPServer.wlt:4056,1-4061,2"
]

VerificationTest[
    $SupportedMCPClients[ "VisualStudioCode", "ConfigKey" ],
    { "servers" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-VSCodeConfigKey@@Tests/InstallMCPServer.wlt:4063,1-4068,2"
]

VerificationTest[
    $SupportedMCPClients[ "OpenCode", "ConfigKey" ],
    { "mcp" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-OpenCodeConfigKey@@Tests/InstallMCPServer.wlt:4070,1-4075,2"
]

VerificationTest[
    AllTrue[ Values @ $SupportedMCPClients, StringQ[ #[ "URL" ] ] && StringStartsQ[ #[ "URL" ], "https://" ] & ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AllHaveValidURLs@@Tests/InstallMCPServer.wlt:4077,1-4082,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Helper Function Unit Tests*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*guessClientNameFromJSON*)

(* Helper to create a temp JSON file with given content *)
makeTestJSONFile[ data_Association ] := Module[ { file },
    file = FileNameJoin @ { $TemporaryDirectory, StringJoin[ "guess_test_", CreateUUID[], ".json" ] };
    Developer`WriteRawJSONFile[ file, data ];
    file
];

(* Variant that uses a specific filename (in a unique temp subdirectory to avoid collisions) *)
makeTestJSONFile[ data_Association, name_String ] := Module[ { dir, file },
    dir = FileNameJoin @ { $TemporaryDirectory, "guess_test_" <> CreateUUID[] };
    CreateDirectory @ dir;
    file = FileNameJoin @ { dir, name };
    Developer`WriteRawJSONFile[ file, data ];
    file
];

(* Zed: has "context_servers" top-level key *)
VerificationTest[
    Module[ { file, result },
        file = makeTestJSONFile @ <| "context_servers" -> <| "MyServer" -> <| "command" -> "wolframscript" |> |> |>;
        result = Wolfram`AgentTools`InstallMCPServer`Private`guessClientNameFromJSON @ file;
        DeleteFile @ file;
        result
    ],
    "Zed",
    SameTest -> Equal,
    TestID   -> "GuessClientNameFromJSON-Zed@@Tests/InstallMCPServer.wlt:4109,1-4119,2"
]

(* VSCode legacy: has "mcp" with nested "servers" (settings.json format) *)
VerificationTest[
    Module[ { file, result },
        file = makeTestJSONFile @ <| "mcp" -> <| "servers" -> <| "MyServer" -> <| "command" -> "wolframscript" |> |> |> |>;
        result = Wolfram`AgentTools`InstallMCPServer`Private`guessClientNameFromJSON @ file;
        DeleteFile @ file;
        result
    ],
    "VisualStudioCode",
    SameTest -> Equal,
    TestID   -> "GuessClientNameFromJSON-VisualStudioCode-Legacy@@Tests/InstallMCPServer.wlt:4122,1-4132,2"
]

(* VSCode: has "servers" at root level (mcp.json format) *)
VerificationTest[
    Module[ { file, result },
        file = makeTestJSONFile[ <| "servers" -> <| "MyServer" -> <| "command" -> "wolframscript" |> |> |>, "mcp.json" ];
        result = Wolfram`AgentTools`InstallMCPServer`Private`guessClientNameFromJSON @ file;
        Quiet @ DeleteFile @ file;
        Quiet @ DeleteDirectory[ DirectoryName @ file ];
        result
    ],
    "VisualStudioCode",
    SameTest -> Equal,
    TestID   -> "GuessClientNameFromJSON-VisualStudioCode@@Tests/InstallMCPServer.wlt:4135,1-4146,2"
]

(* Generic "servers" key in non-mcp.json file -> None (avoid false positives) *)
VerificationTest[
    Module[ { file, result },
        file = makeTestJSONFile @ <| "servers" -> <| "MyServer" -> <| "command" -> "wolframscript" |> |> |>;
        result = Wolfram`AgentTools`InstallMCPServer`Private`guessClientNameFromJSON @ file;
        DeleteFile @ file;
        result
    ],
    None,
    SameTest -> Equal,
    TestID   -> "GuessClientNameFromJSON-GenericServersKey@@Tests/InstallMCPServer.wlt:4149,1-4159,2"
]

(* OpenCode: has "mcp" with entries that have "type" and List-valued "command" *)
VerificationTest[
    Module[ { file, result },
        file = makeTestJSONFile @ <| "mcp" -> <| "MyServer" -> <| "type" -> "local", "command" -> { "wolframscript" }, "enabled" -> True |> |> |>;
        result = Wolfram`AgentTools`InstallMCPServer`Private`guessClientNameFromJSON @ file;
        DeleteFile @ file;
        result
    ],
    "OpenCode",
    SameTest -> Equal,
    TestID   -> "GuessClientNameFromJSON-OpenCode@@Tests/InstallMCPServer.wlt:4162,1-4172,2"
]

(* CopilotCLI: has "mcpServers" with entries that have "tools" *)
VerificationTest[
    Module[ { file, result },
        file = makeTestJSONFile @ <| "mcpServers" -> <| "MyServer" -> <| "command" -> "wolframscript", "args" -> { }, "tools" -> { "*" } |> |> |>;
        result = Wolfram`AgentTools`InstallMCPServer`Private`guessClientNameFromJSON @ file;
        DeleteFile @ file;
        result
    ],
    "CopilotCLI",
    SameTest -> Equal,
    TestID   -> "GuessClientNameFromJSON-CopilotCLI@@Tests/InstallMCPServer.wlt:4175,1-4185,2"
]

(* Cline: has "mcpServers" with entries that have "disabled" and "autoApprove" *)
VerificationTest[
    Module[ { file, result },
        file = makeTestJSONFile @ <| "mcpServers" -> <| "MyServer" -> <| "command" -> "wolframscript", "disabled" -> False, "autoApprove" -> { } |> |> |>;
        result = Wolfram`AgentTools`InstallMCPServer`Private`guessClientNameFromJSON @ file;
        DeleteFile @ file;
        result
    ],
    "Cline",
    SameTest -> Equal,
    TestID   -> "GuessClientNameFromJSON-Cline@@Tests/InstallMCPServer.wlt:4188,1-4198,2"
]

(* Ambiguous: standard mcpServers with only command/args/env -> None *)
VerificationTest[
    Module[ { file, result },
        file = makeTestJSONFile @ <| "mcpServers" -> <| "MyServer" -> <| "command" -> "wolframscript", "args" -> { "-run" }, "env" -> <| |> |> |> |>;
        result = Wolfram`AgentTools`InstallMCPServer`Private`guessClientNameFromJSON @ file;
        DeleteFile @ file;
        result
    ],
    None,
    SameTest -> Equal,
    TestID   -> "GuessClientNameFromJSON-Ambiguous@@Tests/InstallMCPServer.wlt:4201,1-4211,2"
]

(* Empty JSON -> None *)
VerificationTest[
    Module[ { file, result },
        file = makeTestJSONFile @ <| |>;
        result = Wolfram`AgentTools`InstallMCPServer`Private`guessClientNameFromJSON @ file;
        DeleteFile @ file;
        result
    ],
    None,
    SameTest -> Equal,
    TestID   -> "GuessClientNameFromJSON-EmptyJSON@@Tests/InstallMCPServer.wlt:4214,1-4224,2"
]

(* Non-existent file -> None *)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`guessClientNameFromJSON @
        FileNameJoin @ { $TemporaryDirectory, "nonexistent_" <> CreateUUID[] <> ".json" },
    None,
    SameTest -> Equal,
    TestID   -> "GuessClientNameFromJSON-NonExistentFile@@Tests/InstallMCPServer.wlt:4227,1-4233,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*configKeyPath*)
VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = "ClaudeDesktop" },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ ]
    ],
    { "mcpServers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-ClaudeDesktop@@Tests/InstallMCPServer.wlt:4238,1-4245,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = "VisualStudioCode" },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ ]
    ],
    { "servers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-VSCode@@Tests/InstallMCPServer.wlt:4247,1-4254,2"
]

(* VS Code with mcp.json file: uses new key path *)
VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = "VisualStudioCode" },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath @
            File @ FileNameJoin @ { $TemporaryDirectory, "mcp.json" }
    ],
    { "servers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-VSCode-MCPJson@@Tests/InstallMCPServer.wlt:4257,1-4265,2"
]

(* VS Code with legacy settings.json: uses old nested key path *)
VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = "VisualStudioCode" },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath @
            File @ FileNameJoin @ { $TemporaryDirectory, "settings.json" }
    ],
    { "mcp", "servers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-VSCode-LegacySettings@@Tests/InstallMCPServer.wlt:4268,1-4276,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = "Zed" },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ ]
    ],
    { "context_servers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-Zed@@Tests/InstallMCPServer.wlt:4278,1-4285,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = "OpenCode" },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ ]
    ],
    { "mcp" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-OpenCode@@Tests/InstallMCPServer.wlt:4287,1-4294,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ "UnknownClient" ],
    { "mcpServers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-UnknownFallback@@Tests/InstallMCPServer.wlt:4296,1-4301,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = None },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ ]
    ],
    { "mcpServers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-NoneFallback@@Tests/InstallMCPServer.wlt:4303,1-4310,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*emptyConfigForPath*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`emptyConfigForPath @ { "mcpServers" },
    <| "mcpServers" -> <| |> |>,
    SameTest -> Equal,
    TestID   -> "EmptyConfigForPath-SingleKey@@Tests/InstallMCPServer.wlt:4315,1-4320,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`emptyConfigForPath @ { "mcp", "servers" },
    <| "mcp" -> <| "servers" -> <| |> |> |>,
    SameTest -> Equal,
    TestID   -> "EmptyConfigForPath-NestedKeys@@Tests/InstallMCPServer.wlt:4322,1-4327,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`emptyConfigForPath @ { },
    <| |>,
    SameTest -> Equal,
    TestID   -> "EmptyConfigForPath-EmptyPath@@Tests/InstallMCPServer.wlt:4329,1-4334,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ensureNestedKey*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[ <| "other" -> 1 |>, { "mcpServers" } ],
    <| "other" -> 1, "mcpServers" -> <| |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-AddMissing@@Tests/InstallMCPServer.wlt:4339,1-4344,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[
        <| "mcpServers" -> <| "existing" -> "data" |> |>,
        { "mcpServers" }
    ],
    <| "mcpServers" -> <| "existing" -> "data" |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-PreserveExisting@@Tests/InstallMCPServer.wlt:4346,1-4354,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[
        <| "theme" -> "dark" |>,
        { "mcp", "servers" }
    ],
    <| "theme" -> "dark", "mcp" -> <| "servers" -> <| |> |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-DeepNesting@@Tests/InstallMCPServer.wlt:4356,1-4364,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[
        <| "mcp" -> <| "existing" -> 1 |> |>,
        { "mcp", "servers" }
    ],
    <| "mcp" -> <| "existing" -> 1, "servers" -> <| |> |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-PartiallyExisting@@Tests/InstallMCPServer.wlt:4366,1-4374,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[ "notAssoc", { "mcpServers" } ],
    <| "mcpServers" -> <| |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-NonAssocInput@@Tests/InstallMCPServer.wlt:4376,1-4381,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*serverConverter*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`serverConverter[ "OpenCode" ],
    Wolfram`AgentTools`SupportedClients`Private`convertToOpenCodeFormat,
    SameTest -> SameQ,
    TestID   -> "ServerConverter-OpenCode@@Tests/InstallMCPServer.wlt:4386,1-4391,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`serverConverter[ "CopilotCLI" ],
    Wolfram`AgentTools`SupportedClients`Private`convertToCopilotCLIFormat,
    SameTest -> SameQ,
    TestID   -> "ServerConverter-CopilotCLI@@Tests/InstallMCPServer.wlt:4393,1-4398,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`serverConverter[ "Cline" ],
    Wolfram`AgentTools`SupportedClients`Private`convertToClineFormat,
    SameTest -> SameQ,
    TestID   -> "ServerConverter-Cline@@Tests/InstallMCPServer.wlt:4400,1-4405,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`serverConverter[ "ClaudeDesktop" ],
    Identity,
    SameTest -> SameQ,
    TestID   -> "ServerConverter-Default@@Tests/InstallMCPServer.wlt:4407,1-4412,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*resolveMCPServerName*)
VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installMCPServerName = Automatic },
        Wolfram`AgentTools`InstallMCPServer`Private`resolveMCPServerName @ MCPServerObject[ "WolframLanguage" ]
    ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "ResolveMCPServerName-BuiltInServer@@Tests/InstallMCPServer.wlt:4417,1-4424,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installMCPServerName = "CustomKey" },
        Wolfram`AgentTools`InstallMCPServer`Private`resolveMCPServerName @ MCPServerObject[ "WolframLanguage" ]
    ],
    "CustomKey",
    SameTest -> Equal,
    TestID   -> "ResolveMCPServerName-OptionOverride@@Tests/InstallMCPServer.wlt:4426,1-4433,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installMCPServerName = Automatic },
        Wolfram`AgentTools`InstallMCPServer`Private`resolveMCPServerName @ MCPServerObject[ "Wolfram" ]
    ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "ResolveMCPServerName-WolframServer@@Tests/InstallMCPServer.wlt:4435,1-4442,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Paclet-Qualified Server Names*)

$testResourceDirectory = FileNameJoin @ { DirectoryName[ $TestFileName, 2 ], "TestResources" };

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Mock Paclet Setup*)
VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletTest" };
    $mockPaclet = First @ PacletFind[ "MockMCPPacletTest" ];
    $mockPaclet[ "Name" ],
    "MockMCPPacletTest",
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-MockPacletSetup@@Tests/InstallMCPServer.wlt:4453,1-4460,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*MCPServerName property for paclet server*)
VerificationTest[
    MCPServerObject[ "MockMCPPacletTest/TestServer" ][ "MCPServerName" ],
    "TestServer",
    SameTest -> Equal,
    TestID   -> "MCPServerName-PacletServerProperty@@Tests/InstallMCPServer.wlt:4465,1-4470,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*resolveMCPServerName - paclet server uses short name*)
VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installMCPServerName = Automatic },
        Wolfram`AgentTools`InstallMCPServer`Private`resolveMCPServerName @ MCPServerObject[ "MockMCPPacletTest/TestServer" ]
    ],
    "TestServer",
    SameTest -> Equal,
    TestID   -> "ResolveMCPServerName-PacletServerShortName@@Tests/InstallMCPServer.wlt:4475,1-4482,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ensurePacletForInstall - already installed*)
VerificationTest[
    Wolfram`AgentTools`Common`ensurePacletForInstall[ "MockMCPPacletTest/TestServer" ],
    _PacletObject,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-EnsurePacletAlreadyInstalled@@Tests/InstallMCPServer.wlt:4487,1-4492,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ensurePacletForInstall - three-segment name*)
VerificationTest[
    Wolfram`AgentTools`Common`ensurePacletForInstall[ "MockMCPPacletTest/TestServer/SomeItem" ],
    (* "MockMCPPacletTest/TestServer" is NOT a valid paclet name here, so this should fail *)
    _Failure,
    { AgentTools::PacletNotInstalled },
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-EnsurePacletThreeSegment@@Tests/InstallMCPServer.wlt:4497,1-4504,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install paclet-qualified server to config file*)
VerificationTest[
    $pacletConfigFile = testConfigFile[];
    $pacletInstallResult = InstallMCPServer[ $pacletConfigFile, "MockMCPPacletTest/TestServer", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-Install@@Tests/InstallMCPServer.wlt:4509,1-4515,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config file created*)
VerificationTest[
    FileExistsQ @ $pacletConfigFile,
    True,
    SameTest -> Equal,
    TestID   -> "InstallPacletServer-ConfigFileExists@@Tests/InstallMCPServer.wlt:4520,1-4525,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config file has correct server name as key*)
VerificationTest[
    $pacletConfigJSON = Import[ $pacletConfigFile, "RawJSON" ];
    KeyExistsQ[ $pacletConfigJSON[ "mcpServers" ], "TestServer" ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallPacletServer-ConfigHasServerName@@Tests/InstallMCPServer.wlt:4530,1-4536,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config server entry has correct MCP_SERVER_NAME env var*)
VerificationTest[
    $pacletConfigJSON[ "mcpServers", "TestServer", "env", "MCP_SERVER_NAME" ],
    "MockMCPPacletTest/TestServer",
    SameTest -> Equal,
    TestID   -> "InstallPacletServer-ConfigEnvServerName@@Tests/InstallMCPServer.wlt:4541,1-4546,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Uninstall paclet server*)
VerificationTest[
    UninstallMCPServer[ $pacletConfigFile, MCPServerObject[ "MockMCPPacletTest/TestServer" ] ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-Uninstall@@Tests/InstallMCPServer.wlt:4551,1-4556,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config no longer has server after uninstall*)
VerificationTest[
    updatedJSON = Import[ $pacletConfigFile, "RawJSON" ];
    KeyExistsQ[ updatedJSON[ "mcpServers" ], "TestServer" ],
    False,
    SameTest -> Equal,
    TestID   -> "InstallPacletServer-VerifyUninstall@@Tests/InstallMCPServer.wlt:4561,1-4567,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install result contains MCPServerObject*)
VerificationTest[
    $pacletInstallResult2 = InstallMCPServer[ $pacletConfigFile, "MockMCPPacletTest/TestServer", "VerifyLLMKit" -> False ];
    $pacletInstallResult2[ "MCPServerObject" ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-ResultHasMCPServerObject@@Tests/InstallMCPServer.wlt:4572,1-4578,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validatePacletServerDefinitions - no error for valid paclet server*)
VerificationTest[
    obj = MCPServerObject[ "MockMCPPacletTest/TestServer" ];
    Wolfram`AgentTools`InstallMCPServer`Private`validatePacletServerDefinitions @ obj,
    Null,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-ValidateDefinitionsValid@@Tests/InstallMCPServer.wlt:4583,1-4589,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validatePacletServerDefinitions - no-op for server without paclet references*)
VerificationTest[
    testServer = CreateMCPServer[
        StringJoin[ "NoPacletRefs_", CreateUUID[] ],
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "Simple", { "x" -> "Integer" }, #x & ] } |>
    ];
    result = Wolfram`AgentTools`InstallMCPServer`Private`validatePacletServerDefinitions @ testServer;
    DeleteObject @ testServer;
    result,
    Null,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-ValidateDefinitionsNoOp@@Tests/InstallMCPServer.wlt:4594,1-4605,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validatePacletServerDefinitions - catches invalid paclet tool*)
VerificationTest[
    badToolServerName = StringJoin[ "BadToolServer_", CreateUUID[] ];
    badToolServer = CreateMCPServer[
        badToolServerName,
        <| "Tools" -> { "NonExistentPaclet/BadTool" } |>
    ];
    result = Wolfram`AgentTools`Common`catchAlways[
        Wolfram`AgentTools`InstallMCPServer`Private`validatePacletServerDefinitions @ badToolServer
    ];
    DeleteObject @ badToolServer;
    result,
    _Failure,
    { AgentTools::PacletNotInstalled },
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-ValidateToolError@@Tests/InstallMCPServer.wlt:4610,1-4625,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validatePacletServerDefinitions - catches invalid paclet prompt*)
VerificationTest[
    badPromptServerName = StringJoin[ "BadPromptServer_", CreateUUID[] ];
    badPromptServer = CreateMCPServer[
        badPromptServerName,
        <| "MCPPrompts" -> { "NonExistentPaclet/BadPrompt" } |>
    ];
    result = Wolfram`AgentTools`Common`catchAlways[
        Wolfram`AgentTools`InstallMCPServer`Private`validatePacletServerDefinitions @ badPromptServer
    ];
    DeleteObject @ badPromptServer;
    result,
    _Failure,
    { AgentTools::PacletNotInstalled },
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-ValidatePromptError@@Tests/InstallMCPServer.wlt:4630,1-4645,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup*)
VerificationTest[
    cleanupTestFiles @ $pacletConfigFile;
    Wolfram`AgentTools`Common`clearPacletDefinitionCache[ ],
    <| |>,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-Cleanup@@Tests/InstallMCPServer.wlt:4650,1-4656,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*MCPServerName Option*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Built-in server uses "Wolfram" config key*)
VerificationTest[
    mcpNameConfigFile = testConfigFile[];
    InstallMCPServer[ mcpNameConfigFile, "WolframLanguage", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "MCPServerName-BuiltInUsesWolframKey-Install@@Tests/InstallMCPServer.wlt:4665,1-4671,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    KeyExistsQ[ jsonContent[ "mcpServers" ], "Wolfram" ] &&
    ! KeyExistsQ[ jsonContent[ "mcpServers" ], "WolframLanguage" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-BuiltInUsesWolframKey-Verify@@Tests/InstallMCPServer.wlt:4673,1-4680,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Second built-in overwrites first under shared key*)
VerificationTest[
    InstallMCPServer[ mcpNameConfigFile, "WolframAlpha", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "MCPServerName-SecondBuiltInOverwrites-Install@@Tests/InstallMCPServer.wlt:4685,1-4690,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    Length[ Keys[ jsonContent[ "mcpServers" ] ] ] === 1 &&
    KeyExistsQ[ jsonContent[ "mcpServers" ], "Wolfram" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-SecondBuiltInOverwrites-Verify@@Tests/InstallMCPServer.wlt:4692,1-4699,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Uninstall built-in removes "Wolfram" key*)
VerificationTest[
    UninstallMCPServer[ mcpNameConfigFile, "WolframAlpha" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "MCPServerName-UninstallBuiltIn@@Tests/InstallMCPServer.wlt:4704,1-4709,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    ! KeyExistsQ[ jsonContent[ "mcpServers" ], "Wolfram" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-UninstallBuiltIn-Verify@@Tests/InstallMCPServer.wlt:4711,1-4717,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Custom server uses its Name as config key*)
VerificationTest[
    mcpNameCustomName = StringJoin[ "CustomMCPTest_", CreateUUID[] ];
    mcpNameCustomServer = CreateMCPServer[
        mcpNameCustomName,
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "Echo", { "x" -> "String" }, #x & ] } |>
    ];
    InstallMCPServer[ mcpNameConfigFile, mcpNameCustomServer, "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "MCPServerName-CustomServerUsesName-Install@@Tests/InstallMCPServer.wlt:4722,1-4732,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    KeyExistsQ[ jsonContent[ "mcpServers" ], mcpNameCustomName ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-CustomServerUsesName-Verify@@Tests/InstallMCPServer.wlt:4734,1-4740,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*MCPServerName option override*)
VerificationTest[
    InstallMCPServer[ mcpNameConfigFile, "WolframLanguage", "MCPServerName" -> "WolframDev", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "MCPServerName-OptionOverride-Install@@Tests/InstallMCPServer.wlt:4745,1-4750,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    KeyExistsQ[ jsonContent[ "mcpServers" ], "WolframDev" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-OptionOverride-Verify@@Tests/InstallMCPServer.wlt:4752,1-4758,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Two built-in servers with different MCPServerName overrides coexist*)
VerificationTest[
    mcpNameConfigFile2 = testConfigFile[];
    InstallMCPServer[ mcpNameConfigFile2, "Wolfram", "MCPServerName" -> "WolframBasic", "VerifyLLMKit" -> False ];
    InstallMCPServer[ mcpNameConfigFile2, "WolframLanguage", "MCPServerName" -> "WolframDev2", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "MCPServerName-TwoBuiltInWithOverrides-Install@@Tests/InstallMCPServer.wlt:4763,1-4770,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile2, "RawJSON" ];
    KeyExistsQ[ jsonContent[ "mcpServers" ], "WolframBasic" ] &&
    KeyExistsQ[ jsonContent[ "mcpServers" ], "WolframDev2" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-TwoBuiltInWithOverrides-Verify@@Tests/InstallMCPServer.wlt:4772,1-4779,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Installation record clearing for shared key*)
VerificationTest[
    mcpNameConfigFile3 = testConfigFile[];
    InstallMCPServer[ mcpNameConfigFile3, "Wolfram", "VerifyLLMKit" -> False ];
    wolframInstalls = MCPServerObject[ "Wolfram" ][ "Installations" ];
    MemberQ[ wolframInstalls, KeyValuePattern[ "ConfigurationFile" -> mcpNameConfigFile3 ] ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-StaleRecordClearing-Setup@@Tests/InstallMCPServer.wlt:4784,1-4792,2"
]

VerificationTest[
    InstallMCPServer[ mcpNameConfigFile3, "WolframLanguage", "VerifyLLMKit" -> False ];
    wolframInstalls = MCPServerObject[ "Wolfram" ][ "Installations" ];
    wlInstalls = MCPServerObject[ "WolframLanguage" ][ "Installations" ];
    (* Wolfram's record for this file should be cleared, WolframLanguage should have it *)
    ! MemberQ[ wolframInstalls, KeyValuePattern[ "ConfigurationFile" -> mcpNameConfigFile3 ] ] &&
    MemberQ[ wlInstalls, KeyValuePattern[ "ConfigurationFile" -> mcpNameConfigFile3 ] ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-StaleRecordClearing-Verify@@Tests/InstallMCPServer.wlt:4794,1-4804,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup*)
VerificationTest[
    UninstallMCPServer[ mcpNameConfigFile ];
    UninstallMCPServer[ mcpNameConfigFile2 ];
    UninstallMCPServer[ mcpNameConfigFile3 ];
    DeleteObject[ mcpNameCustomServer ];
    cleanupTestFiles[ { mcpNameConfigFile, mcpNameConfigFile2, mcpNameConfigFile3 } ],
    { Null.. },
    SameTest -> MatchQ,
    TestID   -> "MCPServerName-Cleanup@@Tests/InstallMCPServer.wlt:4809,1-4818,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Automatic toolset resolution (per-client DefaultToolset)*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*defaultToolsetForTarget helper*)
VerificationTest[
    defaultToolsetForTarget = Wolfram`AgentTools`Common`defaultToolsetForTarget;
    defaultToolsetForTarget[ "ClaudeCode" ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-ClaudeCode@@Tests/InstallMCPServer.wlt:4827,1-4833,2"
]

VerificationTest[
    defaultToolsetForTarget[ "ClaudeDesktop" ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-ClaudeDesktop@@Tests/InstallMCPServer.wlt:4835,1-4840,2"
]

VerificationTest[
    defaultToolsetForTarget[ "Goose" ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-Goose@@Tests/InstallMCPServer.wlt:4842,1-4847,2"
]

VerificationTest[
    defaultToolsetForTarget[ "Cursor" ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-Cursor@@Tests/InstallMCPServer.wlt:4849,1-4854,2"
]

(* Junie is a coding agent (covers JetBrains IDE plugin and Junie CLI), so it defaults to WolframLanguage *)
VerificationTest[
    defaultToolsetForTarget[ "Junie" ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-Junie@@Tests/InstallMCPServer.wlt:4857,1-4862,2"
]

(* Junie alias resolves to the canonical client's default *)
VerificationTest[
    defaultToolsetForTarget[ "JetBrainsJunie" ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-Alias-JetBrainsJunie@@Tests/InstallMCPServer.wlt:4865,1-4870,2"
]

(* {Junie, dir} project-install form *)
VerificationTest[
    defaultToolsetForTarget[ { "Junie", "/some/dir" } ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-NameDir-Junie@@Tests/InstallMCPServer.wlt:4873,1-4878,2"
]

(* Aliases resolve to their canonical client's default *)
VerificationTest[
    defaultToolsetForTarget[ "Claude" ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-Alias-Claude@@Tests/InstallMCPServer.wlt:4881,1-4886,2"
]

VerificationTest[
    defaultToolsetForTarget[ "VSCode" ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-Alias-VSCode@@Tests/InstallMCPServer.wlt:4888,1-4893,2"
]

(* Unknown client falls back to $defaultMCPServer *)
VerificationTest[
    defaultToolsetForTarget[ "TotallyMadeUpClient" ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-Unknown@@Tests/InstallMCPServer.wlt:4896,1-4901,2"
]

(* {name, dir} project-install form dispatches on the name *)
VerificationTest[
    defaultToolsetForTarget[ { "ClaudeCode", "/some/dir" } ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-NameDir-ClaudeCode@@Tests/InstallMCPServer.wlt:4904,1-4909,2"
]

VerificationTest[
    defaultToolsetForTarget[ { "ClaudeDesktop", "/some/dir" } ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-NameDir-ClaudeDesktop@@Tests/InstallMCPServer.wlt:4911,1-4916,2"
]

(* File target with no client match falls back *)
VerificationTest[
    defaultToolsetForTarget[ File[ "C:/this/path/is/not/a/known/client.json" ] ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-File-Unknown@@Tests/InstallMCPServer.wlt:4919,1-4924,2"
]

(* Recognizable File[...] targets resolve via path-based client detection
   (no ApplicationName needed). These guard against regressions where
   defaultToolsetForTarget would silently fall back to "Wolfram" for files
   that guessClientName already identifies. *)

(* .mcp.json -> ClaudeCode (coding client, "WolframLanguage") *)
VerificationTest[
    defaultToolsetForTarget[ File[ "/some/project/.mcp.json" ] ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-File-ClaudeCodeProject@@Tests/InstallMCPServer.wlt:4932,1-4937,2"
]

(* .vscode/mcp.json -> VisualStudioCode (coding client, "WolframLanguage") *)
VerificationTest[
    defaultToolsetForTarget[ File[ "/some/project/.vscode/mcp.json" ] ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-File-VSCodeProject@@Tests/InstallMCPServer.wlt:4940,1-4945,2"
]

(* opencode.json -> OpenCode (coding client, "WolframLanguage") *)
VerificationTest[
    defaultToolsetForTarget[ File[ "/some/project/opencode.json" ] ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-File-OpenCodeProject@@Tests/InstallMCPServer.wlt:4948,1-4953,2"
]

(* Non-target argument falls back *)
VerificationTest[
    defaultToolsetForTarget[ 42 ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-NonTarget@@Tests/InstallMCPServer.wlt:4956,1-4961,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*defaultToolsetForTarget with explicit ApplicationName*)
(* The 2-arg form lets callers override path-based resolution by passing an
   explicit application name (the same string accepted by "ApplicationName"). *)
VerificationTest[
    defaultToolsetForTarget[ File[ "C:/this/path/is/not/a/known/client.json" ], "Cline" ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-File-AppName-Cline@@Tests/InstallMCPServer.wlt:4968,1-4973,2"
]

VerificationTest[
    defaultToolsetForTarget[ File[ "C:/this/path/is/not/a/known/client.json" ], "ClaudeDesktop" ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-File-AppName-ClaudeDesktop@@Tests/InstallMCPServer.wlt:4975,1-4980,2"
]

(* Aliases route through toInstallName, so an alias picks up the canonical client's default *)
VerificationTest[
    defaultToolsetForTarget[ File[ "C:/this/path/is/not/a/known/client.json" ], "VSCode" ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-File-AppName-Alias@@Tests/InstallMCPServer.wlt:4983,1-4988,2"
]

(* Automatic in the 2-arg form falls back to the existing target-based resolution *)
VerificationTest[
    defaultToolsetForTarget[ File[ "C:/this/path/is/not/a/known/client.json" ], Automatic ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-File-AppName-Automatic@@Tests/InstallMCPServer.wlt:4991,1-4996,2"
]

(* String target is also overridden by an explicit ApplicationName *)
VerificationTest[
    defaultToolsetForTarget[ "ClaudeCode", "ClaudeDesktop" ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "DefaultToolsetForTarget-StringTarget-AppName@@Tests/InstallMCPServer.wlt:4999,1-5004,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*InstallMCPServer with Automatic resolution*)
VerificationTest[
    autoTestDir = CreateDirectory[ ];
    autoInstallResultAuto = InstallMCPServer[
        { "ClaudeCode", autoTestDir },
        Automatic,
        "VerifyLLMKit" -> False
    ];
    autoInstallResultAuto[[ 2 ]][ "MCPServerObject" ][ "Name" ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Automatic-ClaudeCode@@Tests/InstallMCPServer.wlt:5009,1-5020,2"
]

(* 1-arg form should give the same result as Automatic *)
VerificationTest[
    Quiet @ DeleteDirectory[ autoTestDir, DeleteContents -> True ];
    autoTestDir = CreateDirectory[ ];
    autoInstallResult1Arg = InstallMCPServer[
        { "ClaudeCode", autoTestDir },
        "VerifyLLMKit" -> False
    ];
    autoInstallResult1Arg[[ 2 ]][ "MCPServerObject" ][ "Name" ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-1Arg-ClaudeCode@@Tests/InstallMCPServer.wlt:5023,1-5034,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*InstallMCPServer Automatic with File target + ApplicationName*)
(* For arbitrary File[...] targets whose path doesn't reveal the client, an
   explicit "ApplicationName" must drive the Automatic toolset choice. *)
VerificationTest[
    autoCustomFile = testConfigFile[ ];
    autoInstallResultFileApp = InstallMCPServer[
        autoCustomFile,
        Automatic,
        "ApplicationName" -> "Cline",
        "VerifyLLMKit"    -> False
    ];
    autoInstallResultFileApp[[ 2 ]][ "MCPServerObject" ][ "Name" ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Automatic-File-AppName-Cline@@Tests/InstallMCPServer.wlt:5041,1-5053,2"
]

VerificationTest[
    cleanupTestFiles @ autoCustomFile;
    autoCustomFile = testConfigFile[ ];
    autoInstallResultFileChat = InstallMCPServer[
        autoCustomFile,
        Automatic,
        "ApplicationName" -> "ClaudeDesktop",
        "VerifyLLMKit"    -> False
    ];
    autoInstallResultFileChat[[ 2 ]][ "MCPServerObject" ][ "Name" ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Automatic-File-AppName-ClaudeDesktop@@Tests/InstallMCPServer.wlt:5055,1-5068,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*InstallMCPServer Automatic with recognizable File targets (no ApplicationName)*)
(* When the File[...] path itself identifies a known client, Automatic must
   resolve to that client's DefaultToolset without any "ApplicationName"
   override.  These guard against regressions where path-based detection
   silently drops back to the global default. *)

(* .mcp.json -> ClaudeCode -> "WolframLanguage" *)
VerificationTest[
    autoRecognizableDir = CreateDirectory[ ];
    autoRecognizableFile = File @ FileNameJoin @ { autoRecognizableDir, ".mcp.json" };
    autoInstallResultFileClaudeCode = InstallMCPServer[
        autoRecognizableFile,
        Automatic,
        "VerifyLLMKit" -> False
    ];
    autoInstallResultFileClaudeCode[[ 2 ]][ "MCPServerObject" ][ "Name" ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Automatic-File-ClaudeCodeProject@@Tests/InstallMCPServer.wlt:5079,1-5091,2"
]

(* .vscode/mcp.json -> VisualStudioCode -> "WolframLanguage" *)
VerificationTest[
    Quiet @ DeleteDirectory[ autoRecognizableDir, DeleteContents -> True ];
    autoRecognizableDir = CreateDirectory[ ];
    CreateDirectory @ FileNameJoin @ { autoRecognizableDir, ".vscode" };
    autoRecognizableFile = File @ FileNameJoin @ { autoRecognizableDir, ".vscode", "mcp.json" };
    autoInstallResultFileVSCode = InstallMCPServer[
        autoRecognizableFile,
        Automatic,
        "VerifyLLMKit" -> False
    ];
    autoInstallResultFileVSCode[[ 2 ]][ "MCPServerObject" ][ "Name" ],
    "WolframLanguage",
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Automatic-File-VSCodeProject@@Tests/InstallMCPServer.wlt:5094,1-5108,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$SupportedMCPClients DefaultToolset coverage*)
(* Every $SupportedMCPClients entry must expose a string DefaultToolset that
   names a real predefined server.  This catches typos or missing metadata in
   any client whose toolset isn't covered by an individual VerificationTest. *)
VerificationTest[
    Module[ { knownServers, validQ },
        knownServers = Keys @ $DefaultMCPServers;
        validQ = Function[ meta,
            With[ { toolset = Lookup[ meta, "DefaultToolset" ] },
                StringQ @ toolset && MemberQ[ knownServers, toolset ]
            ]
        ];
        Keys @ Select[ $SupportedMCPClients, ! validQ[ # ] & ]
    ],
    { },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-DefaultToolset-Coverage@@Tests/InstallMCPServer.wlt:5116,1-5129,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup*)
VerificationTest[
    Quiet @ DeleteDirectory[ autoTestDir, DeleteContents -> True ];
    Quiet @ DeleteDirectory[ autoRecognizableDir, DeleteContents -> True ];
    cleanupTestFiles @ autoCustomFile;
    True,
    True,
    TestID -> "Automatic-Cleanup@@Tests/InstallMCPServer.wlt:5134,1-5141,2"
]

(* :!CodeAnalysis::EndBlock:: *)