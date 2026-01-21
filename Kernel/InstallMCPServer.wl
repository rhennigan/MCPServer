(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`InstallMCPServer`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)
$installName = None;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*InstallMCPServer*)
InstallMCPServer // beginDefinition;

(* "DevelopmentMode" option:
   - False (default): Uses the installed paclet via PacletSymbol for server startup
   - True: Uses the Scripts/StartMCPServer.wls from $thisPaclet's location (requires unbuilt paclet)
   - path_String: Uses Scripts/StartMCPServer.wls from the specified directory
   This allows testing local changes without reinstalling the paclet. *)
InstallMCPServer // Options = {
    "DevelopmentMode"  -> False,
    ProcessEnvironment -> Automatic,
    "VerifyLLMKit"     -> True
};

InstallMCPServer[ target_, opts: OptionsPattern[ ] ] :=
    catchMine @ InstallMCPServer[ target, Automatic, opts ];

InstallMCPServer[ target_, Automatic, opts: OptionsPattern[ ] ] :=
    catchMine @ InstallMCPServer[ target, $defaultMCPServer, opts ];

InstallMCPServer[ target_File, server_, opts: OptionsPattern[ ] ] :=
    catchMine @ installMCPServer[
        target,
        ensureMCPServerExists @ MCPServerObject @ server,
        OptionValue @ ProcessEnvironment,
        OptionValue @ VerifyLLMKit,
        OptionValue[ "DevelopmentMode" ]
    ];

InstallMCPServer[ name_String, server_, opts: OptionsPattern[ ] ] :=
    catchMine @ Block[ { $installName = toInstallName @ name },
        InstallMCPServer[ installLocation @ name, server, opts ]
    ];

InstallMCPServer[ { name_String, dir_ }, server_, opts: OptionsPattern[ ] ] :=
    catchMine @ Block[ { $installName = toInstallName @ name },
        InstallMCPServer[ projectInstallLocation[ $installName, dir ], server, opts ]
    ];

InstallMCPServer // endExportedDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*installMCPServer*)
installMCPServer // beginDefinition;

installMCPServer[ target_, obj_, Automatic|Inherited, verifyLLMKit_, devMode_ ] :=
    installMCPServer[ target, obj, defaultEnvironment[ ], verifyLLMKit, devMode ];

installMCPServer[ target0_File, obj_MCPServerObject, env_Association, verifyLLMKit_, devMode_ ] := Enclose[
    Module[ { target, name, json, data, server, existing },

        If[ verifyLLMKit, ConfirmMatch[ checkLLMKitRequirements @ obj, _String|None, "LLMKitCheck" ] ];
        initializeTools @ obj;

        target   = ConfirmBy[ ensureFilePath @ target0, fileQ, "Target" ];
        name     = ConfirmBy[ obj[ "Name" ], StringQ, "Name" ];
        json     = ConfirmBy[ obj[ "JSONConfiguration" ], StringQ, "JSONConfiguration" ];
        data     = ConfirmBy[ Developer`ReadRawJSONString @ json, AssociationQ, "JSONConfiguration" ];
        server   = ConfirmBy[ addEnvironmentVariables[ data[ "mcpServers", name ], env ], AssociationQ, "Server" ];
        If[ devMode =!= False,
            server[ "args" ] = ConfirmMatch[ makeDevelopmentArgs @ devMode, { __String }, "DevelopmentArgs" ]
        ];
        existing = ConfirmBy[ readExistingMCPConfig @ target, AssociationQ, "Existing" ];

        Switch[ $installName,
            "VisualStudioCode",
            existing[ "mcp", "servers", name ] = server,
            "OpenCode",
            existing[ "mcp", name ] = ConfirmBy[ convertToOpenCodeFormat @ server, AssociationQ, "OpenCodeServer" ],
            _,
            existing[ "mcpServers", name ] = server
        ];

        ConfirmBy[ writeRawJSONFile[ target, existing ], FileExistsQ, "Export" ];
        ConfirmAssert[ readRawJSONFile @ target === existing, "ExportCheck" ];

        ConfirmBy[ recordMCPInstallation[ target, obj ], FileExistsQ, "Record" ];

        installSuccess[ name, target, obj ]
    ],
    throwInternalFailure
];

installMCPServer // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*initializeTools*)
initializeTools // beginDefinition;
initializeTools[ obj_MCPServerObject ] := initializeTools @ obj[ "Tools" ];
initializeTools[ tools_List ] := initializeTools /@ tools;
initializeTools[ tool_LLMTool ] := initializeTools @ tool[ "Data" ];
initializeTools[ as_Association ] := Lookup[ as, "Initialization", Null ];
initializeTools // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*checkLLMKitRequirements*)
checkLLMKitRequirements // beginDefinition;

checkLLMKitRequirements[ obj_MCPServerObject ] /; llmKitSubscribedQ[ ] :=
    None;

checkLLMKitRequirements[ obj_MCPServerObject ] :=
    checkLLMKitRequirements[ obj[ "Name" ], obj[ "Tools" ] ];

checkLLMKitRequirements[ name_String, tools: { ___LLMTool } ] := Enclose[
    Module[ { requirements, result },

        requirements = ConfirmMatch[
            checkLLMKitRequirements[ name, # ] & /@ tools,
            { (_String|None)... },
            "LLMKitCheck"
        ];

        result = Which[
            MemberQ[ requirements, "Required"  ], "Required",
            MemberQ[ requirements, "Suggested" ], "Suggested",
            True, None
        ];

        issueLLMKitMessage[ name, result ]
    ],
    throwInternalFailure
];


checkLLMKitRequirements[ name_String, tool_LLMTool ] :=
    checkLLMKitRequirements[ name, tool[ "Data" ][ "LLMKit" ] ];

checkLLMKitRequirements[ name_String, type: "Required"|"Suggested" ] :=
    type;

checkLLMKitRequirements[ name_String, _ ] :=
    None;

checkLLMKitRequirements // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*issueLLMKitMessage*)
issueLLMKitMessage // beginDefinition;

issueLLMKitMessage[ name_String, None ] := None;

issueLLMKitMessage[ name_String, "Required" ] := Enclose[
    throwFailure[
        "LLMKitRequired",
        name,
        ConfirmMatch[ $llmKitSubscribeLink, Hyperlink[ _String, _String ], "LLMKitSubscribeLink" ],
        ConfirmMatch[ $llmKitSubscribeURL, _String, "LLMKitSubscribeURL" ]
    ],
    throwInternalFailure
];

issueLLMKitMessage[ name_String, "Suggested" ] := Enclose[
    messagePrint[
        "LLMKitSuggested",
        name,
        ConfirmMatch[ $llmKitSubscribeLink, Hyperlink[ _String, _String ], "LLMKitSubscribeLink" ],
        ConfirmMatch[ $llmKitSubscribeURL, _String, "LLMKitSubscribeURL" ]
    ];
    "Suggested",
    throwInternalFailure
];

issueLLMKitMessage // endDefinition;


$llmKitSubscribeURL  := getLLMKitInfo[ ][ "buyNowUrl" ];
$llmKitSubscribeLink := Hyperlink[ "here", $llmKitSubscribeURL ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*recordMCPInstallation*)
recordMCPInstallation // beginDefinition;

recordMCPInstallation[ target_? fileQ, obj_MCPServerObject ] := Enclose[
    Module[ { file, existing, new },
        file = ConfirmBy[ mcpServerFile[ obj, "Installations.wxf" ], fileQ, "File" ];
        existing = mcpServerInstallations @ obj;
        new = Select[ If[ ListQ @ existing, Union[ existing, { target } ], { target } ], FileExistsQ ];
        ConfirmBy[ writeWXFFile[ file, new ], FileExistsQ, "Export" ]
    ],
    throwInternalFailure
];

recordMCPInstallation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*clearRecordedInstallation*)
clearRecordedInstallation // beginDefinition;

clearRecordedInstallation[ target_? fileQ, obj_MCPServerObject ] := Enclose[
    Module[ { file, existing, new },
        file = ConfirmBy[ mcpServerFile[ obj, "Installations.wxf" ], fileQ, "File" ];
        existing = mcpServerInstallations @ obj;
        new = DeleteCases[ If[ ListQ @ existing, existing, { } ], target ];
        If[ new === { },
            Quiet @ DeleteFile @ file,
            ConfirmBy[ writeWXFFile[ file, new ], FileExistsQ, "Export" ]
        ];
        new
    ],
    throwInternalFailure
];

clearRecordedInstallation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*mcpServerInstallations*)
mcpServerInstallations // beginDefinition;

mcpServerInstallations[ obj0_ ] := Enclose[
    Module[ { obj, file, installations },
        obj = ConfirmBy[ MCPServerObject @ obj0, MCPServerObjectQ, "MCPServerObject" ];
        file = ConfirmBy[ mcpServerFile[ obj, "Installations.wxf" ], fileQ, "File" ];
        installations = If[ FileExistsQ @ file, Quiet @ readWXFFile @ file, { } ];
        If[ ListQ @ installations,
            Select[ installations, FileExistsQ ],
            { }
        ]
    ],
    throwInternalFailure
];

mcpServerInstallations // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*addEnvironmentVariables*)
addEnvironmentVariables // beginDefinition;

addEnvironmentVariables[ server0_Association, extraEnv_Association ] := Enclose[
    Module[ { server, env, newEnv },
        server = ConfirmBy[ server0, AssociationQ, "Server" ];
        env = ConfirmBy[ server[ "env" ], AssociationQ, "Environment" ];
        newEnv = ConfirmBy[ <| env, extraEnv |>, AssociationQ, "NewEnvironment" ];
        server[ "env" ] = newEnv;
        server
    ],
    throwInternalFailure
];

addEnvironmentVariables // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeDevelopmentArgs*)
makeDevelopmentArgs // beginDefinition;

makeDevelopmentArgs[ True ] :=
    makeDevelopmentArgs @ $thisPaclet[ "Location" ];

makeDevelopmentArgs[ dir_String ] :=
    Module[ { script },
        script = FileNameJoin @ { dir, "Scripts", "StartMCPServer.wls" };
        If[ FileExistsQ @ script,
            { "-script", script, "-noinit", "-noprompt" },
            throwFailure[ "DevelopmentModeUnavailable", dir ]
        ]
    ];

makeDevelopmentArgs[ invalid_ ] :=
    throwFailure[ "InvalidDevelopmentMode", invalid ];

makeDevelopmentArgs // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertToOpenCodeFormat*)
convertToOpenCodeFormat // beginDefinition;

convertToOpenCodeFormat[ server_Association ] := Enclose[
    Module[ { command, args, env, result },
        command = ConfirmMatch[ Lookup[ server, "command", Missing[ ] ], _String | _Missing, "Command" ];
        args = Lookup[ server, "args", { } ];
        env = Lookup[ server, "env", <| |> ];

        result = <|
            "type" -> "local",
            "command" -> If[ command === Missing[ ], { }, Prepend[ args, command ] ],
            "enabled" -> True
        |>;

        If[ AssociationQ @ env && Length @ env > 0,
            result[ "environment" ] = env
        ];

        result
    ],
    throwInternalFailure
];

convertToOpenCodeFormat // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*defaultEnvironment*)
defaultEnvironment // beginDefinition;

defaultEnvironment[ ] := Enclose[
    Module[ { env, keys, usable },

        env = KeyMap[
            ToUpperCase,
            KeySelect[
                ConfirmBy[ Association @ GetEnvironment[ ], AssociationQ, "Environment" ],
                StringQ
            ]
        ];

        keys = If[ $OperatingSystem === "Windows",
                   $windowsEnvironmentKeys,
                   $defaultEnvironmentKeys
               ];

        usable = ConfirmBy[ KeyTake[ env, keys ], AssociationQ, "Usable" ];

        defaultEnvironment[ ] = usable
    ],
    throwInternalFailure
];

defaultEnvironment // endDefinition;


$defaultEnvironmentKeys = { "WOLFRAM_BASE", "WOLFRAM_USERBASE", "WOLFRAM_LOCALBASE" };
$windowsEnvironmentKeys = Append[ $defaultEnvironmentKeys, "APPDATA" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*installSuccess*)
installSuccess // beginDefinition;

installSuccess[ serverName_, installLocation_, obj_ ] :=
    installSuccess[ serverName, installLocation, obj, installDisplayName @ $installName ];

installSuccess[ serverName_String, installLocation_File? fileQ, obj_MCPServerObject, installName_String ] :=
    Success[
        "InstallMCPServer",
        <|
            "MessageTemplate"   :> MCPServer::InstallMCPServerNamed,
            "MessageParameters" -> { serverName, installName },
            "Location"          -> installLocation,
            "MCPServerObject"   -> obj
        |>
    ];

installSuccess[ serverName_String, installLocation_File? fileQ, obj_MCPServerObject, installName_ ] :=
    Success[
        "InstallMCPServer",
        <|
            "MessageTemplate"   :> MCPServer::InstallMCPServer,
            "MessageParameters" -> { serverName },
            "Location"          -> installLocation,
            "MCPServerObject"   -> obj
        |>
    ];

installSuccess // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readExistingMCPConfig*)
readExistingMCPConfig // beginDefinition;

readExistingMCPConfig[ file_ ] := Enclose[
    Catch @ Module[ { data },

        If[ ! FileExistsQ @ file,
            Switch[ $installName,
                "VisualStudioCode",
                Throw @ <| "mcp" -> <| "servers" -> <| |> |> |>,
                "OpenCode",
                Throw @ <| "mcp" -> <| |> |>,
                _,
                Throw @ <| "mcpServers" -> <| |> |>
            ]
        ];

        data = readRawJSONFile @ ExpandFileName @ file;
        If[ ! AssociationQ @ data, throwFailure[ "InvalidMCPConfiguration", file ] ];

        Switch[ $installName,
            (* Handle VS Code format *)
            "VisualStudioCode",
            If[ ! AssociationQ @ data[ "mcp" ], data[ "mcp" ] = <| "servers" -> <| |> |> ];
            If[ ! AssociationQ @ data[ "mcp", "servers" ], data[ "mcp", "servers" ] = <| |> ];
            data,
            (* Handle OpenCode format *)
            "OpenCode",
            If[ ! AssociationQ @ data[ "mcp" ], data[ "mcp" ] = <| |> ];
            data,
            (* Handle standard format *)
            _,
            If[ ! AssociationQ @ data[ "mcpServers" ], data[ "mcpServers" ] = <| |> ];
            data
        ]
    ],
    throwInternalFailure
];

readExistingMCPConfig // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*UninstallMCPServer*)
UninstallMCPServer // beginDefinition;

UninstallMCPServer[ target_File ] :=
    catchMine @ UninstallMCPServer[ target, All ];

UninstallMCPServer[ name_String ] :=
    catchMine @ UninstallMCPServer[ name, All ];

UninstallMCPServer[ obj_ ] :=
    catchMine @ UninstallMCPServer[ All, obj ];

UninstallMCPServer[ target: _File | All, All ] :=
    catchMine @ UninstallMCPServer[ target, allMCPServers[ ] ];

UninstallMCPServer[ target: _File | All, servers_List ] :=
    catchMine @ DeleteMissing @ Flatten[ catchAlways @ UninstallMCPServer[ target, # ] & /@ servers ];

UninstallMCPServer[ All, obj_MCPServerObject ] :=
    catchMine @ UninstallMCPServer[ mcpServerInstallations @ obj, obj ];

UninstallMCPServer[ { name_String, dir_ }, obj_ ] :=
    catchMine @ Block[ { $installName = toInstallName @ name },
        UninstallMCPServer[ projectInstallLocation[ $installName, dir ], obj ]
    ];

UninstallMCPServer[ targets_List, obj_MCPServerObject ] :=
    catchMine @ DeleteMissing[ catchAlways @ UninstallMCPServer[ #, obj ] & /@ targets ];

UninstallMCPServer[ target_File, obj_ ] :=
    catchMine @ uninstallMCPServer[ target, ensureMCPServerExists @ MCPServerObject @ obj ];

UninstallMCPServer[ name_String, obj_ ] :=
    catchMine @ Block[ { $installName = toInstallName @ name },
        UninstallMCPServer[ installLocation @ name, obj ]
    ];

UninstallMCPServer // endExportedDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*allMCPServers*)
allMCPServers // beginDefinition;
allMCPServers[ ] := Union[ MCPServerObjects @ All, Values @ $DefaultMCPServers ];
allMCPServers // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*uninstallMCPServer*)
uninstallMCPServer // beginDefinition;

uninstallMCPServer[ target0_File, obj_MCPServerObject ] := Enclose[
    Catch @ Module[ { target, name, existing },

        target = ConfirmBy[ ensureFilePath @ target0, fileQ, "Target" ];
        If[ ! FileExistsQ @ target, Throw @ Missing[ "NotInstalled", target ] ];

        name = ConfirmBy[ obj[ "Name" ], StringQ, "Name" ];
        existing = ConfirmBy[ readExistingMCPConfig @ target, AssociationQ, "Existing" ];

        Switch[ $installName,
            (* Handle VS Code format *)
            "VisualStudioCode",
            If[ ! AssociationQ @ existing[ "mcp", "servers" ], Throw @ Missing[ "NotInstalled", target ] ];
            If[ ! KeyExistsQ[ existing[ "mcp", "servers" ], name ], Throw @ Missing[ "NotInstalled", target ] ];
            KeyDropFrom[ existing[ "mcp", "servers" ], name ],
            (* Handle OpenCode format *)
            "OpenCode",
            If[ ! AssociationQ @ existing[ "mcp" ], Throw @ Missing[ "NotInstalled", target ] ];
            If[ ! KeyExistsQ[ existing[ "mcp" ], name ], Throw @ Missing[ "NotInstalled", target ] ];
            KeyDropFrom[ existing[ "mcp" ], name ],
            (* Handle standard format *)
            _,
            If[ ! AssociationQ @ existing[ "mcpServers" ], Throw @ Missing[ "NotInstalled", target ] ];
            If[ ! KeyExistsQ[ existing[ "mcpServers" ], name ], Throw @ Missing[ "NotInstalled", target ] ];
            KeyDropFrom[ existing[ "mcpServers" ], name ]
        ];

        ConfirmBy[ writeRawJSONFile[ target, existing ], FileExistsQ, "Export" ];

        ConfirmAssert[ readRawJSONFile @ target === existing, "ExportCheck" ];
        ConfirmMatch[ clearRecordedInstallation[ target, obj ], { ___? fileQ }, "Clear" ];

        uninstallSuccess[ name, target, obj ]
    ],
    throwInternalFailure
];

uninstallMCPServer // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*uninstallSuccess*)
uninstallSuccess // beginDefinition;

uninstallSuccess[ serverName_, installLocation_, obj_ ] :=
    uninstallSuccess[ serverName, installLocation, obj, installDisplayName @ $installName ];

uninstallSuccess[ serverName_String, installLocation_File? fileQ, obj_MCPServerObject, installName_String ] :=
    Success[
        "UninstallMCPServer",
        <|
            "MessageTemplate"   :> MCPServer::UninstallMCPServerNamed,
            "MessageParameters" -> { serverName, installName },
            "Location"          -> installLocation,
            "MCPServerObject"   -> obj
        |>
    ];

uninstallSuccess[ serverName_String, installLocation_File? fileQ, obj_MCPServerObject, installName_ ] :=
    Success[
        "UninstallMCPServer",
        <|
            "MessageTemplate"   :> MCPServer::UninstallMCPServer,
            "MessageParameters" -> { serverName },
            "Location"          -> installLocation,
            "MCPServerObject"   -> obj
        |>
    ];

uninstallSuccess // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*installLocation*)
installLocation // beginDefinition;
installLocation[ name_String ] := installLocation[ toInstallName @ name, $OperatingSystem ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Claude Desktop*)
installLocation[ "ClaudeDesktop", "MacOSX" ] :=
    fileNameJoin[ $HomeDirectory, "Library", "Application Support", "Claude", "claude_desktop_config.json" ];

installLocation[ "ClaudeDesktop", "Windows" ] :=
    fileNameJoin[ $HomeDirectory, "AppData", "Roaming", "Claude", "claude_desktop_config.json" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Claude Code*)
installLocation[ "ClaudeCode", _ ] :=
    fileNameJoin[ $HomeDirectory, ".claude.json" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Cursor*)
installLocation[ "Cursor", _ ] := fileNameJoin[ $HomeDirectory, ".cursor", "mcp.json" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Gemini CLI*)
installLocation[ "GeminiCLI", _ ] :=
    fileNameJoin[ $HomeDirectory, ".gemini", "settings.json" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Antigravity*)
installLocation[ "Antigravity", _ ] :=
    fileNameJoin[ $HomeDirectory, ".gemini", "antigravity", "mcp_config.json" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*OpenCode*)
installLocation[ "OpenCode", _ ] :=
    fileNameJoin[ $HomeDirectory, ".config", "opencode", "opencode.json" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Visual Studio Code*)
installLocation[ "VisualStudioCode", "MacOSX" ] :=
    fileNameJoin[ $HomeDirectory, "Library", "Application Support", "Code", "User", "settings.json" ];

installLocation[ "VisualStudioCode", "Windows" ] :=
    fileNameJoin[ $HomeDirectory, "AppData", "Roaming", "Code", "User", "settings.json" ];

installLocation[ "VisualStudioCode", "Linux" ] :=
    fileNameJoin[ $HomeDirectory, ".config", "Code", "User", "settings.json" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Unknown*)
installLocation[ name_String, os_String ] := throwFailure[ "UnknownInstallLocation", name, os ];
installLocation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*projectInstallLocation*)
projectInstallLocation // beginDefinition;

projectInstallLocation[ "ClaudeCode", dir_ ] :=
    fileNameJoin[ dir, ".mcp.json" ];

projectInstallLocation[ "OpenCode", dir_ ] :=
    fileNameJoin[ dir, "opencode.json" ];

projectInstallLocation[ "VisualStudioCode", dir_ ] :=
    fileNameJoin[ dir, ".vscode", "settings.json" ];

projectInstallLocation[ name_, dir_ ] :=
    throwFailure[ "UnknownProjectInstallLocation", name ];

projectInstallLocation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toInstallName*)
toInstallName // beginDefinition;
toInstallName[ "Claude"            ] := "ClaudeDesktop";
toInstallName[ "claude-code"       ] := "ClaudeCode";
toInstallName[ "VSCode"            ] := "VisualStudioCode";
toInstallName[ "Code"              ] := "VisualStudioCode";
toInstallName[ "Gemini"            ] := "GeminiCLI";
toInstallName[ "GoogleAntigravity" ] := "Antigravity";
toInstallName[ name_String         ] := name;
toInstallName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*installDisplayName*)
installDisplayName // beginDefinition;
installDisplayName[ "ClaudeDesktop"    ] := "Claude Desktop";
installDisplayName[ "ClaudeCode"       ] := "Claude Code";
installDisplayName[ "VisualStudioCode" ] := "Visual Studio Code";
installDisplayName[ "GeminiCLI"        ] := "Gemini CLI";
installDisplayName[ "Antigravity"      ] := "Antigravity";
installDisplayName[ "OpenCode"         ] := "OpenCode";
installDisplayName[ name_String        ] := name;
installDisplayName[ None               ] := None;
installDisplayName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
