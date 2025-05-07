(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "RickHennigan`MCPServer`InstallMCPServer`" ];
Begin[ "`Private`" ];

Needs[ "RickHennigan`MCPServer`"        ];
Needs[ "RickHennigan`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)
$installName = None;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*InstallMCPServer*)
InstallMCPServer // beginDefinition;
InstallMCPServer // Options = { ProcessEnvironment -> Automatic };

InstallMCPServer[ target_, opts: OptionsPattern[ ] ] :=
    catchMine @ InstallMCPServer[ target, Automatic, opts ];

InstallMCPServer[ target_, Automatic, opts: OptionsPattern[ ] ] :=
    catchMine @ InstallMCPServer[ target, $defaultMCPServer, opts ];

InstallMCPServer[ target_File, server_, opts: OptionsPattern[ ] ] :=
    catchMine @ installMCPServer[
        target,
        ensureMCPServerExists @ MCPServerObject @ server,
        OptionValue @ ProcessEnvironment
    ];

InstallMCPServer[ name_String, server_, opts: OptionsPattern[ ] ] :=
    catchMine @ Block[ { $installName = toInstallName @ name },
        InstallMCPServer[ installLocation @ name, server, opts ]
    ];

InstallMCPServer // endExportedDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*installMCPServer*)
installMCPServer // beginDefinition;

installMCPServer[ target_, obj_, Automatic|Inherited ] :=
    installMCPServer[ target, obj, defaultEnvironment[ ] ];

installMCPServer[ target0_File, obj_MCPServerObject, env_Association ] := Enclose[
    Module[ { target, name, json, data, server, existing },

        target   = ConfirmBy[ ensureFilePath @ target0, fileQ, "Target" ];
        name     = ConfirmBy[ obj[ "Name" ], StringQ, "Name" ];
        json     = ConfirmBy[ obj[ "JSONConfiguration" ], StringQ, "JSONConfiguration" ];
        data     = ConfirmBy[ Developer`ReadRawJSONString @ json, AssociationQ, "JSONConfiguration" ];
        server   = ConfirmBy[ addEnvironmentVariables[ data[ "mcpServers", name ], env ], AssociationQ, "Server" ];
        existing = ConfirmBy[ readExistingMCPConfig @ target, AssociationQ, "Existing" ];

        existing[ "mcpServers", name ] = server;

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
        If[ ! FileExistsQ @ file, Throw @ <| "mcpServers" -> <| |> |> ];
        data = readRawJSONFile @ ExpandFileName @ file;
        If[ ! MatchQ[ data, KeyValuePattern[ "mcpServers" -> _Association ] ],
            throwFailure[ "InvalidMCPConfiguration", file ]
        ];
        data
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

        If[ ! KeyExistsQ[ existing, "mcpServers" ], Throw @ Missing[ "NotInstalled", target ] ];
        If[ ! KeyExistsQ[ existing[ "mcpServers" ], name ], Throw @ Missing[ "NotInstalled", target ] ];

        KeyDropFrom[ existing[ "mcpServers" ], name ];
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
(*Cursor*)
installLocation[ "Cursor", _ ] := fileNameJoin[ $HomeDirectory, ".cursor", "mcp.json" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Unknown*)
installLocation[ name_String, os_String ] := throwFailure[ "UnknownInstallLocation", name, os ];
installLocation // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toInstallName*)
toInstallName // beginDefinition;
toInstallName[ "Claude" ] := "ClaudeDesktop";
toInstallName[ name_String ] := name;
toInstallName // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*installDisplayName*)
installDisplayName // beginDefinition;
installDisplayName[ "ClaudeDesktop" ] := "Claude Desktop";
installDisplayName[ name_String ] := name;
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
