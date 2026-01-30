(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServerTests`MCPServerTestUtilities`" ];

`$MCPTestProcess;
`$MCPRequestID;
`GetMCPCommandLine;
`GetMCPEnvironment;
`StartMCPTestServer;
`StopMCPTestServer;
`SendMCPRequest;
`SendMCPNotification;
`MCPInitialize;

Begin[ "`Private`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
$MCPRequestID = 0;
$MCPTestProcess = None;
$defaultTimeout = 60; (* seconds *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*GetMCPCommandLine*)
GetMCPCommandLine // ClearAll;

GetMCPCommandLine[ ] := GetMCPCommandLine @ $OperatingSystem;

GetMCPCommandLine[ os_String ] := Module[ { wolframCmd, baseArgs, licenseArgs },
    wolframCmd = getWolframCommand @ os;
    baseArgs = {
        "-run",
        "PacletSymbol[\"Wolfram/MCPServer\",\"Wolfram`MCPServer`StartMCPServer\"][]",
        "-noinit",
        "-noprompt"
    };
    licenseArgs = extractLicenseArgs @ $CommandLine;
    Flatten @ { wolframCmd, baseArgs, licenseArgs }
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getWolframCommand*)
getWolframCommand // ClearAll;
getWolframCommand[ "Windows" ] := FileNameJoin @ { $InstallationDirectory, "wolfram.exe" };
getWolframCommand[ "MacOSX"  ] := FileNameJoin @ { $InstallationDirectory, "MacOS", "wolfram" };
getWolframCommand[ "Unix"    ] := FileNameJoin @ { $InstallationDirectory, "Executables", "wolfram" };
getWolframCommand[ os_String ] := $Failed;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*extractLicenseArgs*)
extractLicenseArgs // ClearAll;

extractLicenseArgs[ commandLine_List ] := Module[ { pwfile, entitlement },
    pwfile = extractArg[ commandLine, "-pwfile" ];
    entitlement = extractArg[ commandLine, "-entitlement" ];
    Flatten @ {
        If[ StringQ @ pwfile, { "-pwfile", pwfile }, { } ],
        If[ StringQ @ entitlement, { "-entitlement", entitlement }, { } ]
    }
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*extractArg*)
extractArg // ClearAll;

extractArg[ commandLine_List, argName_String ] := Module[ { pos },
    pos = Position[ commandLine, argName ];
    If[ Length @ pos > 0 && pos[[ 1, 1 ]] < Length @ commandLine,
        commandLine[[ pos[[ 1, 1 ]] + 1 ]],
        Missing[ "NotFound" ]
    ]
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*GetMCPEnvironment*)
GetMCPEnvironment // ClearAll;

GetMCPEnvironment[ serverName_String ] := Module[ { env, keys, usable },
    env = KeyMap[
        ToUpperCase,
        KeySelect[
            Association @ GetEnvironment[ ],
            StringQ
        ]
    ];

    keys = If[ $OperatingSystem === "Windows",
        { "WOLFRAM_BASE", "WOLFRAM_USERBASE", "WOLFRAM_LOCALBASE", "APPDATA" },
        { "WOLFRAM_BASE", "WOLFRAM_USERBASE", "WOLFRAM_LOCALBASE" }
    ];

    usable = KeyTake[ env, keys ];

    <| usable, "MCP_SERVER_NAME" -> serverName |>
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*StartMCPTestServer*)
StartMCPTestServer // ClearAll;
StartMCPTestServer // Options = {
    "ServerName" -> "WolframLanguage",
    "DevelopmentMode" -> True
};

StartMCPTestServer[ opts: OptionsPattern[ ] ] := Catch @ Module[
    { serverName, devMode, cmd, env, process },

    (* Stop any existing test server *)
    StopMCPTestServer[ ];

    serverName = OptionValue[ "ServerName" ];
    devMode = OptionValue[ "DevelopmentMode" ];
    env = GetMCPEnvironment @ serverName;

    cmd = If[ TrueQ @ devMode,
        getDevelopmentModeCommand[ ],
        GetMCPCommandLine[ ]
    ];

    If[ ! ListQ @ cmd || ! AllTrue[ cmd, StringQ ],
        Throw @ $Failed
    ];

    process = StartProcess[
        cmd,
        ProcessEnvironment -> env
    ];

    If[ ProcessStatus @ process =!= "Running",
        Throw @ $Failed
    ];

    $MCPTestProcess = process;
    $MCPRequestID = 0;

    process
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getDevelopmentModeCommand*)
getDevelopmentModeCommand // ClearAll;

getDevelopmentModeCommand[ ] := Catch @ Module[ { sourceDir, script, wolframCmd, licenseArgs },
    sourceDir = DirectoryName[ $InputFileName, 2 ];
    script = FileNameJoin @ { sourceDir, "Scripts", "StartMCPServer.wls" };

    If[ ! FileExistsQ @ script,
        Throw @ $Failed
    ];

    wolframCmd = getWolframCommand @ $OperatingSystem;
    licenseArgs = extractLicenseArgs @ $CommandLine;

    Flatten @ { wolframCmd, "-script", script, "-noinit", "-noprompt", licenseArgs }
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*StopMCPTestServer*)
StopMCPTestServer // ClearAll;

StopMCPTestServer[ ] := Module[ { process },
    process = $MCPTestProcess;
    If[ processQ @ process,
        Quiet @ KillProcess @ process
    ];
    $MCPTestProcess = None;
    $MCPRequestID = 0;
    Null
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*processQ*)
processQ // ClearAll;
processQ[ p_ProcessObject ] := ProcessStatus @ p =!= "Finished";
processQ[ _ ] := False;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*SendMCPRequest*)
SendMCPRequest // ClearAll;
SendMCPRequest // Options = { "Timeout" -> 60 };

SendMCPRequest[ method_String, opts: OptionsPattern[ ] ] :=
    SendMCPRequest[ method, <| |>, opts ];

SendMCPRequest[ method_String, params_Association, opts: OptionsPattern[ ] ] := Catch @ Module[
    { timeout, process, id, request, requestJSON, response },

    timeout = OptionValue[ "Timeout" ];
    process = $MCPTestProcess;

    If[ ! processQ @ process,
        Throw @ Failure[ "MCPTestServerNotRunning", <| "Message" -> "MCP test server is not running" |> ]
    ];

    id = ++$MCPRequestID;

    request = <|
        "jsonrpc" -> "2.0",
        "method"  -> method,
        "params"  -> params,
        "id"      -> id
    |>;

    requestJSON = Developer`WriteRawJSONString[ request, "Compact" -> True ];

    WriteLine[ process, requestJSON ];

    response = TimeConstrained[
        readJSONResponse @ process,
        timeout,
        $TimedOut
    ];

    If[ response === $TimedOut,
        Throw @ Failure[ "MCPTimeout", <|
            "MessageTemplate" :> "MCP request `1` timed out after `2` seconds.",
            "MessageParameters" -> { method, timeout }
        |> ]
    ];

    response
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readJSONResponse*)
readJSONResponse // ClearAll;

readJSONResponse[ process_ProcessObject ] := Catch @ Module[ { line, parsed },
    (* Read lines until we get a valid JSON response *)
    While[ True,
        line = ReadLine @ process;
        If[ line === EndOfFile,
            Throw @ EndOfFile
        ];
        If[ StringQ @ line && StringLength @ line > 0,
            parsed = Quiet @ Developer`ReadRawJSONString @ line;
            If[ AssociationQ @ parsed,
                Throw @ parsed
            ]
        ]
    ]
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*SendMCPNotification*)
SendMCPNotification // ClearAll;

SendMCPNotification[ method_String ] :=
    SendMCPNotification[ method, <| |> ];

SendMCPNotification[ method_String, params_Association ] := Catch @ Module[
    { process, notification, notificationJSON },

    process = $MCPTestProcess;

    If[ ! processQ @ process,
        Throw @ Failure[ "MCPTestServerNotRunning", <| "Message" -> "MCP test server is not running" |> ]
    ];

    notification = <|
        "jsonrpc" -> "2.0",
        "method"  -> method,
        "params"  -> params
    |>;

    notificationJSON = Developer`WriteRawJSONString[ notification, "Compact" -> True ];

    WriteLine[ process, notificationJSON ];

    (* Notifications don't return responses, give a small pause *)
    Pause[ 0.05 ];

    Null
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*MCPInitialize*)
MCPInitialize // ClearAll;
MCPInitialize // Options = {
    "ClientName" -> "test-client",
    "ProtocolVersion" -> "2024-11-05",
    "Timeout" -> 60
};

MCPInitialize[ opts: OptionsPattern[ ] ] := Module[
    { clientName, protocolVersion, timeout, response },

    clientName = OptionValue[ "ClientName" ];
    protocolVersion = OptionValue[ "ProtocolVersion" ];
    timeout = OptionValue[ "Timeout" ];

    response = SendMCPRequest[
        "initialize",
        <|
            "clientInfo" -> <| "name" -> clientName |>,
            "protocolVersion" -> protocolVersion
        |>,
        "Timeout" -> timeout
    ];

    If[ AssociationQ @ response && KeyExistsQ[ response, "result" ],
        SendMCPNotification[ "notifications/initialized" ]
    ];

    response
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
