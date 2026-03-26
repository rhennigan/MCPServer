(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
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
(*Install from Association*)
VerificationTest[
    configFile = testConfigFile[];
    name = CreateUUID[];
    config = <| "Tools" -> { LLMTool[ "SquareNumber", { "x" -> "Number" }, #x^2 & ] } |>;
    server = CreateMCPServer[name, config];
    installResult = InstallMCPServer[configFile, server],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-FromAssociation@@Tests/InstallMCPServer.wlt:255,1-264,2"
]

VerificationTest[
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent, "mcpServers"] && KeyExistsQ[jsonContent["mcpServers"], name],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-VerifyAssociationServer@@Tests/InstallMCPServer.wlt:266,1-272,2"
]

VerificationTest[
    UninstallMCPServer[configFile, name];
    DeleteObject[server];
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupAssociation@@Tests/InstallMCPServer.wlt:274,1-281,2"
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
    TestID   -> "InstallMCPServer-ClaudeCodeLike@@Tests/InstallMCPServer.wlt:286,1-294,2"
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
    TestID   -> "InstallMCPServer-PreservesOtherData@@Tests/InstallMCPServer.wlt:296,1-306,2"
]

VerificationTest[
    (* Install a second server to verify multiple installations work *)
    installResult2 = InstallMCPServer[configFile, "WolframAlpha"];
    jsonContent = Import[configFile, "RawJSON"];
    Length[Keys[jsonContent["mcpServers"]]] === 1 &&
    KeyExistsQ[jsonContent["mcpServers"], "Wolfram"],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-MultipleBuiltInOverwrite@@Tests/InstallMCPServer.wlt:308,1-317,2"
]

VerificationTest[
    UninstallMCPServer[configFile];
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupClaudeCodeLike@@Tests/InstallMCPServer.wlt:319,1-325,2"
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
    TestID   -> "InstallMCPServer-InvalidJSON@@Tests/InstallMCPServer.wlt:330,1-338,2"
]

VerificationTest[
    configFile = testConfigFile[];
    Export[configFile, "{}", "JSON"];
    InstallMCPServer[configFile, "NonExistentServer"],
    _Failure,
    {InstallMCPServer::MCPServerNotFound},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-NonExistentServer@@Tests/InstallMCPServer.wlt:340,1-348,2"
]

VerificationTest[
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupErrorTests@@Tests/InstallMCPServer.wlt:350,1-355,2"
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
    TestID   -> "InstallLocation-Antigravity-Windows@@Tests/InstallMCPServer.wlt:364,1-369,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Antigravity", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Antigravity-MacOSX@@Tests/InstallMCPServer.wlt:371,1-376,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Antigravity", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Antigravity-Unix@@Tests/InstallMCPServer.wlt:378,1-383,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Antigravity" ],
    "Antigravity",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Antigravity@@Tests/InstallMCPServer.wlt:385,1-390,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "GoogleAntigravity" ],
    "Antigravity",
    SameTest -> Equal,
    TestID   -> "ToInstallName-GoogleAntigravity@@Tests/InstallMCPServer.wlt:392,1-397,2"
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
    TestID   -> "ProjectInstallLocation-ClaudeCode@@Tests/InstallMCPServer.wlt:404,1-413,2"
]

VerificationTest[
    Module[ { result },
        result = Wolfram`AgentTools`Common`projectInstallLocation[ "ClaudeCode", File[ "AgentTools" ] ];
        FileNameTake[ First @ result, -1 ]
    ],
    ".mcp.json",
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-ClaudeCode-FileWrapper@@Tests/InstallMCPServer.wlt:415,1-423,2"
]

VerificationTest[
    Module[ { path, result },
        path = FileNameJoin @ { $TemporaryDirectory, "TestProject" };
        result = Wolfram`AgentTools`Common`projectInstallLocation[ "OpenCode", path ];
        FileNameTake[ First @ result, -1 ]
    ],
    "opencode.json",
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-OpenCode@@Tests/InstallMCPServer.wlt:425,1-434,2"
]

VerificationTest[
    Module[ { path, result },
        path = FileNameJoin @ { $TemporaryDirectory, "TestProject" };
        result = Wolfram`AgentTools`Common`projectInstallLocation[ "VisualStudioCode", path ];
        FileNameTake[ First @ result, -2 ]
    ],
    FileNameJoin @ { ".vscode", "settings.json" },
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-VisualStudioCode@@Tests/InstallMCPServer.wlt:436,1-445,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`catchAlways[
        Wolfram`AgentTools`Common`projectInstallLocation[ "ClaudeCode", Symbol[ "xyz" ] ]
    ],
    _Failure,
    { AgentTools::InvalidProjectDirectory },
    SameTest -> MatchQ,
    TestID   -> "ProjectInstallLocation-InvalidDirectory-Symbol@@Tests/InstallMCPServer.wlt:447,1-455,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`catchAlways[
        Wolfram`AgentTools`Common`projectInstallLocation[ "ClaudeCode", 123 ]
    ],
    _Failure,
    { AgentTools::InvalidProjectDirectory },
    SameTest -> MatchQ,
    TestID   -> "ProjectInstallLocation-InvalidDirectory-Integer@@Tests/InstallMCPServer.wlt:457,1-465,2"
]

VerificationTest[
    InstallMCPServer[ { "ClaudeCode", Symbol[ "xyz" ] } ],
    _Failure,
    { InstallMCPServer::InvalidProjectDirectory },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-InvalidProjectDirectory@@Tests/InstallMCPServer.wlt:467,1-473,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeDevelopmentArgs*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`makeDevelopmentArgs[ DirectoryName[ $TestFileName, 2 ] ],
    { "-script", _String? FileExistsQ, "-noinit", "-noprompt" },
    SameTest -> MatchQ,
    TestID   -> "MakeDevelopmentArgs-ValidPath@@Tests/InstallMCPServer.wlt:478,1-483,2"
]

VerificationTest[
    configFile = testConfigFile[];
    invalidPath = FileNameJoin @ { $TemporaryDirectory, CreateUUID[ "InvalidPath-" ] };
    InstallMCPServer[ configFile, "DevelopmentMode" -> invalidPath, "VerifyLLMKit" -> False ],
    Failure[ "InstallMCPServer::DevelopmentModeUnavailable", _ ],
    { InstallMCPServer::DevelopmentModeUnavailable },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-InvalidPath@@Tests/InstallMCPServer.wlt:485,1-493,2"
]

VerificationTest[
    configFile = testConfigFile[];
    InstallMCPServer[ configFile, "DevelopmentMode" -> InvalidValue, "VerifyLLMKit" -> False ],
    Failure[ "InstallMCPServer::InvalidDevelopmentMode", _ ],
    { InstallMCPServer::InvalidDevelopmentMode },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-InvalidValue@@Tests/InstallMCPServer.wlt:495,1-502,2"
]

(* :!CodeAnalysis::EndBlock:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*DevelopmentMode Option*)
VerificationTest[
    MemberQ[ Keys @ Options @ InstallMCPServer, "DevelopmentMode" ],
    True,
    TestID -> "DevelopmentMode-OptionExists@@Tests/InstallMCPServer.wlt:509,1-513,2"
]

VerificationTest[
    configFile = testConfigFile[];
    InstallMCPServer[ configFile, "DevelopmentMode" -> DirectoryName[ $TestFileName, 2 ], "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-Success@@Tests/InstallMCPServer.wlt:515,1-521,2"
]

VerificationTest[
    json = Developer`ReadRawJSONFile @ First @ configFile;
    json[ "mcpServers", "Wolfram", "args" ],
    { "-script", _String, "-noinit", "-noprompt" },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-Args@@Tests/InstallMCPServer.wlt:523,1-529,2"
]

VerificationTest[
    cleanupTestFiles[ configFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-Cleanup@@Tests/InstallMCPServer.wlt:531,1-536,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Codex (TOML) Support*)

(* Helper function for TOML test files *)
testTOMLFile = Function[
    File @ FileNameJoin @ { $TemporaryDirectory, StringJoin["mcp_test_config_", CreateUUID[], ".toml"] }
];

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for Codex*)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Codex", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Codex-Windows@@Tests/InstallMCPServer.wlt:553,1-558,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Codex", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Codex-MacOSX@@Tests/InstallMCPServer.wlt:560,1-565,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Codex", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Codex-Unix@@Tests/InstallMCPServer.wlt:567,1-572,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "OpenAICodex" ],
    "Codex",
    SameTest -> Equal,
    TestID   -> "ToInstallName-OpenAICodex@@Tests/InstallMCPServer.wlt:577,1-582,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Codex" ],
    "Codex",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Codex@@Tests/InstallMCPServer.wlt:584,1-589,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Codex" ],
    "Codex CLI",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Codex@@Tests/InstallMCPServer.wlt:591,1-596,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*TOML Parsing and Writing*)
VerificationTest[
    toml = Wolfram`AgentTools`Common`readTOMLFile @ FileNameJoin @ { $TemporaryDirectory, "nonexistent.toml" };
    toml[ "Data" ],
    <| |>,
    SameTest -> Equal,
    TestID   -> "ReadTOMLFile-NonExistent@@Tests/InstallMCPServer.wlt:601,1-607,2"
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
    TestID   -> "ReadTOMLFile-BasicParsing@@Tests/InstallMCPServer.wlt:609,1-622,2"
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
    TestID   -> "ReadTOMLFile-MCPServerSection@@Tests/InstallMCPServer.wlt:624,1-642,2"
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
    TestID   -> "InstallMCPServer-Codex-Basic@@Tests/InstallMCPServer.wlt:647,1-654,2"
]

VerificationTest[
    FileExistsQ[ codexConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-FileExists@@Tests/InstallMCPServer.wlt:656,1-661,2"
]

VerificationTest[
    Module[ { content, toml },
        content = ReadString @ codexConfigFile;
        toml = Wolfram`AgentTools`Common`readTOMLFile @ codexConfigFile;
        KeyExistsQ[ toml[ "Data", "mcp_servers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-VerifyContent@@Tests/InstallMCPServer.wlt:663,1-672,2"
]

VerificationTest[
    Module[ { content },
        content = ReadString @ codexConfigFile;
        StringContainsQ[ content, "[mcp_servers.Wolfram]" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-VerifySectionFormat@@Tests/InstallMCPServer.wlt:674,1-682,2"
]

VerificationTest[
    (* Use file-based uninstall - TOML format is auto-detected from .toml extension *)
    uninstallResult = UninstallMCPServer[ codexConfigFile, "WolframLanguage" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Codex-Basic@@Tests/InstallMCPServer.wlt:684,1-690,2"
]

VerificationTest[
    Module[ { toml },
        toml = Wolfram`AgentTools`Common`readTOMLFile @ codexConfigFile;
        ! KeyExistsQ[ Lookup[ toml[ "Data" ], "mcp_servers", <| |> ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Codex-VerifyRemoval@@Tests/InstallMCPServer.wlt:692,1-700,2"
]

VerificationTest[
    cleanupTestFiles[ codexConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-Cleanup@@Tests/InstallMCPServer.wlt:702,1-707,2"
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
    TestID   -> "InstallMCPServer-Codex-MultipleServers@@Tests/InstallMCPServer.wlt:712,1-720,2"
]

VerificationTest[
    Module[ { toml, mcpServers },
        toml = Wolfram`AgentTools`Common`readTOMLFile @ codexConfigFile;
        mcpServers = Lookup[ toml[ "Data" ], "mcp_servers", <| |> ];
        KeyExistsQ[ mcpServers, "Wolfram" ] && Length[ Keys @ mcpServers ] === 1
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-VerifyMultipleBuiltInShareKey@@Tests/InstallMCPServer.wlt:722,1-731,2"
]

VerificationTest[
    cleanupTestFiles[ codexConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-MultipleServers-Cleanup@@Tests/InstallMCPServer.wlt:733,1-738,2"
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
    TestID   -> "InstallMCPServer-Codex-PreserveExisting@@Tests/InstallMCPServer.wlt:743,1-755,2"
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
    TestID   -> "InstallMCPServer-Codex-VerifyPreserved@@Tests/InstallMCPServer.wlt:757,1-767,2"
]

VerificationTest[
    cleanupTestFiles[ codexConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-PreserveExisting-Cleanup@@Tests/InstallMCPServer.wlt:769,1-774,2"
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
    TestID   -> "ConvertToCodexFormat-Basic@@Tests/InstallMCPServer.wlt:779,1-793,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`convertToCodexFormat @ <|
        "command" -> "wolfram"
    |>,
    <| "command" -> "wolfram", "enabled" -> True |>,
    SameTest -> Equal,
    TestID   -> "ConvertToCodexFormat-MinimalConfig@@Tests/InstallMCPServer.wlt:795,1-802,2"
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
    TestID   -> "InstallLocation-CopilotCLI-Windows@@Tests/InstallMCPServer.wlt:811,1-816,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "CopilotCLI", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-CopilotCLI-MacOSX@@Tests/InstallMCPServer.wlt:818,1-823,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "CopilotCLI", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-CopilotCLI-Unix@@Tests/InstallMCPServer.wlt:825,1-830,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Copilot" ],
    "CopilotCLI",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Copilot@@Tests/InstallMCPServer.wlt:835,1-840,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "CopilotCLI" ],
    "CopilotCLI",
    SameTest -> Equal,
    TestID   -> "ToInstallName-CopilotCLI@@Tests/InstallMCPServer.wlt:842,1-847,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "CopilotCLI" ],
    "Copilot CLI",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-CopilotCLI@@Tests/InstallMCPServer.wlt:849,1-854,2"
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
    TestID   -> "ConvertToCopilotCLIFormat-Basic@@Tests/InstallMCPServer.wlt:859,1-873,2"
]

VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToCopilotCLIFormat @ <|
        "command" -> "wolfram"
    |>,
    <| "command" -> "wolfram", "tools" -> { "*" } |>,
    SameTest -> Equal,
    TestID   -> "ConvertToCopilotCLIFormat-MinimalConfig@@Tests/InstallMCPServer.wlt:875,1-882,2"
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
    TestID   -> "InstallLocation-Windsurf-Windows@@Tests/InstallMCPServer.wlt:891,1-896,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Windsurf", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Windsurf-MacOSX@@Tests/InstallMCPServer.wlt:898,1-903,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Windsurf", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Windsurf-Unix@@Tests/InstallMCPServer.wlt:905,1-910,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Codeium" ],
    "Windsurf",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Codeium@@Tests/InstallMCPServer.wlt:915,1-920,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Windsurf" ],
    "Windsurf",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Windsurf@@Tests/InstallMCPServer.wlt:922,1-927,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Windsurf" ],
    "Windsurf",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Windsurf@@Tests/InstallMCPServer.wlt:929,1-934,2"
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
    TestID   -> "InstallLocation-Cline-Windows@@Tests/InstallMCPServer.wlt:943,1-948,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Cline", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Cline-MacOSX@@Tests/InstallMCPServer.wlt:950,1-955,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Cline", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Cline-Unix@@Tests/InstallMCPServer.wlt:957,1-962,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Cline" ],
    "Cline",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Cline@@Tests/InstallMCPServer.wlt:967,1-972,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Cline" ],
    "Cline",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Cline@@Tests/InstallMCPServer.wlt:974,1-979,2"
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
    TestID   -> "ConvertToClineFormat-Basic@@Tests/InstallMCPServer.wlt:984,1-999,2"
]

VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToClineFormat @ <|
        "command" -> "wolfram"
    |>,
    <| "command" -> "wolfram", "disabled" -> False, "autoApprove" -> { } |>,
    SameTest -> Equal,
    TestID   -> "ConvertToClineFormat-MinimalConfig@@Tests/InstallMCPServer.wlt:1001,1-1008,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cline Install and Uninstall*)
VerificationTest[
    clineConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ clineConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "Cline" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Cline-Basic@@Tests/InstallMCPServer.wlt:1013,1-1019,2"
]

VerificationTest[
    FileExistsQ[ clineConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Cline-FileExists@@Tests/InstallMCPServer.wlt:1021,1-1026,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ clineConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Cline-VerifyContent@@Tests/InstallMCPServer.wlt:1028,1-1036,2"
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
    TestID   -> "InstallMCPServer-Cline-VerifyClineFields@@Tests/InstallMCPServer.wlt:1038,1-1048,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ clineConfigFile, "WolframLanguage", "ApplicationName" -> "Cline" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Cline-Basic@@Tests/InstallMCPServer.wlt:1050,1-1055,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ clineConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && ! KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Cline-VerifyRemoval@@Tests/InstallMCPServer.wlt:1057,1-1065,2"
]

VerificationTest[
    cleanupTestFiles[ clineConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Cline-Cleanup@@Tests/InstallMCPServer.wlt:1067,1-1072,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Windsurf Install and Uninstall*)
VerificationTest[
    windsurfConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ windsurfConfigFile, "WolframLanguage", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Windsurf-Basic@@Tests/InstallMCPServer.wlt:1077,1-1083,2"
]

VerificationTest[
    FileExistsQ[ windsurfConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Windsurf-FileExists@@Tests/InstallMCPServer.wlt:1085,1-1090,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ windsurfConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Windsurf-VerifyContent@@Tests/InstallMCPServer.wlt:1092,1-1100,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ windsurfConfigFile, "WolframLanguage" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Windsurf-Basic@@Tests/InstallMCPServer.wlt:1102,1-1107,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ windsurfConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && ! KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Windsurf-VerifyRemoval@@Tests/InstallMCPServer.wlt:1109,1-1117,2"
]

VerificationTest[
    cleanupTestFiles[ windsurfConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Windsurf-Cleanup@@Tests/InstallMCPServer.wlt:1119,1-1124,2"
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
    TestID   -> "InstallLocation-Zed-Windows@@Tests/InstallMCPServer.wlt:1133,1-1138,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Zed", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Zed-MacOSX@@Tests/InstallMCPServer.wlt:1140,1-1145,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Zed", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Zed-Unix@@Tests/InstallMCPServer.wlt:1147,1-1152,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Zed" ],
    "Zed",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Zed@@Tests/InstallMCPServer.wlt:1157,1-1162,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Zed" ],
    "Zed",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Zed@@Tests/InstallMCPServer.wlt:1164,1-1169,2"
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
    TestID   -> "ProjectInstallLocation-Zed@@Tests/InstallMCPServer.wlt:1174,1-1183,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Zed Install and Uninstall*)
VerificationTest[
    zedConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ zedConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "Zed" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Zed-Basic@@Tests/InstallMCPServer.wlt:1188,1-1194,2"
]

VerificationTest[
    FileExistsQ[ zedConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Zed-FileExists@@Tests/InstallMCPServer.wlt:1196,1-1201,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ zedConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "context_servers" ] && KeyExistsQ[ content[ "context_servers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Zed-VerifyContent@@Tests/InstallMCPServer.wlt:1203,1-1211,2"
]

VerificationTest[
    Module[ { content, server },
        content = Import[ zedConfigFile, "RawJSON" ];
        server = content[ "context_servers", "Wolfram" ];
        KeyExistsQ[ server, "command" ] && KeyExistsQ[ server, "args" ] && KeyExistsQ[ server, "env" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Zed-VerifyServerFields@@Tests/InstallMCPServer.wlt:1213,1-1222,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ zedConfigFile, "WolframLanguage", "ApplicationName" -> "Zed" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Zed-Basic@@Tests/InstallMCPServer.wlt:1224,1-1229,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ zedConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "context_servers" ] && ! KeyExistsQ[ content[ "context_servers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Zed-VerifyRemoval@@Tests/InstallMCPServer.wlt:1231,1-1239,2"
]

VerificationTest[
    cleanupTestFiles[ zedConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Zed-Cleanup@@Tests/InstallMCPServer.wlt:1241,1-1246,2"
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
    TestID   -> "InstallMCPServer-Zed-PreserveExisting@@Tests/InstallMCPServer.wlt:1251,1-1258,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ zedConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "theme" ] && content[ "theme" ] === "One Dark" &&
        KeyExistsQ[ content[ "context_servers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Zed-VerifyPreserved@@Tests/InstallMCPServer.wlt:1260,1-1269,2"
]

VerificationTest[
    cleanupTestFiles[ zedConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Zed-PreserveExisting-Cleanup@@Tests/InstallMCPServer.wlt:1271,1-1276,2"
]

(* :!CodeAnalysis::EndBlock:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*$SupportedMCPClients*)
VerificationTest[
    $SupportedMCPClients,
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "SupportedMCPClients-ReturnsAssociation@@Tests/InstallMCPServer.wlt:1283,1-1288,2"
]

VerificationTest[
    Length @ $SupportedMCPClients,
    12,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-Has12Clients@@Tests/InstallMCPServer.wlt:1290,1-1295,2"
]

VerificationTest[
    Keys @ $SupportedMCPClients,
    { "Antigravity", "ClaudeCode", "ClaudeDesktop", "Cline", "Codex", "CopilotCLI", "Cursor", "GeminiCLI", "OpenCode", "VisualStudioCode", "Windsurf", "Zed" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-KeysSorted@@Tests/InstallMCPServer.wlt:1297,1-1302,2"
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
            MatchQ[ meta[ "ConfigKey" ], { __String } ] &&
            KeyExistsQ[ meta, "URL" ]
        ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AllHaveRequiredKeys@@Tests/InstallMCPServer.wlt:1304,1-1321,2"
]

VerificationTest[
    $SupportedMCPClients[ "ClaudeDesktop", "DisplayName" ],
    "Claude Desktop",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ClaudeDesktopDisplayName@@Tests/InstallMCPServer.wlt:1323,1-1328,2"
]

VerificationTest[
    $SupportedMCPClients[ "ClaudeDesktop", "Aliases" ],
    { "Claude" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ClaudeDesktopAliases@@Tests/InstallMCPServer.wlt:1330,1-1335,2"
]

VerificationTest[
    $SupportedMCPClients[ "Codex", "ConfigFormat" ],
    "TOML",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-CodexConfigFormat@@Tests/InstallMCPServer.wlt:1337,1-1342,2"
]

VerificationTest[
    $SupportedMCPClients[ "ClaudeCode", "ProjectSupport" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ClaudeCodeProjectSupport@@Tests/InstallMCPServer.wlt:1344,1-1349,2"
]

VerificationTest[
    $SupportedMCPClients[ "Zed", "ConfigKey" ],
    { "context_servers" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ZedConfigKey@@Tests/InstallMCPServer.wlt:1351,1-1356,2"
]

VerificationTest[
    $SupportedMCPClients[ "VisualStudioCode", "ConfigKey" ],
    { "mcp", "servers" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-VSCodeConfigKey@@Tests/InstallMCPServer.wlt:1358,1-1363,2"
]

VerificationTest[
    $SupportedMCPClients[ "OpenCode", "ConfigKey" ],
    { "mcp" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-OpenCodeConfigKey@@Tests/InstallMCPServer.wlt:1365,1-1370,2"
]

VerificationTest[
    AllTrue[ Values @ $SupportedMCPClients, StringQ[ #[ "URL" ] ] && StringStartsQ[ #[ "URL" ], "https://" ] & ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AllHaveValidURLs@@Tests/InstallMCPServer.wlt:1372,1-1377,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Helper Function Unit Tests*)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*guessClientNameFromJSON*)

(* Helper to create a temp JSON file with given content *)
makeTestJSONFile[ data_Association ] := Module[ { file },
    file = FileNameJoin @ { $TemporaryDirectory, StringJoin[ "guess_test_", CreateUUID[], ".json" ] };
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
    TestID   -> "GuessClientNameFromJSON-Zed@@Tests/InstallMCPServer.wlt:1398,1-1408,2"
]

(* VSCode: has "mcp" with nested "servers" *)
VerificationTest[
    Module[ { file, result },
        file = makeTestJSONFile @ <| "mcp" -> <| "servers" -> <| "MyServer" -> <| "command" -> "wolframscript" |> |> |> |>;
        result = Wolfram`AgentTools`InstallMCPServer`Private`guessClientNameFromJSON @ file;
        DeleteFile @ file;
        result
    ],
    "VisualStudioCode",
    SameTest -> Equal,
    TestID   -> "GuessClientNameFromJSON-VisualStudioCode@@Tests/InstallMCPServer.wlt:1411,1-1421,2"
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
    TestID   -> "GuessClientNameFromJSON-OpenCode@@Tests/InstallMCPServer.wlt:1424,1-1434,2"
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
    TestID   -> "GuessClientNameFromJSON-CopilotCLI@@Tests/InstallMCPServer.wlt:1437,1-1447,2"
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
    TestID   -> "GuessClientNameFromJSON-Cline@@Tests/InstallMCPServer.wlt:1450,1-1460,2"
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
    TestID   -> "GuessClientNameFromJSON-Ambiguous@@Tests/InstallMCPServer.wlt:1463,1-1473,2"
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
    TestID   -> "GuessClientNameFromJSON-EmptyJSON@@Tests/InstallMCPServer.wlt:1476,1-1486,2"
]

(* Non-existent file -> None *)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`guessClientNameFromJSON @
        FileNameJoin @ { $TemporaryDirectory, "nonexistent_" <> CreateUUID[] <> ".json" },
    None,
    SameTest -> Equal,
    TestID   -> "GuessClientNameFromJSON-NonExistentFile@@Tests/InstallMCPServer.wlt:1489,1-1495,2"
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
    TestID   -> "ConfigKeyPath-ClaudeDesktop@@Tests/InstallMCPServer.wlt:1500,1-1507,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = "VisualStudioCode" },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ ]
    ],
    { "mcp", "servers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-VSCode@@Tests/InstallMCPServer.wlt:1509,1-1516,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = "Zed" },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ ]
    ],
    { "context_servers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-Zed@@Tests/InstallMCPServer.wlt:1518,1-1525,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = "OpenCode" },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ ]
    ],
    { "mcp" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-OpenCode@@Tests/InstallMCPServer.wlt:1527,1-1534,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ "UnknownClient" ],
    { "mcpServers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-UnknownFallback@@Tests/InstallMCPServer.wlt:1536,1-1541,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = None },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ ]
    ],
    { "mcpServers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-NoneFallback@@Tests/InstallMCPServer.wlt:1543,1-1550,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*emptyConfigForPath*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`emptyConfigForPath @ { "mcpServers" },
    <| "mcpServers" -> <| |> |>,
    SameTest -> Equal,
    TestID   -> "EmptyConfigForPath-SingleKey@@Tests/InstallMCPServer.wlt:1555,1-1560,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`emptyConfigForPath @ { "mcp", "servers" },
    <| "mcp" -> <| "servers" -> <| |> |> |>,
    SameTest -> Equal,
    TestID   -> "EmptyConfigForPath-NestedKeys@@Tests/InstallMCPServer.wlt:1562,1-1567,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`emptyConfigForPath @ { },
    <| |>,
    SameTest -> Equal,
    TestID   -> "EmptyConfigForPath-EmptyPath@@Tests/InstallMCPServer.wlt:1569,1-1574,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ensureNestedKey*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[ <| "other" -> 1 |>, { "mcpServers" } ],
    <| "other" -> 1, "mcpServers" -> <| |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-AddMissing@@Tests/InstallMCPServer.wlt:1579,1-1584,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[
        <| "mcpServers" -> <| "existing" -> "data" |> |>,
        { "mcpServers" }
    ],
    <| "mcpServers" -> <| "existing" -> "data" |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-PreserveExisting@@Tests/InstallMCPServer.wlt:1586,1-1594,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[
        <| "theme" -> "dark" |>,
        { "mcp", "servers" }
    ],
    <| "theme" -> "dark", "mcp" -> <| "servers" -> <| |> |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-DeepNesting@@Tests/InstallMCPServer.wlt:1596,1-1604,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[
        <| "mcp" -> <| "existing" -> 1 |> |>,
        { "mcp", "servers" }
    ],
    <| "mcp" -> <| "existing" -> 1, "servers" -> <| |> |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-PartiallyExisting@@Tests/InstallMCPServer.wlt:1606,1-1614,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[ "notAssoc", { "mcpServers" } ],
    <| "mcpServers" -> <| |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-NonAssocInput@@Tests/InstallMCPServer.wlt:1616,1-1621,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*serverConverter*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`serverConverter[ "OpenCode" ],
    Wolfram`AgentTools`SupportedClients`Private`convertToOpenCodeFormat,
    SameTest -> SameQ,
    TestID   -> "ServerConverter-OpenCode@@Tests/InstallMCPServer.wlt:1626,1-1631,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`serverConverter[ "CopilotCLI" ],
    Wolfram`AgentTools`SupportedClients`Private`convertToCopilotCLIFormat,
    SameTest -> SameQ,
    TestID   -> "ServerConverter-CopilotCLI@@Tests/InstallMCPServer.wlt:1633,1-1638,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`serverConverter[ "Cline" ],
    Wolfram`AgentTools`SupportedClients`Private`convertToClineFormat,
    SameTest -> SameQ,
    TestID   -> "ServerConverter-Cline@@Tests/InstallMCPServer.wlt:1640,1-1645,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`serverConverter[ "ClaudeDesktop" ],
    Identity,
    SameTest -> SameQ,
    TestID   -> "ServerConverter-Default@@Tests/InstallMCPServer.wlt:1647,1-1652,2"
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
    TestID   -> "ResolveMCPServerName-BuiltInServer@@Tests/InstallMCPServer.wlt:1657,1-1664,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installMCPServerName = "CustomKey" },
        Wolfram`AgentTools`InstallMCPServer`Private`resolveMCPServerName @ MCPServerObject[ "WolframLanguage" ]
    ],
    "CustomKey",
    SameTest -> Equal,
    TestID   -> "ResolveMCPServerName-OptionOverride@@Tests/InstallMCPServer.wlt:1666,1-1673,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installMCPServerName = Automatic },
        Wolfram`AgentTools`InstallMCPServer`Private`resolveMCPServerName @ MCPServerObject[ "Wolfram" ]
    ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "ResolveMCPServerName-WolframServer@@Tests/InstallMCPServer.wlt:1675,1-1682,2"
]

(* :!CodeAnalysis::EndBlock:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Paclet-Qualified Server Names*)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

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
    TestID   -> "InstallPacletServer-MockPacletSetup@@Tests/InstallMCPServer.wlt:1698,1-1705,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*MCPServerName property for paclet server*)
VerificationTest[
    MCPServerObject[ "MockMCPPacletTest/TestServer" ][ "MCPServerName" ],
    "TestServer",
    SameTest -> Equal,
    TestID   -> "MCPServerName-PacletServerProperty@@Tests/InstallMCPServer.wlt:1710,1-1715,2"
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
    TestID   -> "ResolveMCPServerName-PacletServerShortName@@Tests/InstallMCPServer.wlt:1720,1-1727,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ensurePacletForInstall - already installed*)
VerificationTest[
    Wolfram`AgentTools`Common`ensurePacletForInstall[ "MockMCPPacletTest/TestServer" ],
    _PacletObject,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-EnsurePacletAlreadyInstalled@@Tests/InstallMCPServer.wlt:1732,1-1737,2"
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
    TestID   -> "InstallPacletServer-EnsurePacletThreeSegment@@Tests/InstallMCPServer.wlt:1742,1-1749,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install paclet-qualified server to config file*)
VerificationTest[
    $pacletConfigFile = testConfigFile[];
    $pacletInstallResult = InstallMCPServer[ $pacletConfigFile, "MockMCPPacletTest/TestServer", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-Install@@Tests/InstallMCPServer.wlt:1754,1-1760,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config file created*)
VerificationTest[
    FileExistsQ @ $pacletConfigFile,
    True,
    SameTest -> Equal,
    TestID   -> "InstallPacletServer-ConfigFileExists@@Tests/InstallMCPServer.wlt:1765,1-1770,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config file has correct server name as key*)
VerificationTest[
    $pacletConfigJSON = Import[ $pacletConfigFile, "RawJSON" ];
    KeyExistsQ[ $pacletConfigJSON[ "mcpServers" ], "TestServer" ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallPacletServer-ConfigHasServerName@@Tests/InstallMCPServer.wlt:1775,1-1781,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config server entry has correct MCP_SERVER_NAME env var*)
VerificationTest[
    $pacletConfigJSON[ "mcpServers", "TestServer", "env", "MCP_SERVER_NAME" ],
    "MockMCPPacletTest/TestServer",
    SameTest -> Equal,
    TestID   -> "InstallPacletServer-ConfigEnvServerName@@Tests/InstallMCPServer.wlt:1786,1-1791,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Uninstall paclet server*)
VerificationTest[
    UninstallMCPServer[ $pacletConfigFile, MCPServerObject[ "MockMCPPacletTest/TestServer" ] ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-Uninstall@@Tests/InstallMCPServer.wlt:1796,1-1801,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config no longer has server after uninstall*)
VerificationTest[
    updatedJSON = Import[ $pacletConfigFile, "RawJSON" ];
    KeyExistsQ[ updatedJSON[ "mcpServers" ], "TestServer" ],
    False,
    SameTest -> Equal,
    TestID   -> "InstallPacletServer-VerifyUninstall@@Tests/InstallMCPServer.wlt:1806,1-1812,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install result contains MCPServerObject*)
VerificationTest[
    $pacletInstallResult2 = InstallMCPServer[ $pacletConfigFile, "MockMCPPacletTest/TestServer", "VerifyLLMKit" -> False ];
    $pacletInstallResult2[ "MCPServerObject" ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-ResultHasMCPServerObject@@Tests/InstallMCPServer.wlt:1817,1-1823,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validatePacletServerDefinitions - no error for valid paclet server*)
VerificationTest[
    obj = MCPServerObject[ "MockMCPPacletTest/TestServer" ];
    Wolfram`AgentTools`InstallMCPServer`Private`validatePacletServerDefinitions @ obj,
    Null,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-ValidateDefinitionsValid@@Tests/InstallMCPServer.wlt:1828,1-1834,2"
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
    TestID   -> "InstallPacletServer-ValidateDefinitionsNoOp@@Tests/InstallMCPServer.wlt:1839,1-1850,2"
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
    TestID   -> "InstallPacletServer-ValidateToolError@@Tests/InstallMCPServer.wlt:1855,1-1870,2"
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
    TestID   -> "InstallPacletServer-ValidatePromptError@@Tests/InstallMCPServer.wlt:1875,1-1890,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup*)
VerificationTest[
    cleanupTestFiles @ $pacletConfigFile;
    Wolfram`AgentTools`Common`clearPacletDefinitionCache[ ],
    <| |>,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-Cleanup@@Tests/InstallMCPServer.wlt:1895,1-1901,2"
]

(* :!CodeAnalysis::EndBlock:: *)

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
    TestID   -> "MCPServerName-BuiltInUsesWolframKey-Install@@Tests/InstallMCPServer.wlt:1912,1-1918,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    KeyExistsQ[ jsonContent[ "mcpServers" ], "Wolfram" ] &&
    ! KeyExistsQ[ jsonContent[ "mcpServers" ], "WolframLanguage" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-BuiltInUsesWolframKey-Verify@@Tests/InstallMCPServer.wlt:1920,1-1927,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Second built-in overwrites first under shared key*)
VerificationTest[
    InstallMCPServer[ mcpNameConfigFile, "WolframAlpha", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "MCPServerName-SecondBuiltInOverwrites-Install@@Tests/InstallMCPServer.wlt:1932,1-1937,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    Length[ Keys[ jsonContent[ "mcpServers" ] ] ] === 1 &&
    KeyExistsQ[ jsonContent[ "mcpServers" ], "Wolfram" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-SecondBuiltInOverwrites-Verify@@Tests/InstallMCPServer.wlt:1939,1-1946,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Uninstall built-in removes "Wolfram" key*)
VerificationTest[
    UninstallMCPServer[ mcpNameConfigFile, "WolframAlpha" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "MCPServerName-UninstallBuiltIn@@Tests/InstallMCPServer.wlt:1951,1-1956,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    ! KeyExistsQ[ jsonContent[ "mcpServers" ], "Wolfram" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-UninstallBuiltIn-Verify@@Tests/InstallMCPServer.wlt:1958,1-1964,2"
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
    TestID   -> "MCPServerName-CustomServerUsesName-Install@@Tests/InstallMCPServer.wlt:1969,1-1979,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    KeyExistsQ[ jsonContent[ "mcpServers" ], mcpNameCustomName ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-CustomServerUsesName-Verify@@Tests/InstallMCPServer.wlt:1981,1-1987,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*MCPServerName option override*)
VerificationTest[
    InstallMCPServer[ mcpNameConfigFile, "WolframLanguage", "MCPServerName" -> "WolframDev", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "MCPServerName-OptionOverride-Install@@Tests/InstallMCPServer.wlt:1992,1-1997,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    KeyExistsQ[ jsonContent[ "mcpServers" ], "WolframDev" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-OptionOverride-Verify@@Tests/InstallMCPServer.wlt:1999,1-2005,2"
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
    TestID   -> "MCPServerName-TwoBuiltInWithOverrides-Install@@Tests/InstallMCPServer.wlt:2010,1-2017,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile2, "RawJSON" ];
    KeyExistsQ[ jsonContent[ "mcpServers" ], "WolframBasic" ] &&
    KeyExistsQ[ jsonContent[ "mcpServers" ], "WolframDev2" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-TwoBuiltInWithOverrides-Verify@@Tests/InstallMCPServer.wlt:2019,1-2026,2"
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
    TestID   -> "MCPServerName-StaleRecordClearing-Setup@@Tests/InstallMCPServer.wlt:2031,1-2039,2"
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
    TestID   -> "MCPServerName-StaleRecordClearing-Verify@@Tests/InstallMCPServer.wlt:2041,1-2051,2"
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
    TestID   -> "MCPServerName-Cleanup@@Tests/InstallMCPServer.wlt:2056,1-2065,2"
]