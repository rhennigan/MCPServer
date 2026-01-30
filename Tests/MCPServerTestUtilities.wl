(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServerTests`MCPServerTestUtilities`" ];

`$MCPTestProcess;
`$MCPRequestID;
`$MCPTestSourceDirectory;
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

(* Source directory - should be set by the test file before calling StartMCPTestServer *)
$MCPTestSourceDirectory = None;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*GetMCPCommandLine*)
GetMCPCommandLine // ClearAll;

GetMCPCommandLine[ ] := GetMCPCommandLine @ $OperatingSystem;

GetMCPCommandLine[ os_String ] := Module[ { wolframScriptCmd },
    wolframScriptCmd = getWolframScriptCommand @ os;
    (* Use wolframscript with -code for non-development mode *)
    {
        wolframScriptCmd,
        "-code",
        "Needs[\"Wolfram`MCPServer`\"]; Wolfram`MCPServer`StartMCPServer[]"
    }
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getWolframScriptCommand*)
(* Use wolframscript instead of wolfram for proper license handling in subprocesses *)
getWolframScriptCommand // ClearAll;
getWolframScriptCommand[ "Windows" ] := FileNameJoin @ { $InstallationDirectory, "wolframscript.exe" };
getWolframScriptCommand[ "MacOSX"  ] := FileNameJoin @ { $InstallationDirectory, "MacOS", "wolframscript" };
getWolframScriptCommand[ "Unix"    ] := FileNameJoin @ { $InstallationDirectory, "Executables", "wolframscript" };
getWolframScriptCommand[ os_String ] := $Failed;


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

    If[ FailureQ @ cmd,
        Throw @ cmd
    ];

    If[ ! ListQ @ cmd || ! AllTrue[ cmd, StringQ ],
        Throw @ Failure[ "InvalidCommand", <| "Message" -> "Failed to construct valid command", "Command" -> cmd |> ]
    ];

    process = StartProcess[
        cmd,
        ProcessEnvironment -> env
    ];

    If[ ProcessStatus @ process =!= "Running",
        Throw @ Failure[ "ProcessNotRunning", <| "Message" -> "Server process failed to start", "ProcessStatus" -> ProcessStatus @ process |> ]
    ];

    (* Give the server time to initialize before accepting requests *)
    Pause[ 1.0 ];

    (* Verify the process is still running after startup *)
    If[ ProcessStatus @ process =!= "Running",
        Throw @ Failure[ "ProcessCrashed", <| "Message" -> "Server process crashed during startup" |> ]
    ];

    $MCPTestProcess = process;
    $MCPRequestID = 0;

    process
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*getDevelopmentModeCommand*)
getDevelopmentModeCommand // ClearAll;

getDevelopmentModeCommand[ ] := Catch @ Module[ { sourceDir, script, wolframScriptCmd },

    If[ ! StringQ @ $MCPTestSourceDirectory,
        Throw @ Failure[ "MCPTestSourceDirectoryNotSet", <|
            "Message" -> "$MCPTestSourceDirectory must be set before calling StartMCPTestServer"
        |> ]
    ];

    sourceDir = $MCPTestSourceDirectory;
    script = FileNameJoin @ { sourceDir, "Scripts", "StartMCPServer.wls" };

    If[ ! FileExistsQ @ script,
        Throw @ Failure[ "ScriptNotFound", <|
            "Message" -> "StartMCPServer.wls script not found at " <> script
        |> ]
    ];

    wolframScriptCmd = getWolframScriptCommand @ $OperatingSystem;

    (* Use wolframscript -f for proper license handling in subprocesses *)
    { wolframScriptCmd, "-f", script }
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

readJSONResponse[ process_ProcessObject ] := Catch @ Module[ { line, parsed, attempts },
    attempts = 0;
    (* Read lines until we get a valid JSON response *)
    While[ attempts < 1000, (* Prevent infinite loops *)
        attempts++;

        (* Check if process is still running *)
        If[ ProcessStatus @ process === "Finished",
            Throw @ Failure[ "ProcessTerminated", <| "Message" -> "Server process terminated unexpectedly" |> ]
        ];

        line = ReadLine @ process;
        If[ line === EndOfFile,
            Throw @ EndOfFile
        ];
        If[ StringQ @ line && StringLength @ line > 0,
            parsed = Quiet @ Developer`ReadRawJSONString @ line;
            If[ AssociationQ @ parsed,
                Throw @ parsed
            ]
        ];

        (* Add small delay to prevent excessive CPU usage during polling *)
        Pause[ 0.01 ]
    ];
    Throw @ Failure[ "ReadTimeout", <| "Message" -> "Failed to read JSON response after 1000 attempts" |> ]
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
