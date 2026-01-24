(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    If[ ! TrueQ @ Wolfram`MCPServerTests`$TestDefinitionsLoaded,
        Get @ FileNameJoin @ { DirectoryName[ $TestFileName ], "Common.wl" }
    ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/InstallMCPServer.wlt:4,1-11,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/InstallMCPServer.wlt:13,1-18,2"
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
    TestID   -> "InstallMCPServer-CreateTestServer@@Tests/InstallMCPServer.wlt:43,1-53,2"
]

VerificationTest[
    result = InstallMCPServer[configFile, server],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-FileLocation@@Tests/InstallMCPServer.wlt:55,1-60,2"
]

VerificationTest[
    FileExistsQ[configFile],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-ConfigFileExists@@Tests/InstallMCPServer.wlt:62,1-67,2"
]

VerificationTest[
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent, "mcpServers"] && KeyExistsQ[jsonContent["mcpServers"], name],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-VerifyConfigContent@@Tests/InstallMCPServer.wlt:69,1-75,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[configFile, server],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Uninstall@@Tests/InstallMCPServer.wlt:77,1-82,2"
]

VerificationTest[
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent, "mcpServers"] && !KeyExistsQ[jsonContent["mcpServers"], name],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-VerifyUninstall@@Tests/InstallMCPServer.wlt:84,1-90,2"
]

VerificationTest[
    DeleteObject[server];
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupTestServer@@Tests/InstallMCPServer.wlt:92,1-98,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install Predefined Server by Name*)
VerificationTest[
    configFile = testConfigFile[];
    installResult = InstallMCPServer[configFile, "WolframLanguage"],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-PredefinedServer@@Tests/InstallMCPServer.wlt:103,1-109,2"
]

VerificationTest[
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent, "mcpServers"] && KeyExistsQ[jsonContent["mcpServers"], "WolframLanguage"],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-VerifyPredefinedServer@@Tests/InstallMCPServer.wlt:111,1-117,2"
]

VerificationTest[
    uninstallResult = UninstallMCPServer[configFile, "WolframLanguage"],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-UninstallPredefinedServer@@Tests/InstallMCPServer.wlt:119,1-124,2"
]

VerificationTest[
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupPredefinedServer@@Tests/InstallMCPServer.wlt:126,1-131,2"
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
    TestID   -> "InstallMCPServer-MultipleServers@@Tests/InstallMCPServer.wlt:136,1-143,2"
]

VerificationTest[
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent["mcpServers"], "WolframAlpha"] &&
    KeyExistsQ[jsonContent["mcpServers"], "WolframLanguage"],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-VerifyMultipleServers@@Tests/InstallMCPServer.wlt:145,1-152,2"
]

VerificationTest[
    UninstallMCPServer[configFile];
    jsonContent = Import[configFile, "RawJSON"];
    jsonContent["mcpServers"] === <||>,
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-UninstallAll@@Tests/InstallMCPServer.wlt:154,1-161,2"
]

VerificationTest[
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupMultipleServers@@Tests/InstallMCPServer.wlt:163,1-168,2"
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
    TestID   -> "InstallMCPServer-WithEnvironment@@Tests/InstallMCPServer.wlt:173,1-183,2"
]

VerificationTest[
    jsonContent = Import[configFile, "RawJSON"];
    envVars = jsonContent["mcpServers"]["WolframLanguage"]["env"];
    KeyExistsQ[envVars, "TEST_VAR"] && envVars["TEST_VAR"] === "test_value",
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-VerifyEnvironmentVars@@Tests/InstallMCPServer.wlt:185,1-192,2"
]

VerificationTest[
    UninstallMCPServer[configFile, "WolframLanguage"];
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupEnvironment@@Tests/InstallMCPServer.wlt:194,1-200,2"
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
    TestID   -> "InstallMCPServer-FromAssociation@@Tests/InstallMCPServer.wlt:205,1-214,2"
]

VerificationTest[
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent, "mcpServers"] && KeyExistsQ[jsonContent["mcpServers"], name],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-VerifyAssociationServer@@Tests/InstallMCPServer.wlt:216,1-222,2"
]

VerificationTest[
    UninstallMCPServer[configFile, name];
    DeleteObject[server];
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupAssociation@@Tests/InstallMCPServer.wlt:224,1-231,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Named Client Installations*)
VerificationTest[
    (* Create a temporary .claude.json-like file with existing data *)
    configFile = testConfigFile[];
    Export[configFile, <|"numStartups" -> 1, "mcpServers" -> <||>|>, "JSON"];
    installResult = InstallMCPServer[configFile, "WolframLanguage"],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-ClaudeCodeLike@@Tests/InstallMCPServer.wlt:236,1-244,2"
]

VerificationTest[
    (* Verify the server was added and other data preserved *)
    jsonContent = Import[configFile, "RawJSON"];
    KeyExistsQ[jsonContent, "mcpServers"] &&
    KeyExistsQ[jsonContent["mcpServers"], "WolframLanguage"] &&
    KeyExistsQ[jsonContent, "numStartups"] &&
    jsonContent["numStartups"] === 1,
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-PreservesOtherData@@Tests/InstallMCPServer.wlt:246,1-256,2"
]

VerificationTest[
    (* Install a second server to verify multiple installations work *)
    installResult2 = InstallMCPServer[configFile, "WolframAlpha"];
    jsonContent = Import[configFile, "RawJSON"];
    Length[Keys[jsonContent["mcpServers"]]] === 2,
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-MultipleInClaudeCodeLike@@Tests/InstallMCPServer.wlt:258,1-266,2"
]

VerificationTest[
    UninstallMCPServer[configFile];
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupClaudeCodeLike@@Tests/InstallMCPServer.wlt:268,1-274,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Cases*)
VerificationTest[
    configFile = testConfigFile[];
    Export[configFile, "{\"invalidJSON\":true", "String"];
    InstallMCPServer[configFile, "WolframLanguage"],
    _Failure,
    {Developer`ReadRawJSONFile::jsonobjmissingsep, Developer`ReadRawJSONFile::jsonhintposandchar, InstallMCPServer::InvalidMCPConfiguration},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-InvalidJSON@@Tests/InstallMCPServer.wlt:279,1-287,2"
]

VerificationTest[
    configFile = testConfigFile[];
    Export[configFile, "{}", "JSON"];
    InstallMCPServer[configFile, "NonExistentServer"],
    _Failure,
    {InstallMCPServer::MCPServerNotFound},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-NonExistentServer@@Tests/InstallMCPServer.wlt:289,1-297,2"
]

VerificationTest[
    cleanupTestFiles[configFile],
    {Null},
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-CleanupErrorTests@@Tests/InstallMCPServer.wlt:299,1-304,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Install Location Resolution*)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`installLocation[ "Antigravity", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Antigravity-Windows@@Tests/InstallMCPServer.wlt:313,1-318,2"
]

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`installLocation[ "Antigravity", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Antigravity-MacOSX@@Tests/InstallMCPServer.wlt:320,1-325,2"
]

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`installLocation[ "Antigravity", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Antigravity-Unix@@Tests/InstallMCPServer.wlt:327,1-332,2"
]

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`installDisplayName[ "Antigravity" ],
    "Antigravity",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Antigravity@@Tests/InstallMCPServer.wlt:334,1-339,2"
]

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`toInstallName[ "GoogleAntigravity" ],
    "Antigravity",
    SameTest -> Equal,
    TestID   -> "ToInstallName-GoogleAntigravity@@Tests/InstallMCPServer.wlt:341,1-346,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*projectInstallLocation*)

(* Tests for project-scoped install locations *)
VerificationTest[
    Module[ { path, result },
        path = FileNameJoin @ { $TemporaryDirectory, "testproject" };
        result = Wolfram`MCPServer`InstallMCPServer`Private`projectInstallLocation[ "ClaudeCode", path ];
        FileNameTake[ First @ result, -1 ]
    ],
    ".mcp.json",
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-ClaudeCode@@Tests/InstallMCPServer.wlt:353,1-362,2"
]

VerificationTest[
    Module[ { result },
        result = Wolfram`MCPServer`InstallMCPServer`Private`projectInstallLocation[ "ClaudeCode", File[ "MCPServer" ] ];
        FileNameTake[ First @ result, -1 ]
    ],
    ".mcp.json",
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-ClaudeCode-FileWrapper@@Tests/InstallMCPServer.wlt:364,1-372,2"
]

VerificationTest[
    Module[ { path, result },
        path = FileNameJoin @ { $TemporaryDirectory, "testproject" };
        result = Wolfram`MCPServer`InstallMCPServer`Private`projectInstallLocation[ "OpenCode", path ];
        FileNameTake[ First @ result, -1 ]
    ],
    "opencode.json",
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-OpenCode@@Tests/InstallMCPServer.wlt:374,1-383,2"
]

VerificationTest[
    Module[ { path, result },
        path = FileNameJoin @ { $TemporaryDirectory, "testproject" };
        result = Wolfram`MCPServer`InstallMCPServer`Private`projectInstallLocation[ "VisualStudioCode", path ];
        FileNameTake[ First @ result, -2 ]
    ],
    FileNameJoin @ { ".vscode", "settings.json" },
    SameTest -> Equal,
    TestID   -> "ProjectInstallLocation-VisualStudioCode@@Tests/InstallMCPServer.wlt:385,1-394,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeDevelopmentArgs*)
VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`makeDevelopmentArgs[ DirectoryName[ $TestFileName, 2 ] ],
    { "-script", _String? FileExistsQ, "-noinit", "-noprompt" },
    SameTest -> MatchQ,
    TestID   -> "MakeDevelopmentArgs-ValidPath@@Tests/InstallMCPServer.wlt:399,1-404,2"
]

VerificationTest[
    configFile = testConfigFile[];
    invalidPath = FileNameJoin @ { $TemporaryDirectory, CreateUUID[ "InvalidPath-" ] };
    InstallMCPServer[ configFile, "DevelopmentMode" -> invalidPath, "VerifyLLMKit" -> False ],
    Failure[ "InstallMCPServer::DevelopmentModeUnavailable", _ ],
    { InstallMCPServer::DevelopmentModeUnavailable },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-InvalidPath@@Tests/InstallMCPServer.wlt:406,1-414,2"
]

VerificationTest[
    configFile = testConfigFile[];
    InstallMCPServer[ configFile, "DevelopmentMode" -> InvalidValue, "VerifyLLMKit" -> False ],
    Failure[ "InstallMCPServer::InvalidDevelopmentMode", _ ],
    { InstallMCPServer::InvalidDevelopmentMode },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-InvalidValue@@Tests/InstallMCPServer.wlt:416,1-423,2"
]

(* :!CodeAnalysis::EndBlock:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*DevelopmentMode Option*)
VerificationTest[
    MemberQ[ Keys @ Options @ InstallMCPServer, "DevelopmentMode" ],
    True,
    TestID -> "DevelopmentMode-OptionExists@@Tests/InstallMCPServer.wlt:430,1-434,2"
]

VerificationTest[
    configFile = testConfigFile[];
    InstallMCPServer[ configFile, "DevelopmentMode" -> DirectoryName[ $TestFileName, 2 ], "VerifyLLMKit" -> False ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-Success@@Tests/InstallMCPServer.wlt:436,1-442,2"
]

VerificationTest[
    json = Developer`ReadRawJSONFile @ First @ configFile;
    json[ "mcpServers", "Wolfram", "args" ],
    { "-script", _String, "-noinit", "-noprompt" },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-Args@@Tests/InstallMCPServer.wlt:444,1-450,2"
]

VerificationTest[
    cleanupTestFiles[ configFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-DevelopmentMode-Cleanup@@Tests/InstallMCPServer.wlt:452,1-457,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Codex Support*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*TOML Parsing*)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

VerificationTest[
    Wolfram`MCPServer`Files`Private`parseTOML[ "" ],
    <| |>,
    SameTest -> MatchQ,
    TestID   -> "ParseTOML-EmptyString@@Tests/InstallMCPServer.wlt:470,1-475,2"
]

VerificationTest[
    Wolfram`MCPServer`Files`Private`parseTOML[ "# This is a comment\n\n" ],
    <| |>,
    SameTest -> MatchQ,
    TestID   -> "ParseTOML-OnlyComments@@Tests/InstallMCPServer.wlt:477,1-482,2"
]

VerificationTest[
    Wolfram`MCPServer`Files`Private`parseTOML[ "key = \"value\"" ],
    <| "key" -> "value" |>,
    SameTest -> Equal,
    TestID   -> "ParseTOML-SimpleKeyValue@@Tests/InstallMCPServer.wlt:484,1-489,2"
]

VerificationTest[
    Wolfram`MCPServer`Files`Private`parseTOML[ "[section]\nkey = \"value\"" ],
    <| "section" -> <| "key" -> "value" |> |>,
    SameTest -> Equal,
    TestID   -> "ParseTOML-Section@@Tests/InstallMCPServer.wlt:491,1-496,2"
]

VerificationTest[
    Wolfram`MCPServer`Files`Private`parseTOML[ "[outer.inner]\nkey = \"value\"" ],
    <| "outer" -> <| "inner" -> <| "key" -> "value" |> |> |>,
    SameTest -> Equal,
    TestID   -> "ParseTOML-NestedSection@@Tests/InstallMCPServer.wlt:498,1-503,2"
]

VerificationTest[
    Wolfram`MCPServer`Files`Private`parseTOML[ "args = [\"a\", \"b\", \"c\"]" ],
    <| "args" -> { "a", "b", "c" } |>,
    SameTest -> Equal,
    TestID   -> "ParseTOML-StringArray@@Tests/InstallMCPServer.wlt:505,1-510,2"
]

VerificationTest[
    Wolfram`MCPServer`Files`Private`parseTOML[ "enabled = true\ndisabled = false" ],
    <| "enabled" -> True, "disabled" -> False |>,
    SameTest -> Equal,
    TestID   -> "ParseTOML-Booleans@@Tests/InstallMCPServer.wlt:512,1-517,2"
]

VerificationTest[
    Wolfram`MCPServer`Files`Private`parseTOML[ "count = 42\nnegative = -5" ],
    <| "count" -> 42, "negative" -> -5 |>,
    SameTest -> Equal,
    TestID   -> "ParseTOML-Integers@@Tests/InstallMCPServer.wlt:519,1-524,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*TOML Serialization*)

VerificationTest[
    Wolfram`MCPServer`Files`Private`serializeTOML[ <| |> ],
    "\n",
    SameTest -> Equal,
    TestID   -> "SerializeTOML-Empty@@Tests/InstallMCPServer.wlt:530,1-535,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Files`Private`serializeTOML[ <| "key" -> "value" |> ],
        "key = \"value\""
    ],
    True,
    SameTest -> Equal,
    TestID   -> "SerializeTOML-SimpleKeyValue@@Tests/InstallMCPServer.wlt:537,1-545,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Files`Private`serializeTOML[ <| "section" -> <| "key" -> "value" |> |> ],
        "[section]"
    ],
    True,
    SameTest -> Equal,
    TestID   -> "SerializeTOML-SectionHeader@@Tests/InstallMCPServer.wlt:547,1-555,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Files`Private`serializeTOML[ <| "args" -> { "a", "b" } |> ],
        "args = [\"a\", \"b\"]"
    ],
    True,
    SameTest -> Equal,
    TestID   -> "SerializeTOML-Array@@Tests/InstallMCPServer.wlt:557,1-565,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Files`Private`serializeTOML[ <| "flag" -> True |> ],
        "flag = true"
    ],
    True,
    SameTest -> Equal,
    TestID   -> "SerializeTOML-Boolean@@Tests/InstallMCPServer.wlt:567,1-575,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*TOML Round-Trip*)

VerificationTest[
    Module[ { original, serialized, parsed },
        original = <|
            "mcp_servers" -> <|
                "wolfram" -> <|
                    "command" -> "wolframscript",
                    "args" -> { "-run", "test", "-noinit" },
                    "env" -> <| "VAR" -> "value" |>
                |>
            |>
        |>;
        serialized = Wolfram`MCPServer`Files`Private`serializeTOML @ original;
        parsed = Wolfram`MCPServer`Files`Private`parseTOML @ serialized;
        parsed
    ],
    <| "mcp_servers" -> <| "wolfram" -> <| "command" -> "wolframscript", "args" -> { "-run", "test", "-noinit" }, "env" -> <| "VAR" -> "value" |> |> |> |>,
    SameTest -> Equal,
    TestID   -> "TOML-RoundTrip@@Tests/InstallMCPServer.wlt:581,1-599,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Codex Install Location*)

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`installLocation[ "Codex", "Windows" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Codex-Windows@@Tests/InstallMCPServer.wlt:605,1-610,2"
]

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`installLocation[ "Codex", "MacOSX" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Codex-MacOSX@@Tests/InstallMCPServer.wlt:612,1-617,2"
]

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`installLocation[ "Codex", "Unix" ],
    _File,
    SameTest -> MatchQ,
    TestID   -> "InstallLocation-Codex-Unix@@Tests/InstallMCPServer.wlt:619,1-624,2"
]

VerificationTest[
    StringEndsQ[ First @ Wolfram`MCPServer`InstallMCPServer`Private`installLocation[ "Codex", "Windows" ], "config.toml" ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallLocation-Codex-EndsWithTOML@@Tests/InstallMCPServer.wlt:626,1-631,2"
]

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`installDisplayName[ "Codex" ],
    "Codex",
    SameTest -> Equal,
    TestID   -> "InstallDisplayName-Codex@@Tests/InstallMCPServer.wlt:633,1-638,2"
]

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`toInstallName[ "codex" ],
    "Codex",
    SameTest -> Equal,
    TestID   -> "ToInstallName-codex@@Tests/InstallMCPServer.wlt:640,1-645,2"
]

VerificationTest[
    Wolfram`MCPServer`InstallMCPServer`Private`toInstallName[ "OpenAICodex" ],
    "Codex",
    SameTest -> Equal,
    TestID   -> "ToInstallName-OpenAICodex@@Tests/InstallMCPServer.wlt:647,1-652,2"
]

(* :!CodeAnalysis::EndBlock:: *)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Codex Install and Uninstall*)

(* Setup a temporary TOML file to use for testing Codex installations *)
testCodexConfigFile = Function[
    File @ FileNameJoin @ { $TemporaryDirectory, StringJoin["codex_test_config_", CreateUUID[], ".toml"] }
];

VerificationTest[
    codexConfigFile = testCodexConfigFile[];
    Block[ { Wolfram`MCPServer`InstallMCPServer`Private`$installName = "Codex" },
        InstallMCPServer[ codexConfigFile, "WolframLanguage" ]
    ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-Basic@@Tests/InstallMCPServer.wlt:665,1-673,2"
]

VerificationTest[
    FileExistsQ[ codexConfigFile ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-FileExists@@Tests/InstallMCPServer.wlt:675,1-680,2"
]

VerificationTest[
    Module[ { content, parsed },
        content = ReadString @ First @ codexConfigFile;
        parsed = Wolfram`MCPServer`Files`Private`parseTOML @ content;
        KeyExistsQ[ parsed, "mcp_servers" ] && KeyExistsQ[ parsed[ "mcp_servers" ], "WolframLanguage" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-VerifyContent@@Tests/InstallMCPServer.wlt:682,1-691,2"
]

VerificationTest[
    Module[ { content, parsed },
        content = ReadString @ First @ codexConfigFile;
        parsed = Wolfram`MCPServer`Files`Private`parseTOML @ content;
        KeyExistsQ[ parsed[ "mcp_servers", "WolframLanguage" ], "command" ] &&
        KeyExistsQ[ parsed[ "mcp_servers", "WolframLanguage" ], "args" ] &&
        KeyExistsQ[ parsed[ "mcp_servers", "WolframLanguage" ], "env" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-HasRequiredFields@@Tests/InstallMCPServer.wlt:693,1-704,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`InstallMCPServer`Private`$installName = "Codex" },
        UninstallMCPServer[ codexConfigFile, "WolframLanguage" ]
    ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "UninstallMCPServer-Codex-Basic@@Tests/InstallMCPServer.wlt:706,1-713,2"
]

VerificationTest[
    Module[ { content, parsed },
        content = ReadString @ First @ codexConfigFile;
        parsed = Wolfram`MCPServer`Files`Private`parseTOML @ content;
        KeyExistsQ[ parsed, "mcp_servers" ] && ! KeyExistsQ[ parsed[ "mcp_servers" ], "WolframLanguage" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "UninstallMCPServer-Codex-VerifyRemoved@@Tests/InstallMCPServer.wlt:715,1-724,2"
]

VerificationTest[
    cleanupTestFiles[ codexConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-Cleanup@@Tests/InstallMCPServer.wlt:726,1-731,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Codex Install With Existing Config*)

VerificationTest[
    codexConfigFile = testCodexConfigFile[];
    (* Create a config file with existing settings *)
    WriteString[
        First @ codexConfigFile,
        "model = \"gpt-4\"\napproval_mode = \"suggest\"\n\n[other_section]\nkey = \"value\"\n"
    ];
    Close @ First @ codexConfigFile;
    Block[ { Wolfram`MCPServer`InstallMCPServer`Private`$installName = "Codex" },
        InstallMCPServer[ codexConfigFile, "WolframLanguage" ]
    ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-PreservesExisting@@Tests/InstallMCPServer.wlt:737,1-751,2"
]

VerificationTest[
    Module[ { content, parsed },
        content = ReadString @ First @ codexConfigFile;
        parsed = Wolfram`MCPServer`Files`Private`parseTOML @ content;
        (* Check both old settings and new server are present *)
        parsed[ "model" ] === "gpt-4" &&
        KeyExistsQ[ parsed[ "other_section" ], "key" ] &&
        KeyExistsQ[ parsed[ "mcp_servers", "WolframLanguage" ], "command" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-VerifyPreserved@@Tests/InstallMCPServer.wlt:753,1-765,2"
]

VerificationTest[
    cleanupTestFiles[ codexConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-CleanupPreserved@@Tests/InstallMCPServer.wlt:767,1-772,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Codex Install With Environment Variables*)

VerificationTest[
    codexConfigFile = testCodexConfigFile[];
    Block[ { Wolfram`MCPServer`InstallMCPServer`Private`$installName = "Codex" },
        InstallMCPServer[
            codexConfigFile,
            "WolframLanguage",
            ProcessEnvironment -> <| "CUSTOM_VAR" -> "custom_value" |>
        ]
    ],
    _Success,
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-WithEnv@@Tests/InstallMCPServer.wlt:778,1-790,2"
]

VerificationTest[
    Module[ { content, parsed, env },
        content = ReadString @ First @ codexConfigFile;
        parsed = Wolfram`MCPServer`Files`Private`parseTOML @ content;
        env = parsed[ "mcp_servers", "WolframLanguage", "env" ];
        KeyExistsQ[ env, "CUSTOM_VAR" ] && env[ "CUSTOM_VAR" ] === "custom_value" &&
        KeyExistsQ[ env, "MCP_SERVER_NAME" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InstallMCPServer-Codex-VerifyEnv@@Tests/InstallMCPServer.wlt:792,1-803,2"
]

VerificationTest[
    cleanupTestFiles[ codexConfigFile ],
    { Null },
    SameTest -> MatchQ,
    TestID   -> "InstallMCPServer-Codex-CleanupEnv@@Tests/InstallMCPServer.wlt:805,1-810,2"
]