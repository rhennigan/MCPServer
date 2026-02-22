(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`InstallMCPServer`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)
$installClientName = None;

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
    catchMine @ Block[
        (* Auto-detect TOML format from file extension *)
        { $installClientName = If[ StringEndsQ[ First @ target, ".toml", IgnoreCase -> True ], "Codex", $installClientName ] },
        installMCPServer[
            target,
            ensureMCPServerExists @ MCPServerObject @ server,
            OptionValue @ ProcessEnvironment,
            OptionValue @ VerifyLLMKit,
            OptionValue[ "DevelopmentMode" ]
        ]
    ];

InstallMCPServer[ name_String, server_, opts: OptionsPattern[ ] ] :=
    catchMine @ Block[ { $installClientName = toInstallName @ name },
        InstallMCPServer[ installLocation @ name, server, opts ]
    ];

InstallMCPServer[ { name_String, dir_ }, server_, opts: OptionsPattern[ ] ] :=
    catchMine @ Block[ { $installClientName = toInstallName @ name },
        InstallMCPServer[ projectInstallLocation[ $installClientName, dir ], server, opts ]
    ];

InstallMCPServer // endExportedDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*installMCPServer*)
installMCPServer // beginDefinition;

installMCPServer[ target_, obj_, Automatic|Inherited, verifyLLMKit_, devMode_ ] :=
    installMCPServer[ target, obj, defaultEnvironment[ ], verifyLLMKit, devMode ];

installMCPServer[ target0_File, obj_MCPServerObject, env_Association, verifyLLMKit_, devMode_ ] /; $installClientName === "Codex" := Enclose[
    Module[ { target, name, json, data, server, existing, updated },

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

        (* Convert to Codex format *)
        server = ConfirmBy[ convertToCodexFormat @ server, AssociationQ, "CodexServer" ];

        (* Read existing TOML config *)
        existing = ConfirmBy[ readTOMLFile @ target, AssociationQ, "ExistingTOML" ];

        (* Add/update the server *)
        updated = ConfirmBy[ setMCPServer[ existing, name, server ], AssociationQ, "UpdatedTOML" ];

        (* Write back *)
        ConfirmBy[ writeTOMLFile[ target, updated[ "Data" ], updated ], fileQ, "Export" ];
        ConfirmBy[ recordMCPInstallation[ target, obj ], FileExistsQ, "Record" ];

        installSuccess[ name, target, obj ]
    ],
    throwInternalFailure
];

installMCPServer[ target0_File, obj_MCPServerObject, env_Association, verifyLLMKit_, devMode_ ] := Enclose[
    Module[ { target, name, json, data, server, existing, path, convert },

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

        path    = ConfirmMatch[ configKeyPath[ ], { __String }, "ConfigKeyPath" ];
        convert = serverConverter @ $installClientName;
        server  = ConfirmBy[ convert @ server, AssociationQ, "ConvertedServer" ];

        With[ { keys = Sequence @@ path },
            existing[ keys, name ] = server
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

recordMCPInstallation[ target_? fileQ, obj_MCPServerObject ] :=
    recordMCPInstallation[ { $installClientName, target }, obj ];

recordMCPInstallation[ { name: _String|None, target_? fileQ }, obj_MCPServerObject ] := Enclose[
    Module[ { file, existing, installation, new, filtered },
        file = ConfirmBy[ mcpServerFile[ obj, "Installations.wxf" ], fileQ, "File" ];
        existing = mcpServerInstallations @ obj;
        installation = ConfirmBy[ toMCPInstallationData @ { name, target }, AssociationQ, "Installation" ];
        new = If[ ListQ @ existing, Union[ existing, { installation } ], { installation } ];
        filtered = Select[ new, mcpConfigExistsQ ];
        ConfirmBy[ writeWXFFile[ file, filtered ], FileExistsQ, "Export" ]
    ],
    throwInternalFailure
];

recordMCPInstallation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*clearRecordedInstallation*)
clearRecordedInstallation // beginDefinition;

clearRecordedInstallation[ target_? fileQ, obj_MCPServerObject ] :=
    clearRecordedInstallation[ { $installClientName, target }, obj ];

clearRecordedInstallation[ { name: _String|None, target_? fileQ }, obj_MCPServerObject ] := Enclose[
    Module[ { file, existing, installation, new },
        file = ConfirmBy[ mcpServerFile[ obj, "Installations.wxf" ], fileQ, "File" ];
        existing = mcpServerInstallations @ obj;
        installation = toMCPInstallationData @ { name, target };

        new = DeleteCases[
            If[ ListQ @ existing, existing, { } ],
            installation | KeyValuePattern[ "ConfigurationFile" -> target ]
        ];

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
    Catch @ Module[ { obj, file, installations, updated, unique },
        obj = ConfirmBy[ MCPServerObject @ obj0, MCPServerObjectQ, "MCPServerObject" ];
        file = ConfirmBy[ mcpServerFile[ obj, "Installations.wxf" ], fileQ, "File" ];
        installations = If[ FileExistsQ @ file, Quiet @ readWXFFile @ file, { } ];
        If[ ! ListQ @ installations, Throw @ { } ];

        (* Legacy installations have only the configuration file, so we try to guess the client name from it *)
        updated = ConfirmMatch[ toMCPInstallationData /@ installations, { ___Association }, "Updated" ];
        unique = DeleteDuplicates[ KeySort /@ updated ];

        (* If we've updated legacy data, be sure to write it back to the file *)
        If[ unique =!= installations, ConfirmBy[ writeWXFFile[ file, unique ], FileExistsQ, "Export" ] ];

        (* Return the unique installations *)
        unique
    ],
    throwInternalFailure
];

mcpServerInstallations // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toMCPInstallationData*)
toMCPInstallationData // beginDefinition;

toMCPInstallationData[ as: KeyValuePattern @ { "ClientName" -> _String|None, "ConfigurationFile" -> _? fileQ } ] :=
    as;

toMCPInstallationData[ { name: _String|None, file_? fileQ } ] := <|
    "ClientName"        -> name,
    "ConfigurationFile" -> file
|>;

toMCPInstallationData[ file_? fileQ ] := <|
    "ClientName"        -> guessClientName @ file,
    "ConfigurationFile" -> file
|>;

toMCPInstallationData // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*guessClientName*)
guessClientName // beginDefinition;

(* Legacy code only recorded the file name, not the name of the client.
   To update these, we attempt to guess the original client name from the file name. *)
guessClientName[ file_? fileQ ] := Enclose[
    Catch @ Module[ { clientNames, client, split, extension, format },

        (* Check if the file explicitly matches a client's global install location *)
        clientNames = Keys @ $SupportedMCPClients;
        client = SelectFirst[ clientNames, Quiet @ catchAlways @ installLocation @ # === file & ];
        If[ StringQ @ client, Throw @ client ];

        (* Try to guess from the file path for project-level installations *)
        split = ToLowerCase @ ConfirmMatch[ FileNameSplit @ file, { __String }, "Split" ];
        Switch[ split,
            { __, ".mcp.json" }, Throw[ "ClaudeCode" ],
            { __, "opencode.json" }, Throw[ "OpenCode" ],
            { __, ".vscode", "settings.json" }, Throw[ "VisualStudioCode" ],
            { __, ".zed", "settings.json" }, Throw[ "Zed" ]
        ];

        (* Try to guess from the file extension *)
        extension = ToLowerCase @ ConfirmBy[ FileExtension @ file, StringQ, "Extension" ];
        If[ extension === "toml", Throw[ "Codex" ] ];
        If[ extension === "json", Throw @ guessClientNameFromJSON @ file ];

        (* Try to guess from the file format (only if the file exists) *)
        If[ ! FileExistsQ @ file, Throw @ None ];
        format = Quiet @ FileFormat @ file;
        If[ ! StringQ @ format, Throw @ None ];
        format = ToLowerCase @ ConfirmBy[ format, StringQ, "Format" ];
        If[ format === "json", Throw @ guessClientNameFromJSON @ file ];
        If[ format === "toml", Throw[ "Codex" ] ];

        (* If all else fails, return None *)
        None
    ],
    None &
];

guessClientName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*guessClientNameFromJSON*)
guessClientNameFromJSON // beginDefinition;
guessClientNameFromJSON[ _ ] := None; (* TODO: This should guess based on the JSON structure *)
guessClientNameFromJSON // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*mcpConfigExistsQ*)
mcpConfigExistsQ // beginDefinition;
mcpConfigExistsQ[ KeyValuePattern[ "ConfigurationFile" -> file_ ] ] := mcpConfigExistsQ @ file;
mcpConfigExistsQ[ target_? fileQ ] := FileExistsQ @ target;
mcpConfigExistsQ // endDefinition;

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
(*convertToCopilotCLIFormat*)
convertToCopilotCLIFormat // beginDefinition;

convertToCopilotCLIFormat[ server_Association ] := Enclose[
    Module[ { result },
        result = ConfirmBy[ server, AssociationQ, "Server" ];
        result[ "tools" ] = { "*" };
        result
    ],
    throwInternalFailure
];

convertToCopilotCLIFormat // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertToClineFormat*)
convertToClineFormat // beginDefinition;

convertToClineFormat[ server_Association ] := Enclose[
    Module[ { result },
        result = ConfirmBy[ server, AssociationQ, "Server" ];
        result[ "disabled" ] = False;
        result[ "autoApprove" ] = { };
        result
    ],
    throwInternalFailure
];

convertToClineFormat // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertToCodexFormat*)
convertToCodexFormat // beginDefinition;

convertToCodexFormat[ server_Association ] := Enclose[
    Module[ { command, args, env, result },
        command = ConfirmMatch[ Lookup[ server, "command", Missing[ ] ], _String | _Missing, "Command" ];
        args = Lookup[ server, "args", { } ];
        env = Lookup[ server, "env", <| |> ];

        result = <| |>;

        If[ command =!= Missing[ ],
            result[ "command" ] = command
        ];

        If[ ListQ @ args && Length @ args > 0,
            result[ "args" ] = args
        ];

        If[ AssociationQ @ env && Length @ env > 0,
            result[ "env" ] = env
        ];

        result[ "enabled" ] = True;

        result
    ],
    throwInternalFailure
];

convertToCodexFormat // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*defaultEnvironment*)
defaultEnvironment // beginDefinition;

defaultEnvironment[ ] := Enclose[
    Module[ { env, keys, usable, override },

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

        override = ConfirmBy[ $overrideEnvironment, AssociationQ, "Fallback" ];
        ConfirmAssert[ AllTrue[ override, StringQ ], "FallbackCheck" ];

        defaultEnvironment[ ] = ConfirmBy[ <| usable, override |>, AssociationQ, "Result" ]
    ],
    throwInternalFailure
];

defaultEnvironment // endDefinition;


$defaultEnvironmentKeys = { "WOLFRAM_BASE", "WOLFRAM_USERBASE", "WOLFRAM_LOCALBASE" };
$windowsEnvironmentKeys = Append[ $defaultEnvironmentKeys, "APPDATA" ];

$overrideEnvironment := <|
    "WOLFRAM_BASE"      -> $BaseDirectory,
    "WOLFRAM_LOCALBASE" -> ExpandFileName @ LocalObject @ $LocalBase,
    "WOLFRAM_USERBASE"  -> $UserBaseDirectory
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*installSuccess*)
installSuccess // beginDefinition;

installSuccess[ serverName_, installLocation_, obj_ ] :=
    installSuccess[ serverName, installLocation, obj, installDisplayName @ $installClientName ];

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
(*configKeyPath*)
configKeyPath // beginDefinition;
configKeyPath[ ] := configKeyPath @ $installClientName;
configKeyPath[ name_String ] /; KeyExistsQ[ $supportedMCPClients, name ] := $supportedMCPClients[ name, "ConfigKey" ];
configKeyPath[ _ ] := { "mcpServers" };
configKeyPath // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*emptyConfigForPath*)
emptyConfigForPath // beginDefinition;
emptyConfigForPath[ { } ] := <| |>;
emptyConfigForPath[ { key_String, rest___String } ] := <| key -> emptyConfigForPath @ { rest } |>;
emptyConfigForPath // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ensureNestedKey*)
ensureNestedKey // beginDefinition;
ensureNestedKey[ data_? AssociationQ, { } ] := data;
ensureNestedKey[ data_? AssociationQ, { key_String, rest___String } ] :=
    Append[ data, key -> ensureNestedKey[
        Replace[ data @ key, Except[ _? AssociationQ ] -> <| |> ],
        { rest }
    ] ];
ensureNestedKey[ data_, path_List ] := ensureNestedKey[ <| |>, path ];
ensureNestedKey // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*serverConverter*)
(* TODO: This should be a property of the client *)
serverConverter // beginDefinition;
serverConverter[ "OpenCode"   ] := convertToOpenCodeFormat;
serverConverter[ "CopilotCLI" ] := convertToCopilotCLIFormat;
serverConverter[ "Cline"      ] := convertToClineFormat;
serverConverter[ _            ] := Identity;
serverConverter // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readExistingMCPConfig*)
readExistingMCPConfig // beginDefinition;

readExistingMCPConfig[ file_ ] := Enclose[
    Catch @ Module[ { path, data },
        path = ConfirmMatch[ configKeyPath[ ], { __String }, "ConfigKeyPath" ];
        If[ ! FileExistsQ @ file, Throw @ emptyConfigForPath @ path ];
        data = readRawJSONFile @ ExpandFileName @ file;
        If[ ! AssociationQ @ data, throwFailure[ "InvalidMCPConfiguration", file ] ];
        ensureNestedKey[ data, path ]
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

UninstallMCPServer[ All, obj0: _MCPServerObject|_String ] := catchMine @ Enclose[
    Module[ { obj, installations },
        obj = ensureMCPServerExists @ MCPServerObject @ obj0;
        installations = ConfirmMatch[ mcpServerInstallations @ obj, { ___Association }, "Installations" ];

        ConfirmMatch[
            DeleteMissing[ catchAlways @ UninstallMCPServer[ #, obj ] & /@ installations ],
            { ___Success },
            "Results"
        ]
    ],
    throwInternalFailure
];

UninstallMCPServer[ KeyValuePattern @ { "ClientName" -> name_, "ConfigurationFile" -> file_ }, obj_ ] :=
    catchMine @ Block[ { $installClientName = toInstallName @ name },
        UninstallMCPServer[ file, obj ]
    ];

UninstallMCPServer[ { name_String, dir_ }, obj_ ] :=
    catchMine @ Block[ { $installClientName = toInstallName @ name },
        UninstallMCPServer[ projectInstallLocation[ $installClientName, dir ], obj ]
    ];

(* FIXME: This is ambiguous, because a list could also refer to a project-level installation *)
UninstallMCPServer[ targets_List, obj_MCPServerObject ] :=
    catchMine @ DeleteMissing[ catchAlways @ UninstallMCPServer[ #, obj ] & /@ targets ];

UninstallMCPServer[ target_File, obj_ ] :=
    catchMine @ Block[
        (* FIXME: Shouldn't this use guessClientName instead? *)
        (* Auto-detect TOML format from file extension *)
        { $installClientName = If[ StringEndsQ[ First @ target, ".toml", IgnoreCase -> True ], "Codex", $installClientName ] },
        uninstallMCPServer[ target, ensureMCPServerExists @ MCPServerObject @ obj ]
    ];

UninstallMCPServer[ name_String, obj_ ] :=
    catchMine @ Block[ { $installClientName = toInstallName @ name },
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

uninstallMCPServer[ target0_File, obj_MCPServerObject ] /; $installClientName === "Codex" := Enclose[
    Catch @ Module[ { target, name, existing, mcpServers, updated },

        target = ConfirmBy[ ensureFilePath @ target0, fileQ, "Target" ];
        If[ ! FileExistsQ @ target, Throw @ Missing[ "NotInstalled", target ] ];

        name = ConfirmBy[ obj[ "Name" ], StringQ, "Name" ];

        (* Read existing TOML config *)
        existing = ConfirmBy[ readTOMLFile @ target, AssociationQ, "ExistingTOML" ];

        (* Check if server exists *)
        mcpServers = getMCPServers @ existing;
        If[ ! KeyExistsQ[ mcpServers, name ], Throw @ Missing[ "NotInstalled", target ] ];

        (* Remove the server *)
        updated = ConfirmBy[ removeMCPServer[ existing, name ], AssociationQ, "UpdatedTOML" ];

        (* Write back *)
        ConfirmBy[ writeTOMLFile[ target, updated[ "Data" ], updated ], fileQ, "Export" ];
        ConfirmMatch[ clearRecordedInstallation[ target, obj ], { ___Association }, "Clear" ];

        uninstallSuccess[ name, target, obj ]
    ],
    throwInternalFailure
];

uninstallMCPServer[ target0_File, obj_MCPServerObject ] := Enclose[
    Catch @ Module[ { target, name, existing, path },

        target = ConfirmBy[ ensureFilePath @ target0, fileQ, "Target" ];
        If[ ! FileExistsQ @ target, Throw @ Missing[ "NotInstalled", target ] ];

        name = ConfirmBy[ obj[ "Name" ], StringQ, "Name" ];
        existing = ConfirmBy[ readExistingMCPConfig @ target, AssociationQ, "Existing" ];

        path = ConfirmMatch[ configKeyPath[ ], { __String }, "ConfigKeyPath" ];

        With[ { keys = Sequence @@ path },
            If[ ! AssociationQ @ existing[ keys ], Throw @ Missing[ "NotInstalled", target ] ];
            If[ ! KeyExistsQ[ existing[ keys ], name ], Throw @ Missing[ "NotInstalled", target ] ];
            KeyDropFrom[ existing[ keys ], name ]
        ];

        ConfirmBy[ writeRawJSONFile[ target, existing ], FileExistsQ, "Export" ];

        ConfirmAssert[ readRawJSONFile @ target === existing, "ExportCheck" ];
        ConfirmMatch[ clearRecordedInstallation[ target, obj ], { ___Association }, "Clear" ];

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
    uninstallSuccess[ serverName, installLocation, obj, installDisplayName @ $installClientName ];

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

installLocation[ name_String ] := installLocation[ name, $OperatingSystem ];

installLocation[ name0_String, os0_String ] := Enclose[
    Module[ { name, os, clientData, locationSpec, path },

        name = ConfirmBy[ toInstallName @ name0, StringQ, "Name" ];
        os = ConfirmBy[ os0, StringQ, "OperatingSystem" ];

        clientData = ConfirmMatch[ Lookup[ $SupportedMCPClients, name, None ], _Association|None, "ClientData" ];
        If[ clientData === None, throwFailure[ "UnsupportedMCPClient", name ] ];
        locationSpec = ConfirmMatch[ clientData[ "InstallLocation" ], _Association|_List, "InstallLocation" ];

        path = ConfirmMatch[
            If[ AssociationQ @ locationSpec, Lookup[ locationSpec, os, None ], locationSpec ],
            { __String }|None,
            "Path"
        ];

        If[ path === None, throwFailure[ "UnknownInstallLocation", name, os ] ];

        ConfirmBy[ fileNameJoin @ path, fileQ, "Result" ]
    ],
    throwInternalFailure
];

installLocation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*projectInstallLocation*)
projectInstallLocation // beginDefinition;

projectInstallLocation[ name_String, dir_ ] := Enclose[
    Module[ { clientData, path },
        clientData = Lookup[ $SupportedMCPClients, name, None ];
        If[ clientData === None, throwFailure[ "UnsupportedMCPClient", name ] ];
        ConfirmAssert[ AssociationQ @ clientData, "ClientData" ];
        If[ ! TrueQ @ clientData[ "ProjectSupport" ], throwFailure[ "UnsupportedMCPClientProject", name ] ];
        path = ConfirmMatch[ Lookup[ clientData, "ProjectPath" ], { __String }, "ProjectPath" ];
        If[ path === None, throwFailure[ "UnknownProjectInstallLocation", name ] ];
        fileNameJoin[ dir, path ]
    ],
    throwInternalFailure
];

projectInstallLocation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toInstallName*)
toInstallName // beginDefinition;
toInstallName[ name_String ] := Lookup[ $aliasToCanonicalName, name, name ];
toInstallName[ None ] := None;
toInstallName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*installDisplayName*)
installDisplayName // beginDefinition;
installDisplayName[ name_String ] := Lookup[ $supportedMCPClients, name, <| |> ][ "DisplayName" ] // Replace[ _Missing -> name ];
installDisplayName[ None ] := None;
installDisplayName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
