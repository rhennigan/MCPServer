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
        result = Wolfram`AgentTools`Common`projectInstallLocation[ "Codex", path ];
        FileNameTake[ First @ result, -2 ]
    ],
    FileNameJoin @ { ".codex", "config.toml" },
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-Codex@@Tests/InstallMCPServer.wlt:436,1-445,2"
]

VerificationTest[
    Module[ { path, result },
        path = FileNameJoin @ { $TemporaryDirectory, "TestProject" };
        result = Wolfram`AgentTools`Common`projectInstallLocation[ "VisualStudioCode", path ];
        FileNameTake[ First @ result, -2 ]
    ],
    FileNameJoin @ { ".vscode", "mcp.json" },
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-VisualStudioCode@@Tests/InstallMCPServer.wlt:447,1-456,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`catchAlways[
        Wolfram`AgentTools`Common`projectInstallLocation[ "ClaudeCode", Symbol[ "xyz" ] ]
    ],
    _Failure,
    { AgentTools::InvalidProjectDirectory },
    SameTest -> MatchQ,
    TestID   -> "ProjectInstallLocation-InvalidDirectory-Symbol@@Tests/InstallMCPServer.wlt:458,1-466,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`catchAlways[
        Wolfram`AgentTools`Common`projectInstallLocation[ "ClaudeCode", 123 ]
    ],
    _Failure,
    { AgentTools::InvalidProjectDirectory },
    SameTest -> MatchQ,
    TestID   -> "ProjectInstallLocation-InvalidDirectory-Integer@@Tests/InstallMCPServer.wlt:468,1-476,2"
]

VerificationTest[
    InstallMCPServer[ { "ClaudeCode", Symbol[ "xyz" ] } ],
    _Failure,
    { InstallMCPServer::InvalidProjectDirectory },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-InvalidProjectDirectory@@Tests/InstallMCPServer.wlt:478,1-484,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeDevelopmentArgs*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`makeDevelopmentArgs[ DirectoryName[ $TestFileName, 2 ] ],
    { "-script", _String? FileExistsQ, "-noinit", "-noprompt" },
    SameTest -> MatchQ,
    TestID   -> "MakeDevelopmentArgs-ValidPath@@Tests/InstallMCPServer.wlt:489,1-494,2"
]

VerificationTest[
    configFile = testConfigFile[];
    invalidPath = FileNameJoin @ { $TemporaryDirectory, CreateUUID[ "InvalidPath-" ] };
    InstallMCPServer[ configFile, "DevelopmentMode" -> invalidPath, "VerifyLLMKit" -> False ],
    Failure[ "InstallMCPServer::DevelopmentModeUnavailable", _ ],
    { InstallMCPServer::DevelopmentModeUnavailable },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-InvalidPath@@Tests/InstallMCPServer.wlt:496,1-504,2"
]

VerificationTest[
    configFile = testConfigFile[];
    InstallMCPServer[ configFile, "DevelopmentMode" -> InvalidValue, "VerifyLLMKit" -> False ],
    Failure[ "InstallMCPServer::InvalidDevelopmentMode", _ ],
    { InstallMCPServer::InvalidDevelopmentMode },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-InvalidValue@@Tests/InstallMCPServer.wlt:506,1-513,2"
]

(* :!CodeAnalysis::EndBlock:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*DevelopmentMode Option*)
VerificationTest[
    MemberQ[ Keys @ Options @ InstallMCPServer, "DevelopmentMode" ],
    True,
    TestID -> "DevelopmentMode-OptionExists@@Tests/InstallMCPServer.wlt:520,1-524,2"
]

VerificationTest[
    configFile = testConfigFile[];
    InstallMCPServer[ configFile, "DevelopmentMode" -> DirectoryName[ $TestFileName, 2 ], "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-Success@@Tests/InstallMCPServer.wlt:526,1-532,2"
]

VerificationTest[
    json = Developer`ReadRawJSONFile @ First @ configFile;
    json[ "mcpServers", "Wolfram", "args" ],
    { "-script", _String, "-noinit", "-noprompt" },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-Args@@Tests/InstallMCPServer.wlt:534,1-540,2"
]

VerificationTest[
    cleanupTestFiles[ configFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-Cleanup@@Tests/InstallMCPServer.wlt:542,1-547,2"
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
    TestID   -> "InstallLocation-Codex-Windows@@Tests/InstallMCPServer.wlt:564,1-569,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Codex", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Codex-MacOSX@@Tests/InstallMCPServer.wlt:571,1-576,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Codex", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Codex-Unix@@Tests/InstallMCPServer.wlt:578,1-583,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "OpenAICodex" ],
    "Codex",
    SameTest -> Equal,
    TestID   -> "ToInstallName-OpenAICodex@@Tests/InstallMCPServer.wlt:588,1-593,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Codex" ],
    "Codex",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Codex@@Tests/InstallMCPServer.wlt:595,1-600,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Codex" ],
    "Codex CLI",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Codex@@Tests/InstallMCPServer.wlt:602,1-607,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*TOML Parsing and Writing*)
VerificationTest[
    toml = Wolfram`AgentTools`Common`readTOMLFile @ FileNameJoin @ { $TemporaryDirectory, "nonexistent.toml" };
    toml[ "Data" ],
    <| |>,
    SameTest -> Equal,
    TestID   -> "ReadTOMLFile-NonExistent@@Tests/InstallMCPServer.wlt:612,1-618,2"
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
    TestID   -> "ReadTOMLFile-BasicParsing@@Tests/InstallMCPServer.wlt:620,1-633,2"
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
    TestID   -> "ReadTOMLFile-MCPServerSection@@Tests/InstallMCPServer.wlt:635,1-653,2"
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
    TestID   -> "InstallMCPServer-Codex-Basic@@Tests/InstallMCPServer.wlt:658,1-665,2"
]

VerificationTest[
    FileExistsQ[ codexConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-FileExists@@Tests/InstallMCPServer.wlt:667,1-672,2"
]

VerificationTest[
    Module[ { content, toml },
        content = ReadString @ codexConfigFile;
        toml = Wolfram`AgentTools`Common`readTOMLFile @ codexConfigFile;
        KeyExistsQ[ toml[ "Data", "mcp_servers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-VerifyContent@@Tests/InstallMCPServer.wlt:674,1-683,2"
]

VerificationTest[
    Module[ { content },
        content = ReadString @ codexConfigFile;
        StringContainsQ[ content, "[mcp_servers.Wolfram]" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-VerifySectionFormat@@Tests/InstallMCPServer.wlt:685,1-693,2"
]

VerificationTest[
    (* Use file-based uninstall - TOML format is auto-detected from .toml extension *)
    uninstallResult = UninstallMCPServer[ codexConfigFile, "WolframLanguage" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Codex-Basic@@Tests/InstallMCPServer.wlt:695,1-701,2"
]

VerificationTest[
    Module[ { toml },
        toml = Wolfram`AgentTools`Common`readTOMLFile @ codexConfigFile;
        ! KeyExistsQ[ Lookup[ toml[ "Data" ], "mcp_servers", <| |> ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Codex-VerifyRemoval@@Tests/InstallMCPServer.wlt:703,1-711,2"
]

VerificationTest[
    cleanupTestFiles[ codexConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-Cleanup@@Tests/InstallMCPServer.wlt:713,1-718,2"
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
    TestID   -> "InstallMCPServer-Codex-MultipleServers@@Tests/InstallMCPServer.wlt:723,1-731,2"
]

VerificationTest[
    Module[ { toml, mcpServers },
        toml = Wolfram`AgentTools`Common`readTOMLFile @ codexConfigFile;
        mcpServers = Lookup[ toml[ "Data" ], "mcp_servers", <| |> ];
        KeyExistsQ[ mcpServers, "Wolfram" ] && Length[ Keys @ mcpServers ] === 1
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-VerifyMultipleBuiltInShareKey@@Tests/InstallMCPServer.wlt:733,1-742,2"
]

VerificationTest[
    cleanupTestFiles[ codexConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-MultipleServers-Cleanup@@Tests/InstallMCPServer.wlt:744,1-749,2"
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
    TestID   -> "InstallMCPServer-Codex-PreserveExisting@@Tests/InstallMCPServer.wlt:754,1-766,2"
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
    TestID   -> "InstallMCPServer-Codex-VerifyPreserved@@Tests/InstallMCPServer.wlt:768,1-778,2"
]

VerificationTest[
    cleanupTestFiles[ codexConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-PreserveExisting-Cleanup@@Tests/InstallMCPServer.wlt:780,1-785,2"
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
    TestID   -> "ConvertToCodexFormat-Basic@@Tests/InstallMCPServer.wlt:790,1-804,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`convertToCodexFormat @ <|
        "command" -> "wolfram"
    |>,
    <| "command" -> "wolfram", "enabled" -> True |>,
    SameTest -> Equal,
    TestID   -> "ConvertToCodexFormat-MinimalConfig@@Tests/InstallMCPServer.wlt:806,1-813,2"
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
    TestID   -> "InstallMCPServer-Codex-ProjectInstall@@Tests/InstallMCPServer.wlt:818,1-829,2"
]

VerificationTest[
    FileExistsQ @ codexProjectConfigFile,
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-ProjectConfigExists@@Tests/InstallMCPServer.wlt:831,1-836,2"
]

VerificationTest[
    Module[ { toml },
        toml = Wolfram`AgentTools`Common`readTOMLFile @ codexProjectConfigFile;
        KeyExistsQ[ Lookup[ toml[ "Data" ], "mcp_servers", <| |> ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-ProjectVerifyContent@@Tests/InstallMCPServer.wlt:838,1-846,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ { "Codex", codexProjectDir }, "WolframLanguage" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Codex-ProjectInstall@@Tests/InstallMCPServer.wlt:848,1-853,2"
]

VerificationTest[
    Module[ { toml },
        toml = Wolfram`AgentTools`Common`readTOMLFile @ codexProjectConfigFile;
        ! KeyExistsQ[ Lookup[ toml[ "Data" ], "mcp_servers", <| |> ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Codex-ProjectVerifyRemoval@@Tests/InstallMCPServer.wlt:855,1-863,2"
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
    TestID   -> "InstallMCPServer-Codex-ProjectCleanup@@Tests/InstallMCPServer.wlt:865,1-877,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Goose (YAML) Support*)

(* Helper function for YAML test files *)
testYAMLFile = Function[
    File @ FileNameJoin @ { $TemporaryDirectory, StringJoin[ "mcp_test_config_", CreateUUID[ ], ".yaml" ] }
];

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for Goose*)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Goose", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Goose-Windows@@Tests/InstallMCPServer.wlt:894,1-899,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Goose", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Goose-MacOSX@@Tests/InstallMCPServer.wlt:901,1-906,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Goose", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Goose-Unix@@Tests/InstallMCPServer.wlt:908,1-913,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Display Name*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Goose" ],
    "Goose",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Goose@@Tests/InstallMCPServer.wlt:918,1-923,2"
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
    TestID   -> "ConvertToGooseFormat-Basic@@Tests/InstallMCPServer.wlt:928,1-944,2"
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
    TestID   -> "ConvertToGooseFormat-MinimalConfig@@Tests/InstallMCPServer.wlt:946,1-958,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Goose Install/Uninstall*)
VerificationTest[
    gooseConfigFile = testYAMLFile[ ];
    installResult = InstallMCPServer[ gooseConfigFile, "WolframLanguage", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Goose-Basic@@Tests/InstallMCPServer.wlt:963,1-969,2"
]

VerificationTest[
    FileExistsQ @ gooseConfigFile,
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Goose-FileExists@@Tests/InstallMCPServer.wlt:971,1-976,2"
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
    TestID   -> "InstallMCPServer-Goose-VerifyContent@@Tests/InstallMCPServer.wlt:978,1-988,2"
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
    TestID   -> "InstallMCPServer-Goose-VerifyAllFields@@Tests/InstallMCPServer.wlt:990,1-1002,2"
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
    TestID   -> "InstallMCPServer-Goose-VerifyFieldValues@@Tests/InstallMCPServer.wlt:1004,1-1016,2"
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
    TestID   -> "InstallMCPServer-Goose-VerifyLiteralYAML@@Tests/InstallMCPServer.wlt:1018,1-1028,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ gooseConfigFile, "WolframLanguage" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Goose-Basic@@Tests/InstallMCPServer.wlt:1030,1-1035,2"
]

VerificationTest[
    Module[ { yaml },
        yaml = Wolfram`AgentTools`Common`importYAML @ gooseConfigFile;
        ! KeyExistsQ[ Lookup[ yaml, "extensions", <| |> ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Goose-VerifyRemoval@@Tests/InstallMCPServer.wlt:1037,1-1045,2"
]

VerificationTest[
    cleanupTestFiles[ gooseConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Goose-Cleanup@@Tests/InstallMCPServer.wlt:1047,1-1052,2"
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
    TestID   -> "InstallMCPServer-Goose-MultipleServers@@Tests/InstallMCPServer.wlt:1057,1-1064,2"
]

VerificationTest[
    Module[ { yaml, extensions },
        yaml = Wolfram`AgentTools`Common`importYAML @ gooseConfigFile;
        extensions = Lookup[ yaml, "extensions", <| |> ];
        KeyExistsQ[ extensions, "Wolfram" ] && Length[ Keys @ extensions ] === 1
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Goose-VerifyMultipleBuiltInShareKey@@Tests/InstallMCPServer.wlt:1066,1-1075,2"
]

VerificationTest[
    cleanupTestFiles[ gooseConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Goose-MultipleServers-Cleanup@@Tests/InstallMCPServer.wlt:1077,1-1082,2"
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
    TestID   -> "InstallMCPServer-Goose-PreserveExisting@@Tests/InstallMCPServer.wlt:1087,1-1101,2"
]

VerificationTest[
    Module[ { yaml, extensions },
        yaml = Wolfram`AgentTools`Common`importYAML @ gooseConfigFile;
        extensions = Lookup[ yaml, "extensions", <| |> ];
        KeyExistsQ[ extensions, "other" ] && KeyExistsQ[ extensions, "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Goose-VerifyPreserved@@Tests/InstallMCPServer.wlt:1103,1-1112,2"
]

VerificationTest[
    cleanupTestFiles[ gooseConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Goose-PreserveExisting-Cleanup@@Tests/InstallMCPServer.wlt:1114,1-1119,2"
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
    TestID   -> "InstallMCPServer-Goose-RefusesUnparseableYAML@@Tests/InstallMCPServer.wlt:1124,1-1137,2"
]

VerificationTest[
    Module[ { content },
        content = ReadString @ First @ gooseConfigFile;
        (* The file must NOT have been overwritten *)
        StringContainsQ[ content, "bad-indent" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Goose-PreservesUnparseableYAML@@Tests/InstallMCPServer.wlt:1139,1-1148,2"
]

VerificationTest[
    cleanupTestFiles[ gooseConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Goose-RefusesUnparseableYAML-Cleanup@@Tests/InstallMCPServer.wlt:1150,1-1155,2"
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
    TestID   -> "UninstallMCPServer-Goose-RefusesUnparseableYAML@@Tests/InstallMCPServer.wlt:1160,1-1172,2"
]

VerificationTest[
    Module[ { content },
        content = ReadString @ First @ gooseConfigFile;
        (* The file must NOT have been overwritten *)
        StringContainsQ[ content, "bad-indent" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Goose-PreservesUnparseableYAML@@Tests/InstallMCPServer.wlt:1174,1-1183,2"
]

VerificationTest[
    cleanupTestFiles[ gooseConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Goose-RefusesUnparseableYAML-Cleanup@@Tests/InstallMCPServer.wlt:1185,1-1190,2"
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
    TestID   -> "InstallMCPServer-Goose-NoProjectSupport@@Tests/InstallMCPServer.wlt:1195,1-1205,2"
]

(* :!CodeAnalysis::EndBlock:: *)

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
    TestID   -> "InstallLocation-CopilotCLI-Windows@@Tests/InstallMCPServer.wlt:1216,1-1221,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "CopilotCLI", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-CopilotCLI-MacOSX@@Tests/InstallMCPServer.wlt:1223,1-1228,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "CopilotCLI", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-CopilotCLI-Unix@@Tests/InstallMCPServer.wlt:1230,1-1235,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Copilot" ],
    "CopilotCLI",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Copilot@@Tests/InstallMCPServer.wlt:1240,1-1245,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "CopilotCLI" ],
    "CopilotCLI",
    SameTest -> Equal,
    TestID   -> "ToInstallName-CopilotCLI@@Tests/InstallMCPServer.wlt:1247,1-1252,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "CopilotCLI" ],
    "Copilot CLI",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-CopilotCLI@@Tests/InstallMCPServer.wlt:1254,1-1259,2"
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
    TestID   -> "ConvertToCopilotCLIFormat-Basic@@Tests/InstallMCPServer.wlt:1264,1-1278,2"
]

VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToCopilotCLIFormat @ <|
        "command" -> "wolfram"
    |>,
    <| "command" -> "wolfram", "tools" -> { "*" } |>,
    SameTest -> Equal,
    TestID   -> "ConvertToCopilotCLIFormat-MinimalConfig@@Tests/InstallMCPServer.wlt:1280,1-1287,2"
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
    TestID   -> "InstallLocation-Windsurf-Windows@@Tests/InstallMCPServer.wlt:1296,1-1301,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Windsurf", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Windsurf-MacOSX@@Tests/InstallMCPServer.wlt:1303,1-1308,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Windsurf", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Windsurf-Unix@@Tests/InstallMCPServer.wlt:1310,1-1315,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Codeium" ],
    "Windsurf",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Codeium@@Tests/InstallMCPServer.wlt:1320,1-1325,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Windsurf" ],
    "Windsurf",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Windsurf@@Tests/InstallMCPServer.wlt:1327,1-1332,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Windsurf" ],
    "Windsurf",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Windsurf@@Tests/InstallMCPServer.wlt:1334,1-1339,2"
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
    TestID   -> "InstallLocation-Cline-Windows@@Tests/InstallMCPServer.wlt:1348,1-1353,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Cline", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Cline-MacOSX@@Tests/InstallMCPServer.wlt:1355,1-1360,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Cline", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Cline-Unix@@Tests/InstallMCPServer.wlt:1362,1-1367,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Cline" ],
    "Cline",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Cline@@Tests/InstallMCPServer.wlt:1372,1-1377,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Cline" ],
    "Cline",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Cline@@Tests/InstallMCPServer.wlt:1379,1-1384,2"
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
    TestID   -> "ConvertToClineFormat-Basic@@Tests/InstallMCPServer.wlt:1389,1-1404,2"
]

VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToClineFormat @ <|
        "command" -> "wolfram"
    |>,
    <| "command" -> "wolfram", "disabled" -> False, "autoApprove" -> { } |>,
    SameTest -> Equal,
    TestID   -> "ConvertToClineFormat-MinimalConfig@@Tests/InstallMCPServer.wlt:1406,1-1413,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cline Install and Uninstall*)
VerificationTest[
    clineConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ clineConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "Cline" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Cline-Basic@@Tests/InstallMCPServer.wlt:1418,1-1424,2"
]

VerificationTest[
    FileExistsQ[ clineConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Cline-FileExists@@Tests/InstallMCPServer.wlt:1426,1-1431,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ clineConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Cline-VerifyContent@@Tests/InstallMCPServer.wlt:1433,1-1441,2"
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
    TestID   -> "InstallMCPServer-Cline-VerifyClineFields@@Tests/InstallMCPServer.wlt:1443,1-1453,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ clineConfigFile, "WolframLanguage", "ApplicationName" -> "Cline" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Cline-Basic@@Tests/InstallMCPServer.wlt:1455,1-1460,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ clineConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && ! KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Cline-VerifyRemoval@@Tests/InstallMCPServer.wlt:1462,1-1470,2"
]

VerificationTest[
    cleanupTestFiles[ clineConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Cline-Cleanup@@Tests/InstallMCPServer.wlt:1472,1-1477,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Windsurf Install and Uninstall*)
VerificationTest[
    windsurfConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ windsurfConfigFile, "WolframLanguage", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Windsurf-Basic@@Tests/InstallMCPServer.wlt:1482,1-1488,2"
]

VerificationTest[
    FileExistsQ[ windsurfConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Windsurf-FileExists@@Tests/InstallMCPServer.wlt:1490,1-1495,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ windsurfConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Windsurf-VerifyContent@@Tests/InstallMCPServer.wlt:1497,1-1505,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ windsurfConfigFile, "WolframLanguage" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Windsurf-Basic@@Tests/InstallMCPServer.wlt:1507,1-1512,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ windsurfConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && ! KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Windsurf-VerifyRemoval@@Tests/InstallMCPServer.wlt:1514,1-1522,2"
]

VerificationTest[
    cleanupTestFiles[ windsurfConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Windsurf-Cleanup@@Tests/InstallMCPServer.wlt:1524,1-1529,2"
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
    TestID   -> "InstallLocation-AugmentCode-Windows@@Tests/InstallMCPServer.wlt:1538,1-1543,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AugmentCode", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AugmentCode-MacOSX@@Tests/InstallMCPServer.wlt:1545,1-1550,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AugmentCode", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AugmentCode-Unix@@Tests/InstallMCPServer.wlt:1552,1-1557,2"
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
    TestID   -> "InstallLocation-AugmentCode-PathShape@@Tests/InstallMCPServer.wlt:1560,1-1569,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "AugmentCode" ],
    "AugmentCode",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AugmentCode@@Tests/InstallMCPServer.wlt:1574,1-1579,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Auggie" ],
    "AugmentCode",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Auggie@@Tests/InstallMCPServer.wlt:1581,1-1586,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Augment" ],
    "AugmentCode",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Augment@@Tests/InstallMCPServer.wlt:1588,1-1593,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "AugmentCode" ],
    "Augment Code",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-AugmentCode@@Tests/InstallMCPServer.wlt:1595,1-1600,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*AugmentCode Install and Uninstall*)
VerificationTest[
    augmentConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ augmentConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "AugmentCode" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AugmentCode-Basic@@Tests/InstallMCPServer.wlt:1605,1-1611,2"
]

VerificationTest[
    FileExistsQ[ augmentConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AugmentCode-FileExists@@Tests/InstallMCPServer.wlt:1613,1-1618,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ augmentConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AugmentCode-VerifyContent@@Tests/InstallMCPServer.wlt:1620,1-1628,2"
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
    TestID   -> "InstallMCPServer-AugmentCode-StandardFormat@@Tests/InstallMCPServer.wlt:1632,1-1644,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ augmentConfigFile, "WolframLanguage", "ApplicationName" -> "AugmentCode" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-AugmentCode-Basic@@Tests/InstallMCPServer.wlt:1646,1-1651,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ augmentConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && ! KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-AugmentCode-VerifyRemoval@@Tests/InstallMCPServer.wlt:1653,1-1661,2"
]

VerificationTest[
    cleanupTestFiles[ augmentConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AugmentCode-Cleanup@@Tests/InstallMCPServer.wlt:1663,1-1668,2"
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
    TestID   -> "ConvertToAugmentCodeFormat-NonWindows@@Tests/InstallMCPServer.wlt:1675,1-1691,2"
]

(* Non-Windows with a space-containing command: still unchanged *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToAugmentCodeFormat[
        <| "command" -> "/Applications/Wolfram Desktop.app/Contents/MacOS/wolfram" |>,
        "MacOSX"
    ],
    <| "command" -> "/Applications/Wolfram Desktop.app/Contents/MacOS/wolfram" |>,
    SameTest -> Equal,
    TestID   -> "ConvertToAugmentCodeFormat-NonWindows-WithSpaces@@Tests/InstallMCPServer.wlt:1694,1-1702,2"
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
    TestID   -> "ConvertToAugmentCodeFormat-Windows-NoSpaces@@Tests/InstallMCPServer.wlt:1705,1-1719,2"
]

(* Missing command: converter should not error *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToAugmentCodeFormat[
        <| "args" -> { "-run", "test" } |>,
        "Windows"
    ],
    <| "args" -> { "-run", "test" } |>,
    SameTest -> Equal,
    TestID   -> "ConvertToAugmentCodeFormat-MissingCommand@@Tests/InstallMCPServer.wlt:1722,1-1730,2"
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
    TestID   -> "ConvertToAugmentCodeFormat-Windows-NonExistentPath@@Tests/InstallMCPServer.wlt:1734,1-1742,2"
]

(* 1-arg form dispatches to 2-arg form using $OperatingSystem *)
VerificationTest[
    Wolfram`AgentTools`SupportedClients`Private`convertToAugmentCodeFormat @ <|
        "command" -> "/no/spaces/here"
    |>,
    <| "command" -> "/no/spaces/here" |>,
    SameTest -> Equal,
    TestID   -> "ConvertToAugmentCodeFormat-OneArgForm@@Tests/InstallMCPServer.wlt:1745,1-1752,2"
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
    TestID   -> "InstallLocation-AugmentCodeIDE-Windows@@Tests/InstallMCPServer.wlt:1761,1-1766,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AugmentCodeIDE", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AugmentCodeIDE-MacOSX@@Tests/InstallMCPServer.wlt:1768,1-1773,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AugmentCodeIDE", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AugmentCodeIDE-Unix@@Tests/InstallMCPServer.wlt:1775,1-1780,2"
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
    TestID   -> "InstallLocation-AugmentCodeIDE-PathShape@@Tests/InstallMCPServer.wlt:1783,1-1792,2"
]

(* Install locations for AugmentCode (CLI) and AugmentCodeIDE must differ *)
VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AugmentCode", $OperatingSystem ]
        =!= Wolfram`AgentTools`Common`installLocation[ "AugmentCodeIDE", $OperatingSystem ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallLocation-AugmentCode-vs-AugmentCodeIDE-Distinct@@Tests/InstallMCPServer.wlt:1795,1-1801,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "AugmentCodeIDE" ],
    "AugmentCodeIDE",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AugmentCodeIDE@@Tests/InstallMCPServer.wlt:1806,1-1811,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "AugmentIDE" ],
    "AugmentCodeIDE",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AugmentIDE@@Tests/InstallMCPServer.wlt:1813,1-1818,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "AuggieIDE" ],
    "AugmentCodeIDE",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AuggieIDE@@Tests/InstallMCPServer.wlt:1820,1-1825,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "AugmentCodeIDE" ],
    "Augment Code IDE",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-AugmentCodeIDE@@Tests/InstallMCPServer.wlt:1827,1-1832,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*AugmentCodeIDE Install and Uninstall*)
VerificationTest[
    augmentIDEConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ augmentIDEConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "AugmentCodeIDE" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AugmentCodeIDE-Basic@@Tests/InstallMCPServer.wlt:1837,1-1843,2"
]

VerificationTest[
    FileExistsQ[ augmentIDEConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AugmentCodeIDE-FileExists@@Tests/InstallMCPServer.wlt:1845,1-1850,2"
]

(* The file root is a JSON array, not an object *)
VerificationTest[
    Module[ { content },
        content = Import[ augmentIDEConfigFile, "RawJSON" ];
        ListQ @ content
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AugmentCodeIDE-RootIsArray@@Tests/InstallMCPServer.wlt:1853,1-1861,2"
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
    TestID   -> "InstallMCPServer-AugmentCodeIDE-EntryShape@@Tests/InstallMCPServer.wlt:1864,1-1876,2"
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
    TestID   -> "InstallMCPServer-AugmentCodeIDE-Idempotent@@Tests/InstallMCPServer.wlt:1879,1-1889,2"
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
    TestID   -> "InstallMCPServer-AugmentCodeIDE-MultiServer@@Tests/InstallMCPServer.wlt:1892,1-1902,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ augmentIDEConfigFile, "WolframLanguage", "ApplicationName" -> "AugmentCodeIDE" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-AugmentCodeIDE-Basic@@Tests/InstallMCPServer.wlt:1904,1-1909,2"
]

VerificationTest[
    Module[ { content, matches },
        content = Import[ augmentIDEConfigFile, "RawJSON" ];
        matches = Select[ content, MatchQ[ #, KeyValuePattern @ { "name" -> "Wolfram" } ] & ];
        Length @ matches
    ],
    0,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-AugmentCodeIDE-VerifyRemoval@@Tests/InstallMCPServer.wlt:1911,1-1920,2"
]

(* Uninstalling the other entry as well leaves an empty array, not a removed file *)
VerificationTest[
    UninstallMCPServer[ augmentIDEConfigFile, "WolframAlpha", "ApplicationName" -> "AugmentCodeIDE", "MCPServerName" -> "WolframAlphaExtra" ];
    Import[ augmentIDEConfigFile, "RawJSON" ],
    { },
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-AugmentCodeIDE-EmptiesToArray@@Tests/InstallMCPServer.wlt:1923,1-1929,2"
]

(* Uninstalling a server that isn't installed returns NotInstalled, not an error *)
VerificationTest[
    UninstallMCPServer[ augmentIDEConfigFile, "WolframLanguage", "ApplicationName" -> "AugmentCodeIDE" ],
    Missing[ "NotInstalled", _ ],
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-AugmentCodeIDE-NotInstalled@@Tests/InstallMCPServer.wlt:1932,1-1937,2"
]

VerificationTest[
    cleanupTestFiles[ augmentIDEConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AugmentCodeIDE-Cleanup@@Tests/InstallMCPServer.wlt:1939,1-1944,2"
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
    TestID   -> "ConvertToAugmentCodeIDEFormat-Basic@@Tests/InstallMCPServer.wlt:1951,1-1968,2"
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
    TestID   -> "ConvertToAugmentCodeIDEFormat-NonWindows-WithSpaces@@Tests/InstallMCPServer.wlt:1971,1-1982,2"
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
    TestID   -> "ConvertToAugmentCodeIDEFormat-Windows-NoSpaces@@Tests/InstallMCPServer.wlt:1985,1-1997,2"
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
    TestID   -> "ConvertToAugmentCodeIDEFormat-MissingCommand@@Tests/InstallMCPServer.wlt:2000,1-2011,2"
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
    TestID   -> "ConvertToAugmentCodeIDEFormat-NoNameField@@Tests/InstallMCPServer.wlt:2014,1-2025,2"
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
    TestID   -> "ReadExistingAugmentCodeIDEConfig-NonExistent@@Tests/InstallMCPServer.wlt:2032,1-2038,2"
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
    TestID   -> "ReadExistingAugmentCodeIDEConfig-EmptyFile@@Tests/InstallMCPServer.wlt:2041,1-2053,2"
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
    TestID   -> "ReadExistingAugmentCodeIDEConfig-ValidArray@@Tests/InstallMCPServer.wlt:2056,1-2069,2"
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
    TestID   -> "ReadExistingAugmentCodeIDEConfig-NonListRoot@@Tests/InstallMCPServer.wlt:2074,1-2087,2"
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
    TestID   -> "GuessClientName-AugmentCodeIDE-PathMatch@@Tests/InstallMCPServer.wlt:2096,1-2114,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$SupportedMCPClients metadata for AugmentCodeIDE*)
VerificationTest[
    $SupportedMCPClients[ "AugmentCodeIDE", "DisplayName" ],
    "Augment Code IDE",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeIDEDisplayName@@Tests/InstallMCPServer.wlt:2119,1-2124,2"
]

VerificationTest[
    Sort @ $SupportedMCPClients[ "AugmentCodeIDE", "Aliases" ],
    Sort @ { "AugmentIDE", "AuggieIDE" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeIDEAliases@@Tests/InstallMCPServer.wlt:2126,1-2131,2"
]

VerificationTest[
    $SupportedMCPClients[ "AugmentCodeIDE", "ConfigFormat" ],
    "JSON",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeIDEConfigFormat@@Tests/InstallMCPServer.wlt:2133,1-2138,2"
]

(* Empty ConfigKey signals the root of the file is an array, not a keyed object *)
VerificationTest[
    $SupportedMCPClients[ "AugmentCodeIDE", "ConfigKey" ],
    { },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeIDEConfigKey@@Tests/InstallMCPServer.wlt:2141,1-2146,2"
]

VerificationTest[
    $SupportedMCPClients[ "AugmentCodeIDE", "ProjectSupport" ],
    False,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeIDEProjectSupport@@Tests/InstallMCPServer.wlt:2148,1-2153,2"
]

VerificationTest[
    StringStartsQ[ $SupportedMCPClients[ "AugmentCodeIDE", "URL" ], "https://" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeIDEURL@@Tests/InstallMCPServer.wlt:2155,1-2160,2"
]

(* AugmentCode (CLI) and AugmentCodeIDE (VS Code) must be distinct entries with distinct display names *)
VerificationTest[
    $SupportedMCPClients[ "AugmentCode", "DisplayName" ]
        =!= $SupportedMCPClients[ "AugmentCodeIDE", "DisplayName" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCode-vs-AugmentCodeIDE-Distinct@@Tests/InstallMCPServer.wlt:2163,1-2169,2"
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
    TestID   -> "ToWindowsShortPath-NonExistent@@Tests/InstallMCPServer.wlt:2176,1-2183,2"
]

(* Space-free existing path on Windows: result equals the input (no short form needed).
   On non-Windows, the file probably exists and the function still returns a string. *)
VerificationTest[
    With[ { result = Wolfram`AgentTools`SupportedClients`Private`toWindowsShortPath @ $TemporaryDirectory },
        StringQ @ result
    ],
    True,
    SameTest -> Equal,
    TestID   -> "ToWindowsShortPath-ReturnsString@@Tests/InstallMCPServer.wlt:2187,1-2194,2"
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
        TestID   -> "ToWindowsShortPath-WolframExe@@Tests/InstallMCPServer.wlt:2199,5-2209,6"
    ]
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$SupportedMCPClients metadata for AugmentCode*)
VerificationTest[
    $SupportedMCPClients[ "AugmentCode", "DisplayName" ],
    "Augment Code",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeDisplayName@@Tests/InstallMCPServer.wlt:2215,1-2220,2"
]

VerificationTest[
    Sort @ $SupportedMCPClients[ "AugmentCode", "Aliases" ],
    Sort @ { "Auggie", "Augment" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeAliases@@Tests/InstallMCPServer.wlt:2222,1-2227,2"
]

VerificationTest[
    $SupportedMCPClients[ "AugmentCode", "ConfigFormat" ],
    "JSON",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeConfigFormat@@Tests/InstallMCPServer.wlt:2229,1-2234,2"
]

VerificationTest[
    $SupportedMCPClients[ "AugmentCode", "ConfigKey" ],
    { "mcpServers" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeConfigKey@@Tests/InstallMCPServer.wlt:2236,1-2241,2"
]

VerificationTest[
    $SupportedMCPClients[ "AugmentCode", "ProjectSupport" ],
    False,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeProjectSupport@@Tests/InstallMCPServer.wlt:2243,1-2248,2"
]

VerificationTest[
    StringStartsQ[ $SupportedMCPClients[ "AugmentCode", "URL" ], "https://" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AugmentCodeURL@@Tests/InstallMCPServer.wlt:2250,1-2255,2"
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
    TestID   -> "InstallLocation-Zed-Windows@@Tests/InstallMCPServer.wlt:2264,1-2269,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Zed", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Zed-MacOSX@@Tests/InstallMCPServer.wlt:2271,1-2276,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Zed", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Zed-Unix@@Tests/InstallMCPServer.wlt:2278,1-2283,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Name Normalization*)
VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Zed" ],
    "Zed",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Zed@@Tests/InstallMCPServer.wlt:2288,1-2293,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Zed" ],
    "Zed",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Zed@@Tests/InstallMCPServer.wlt:2295,1-2300,2"
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
    TestID   -> "ProjectInstallLocation-Zed@@Tests/InstallMCPServer.wlt:2305,1-2314,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Zed Install and Uninstall*)
VerificationTest[
    zedConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ zedConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "Zed" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Zed-Basic@@Tests/InstallMCPServer.wlt:2319,1-2325,2"
]

VerificationTest[
    FileExistsQ[ zedConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Zed-FileExists@@Tests/InstallMCPServer.wlt:2327,1-2332,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ zedConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "context_servers" ] && KeyExistsQ[ content[ "context_servers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Zed-VerifyContent@@Tests/InstallMCPServer.wlt:2334,1-2342,2"
]

VerificationTest[
    Module[ { content, server },
        content = Import[ zedConfigFile, "RawJSON" ];
        server = content[ "context_servers", "Wolfram" ];
        KeyExistsQ[ server, "command" ] && KeyExistsQ[ server, "args" ] && KeyExistsQ[ server, "env" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Zed-VerifyServerFields@@Tests/InstallMCPServer.wlt:2344,1-2353,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ zedConfigFile, "WolframLanguage", "ApplicationName" -> "Zed" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Zed-Basic@@Tests/InstallMCPServer.wlt:2355,1-2360,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ zedConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "context_servers" ] && ! KeyExistsQ[ content[ "context_servers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Zed-VerifyRemoval@@Tests/InstallMCPServer.wlt:2362,1-2370,2"
]

VerificationTest[
    cleanupTestFiles[ zedConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Zed-Cleanup@@Tests/InstallMCPServer.wlt:2372,1-2377,2"
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
    TestID   -> "InstallMCPServer-Zed-PreserveExisting@@Tests/InstallMCPServer.wlt:2382,1-2389,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ zedConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "theme" ] && content[ "theme" ] === "One Dark" &&
        KeyExistsQ[ content[ "context_servers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Zed-VerifyPreserved@@Tests/InstallMCPServer.wlt:2391,1-2400,2"
]

VerificationTest[
    cleanupTestFiles[ zedConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Zed-PreserveExisting-Cleanup@@Tests/InstallMCPServer.wlt:2402,1-2407,2"
]

(* :!CodeAnalysis::EndBlock:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Kiro Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for Kiro*)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Kiro", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Kiro-Windows@@Tests/InstallMCPServer.wlt:2422,1-2427,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Kiro", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Kiro-MacOSX@@Tests/InstallMCPServer.wlt:2429,1-2434,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "Kiro", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Kiro-Unix@@Tests/InstallMCPServer.wlt:2436,1-2441,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "Kiro" ],
    "Kiro",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Kiro@@Tests/InstallMCPServer.wlt:2443,1-2448,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Kiro" ],
    "Kiro",
    SameTest -> Equal,
    TestID   -> "ToInstallName-Kiro@@Tests/InstallMCPServer.wlt:2450,1-2455,2"
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
    TestID   -> "ProjectInstallLocation-Kiro@@Tests/InstallMCPServer.wlt:2460,1-2469,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Kiro Install and Uninstall*)
VerificationTest[
    kiroConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ kiroConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "Kiro" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Kiro-Basic@@Tests/InstallMCPServer.wlt:2474,1-2480,2"
]

VerificationTest[
    FileExistsQ[ kiroConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Kiro-FileExists@@Tests/InstallMCPServer.wlt:2482,1-2487,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ kiroConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Kiro-VerifyContent@@Tests/InstallMCPServer.wlt:2489,1-2497,2"
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
    TestID   -> "InstallMCPServer-Kiro-VerifyKiroFields@@Tests/InstallMCPServer.wlt:2499,1-2509,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ kiroConfigFile, "WolframLanguage", "ApplicationName" -> "Kiro" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Kiro-Basic@@Tests/InstallMCPServer.wlt:2511,1-2516,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ kiroConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && ! KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Kiro-VerifyRemoval@@Tests/InstallMCPServer.wlt:2518,1-2526,2"
]

VerificationTest[
    cleanupTestFiles[ kiroConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Kiro-Cleanup@@Tests/InstallMCPServer.wlt:2528,1-2533,2"
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
    TestID   -> "InstallMCPServer-Kiro-PreserveExisting@@Tests/InstallMCPServer.wlt:2538,1-2545,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ kiroConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "customSetting" ] && content[ "customSetting" ] === True &&
        KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Kiro-VerifyPreserved@@Tests/InstallMCPServer.wlt:2547,1-2556,2"
]

VerificationTest[
    cleanupTestFiles[ kiroConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Kiro-PreserveExisting-Cleanup@@Tests/InstallMCPServer.wlt:2558,1-2563,2"
]

(* :!CodeAnalysis::EndBlock:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Amazon Q Developer Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Location for Amazon Q Developer*)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AmazonQ", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AmazonQ-Windows@@Tests/InstallMCPServer.wlt:2578,1-2583,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AmazonQ", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AmazonQ-MacOSX@@Tests/InstallMCPServer.wlt:2585,1-2590,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`installLocation[ "AmazonQ", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-AmazonQ-Unix@@Tests/InstallMCPServer.wlt:2592,1-2597,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`installDisplayName[ "AmazonQ" ],
    "Amazon Q Developer",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-AmazonQ@@Tests/InstallMCPServer.wlt:2599,1-2604,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "AmazonQ" ],
    "AmazonQ",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AmazonQ@@Tests/InstallMCPServer.wlt:2606,1-2611,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "AmazonQDeveloper" ],
    "AmazonQ",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AmazonQ-Alias-AmazonQDeveloper@@Tests/InstallMCPServer.wlt:2613,1-2618,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "Q" ],
    "AmazonQ",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AmazonQ-Alias-Q@@Tests/InstallMCPServer.wlt:2620,1-2625,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`toInstallName[ "QDeveloper" ],
    "AmazonQ",
    SameTest -> Equal,
    TestID   -> "ToInstallName-AmazonQ-Alias-QDeveloper@@Tests/InstallMCPServer.wlt:2627,1-2632,2"
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
    TestID   -> "ProjectInstallLocation-AmazonQ@@Tests/InstallMCPServer.wlt:2637,1-2646,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Amazon Q Install and Uninstall*)
VerificationTest[
    amazonQConfigFile = testConfigFile[];
    installResult = InstallMCPServer[ amazonQConfigFile, "WolframLanguage", "VerifyLLMKit" -> False, "ApplicationName" -> "AmazonQ" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AmazonQ-Basic@@Tests/InstallMCPServer.wlt:2651,1-2657,2"
]

VerificationTest[
    FileExistsQ[ amazonQConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AmazonQ-FileExists@@Tests/InstallMCPServer.wlt:2659,1-2664,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ amazonQConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AmazonQ-VerifyContent@@Tests/InstallMCPServer.wlt:2666,1-2674,2"
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
    TestID   -> "InstallMCPServer-AmazonQ-VerifyFields@@Tests/InstallMCPServer.wlt:2676,1-2687,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[ amazonQConfigFile, "WolframLanguage", "ApplicationName" -> "AmazonQ" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-AmazonQ-Basic@@Tests/InstallMCPServer.wlt:2689,1-2694,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ amazonQConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "mcpServers" ] && ! KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-AmazonQ-VerifyRemoval@@Tests/InstallMCPServer.wlt:2696,1-2704,2"
]

VerificationTest[
    cleanupTestFiles[ amazonQConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AmazonQ-Cleanup@@Tests/InstallMCPServer.wlt:2706,1-2711,2"
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
    TestID   -> "InstallMCPServer-AmazonQ-PreserveExisting@@Tests/InstallMCPServer.wlt:2716,1-2723,2"
]

VerificationTest[
    Module[ { content },
        content = Import[ amazonQConfigFile, "RawJSON" ];
        KeyExistsQ[ content, "customSetting" ] && content[ "customSetting" ] === True &&
        KeyExistsQ[ content[ "mcpServers" ], "Wolfram" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-AmazonQ-VerifyPreserved@@Tests/InstallMCPServer.wlt:2725,1-2734,2"
]

VerificationTest[
    cleanupTestFiles[ amazonQConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-AmazonQ-PreserveExisting-Cleanup@@Tests/InstallMCPServer.wlt:2736,1-2741,2"
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
    TestID   -> "InstallMCPServer-AmazonQ-AutoDetect-Project@@Tests/InstallMCPServer.wlt:2746,1-2757,2"
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
    TestID   -> "InstallMCPServer-AmazonQ-AutoDetect-Global@@Tests/InstallMCPServer.wlt:2759,1-2770,2"
]

(* :!CodeAnalysis::EndBlock:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*$SupportedMCPClients*)
VerificationTest[
    $SupportedMCPClients,
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "SupportedMCPClients-ReturnsAssociation@@Tests/InstallMCPServer.wlt:2777,1-2782,2"
]

VerificationTest[
    Length @ $SupportedMCPClients,
    17,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-Has17Clients@@Tests/InstallMCPServer.wlt:2784,1-2789,2"
]

VerificationTest[
    Keys @ $SupportedMCPClients,
    { "AmazonQ", "Antigravity", "AugmentCode", "AugmentCodeIDE", "ClaudeCode", "ClaudeDesktop", "Cline", "Codex", "CopilotCLI", "Cursor", "GeminiCLI", "Goose", "Kiro", "OpenCode", "VisualStudioCode", "Windsurf", "Zed" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-KeysSorted@@Tests/InstallMCPServer.wlt:2791,1-2796,2"
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
    TestID   -> "SupportedMCPClients-AllHaveRequiredKeys@@Tests/InstallMCPServer.wlt:2798,1-2815,2"
]

VerificationTest[
    $SupportedMCPClients[ "ClaudeDesktop", "DisplayName" ],
    "Claude Desktop",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ClaudeDesktopDisplayName@@Tests/InstallMCPServer.wlt:2817,1-2822,2"
]

VerificationTest[
    $SupportedMCPClients[ "ClaudeDesktop", "Aliases" ],
    { "Claude" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ClaudeDesktopAliases@@Tests/InstallMCPServer.wlt:2824,1-2829,2"
]

VerificationTest[
    $SupportedMCPClients[ "Codex", "ConfigFormat" ],
    "TOML",
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-CodexConfigFormat@@Tests/InstallMCPServer.wlt:2831,1-2836,2"
]

VerificationTest[
    $SupportedMCPClients[ "Codex", "ProjectSupport" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-CodexProjectSupport@@Tests/InstallMCPServer.wlt:2838,1-2843,2"
]

VerificationTest[
    $SupportedMCPClients[ "ClaudeCode", "ProjectSupport" ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ClaudeCodeProjectSupport@@Tests/InstallMCPServer.wlt:2845,1-2850,2"
]

VerificationTest[
    $SupportedMCPClients[ "Zed", "ConfigKey" ],
    { "context_servers" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-ZedConfigKey@@Tests/InstallMCPServer.wlt:2852,1-2857,2"
]

VerificationTest[
    $SupportedMCPClients[ "VisualStudioCode", "ConfigKey" ],
    { "servers" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-VSCodeConfigKey@@Tests/InstallMCPServer.wlt:2859,1-2864,2"
]

VerificationTest[
    $SupportedMCPClients[ "OpenCode", "ConfigKey" ],
    { "mcp" },
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-OpenCodeConfigKey@@Tests/InstallMCPServer.wlt:2866,1-2871,2"
]

VerificationTest[
    AllTrue[ Values @ $SupportedMCPClients, StringQ[ #[ "URL" ] ] && StringStartsQ[ #[ "URL" ], "https://" ] & ],
    True,
    SameTest -> Equal,
    TestID   -> "SupportedMCPClients-AllHaveValidURLs@@Tests/InstallMCPServer.wlt:2873,1-2878,2"
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
    TestID   -> "GuessClientNameFromJSON-Zed@@Tests/InstallMCPServer.wlt:2908,1-2918,2"
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
    TestID   -> "GuessClientNameFromJSON-VisualStudioCode-Legacy@@Tests/InstallMCPServer.wlt:2921,1-2931,2"
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
    TestID   -> "GuessClientNameFromJSON-VisualStudioCode@@Tests/InstallMCPServer.wlt:2934,1-2945,2"
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
    TestID   -> "GuessClientNameFromJSON-GenericServersKey@@Tests/InstallMCPServer.wlt:2948,1-2958,2"
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
    TestID   -> "GuessClientNameFromJSON-OpenCode@@Tests/InstallMCPServer.wlt:2961,1-2971,2"
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
    TestID   -> "GuessClientNameFromJSON-CopilotCLI@@Tests/InstallMCPServer.wlt:2974,1-2984,2"
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
    TestID   -> "GuessClientNameFromJSON-Cline@@Tests/InstallMCPServer.wlt:2987,1-2997,2"
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
    TestID   -> "GuessClientNameFromJSON-Ambiguous@@Tests/InstallMCPServer.wlt:3000,1-3010,2"
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
    TestID   -> "GuessClientNameFromJSON-EmptyJSON@@Tests/InstallMCPServer.wlt:3013,1-3023,2"
]

(* Non-existent file -> None *)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`guessClientNameFromJSON @
        FileNameJoin @ { $TemporaryDirectory, "nonexistent_" <> CreateUUID[] <> ".json" },
    None,
    SameTest -> Equal,
    TestID   -> "GuessClientNameFromJSON-NonExistentFile@@Tests/InstallMCPServer.wlt:3026,1-3032,2"
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
    TestID   -> "ConfigKeyPath-ClaudeDesktop@@Tests/InstallMCPServer.wlt:3037,1-3044,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = "VisualStudioCode" },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ ]
    ],
    { "servers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-VSCode@@Tests/InstallMCPServer.wlt:3046,1-3053,2"
]

(* VS Code with mcp.json file: uses new key path *)
VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = "VisualStudioCode" },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath @
            File @ FileNameJoin @ { $TemporaryDirectory, "mcp.json" }
    ],
    { "servers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-VSCode-MCPJson@@Tests/InstallMCPServer.wlt:3056,1-3064,2"
]

(* VS Code with legacy settings.json: uses old nested key path *)
VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = "VisualStudioCode" },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath @
            File @ FileNameJoin @ { $TemporaryDirectory, "settings.json" }
    ],
    { "mcp", "servers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-VSCode-LegacySettings@@Tests/InstallMCPServer.wlt:3067,1-3075,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = "Zed" },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ ]
    ],
    { "context_servers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-Zed@@Tests/InstallMCPServer.wlt:3077,1-3084,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = "OpenCode" },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ ]
    ],
    { "mcp" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-OpenCode@@Tests/InstallMCPServer.wlt:3086,1-3093,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ "UnknownClient" ],
    { "mcpServers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-UnknownFallback@@Tests/InstallMCPServer.wlt:3095,1-3100,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installClientName = None },
        Wolfram`AgentTools`InstallMCPServer`Private`configKeyPath[ ]
    ],
    { "mcpServers" },
    SameTest -> Equal,
    TestID   -> "ConfigKeyPath-NoneFallback@@Tests/InstallMCPServer.wlt:3102,1-3109,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*emptyConfigForPath*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`emptyConfigForPath @ { "mcpServers" },
    <| "mcpServers" -> <| |> |>,
    SameTest -> Equal,
    TestID   -> "EmptyConfigForPath-SingleKey@@Tests/InstallMCPServer.wlt:3114,1-3119,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`emptyConfigForPath @ { "mcp", "servers" },
    <| "mcp" -> <| "servers" -> <| |> |> |>,
    SameTest -> Equal,
    TestID   -> "EmptyConfigForPath-NestedKeys@@Tests/InstallMCPServer.wlt:3121,1-3126,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`emptyConfigForPath @ { },
    <| |>,
    SameTest -> Equal,
    TestID   -> "EmptyConfigForPath-EmptyPath@@Tests/InstallMCPServer.wlt:3128,1-3133,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ensureNestedKey*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[ <| "other" -> 1 |>, { "mcpServers" } ],
    <| "other" -> 1, "mcpServers" -> <| |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-AddMissing@@Tests/InstallMCPServer.wlt:3138,1-3143,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[
        <| "mcpServers" -> <| "existing" -> "data" |> |>,
        { "mcpServers" }
    ],
    <| "mcpServers" -> <| "existing" -> "data" |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-PreserveExisting@@Tests/InstallMCPServer.wlt:3145,1-3153,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[
        <| "theme" -> "dark" |>,
        { "mcp", "servers" }
    ],
    <| "theme" -> "dark", "mcp" -> <| "servers" -> <| |> |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-DeepNesting@@Tests/InstallMCPServer.wlt:3155,1-3163,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[
        <| "mcp" -> <| "existing" -> 1 |> |>,
        { "mcp", "servers" }
    ],
    <| "mcp" -> <| "existing" -> 1, "servers" -> <| |> |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-PartiallyExisting@@Tests/InstallMCPServer.wlt:3165,1-3173,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`ensureNestedKey[ "notAssoc", { "mcpServers" } ],
    <| "mcpServers" -> <| |> |>,
    SameTest -> Equal,
    TestID   -> "EnsureNestedKey-NonAssocInput@@Tests/InstallMCPServer.wlt:3175,1-3180,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*serverConverter*)
VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`serverConverter[ "OpenCode" ],
    Wolfram`AgentTools`SupportedClients`Private`convertToOpenCodeFormat,
    SameTest -> SameQ,
    TestID   -> "ServerConverter-OpenCode@@Tests/InstallMCPServer.wlt:3185,1-3190,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`serverConverter[ "CopilotCLI" ],
    Wolfram`AgentTools`SupportedClients`Private`convertToCopilotCLIFormat,
    SameTest -> SameQ,
    TestID   -> "ServerConverter-CopilotCLI@@Tests/InstallMCPServer.wlt:3192,1-3197,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`serverConverter[ "Cline" ],
    Wolfram`AgentTools`SupportedClients`Private`convertToClineFormat,
    SameTest -> SameQ,
    TestID   -> "ServerConverter-Cline@@Tests/InstallMCPServer.wlt:3199,1-3204,2"
]

VerificationTest[
    Wolfram`AgentTools`InstallMCPServer`Private`serverConverter[ "ClaudeDesktop" ],
    Identity,
    SameTest -> SameQ,
    TestID   -> "ServerConverter-Default@@Tests/InstallMCPServer.wlt:3206,1-3211,2"
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
    TestID   -> "ResolveMCPServerName-BuiltInServer@@Tests/InstallMCPServer.wlt:3216,1-3223,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installMCPServerName = "CustomKey" },
        Wolfram`AgentTools`InstallMCPServer`Private`resolveMCPServerName @ MCPServerObject[ "WolframLanguage" ]
    ],
    "CustomKey",
    SameTest -> Equal,
    TestID   -> "ResolveMCPServerName-OptionOverride@@Tests/InstallMCPServer.wlt:3225,1-3232,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`InstallMCPServer`Private`$installMCPServerName = Automatic },
        Wolfram`AgentTools`InstallMCPServer`Private`resolveMCPServerName @ MCPServerObject[ "Wolfram" ]
    ],
    "Wolfram",
    SameTest -> Equal,
    TestID   -> "ResolveMCPServerName-WolframServer@@Tests/InstallMCPServer.wlt:3234,1-3241,2"
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
    TestID   -> "InstallPacletServer-MockPacletSetup@@Tests/InstallMCPServer.wlt:3257,1-3264,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*MCPServerName property for paclet server*)
VerificationTest[
    MCPServerObject[ "MockMCPPacletTest/TestServer" ][ "MCPServerName" ],
    "TestServer",
    SameTest -> Equal,
    TestID   -> "MCPServerName-PacletServerProperty@@Tests/InstallMCPServer.wlt:3269,1-3274,2"
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
    TestID   -> "ResolveMCPServerName-PacletServerShortName@@Tests/InstallMCPServer.wlt:3279,1-3286,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ensurePacletForInstall - already installed*)
VerificationTest[
    Wolfram`AgentTools`Common`ensurePacletForInstall[ "MockMCPPacletTest/TestServer" ],
    _PacletObject,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-EnsurePacletAlreadyInstalled@@Tests/InstallMCPServer.wlt:3291,1-3296,2"
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
    TestID   -> "InstallPacletServer-EnsurePacletThreeSegment@@Tests/InstallMCPServer.wlt:3301,1-3308,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install paclet-qualified server to config file*)
VerificationTest[
    $pacletConfigFile = testConfigFile[];
    $pacletInstallResult = InstallMCPServer[ $pacletConfigFile, "MockMCPPacletTest/TestServer", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-Install@@Tests/InstallMCPServer.wlt:3313,1-3319,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config file created*)
VerificationTest[
    FileExistsQ @ $pacletConfigFile,
    True,
    SameTest -> Equal,
    TestID   -> "InstallPacletServer-ConfigFileExists@@Tests/InstallMCPServer.wlt:3324,1-3329,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config file has correct server name as key*)
VerificationTest[
    $pacletConfigJSON = Import[ $pacletConfigFile, "RawJSON" ];
    KeyExistsQ[ $pacletConfigJSON[ "mcpServers" ], "TestServer" ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallPacletServer-ConfigHasServerName@@Tests/InstallMCPServer.wlt:3334,1-3340,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config server entry has correct MCP_SERVER_NAME env var*)
VerificationTest[
    $pacletConfigJSON[ "mcpServers", "TestServer", "env", "MCP_SERVER_NAME" ],
    "MockMCPPacletTest/TestServer",
    SameTest -> Equal,
    TestID   -> "InstallPacletServer-ConfigEnvServerName@@Tests/InstallMCPServer.wlt:3345,1-3350,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Uninstall paclet server*)
VerificationTest[
    UninstallMCPServer[ $pacletConfigFile, MCPServerObject[ "MockMCPPacletTest/TestServer" ] ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-Uninstall@@Tests/InstallMCPServer.wlt:3355,1-3360,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Config no longer has server after uninstall*)
VerificationTest[
    updatedJSON = Import[ $pacletConfigFile, "RawJSON" ];
    KeyExistsQ[ updatedJSON[ "mcpServers" ], "TestServer" ],
    False,
    SameTest -> Equal,
    TestID   -> "InstallPacletServer-VerifyUninstall@@Tests/InstallMCPServer.wlt:3365,1-3371,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install result contains MCPServerObject*)
VerificationTest[
    $pacletInstallResult2 = InstallMCPServer[ $pacletConfigFile, "MockMCPPacletTest/TestServer", "VerifyLLMKit" -> False ];
    $pacletInstallResult2[ "MCPServerObject" ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-ResultHasMCPServerObject@@Tests/InstallMCPServer.wlt:3376,1-3382,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validatePacletServerDefinitions - no error for valid paclet server*)
VerificationTest[
    obj = MCPServerObject[ "MockMCPPacletTest/TestServer" ];
    Wolfram`AgentTools`InstallMCPServer`Private`validatePacletServerDefinitions @ obj,
    Null,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-ValidateDefinitionsValid@@Tests/InstallMCPServer.wlt:3387,1-3393,2"
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
    TestID   -> "InstallPacletServer-ValidateDefinitionsNoOp@@Tests/InstallMCPServer.wlt:3398,1-3409,2"
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
    TestID   -> "InstallPacletServer-ValidateToolError@@Tests/InstallMCPServer.wlt:3414,1-3429,2"
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
    TestID   -> "InstallPacletServer-ValidatePromptError@@Tests/InstallMCPServer.wlt:3434,1-3449,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup*)
VerificationTest[
    cleanupTestFiles @ $pacletConfigFile;
    Wolfram`AgentTools`Common`clearPacletDefinitionCache[ ],
    <| |>,
    SameTest -> MatchQ,
    TestID   -> "InstallPacletServer-Cleanup@@Tests/InstallMCPServer.wlt:3454,1-3460,2"
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
    TestID   -> "MCPServerName-BuiltInUsesWolframKey-Install@@Tests/InstallMCPServer.wlt:3471,1-3477,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    KeyExistsQ[ jsonContent[ "mcpServers" ], "Wolfram" ] &&
    ! KeyExistsQ[ jsonContent[ "mcpServers" ], "WolframLanguage" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-BuiltInUsesWolframKey-Verify@@Tests/InstallMCPServer.wlt:3479,1-3486,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Second built-in overwrites first under shared key*)
VerificationTest[
    InstallMCPServer[ mcpNameConfigFile, "WolframAlpha", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "MCPServerName-SecondBuiltInOverwrites-Install@@Tests/InstallMCPServer.wlt:3491,1-3496,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    Length[ Keys[ jsonContent[ "mcpServers" ] ] ] === 1 &&
    KeyExistsQ[ jsonContent[ "mcpServers" ], "Wolfram" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-SecondBuiltInOverwrites-Verify@@Tests/InstallMCPServer.wlt:3498,1-3505,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Uninstall built-in removes "Wolfram" key*)
VerificationTest[
    UninstallMCPServer[ mcpNameConfigFile, "WolframAlpha" ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "MCPServerName-UninstallBuiltIn@@Tests/InstallMCPServer.wlt:3510,1-3515,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    ! KeyExistsQ[ jsonContent[ "mcpServers" ], "Wolfram" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-UninstallBuiltIn-Verify@@Tests/InstallMCPServer.wlt:3517,1-3523,2"
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
    TestID   -> "MCPServerName-CustomServerUsesName-Install@@Tests/InstallMCPServer.wlt:3528,1-3538,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    KeyExistsQ[ jsonContent[ "mcpServers" ], mcpNameCustomName ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-CustomServerUsesName-Verify@@Tests/InstallMCPServer.wlt:3540,1-3546,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*MCPServerName option override*)
VerificationTest[
    InstallMCPServer[ mcpNameConfigFile, "WolframLanguage", "MCPServerName" -> "WolframDev", "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "MCPServerName-OptionOverride-Install@@Tests/InstallMCPServer.wlt:3551,1-3556,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile, "RawJSON" ];
    KeyExistsQ[ jsonContent[ "mcpServers" ], "WolframDev" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-OptionOverride-Verify@@Tests/InstallMCPServer.wlt:3558,1-3564,2"
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
    TestID   -> "MCPServerName-TwoBuiltInWithOverrides-Install@@Tests/InstallMCPServer.wlt:3569,1-3576,2"
]

VerificationTest[
    jsonContent = Import[ mcpNameConfigFile2, "RawJSON" ];
    KeyExistsQ[ jsonContent[ "mcpServers" ], "WolframBasic" ] &&
    KeyExistsQ[ jsonContent[ "mcpServers" ], "WolframDev2" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPServerName-TwoBuiltInWithOverrides-Verify@@Tests/InstallMCPServer.wlt:3578,1-3585,2"
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
    TestID   -> "MCPServerName-StaleRecordClearing-Setup@@Tests/InstallMCPServer.wlt:3590,1-3598,2"
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
    TestID   -> "MCPServerName-StaleRecordClearing-Verify@@Tests/InstallMCPServer.wlt:3600,1-3610,2"
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
    TestID   -> "MCPServerName-Cleanup@@Tests/InstallMCPServer.wlt:3615,1-3624,2"
]
