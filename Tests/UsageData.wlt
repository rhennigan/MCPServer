(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/UsageData.wlt:7,1-12,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/UsageData.wlt:14,1-19,2"
]

VerificationTest[
    Get[ FileNameJoin @ { DirectoryName @ $TestFileName, "MCPServerTestUtilities.wl" } ];
    (* Set the source directory so the test utilities can find Scripts/StartMCPServer.wls *)
    Wolfram`AgentToolsTests`MCPServerTestUtilities`$MCPTestSourceDirectory = DirectoryName[ $TestFileName, 2 ],
    _String? DirectoryQ,
    SameTest -> MatchQ,
    TestID   -> "LoadTestUtilities@@Tests/UsageData.wlt:21,1-28,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Fixtures*)
usageDataEnabledQ   = Wolfram`AgentTools`Server`UsageData`Private`usageDataEnabledQ;
booleanString       = Wolfram`AgentTools`Server`UsageData`Private`booleanString;
initializeUsageData = Wolfram`AgentTools`Server`initializeUsageData;
recordUsageData     = Wolfram`AgentTools`Server`recordUsageData;
stopUsageDataTasks  = Wolfram`AgentTools`Server`UsageData`Private`stopUsageDataTasks;
usageDataPayload    = Wolfram`AgentTools`Server`UsageData`Private`usageDataPayload;
usageDataJSON       = Wolfram`AgentTools`Server`UsageData`Private`usageDataJSON;
touchUsageStatsFile = Wolfram`AgentTools`Server`UsageData`Private`touchUsageStatsFile;
staleUsageFileQ     = Wolfram`AgentTools`Server`UsageData`Private`staleUsageFileQ;
fileAge             = Wolfram`AgentTools`Server`UsageData`Private`fileAge;
submitUsageData     = Wolfram`AgentTools`Server`UsageData`Private`submitUsageData;
submitUsagePayload  = Wolfram`AgentTools`Server`UsageData`Private`submitUsagePayload;

usageStatsFile[ ] := Wolfram`AgentTools`Server`UsageData`Private`$usageStatsFile;
usageDataPath[ ]  := Wolfram`AgentTools`Server`UsageData`Private`$usageDataPath;
sessionData[ ]    := Developer`ReadWXFFile @ usageStatsFile[ ];
usageEvents[ ]    := Internal`BagPart[ Wolfram`AgentTools`Server`$usageEvents, All ];

$testTool = LLMTool[ "PrimeFinder", { "n" -> "Integer" }, Prime[ #n ] & ];

makeTempRoot[ ] := FileNameJoin @ { $TemporaryDirectory, "AgentToolsUsageData_" <> CreateUUID[ ] };

(* Evaluates body as if inside a tracked server session (fresh session ID, data under a temporary root directory),
   then removes the directory again. *)
withUsageSession // Attributes = { HoldFirst };
withUsageSession[ body_ ] :=
    Module[ { root, result },
        root = makeTempRoot[ ];
        result = Block[
            {
                Wolfram`AgentTools`Common`$rootPath                              = root,
                Wolfram`AgentTools`Server`$usageDataEnabled                      = True,
                Wolfram`AgentTools`Server`$mcpSessionID                          = CreateUUID[ ],
                Wolfram`AgentTools`Server`$mcpClientInformation                  = Null,
                Wolfram`AgentTools`Server`$usageEvents                           = Internal`Bag[ ],
                Wolfram`AgentTools`Server`UsageData`Private`$usageDataServerName = "TestServer",
                Wolfram`AgentTools`Server`$llmTools                              = <| "PrimeFinder" -> $testTool |>,
                Wolfram`AgentTools`Server`$promptLookup                          = <| "Greet" -> <| "Name" -> "Greet", "Type" -> "Text", "Content" -> "Hello" |> |>
            },
            body
        ];
        Quiet @ DeleteDirectory[ root, DeleteContents -> True ];
        result
    ];

(* A session file for a session named `name` whose last modification was `age` ago *)
makeUsageFile[ dir_, name_, age_ ] :=
    With[ { file = FileNameJoin @ { dir, name <> ".wxf" } },
        Developer`WriteWXFFile[ file, <| "MCPSessionID" -> name, "Events" -> { } |> ];
        SetFileDate[ file, Now - age, "Modification" ];
        file
    ];

$initMessage = <|
    "jsonrpc" -> "2.0",
    "id"      -> 0,
    "method"  -> "initialize",
    "params"  -> <|
        "clientInfo"      -> <| "name" -> "test-client", "version" -> "1.2.3" |>,
        "protocolVersion" -> "2025-11-25",
        "capabilities"    -> <| "roots" -> <| |> |>
    |>
|>;

$initResponse = <| "jsonrpc" -> "2.0", "id" -> 0, "result" -> <| "protocolVersion" -> "2025-11-25" |> |>;

$toolCallMessage = <|
    "jsonrpc" -> "2.0",
    "id"      -> 1,
    "method"  -> "tools/call",
    "params"  -> <| "name" -> "PrimeFinder", "arguments" -> <| "n" -> 12345 |> |>
|>;

$toolCallResponse = <|
    "jsonrpc" -> "2.0",
    "id"      -> 1,
    "result"  -> <| "content" -> { <| "type" -> "text", "text" -> "SECRET-RESULT" |> }, "isError" -> False |>
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
VerificationTest[
    Wolfram`AgentTools`Server`UsageData`Private`$usageDataEndpoint,
    "https://www.wolframcloud.com/obj/wolframai-content/api/1.0/usage",
    SameTest -> SameQ,
    TestID   -> "UsageData-Endpoint@@Tests/UsageData.wlt:115,1-120,2"
]

(* Outside a server session nothing is tracked *)
VerificationTest[
    {
        Wolfram`AgentTools`Server`$usageDataEnabled,
        Wolfram`AgentTools`Server`$mcpSessionID,
        recordUsageData[ "tools/call", $toolCallMessage, $toolCallResponse ]
    },
    { False, None, Null },
    SameTest -> SameQ,
    TestID   -> "UsageData-DisabledOutsideServer@@Tests/UsageData.wlt:123,1-132,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*usageDataEnabledQ*)
VerificationTest[
    booleanString /@ { "true", "TRUE", " yes ", "on", "1", "false", "No", "off", "0", "", "maybe", 1, None },
    { True, True, True, True, True, False, False, False, False, None, None, None, None },
    SameTest -> SameQ,
    TestID   -> "UsageData-BooleanString@@Tests/UsageData.wlt:137,1-142,2"
]

$customServer = CreateMCPServer[
    "TestServer_UsageData_" <> CreateUUID[ ],
    LLMConfiguration @ <| "Tools" -> { $testTool } |>
];

(* Without SUBMIT_USAGE_DATA the server's "EnableUsageData" property decides *)
VerificationTest[
    environmentBlock[ "SUBMIT_USAGE_DATA" -> None,
        {
            usageDataEnabledQ @ MCPServerObject[ "Wolfram" ],
            AllTrue[ Values @ $DefaultMCPServers, usageDataEnabledQ ],
            usageDataEnabledQ @ $customServer,
            usageDataEnabledQ @ None
        }
    ],
    { True, True, False, False },
    SameTest -> SameQ,
    TestID   -> "UsageDataEnabledQ-Property@@Tests/UsageData.wlt:150,1-162,2"
]

(* An explicit boolean in SUBMIT_USAGE_DATA takes precedence over the property in both directions *)
VerificationTest[
    environmentBlock[ "SUBMIT_USAGE_DATA" -> "false",
        { usageDataEnabledQ @ MCPServerObject[ "Wolfram" ], usageDataEnabledQ @ $customServer }
    ],
    { False, False },
    SameTest -> SameQ,
    TestID   -> "UsageDataEnabledQ-EnvironmentFalse@@Tests/UsageData.wlt:165,1-172,2"
]

VerificationTest[
    environmentBlock[ "SUBMIT_USAGE_DATA" -> "true",
        { usageDataEnabledQ @ MCPServerObject[ "Wolfram" ], usageDataEnabledQ @ $customServer }
    ],
    { True, True },
    SameTest -> SameQ,
    TestID   -> "UsageDataEnabledQ-EnvironmentTrue@@Tests/UsageData.wlt:174,1-181,2"
]

(* A value that is not a boolean is ignored *)
VerificationTest[
    environmentBlock[ "SUBMIT_USAGE_DATA" -> "maybe",
        { usageDataEnabledQ @ MCPServerObject[ "Wolfram" ], usageDataEnabledQ @ $customServer }
    ],
    { True, False },
    SameTest -> SameQ,
    TestID   -> "UsageDataEnabledQ-EnvironmentNonBoolean@@Tests/UsageData.wlt:184,1-191,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*initializeUsageData*)

(* A tracked server: fresh session ID, tracking enabled, keep-alive and submission tasks started, but no file yet *)
VerificationTest[
    Module[ { root, result },
        root = makeTempRoot[ ];
        result = Block[
            {
                Wolfram`AgentTools`Common`$rootPath                             = root,
                Wolfram`AgentTools`Server`$usageDataEnabled                     = False,
                Wolfram`AgentTools`Server`$mcpSessionID                         = None,
                Wolfram`AgentTools`Server`$mcpClientInformation                 = Null,
                Wolfram`AgentTools`Server`$usageEvents                          = Internal`Bag[ ],
                Wolfram`AgentTools`Server`UsageData`Private`$usageKeepAliveTask = None,
                Wolfram`AgentTools`Server`UsageData`Private`$usageSubmitTask    = None
            },
            environmentBlock[ "SUBMIT_USAGE_DATA" -> None,
                WithCleanup[
                    {
                        initializeUsageData @ MCPServerObject[ "Wolfram" ],
                        Wolfram`AgentTools`Server`$usageDataEnabled,
                        StringMatchQ[ Wolfram`AgentTools`Server`$mcpSessionID, Repeated[ HexadecimalCharacter | "-" ] ],
                        Head @ Wolfram`AgentTools`Server`UsageData`Private`$usageKeepAliveTask,
                        Head @ Wolfram`AgentTools`Server`UsageData`Private`$usageSubmitTask,
                        Wolfram`AgentTools`Server`UsageData`Private`$usageDataServerName,
                        DirectoryQ @ usageDataPath[ ]
                    },
                    stopUsageDataTasks[ ]
                ]
            ]
        ];
        Quiet @ DeleteDirectory[ root, DeleteContents -> True ];
        result
    ],
    { True, True, True, TaskObject, TaskObject, "Wolfram", False },
    SameTest -> SameQ,
    TestID   -> "InitializeUsageData-Enabled@@Tests/UsageData.wlt:198,1-232,2"
]

(* An untracked server still gets a session ID, but nothing else happens *)
VerificationTest[
    Block[
        {
            Wolfram`AgentTools`Server`$usageDataEnabled                     = False,
            Wolfram`AgentTools`Server`$mcpSessionID                         = None,
            Wolfram`AgentTools`Server`UsageData`Private`$usageKeepAliveTask = None,
            Wolfram`AgentTools`Server`UsageData`Private`$usageSubmitTask    = None
        },
        environmentBlock[ "SUBMIT_USAGE_DATA" -> None,
            {
                initializeUsageData @ $customServer,
                Wolfram`AgentTools`Server`$usageDataEnabled,
                StringQ @ Wolfram`AgentTools`Server`$mcpSessionID,
                Wolfram`AgentTools`Server`UsageData`Private`$usageKeepAliveTask,
                Wolfram`AgentTools`Server`UsageData`Private`$usageSubmitTask
            }
        ]
    ],
    { False, False, True, None, None },
    SameTest -> SameQ,
    TestID   -> "InitializeUsageData-Disabled@@Tests/UsageData.wlt:235,1-256,2"
]

(* Opting out via the environment wins over the built-in server's property *)
VerificationTest[
    Block[
        {
            Wolfram`AgentTools`Server`$usageDataEnabled                     = False,
            Wolfram`AgentTools`Server`$mcpSessionID                         = None,
            Wolfram`AgentTools`Server`UsageData`Private`$usageKeepAliveTask = None,
            Wolfram`AgentTools`Server`UsageData`Private`$usageSubmitTask    = None
        },
        environmentBlock[ "SUBMIT_USAGE_DATA" -> "false",
            { initializeUsageData @ MCPServerObject[ "Wolfram" ], Wolfram`AgentTools`Server`$usageDataEnabled }
        ]
    ],
    { False, False },
    SameTest -> SameQ,
    TestID   -> "InitializeUsageData-OptedOut@@Tests/UsageData.wlt:259,1-274,2"
]

(* Initialization never breaks server startup, even with a bogus server *)
VerificationTest[
    Block[
        {
            Wolfram`AgentTools`Server`$usageDataEnabled                     = False,
            Wolfram`AgentTools`Server`$mcpSessionID                         = None,
            Wolfram`AgentTools`Server`UsageData`Private`$usageKeepAliveTask = None,
            Wolfram`AgentTools`Server`UsageData`Private`$usageSubmitTask    = None
        },
        environmentBlock[ "SUBMIT_USAGE_DATA" -> None, initializeUsageData @ None ]
    ],
    False,
    SameTest -> SameQ,
    TestID   -> "InitializeUsageData-InvalidServer@@Tests/UsageData.wlt:277,1-290,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Recording*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Client Information*)
VerificationTest[
    withUsageSession[
        recordUsageData[ "initialize", $initMessage, $initResponse ];
        With[ { data = sessionData[ ] },
            {
                data[ "MCPSessionID" ] === Wolfram`AgentTools`Server`$mcpSessionID,
                data[ "ClientInformation" ] === $initMessage[ "params" ],
                data[ "Events" ],
                data[ "ServerName" ],
                data[ "PacletVersion" ] === Wolfram`AgentTools`Common`$pacletVersion,
                data[ "WolframVersion" ] === $Version,
                data[ "SystemID" ] === $SystemID,
                Abs[ data[ "LastUpdated" ] - AbsoluteTime[ TimeZone -> 0 ] ] < 60,
                Sort @ Keys @ data
            }
        ]
    ],
    {
        True, True, { }, "TestServer", True, True, True, True,
        { "ClientInformation", "Events", "LastUpdated", "MCPSessionID", "PacletVersion", "ServerName", "SystemID", "WolframVersion" }
    },
    SameTest -> SameQ,
    TestID   -> "RecordUsageData-Initialize@@Tests/UsageData.wlt:299,1-322,2"
]

(* The session file is named after the session ID and lives in $rootPath/UsageData *)
VerificationTest[
    withUsageSession[
        recordUsageData[ "initialize", $initMessage, $initResponse ];
        {
            FileExistsQ @ usageStatsFile[ ],
            FileBaseName @ usageStatsFile[ ] === Wolfram`AgentTools`Server`$mcpSessionID,
            DirectoryName @ usageStatsFile[ ] === FileNameJoin @ { Wolfram`AgentTools`Common`$rootPath, "UsageData" } <> $PathnameSeparator
        }
    ],
    { True, True, True },
    SameTest -> SameQ,
    TestID   -> "RecordUsageData-SessionFileLocation@@Tests/UsageData.wlt:325,1-337,2"
]

(* Malformed initialize parameters are stored as Null rather than failing *)
VerificationTest[
    withUsageSession[
        recordUsageData[ "initialize", <| "method" -> "initialize", "params" -> "bogus" |>, $initResponse ];
        sessionData[ ][ "ClientInformation" ]
    ],
    Null,
    SameTest -> SameQ,
    TestID   -> "RecordUsageData-InitializeInvalidParams@@Tests/UsageData.wlt:340,1-348,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tool Calls*)
VerificationTest[
    withUsageSession[
        recordUsageData[ "tools/call", $toolCallMessage, $toolCallResponse ];
        sessionData[ ][ "Events" ]
    ],
    { KeyValuePattern @ { "Type" -> "ToolCall", "Name" -> "PrimeFinder", "Success" -> True, "Timestamp" -> _Real } },
    SameTest -> MatchQ,
    TestID   -> "RecordUsageData-ToolCallSuccess@@Tests/UsageData.wlt:353,1-361,2"
]

VerificationTest[
    withUsageSession[
        recordUsageData[ "tools/call", $toolCallMessage, $toolCallResponse ];
        With[ { event = First @ sessionData[ ][ "Events" ] },
            { Sort @ Keys @ event, Abs[ event[ "Timestamp" ] - AbsoluteTime[ TimeZone -> 0 ] ] < 60 }
        ]
    ],
    { { "Name", "Success", "Timestamp", "Type" }, True },
    SameTest -> SameQ,
    TestID   -> "RecordUsageData-ToolCallEventShape@@Tests/UsageData.wlt:363,1-373,2"
]

(* Neither arguments nor results are recorded *)
VerificationTest[
    withUsageSession[
        recordUsageData[ "tools/call", $toolCallMessage, $toolCallResponse ];
        With[ { data = sessionData[ ] },
            { FreeQ[ data, 12345 ], FreeQ[ data, "arguments" ], FreeQ[ data, "SECRET-RESULT" ], FreeQ[ data, "content" ] }
        ]
    ],
    { True, True, True, True },
    SameTest -> SameQ,
    TestID   -> "RecordUsageData-ToolCallNoParameters@@Tests/UsageData.wlt:376,1-386,2"
]

(* Failures: tool errors, unknown tools (name not recorded), internal failures, and JSON-RPC errors *)
VerificationTest[
    withUsageSession[
        recordUsageData[ "tools/call", $toolCallMessage, <| "result" -> <| "content" -> { }, "isError" -> True |> |> ];
        recordUsageData[ "tools/call", <| "params" -> <| "name" -> "NoSuchTool", "arguments" -> <| "n" -> 1 |> |> |>, <| "result" -> <| "content" -> { }, "isError" -> True |> |> ];
        recordUsageData[ "tools/call", $toolCallMessage, Failure[ "AgentTools::Internal", <| |> ] ];
        recordUsageData[ "tools/call", $toolCallMessage, <| "error" -> <| "code" -> -32603, "message" -> "Internal error" |> |> ];
        recordUsageData[ "tools/call", <| "params" -> <| |> |>, <| "result" -> <| "isError" -> True |> |> ];
        Lookup[ sessionData[ ][ "Events" ], { "Name", "Success" } ]
    ],
    { { "PrimeFinder", False }, { Null, False }, { "PrimeFinder", False }, { "PrimeFinder", False }, { Null, False } },
    SameTest -> SameQ,
    TestID   -> "RecordUsageData-ToolCallFailures@@Tests/UsageData.wlt:389,1-401,2"
]

(* Events accumulate in order, and the file always holds all of them *)
VerificationTest[
    withUsageSession[
        recordUsageData[ "initialize", $initMessage, $initResponse ];
        recordUsageData[ "tools/call", $toolCallMessage, $toolCallResponse ];
        recordUsageData[ "tools/call", $toolCallMessage, <| "result" -> <| "content" -> { }, "isError" -> True |> |> ];
        recordUsageData[ "tools/call", $toolCallMessage, $toolCallResponse ];
        { Lookup[ sessionData[ ][ "Events" ], "Success" ], Length @ usageEvents[ ], sessionData[ ][ "ClientInformation" ] === $initMessage[ "params" ] }
    ],
    { { True, False, True }, 3, True },
    SameTest -> SameQ,
    TestID   -> "RecordUsageData-EventsAccumulate@@Tests/UsageData.wlt:404,1-415,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Prompts*)
VerificationTest[
    withUsageSession[
        recordUsageData[ "prompts/get", <| "params" -> <| "name" -> "Greet", "arguments" -> <| "who" -> "SECRET" |> |> |>, <| "result" -> <| "messages" -> { } |> |> ];
        recordUsageData[ "prompts/get", <| "params" -> <| "name" -> "NoSuchPrompt" |> |>, Failure[ "AgentTools::Internal", <| |> ] ];
        With[ { data = sessionData[ ] },
            { Lookup[ data[ "Events" ], { "Type", "Name", "Success" } ], FreeQ[ data, "SECRET" ], FreeQ[ data, "who" ] }
        ]
    ],
    { { { "PromptGet", "Greet", True }, { "PromptGet", Null, False } }, True, True },
    SameTest -> SameQ,
    TestID   -> "RecordUsageData-Prompts@@Tests/UsageData.wlt:420,1-431,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Other Requests and Disabled Tracking*)
VerificationTest[
    withUsageSession[
        recordUsageData[ "tools/list", <| "params" -> <| |> |>, <| "result" -> <| "tools" -> { } |> |> ];
        recordUsageData[ "ping", <| |>, <| "result" -> <| |> |> ];
        recordUsageData[ "resources/list", <| |>, <| "result" -> <| "resources" -> { } |> |> ];
        recordUsageData[ "notifications/initialized", <| |>, Null ];
        recordUsageData[ None, <| |>, Null ];
        { FileExistsQ @ usageStatsFile[ ], Length @ usageEvents[ ] }
    ],
    { False, 0 },
    SameTest -> SameQ,
    TestID   -> "RecordUsageData-OtherMethodsIgnored@@Tests/UsageData.wlt:436,1-448,2"
]

VerificationTest[
    withUsageSession[
        Block[ { Wolfram`AgentTools`Server`$usageDataEnabled = False },
            {
                recordUsageData[ "initialize", $initMessage, $initResponse ],
                recordUsageData[ "tools/call", $toolCallMessage, $toolCallResponse ],
                FileExistsQ @ usageStatsFile[ ],
                DirectoryQ @ usageDataPath[ ],
                Wolfram`AgentTools`Server`$mcpClientInformation,
                Length @ usageEvents[ ]
            }
        ]
    ],
    { Null, Null, False, False, Null, 0 },
    SameTest -> SameQ,
    TestID   -> "RecordUsageData-DisabledRecordsNothing@@Tests/UsageData.wlt:450,1-466,2"
]

(* The number of events per session is capped *)
VerificationTest[
    withUsageSession[
        Block[ { Wolfram`AgentTools`Server`UsageData`Private`$usageDataMaxEvents = 3 },
            Do[ recordUsageData[ "tools/call", $toolCallMessage, $toolCallResponse ], 5 ];
            { Length @ usageEvents[ ], Length @ sessionData[ ][ "Events" ] }
        ]
    ],
    { 3, 3 },
    SameTest -> SameQ,
    TestID   -> "RecordUsageData-EventLimit@@Tests/UsageData.wlt:469,1-479,2"
]

(* A failure while recording (here: the session file cannot be written) is swallowed and never propagates to the
   read loop; the event itself is still kept in memory *)
VerificationTest[
    withUsageSession[
        Block[ { Wolfram`AgentTools`Common`writeWXFFile = $Failed & },
            { recordUsageData[ "tools/call", $toolCallMessage, $toolCallResponse ], Length @ usageEvents[ ] }
        ]
    ],
    { _Failure, 1 },
    SameTest -> MatchQ,
    TestID   -> "RecordUsageData-FailuresAreIsolated@@Tests/UsageData.wlt:483,1-492,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*JSON Payload*)
VerificationTest[
    withUsageSession[
        recordUsageData[ "initialize", $initMessage, $initResponse ];
        recordUsageData[ "tools/call", $toolCallMessage, $toolCallResponse ];
        recordUsageData[ "tools/call", <| "params" -> <| "name" -> "NoSuchTool" |> |>, <| "result" -> <| "isError" -> True |> |> ];
        Developer`ReadRawJSONString @ usageDataJSON @ usageDataPayload[ ]
    ],
    KeyValuePattern @ {
        "MCPSessionID"      -> _String,
        "ServerName"        -> "TestServer",
        "ClientInformation" -> KeyValuePattern[ "clientInfo" -> KeyValuePattern[ "name" -> "test-client" ] ],
        "Events"            -> {
            KeyValuePattern @ { "Type" -> "ToolCall", "Name" -> "PrimeFinder", "Success" -> True, "Timestamp" -> _Real },
            KeyValuePattern @ { "Type" -> "ToolCall", "Name" -> Null, "Success" -> False }
        },
        "PacletVersion"     -> _String,
        "WolframVersion"    -> _String,
        "SystemID"          -> _String,
        "LastUpdated"       -> _Real
    },
    SameTest -> MatchQ,
    TestID   -> "UsageData-JSONPayload@@Tests/UsageData.wlt:497,1-519,2"
]

(* The JSON is exactly what is stored in the session file *)
VerificationTest[
    withUsageSession[
        recordUsageData[ "initialize", $initMessage, $initResponse ];
        recordUsageData[ "tools/call", $toolCallMessage, $toolCallResponse ];
        With[ { stored = sessionData[ ] },
            KeyDrop[ Developer`ReadRawJSONString @ usageDataJSON @ stored, "LastUpdated" ] === KeyDrop[ stored, "LastUpdated" ]
        ]
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "UsageData-JSONRoundTrip@@Tests/UsageData.wlt:522,1-533,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Keep-Alive*)
VerificationTest[
    withUsageSession[
        recordUsageData[ "initialize", $initMessage, $initResponse ];
        SetFileDate[ usageStatsFile[ ], Now - Quantity[ 2, "Hours" ], "Modification" ];
        {
            fileAge @ usageStatsFile[ ] > 3600,
            touchUsageStatsFile[ ] === usageStatsFile[ ],
            fileAge @ usageStatsFile[ ] < 60,
            sessionData[ ][ "ClientInformation" ] === $initMessage[ "params" ] (* touching does not rewrite the data *)
        }
    ],
    { True, True, True, True },
    SameTest -> SameQ,
    TestID   -> "UsageData-KeepAliveTouchesFile@@Tests/UsageData.wlt:538,1-552,2"
]

VerificationTest[
    withUsageSession[ { touchUsageStatsFile[ ], FileExistsQ @ usageStatsFile[ ] } ],
    { Null, False },
    SameTest -> SameQ,
    TestID   -> "UsageData-KeepAliveWithoutFile@@Tests/UsageData.wlt:554,1-559,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Finished Sessions*)
VerificationTest[
    withUsageSession[
        recordUsageData[ "initialize", $initMessage, $initResponse ];
        With[ { other = FileNameJoin @ { usageDataPath[ ], "other-session.wxf" } },
            CopyFile[ usageStatsFile[ ], other ];
            SetFileDate[ other, Now - Quantity[ 25, "Hours" ], "Modification" ];
            SetFileDate[ usageStatsFile[ ], Now - Quantity[ 25, "Hours" ], "Modification" ];
            {
                staleUsageFileQ @ other,
                staleUsageFileQ @ usageStatsFile[ ], (* the current session is never considered finished *)
                (SetFileDate @ other; staleUsageFileQ @ other)
            }
        ]
    ],
    { True, False, False },
    SameTest -> SameQ,
    TestID   -> "UsageData-StaleUsageFileQ@@Tests/UsageData.wlt:564,1-581,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Submission*)

(* Finished sessions are submitted (oldest first) and deleted; expired and unreadable files are discarded without
   submission; the fresh session stays; the lock is released. *)
VerificationTest[
    Module[ { root, dir, submitted = { }, result, remaining, lockLeft },
        root = makeTempRoot[ ];
        dir  = FileNameJoin @ { root, "UsageData" };
        CreateDirectory[ dir, CreateIntermediateDirectories -> True ];
        makeUsageFile[ dir, "finished", Quantity[ 25, "Hours" ] ];
        makeUsageFile[ dir, "older"   , Quantity[ 3, "Days" ] ];
        makeUsageFile[ dir, "fresh"   , Quantity[ 1, "Hours" ] ];
        makeUsageFile[ dir, "expired" , Quantity[ 31, "Days" ] ];
        Export[ FileNameJoin @ { dir, "corrupt.wxf" }, "this is not WXF", "Text" ];
        SetFileDate[ FileNameJoin @ { dir, "corrupt.wxf" }, Now - Quantity[ 25, "Hours" ], "Modification" ];
        result = Block[
            {
                Wolfram`AgentTools`Common`$rootPath                            = root,
                Wolfram`AgentTools`Server`$mcpSessionID                        = None,
                Wolfram`AgentTools`Server`UsageData`Private`submitUsagePayload = Function[ AppendTo[ submitted, #MCPSessionID ]; True ]
            },
            submitUsageData[ ]
        ];
        remaining = FileBaseName /@ FileNames[ "*.wxf", dir ];
        lockLeft  = FileExistsQ @ FileNameJoin @ { dir, "Submit.lock" };
        Quiet @ DeleteDirectory[ root, DeleteContents -> True ];
        { Sort[ FileBaseName /@ result ], submitted, remaining, lockLeft }
    ],
    { { "corrupt", "expired", "finished", "older" }, { "older", "finished" }, { "fresh" }, False },
    SameTest -> SameQ,
    TestID   -> "SubmitUsageData-SubmitsFinishedSessions@@Tests/UsageData.wlt:589,1-616,2"
]

(* A failed submission keeps the file and stops the batch *)
VerificationTest[
    Module[ { root, dir, calls = 0, result, remaining },
        root = makeTempRoot[ ];
        dir  = FileNameJoin @ { root, "UsageData" };
        CreateDirectory[ dir, CreateIntermediateDirectories -> True ];
        makeUsageFile[ dir, "first" , Quantity[ 26, "Hours" ] ];
        makeUsageFile[ dir, "second", Quantity[ 25, "Hours" ] ];
        result = Block[
            {
                Wolfram`AgentTools`Common`$rootPath                            = root,
                Wolfram`AgentTools`Server`$mcpSessionID                        = None,
                Wolfram`AgentTools`Server`UsageData`Private`submitUsagePayload = Function[ calls++; False ]
            },
            submitUsageData[ ]
        ];
        remaining = Sort[ FileBaseName /@ FileNames[ "*.wxf", dir ] ];
        Quiet @ DeleteDirectory[ root, DeleteContents -> True ];
        { result, calls, remaining }
    ],
    { { }, 1, { "first", "second" } },
    SameTest -> SameQ,
    TestID   -> "SubmitUsageData-FailureStopsBatch@@Tests/UsageData.wlt:619,1-641,2"
]

(* While another process holds the lock, this one skips its turn without waiting long *)
VerificationTest[
    Module[ { root, dir, calls = 0, timing, result, remaining },
        root = makeTempRoot[ ];
        dir  = FileNameJoin @ { root, "UsageData" };
        CreateDirectory[ dir, CreateIntermediateDirectories -> True ];
        makeUsageFile[ dir, "finished", Quantity[ 25, "Hours" ] ];
        Put[ <| "Header" -> "held by another process" |>, FileNameJoin @ { dir, "Submit.lock" } ];
        { timing, result } = AbsoluteTiming @ Block[
            {
                Wolfram`AgentTools`Common`$rootPath                            = root,
                Wolfram`AgentTools`Server`$mcpSessionID                        = None,
                Wolfram`AgentTools`Server`UsageData`Private`submitUsagePayload = Function[ calls++; True ]
            },
            submitUsageData[ ]
        ];
        remaining = FileBaseName /@ FileNames[ "*.wxf", dir ];
        Quiet @ DeleteDirectory[ root, DeleteContents -> True ];
        { result, calls, remaining, timing < 30 }
    ],
    { { }, 0, { "finished" }, True },
    SameTest -> SameQ,
    TestID   -> "SubmitUsageData-LockHeld@@Tests/UsageData.wlt:644,1-666,2"
]

VerificationTest[
    submitUsageData @ FileNameJoin @ { $TemporaryDirectory, "does-not-exist-" <> CreateUUID[ ] },
    { },
    SameTest -> SameQ,
    TestID   -> "SubmitUsageData-NoDirectory@@Tests/UsageData.wlt:668,1-673,2"
]

(* The current session's file is never submitted, even when it looks old *)
VerificationTest[
    withUsageSession[
        Module[ { calls = 0, result, remaining },
            recordUsageData[ "initialize", $initMessage, $initResponse ];
            SetFileDate[ usageStatsFile[ ], Now - Quantity[ 25, "Hours" ], "Modification" ];
            result = Block[
                { Wolfram`AgentTools`Server`UsageData`Private`submitUsagePayload = Function[ calls++; True ] },
                submitUsageData[ ]
            ];
            { result, calls, FileExistsQ @ usageStatsFile[ ] }
        ]
    ],
    { { }, 0, True },
    SameTest -> SameQ,
    TestID   -> "SubmitUsageData-CurrentSessionExcluded@@Tests/UsageData.wlt:676,1-691,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*HTTP Request*)

(* An unreachable endpoint reports failure (and nothing is thrown) *)
VerificationTest[
    Block[
        {
            Wolfram`AgentTools`Server`UsageData`Private`$usageDataEndpoint      = "http://127.0.0.1:9/usage",
            Wolfram`AgentTools`Server`UsageData`Private`$usageDataSubmitTimeout = 2
        },
        submitUsagePayload @ <| "MCPSessionID" -> "test", "Events" -> { } |>
    ],
    False,
    SameTest -> SameQ,
    TestID   -> "SubmitUsagePayload-Unreachable@@Tests/UsageData.wlt:698,1-709,2"
]

(* The development endpoint accepts a JSON body (skipped on CI, where network access is not guaranteed) *)
skipIfGitHubActions @ VerificationTest[
    submitUsagePayload @ <|
        "MCPSessionID"      -> "AgentToolsTestSuite-" <> CreateUUID[ ],
        "ServerName"        -> "AgentToolsTestSuite",
        "ClientInformation" -> Null,
        "Events"            -> { },
        "PacletVersion"     -> Wolfram`AgentTools`Common`$pacletVersion,
        "WolframVersion"    -> $Version,
        "SystemID"          -> $SystemID,
        "LastUpdated"       -> AbsoluteTime[ TimeZone -> 0 ]
    |>,
    True,
    SameTest -> SameQ,
    TestID   -> "SubmitUsagePayload-Endpoint@@Tests/UsageData.wlt:712,23-726,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Server Integration*)

(* Note: These integration tests spawn a subprocess running the MCP server and communicate via JSON-RPC. As in
   StartMCPServer.wlt, they are skipped when running as a script (see skipIfScript). Test servers get
   SUBMIT_USAGE_DATA=false by default (see GetMCPEnvironment), so the tracked session here opts in explicitly. *)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tracked Session*)
skipIfScript @ VerificationTest[
    $usageProcess = StartMCPTestServer[
        "ServerName"  -> "WolframLanguage",
        "Environment" -> <| "SUBMIT_USAGE_DATA" -> "true" |>
    ],
    _ProcessObject,
    SameTest -> MatchQ,
    TestID   -> "UsageData-Integration-ServerStarts@@Tests/UsageData.wlt:739,16-747,2"
]

skipIfScript @ VerificationTest[
    $usageClientName = "usage-data-test-" <> CreateUUID[ ];
    MCPInitialize[ "ClientName" -> $usageClientName ],
    KeyValuePattern[ "result" -> _Association ],
    SameTest -> MatchQ,
    TestID   -> "UsageData-Integration-Initialize@@Tests/UsageData.wlt:749,16-755,2"
]

skipIfScript @ VerificationTest[
    SendMCPRequest[ "tools/call", <| "name" -> "WolframLanguageEvaluator", "arguments" -> <| "code" -> "Prime[1000]" |> |> ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "isError" -> False ] ],
    SameTest -> MatchQ,
    TestID   -> "UsageData-Integration-ToolCall@@Tests/UsageData.wlt:757,16-762,2"
]

skipIfScript @ VerificationTest[
    SendMCPRequest[ "tools/call", <| "name" -> "NoSuchTool", "arguments" -> <| |> |> ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "isError" -> True ] ],
    SameTest -> MatchQ,
    TestID   -> "UsageData-Integration-UnknownToolCall@@Tests/UsageData.wlt:764,16-769,2"
]

skipIfScript @ VerificationTest[
    SendMCPRequest[ "prompts/get", <| "name" -> "NoSuchPrompt", "arguments" -> <| |> |> ],
    KeyValuePattern[ "error" -> _Association ],
    SameTest -> MatchQ,
    TestID   -> "UsageData-Integration-UnknownPrompt@@Tests/UsageData.wlt:771,16-776,2"
]

skipIfScript @ VerificationTest[
    $usageFile = SelectFirst[
        FileNames[ "*.wxf", FileNameJoin @ { Wolfram`AgentTools`Common`$rootPath, "UsageData" } ],
        Quiet[ Developer`ReadWXFFile[ # ][ "ClientInformation", "clientInfo", "name" ] ] === $usageClientName &
    ],
    _String? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "UsageData-Integration-SessionFileWritten@@Tests/UsageData.wlt:778,16-786,2"
]

skipIfScript @ VerificationTest[
    $usageSession = Developer`ReadWXFFile @ $usageFile;
    $usageSession[ "Events" ],
    {
        KeyValuePattern @ { "Type" -> "ToolCall" , "Name" -> "WolframLanguageEvaluator", "Success" -> True, "Timestamp" -> _Real },
        KeyValuePattern @ { "Type" -> "ToolCall" , "Name" -> Null, "Success" -> False },
        KeyValuePattern @ { "Type" -> "PromptGet", "Name" -> Null, "Success" -> False }
    },
    SameTest -> MatchQ,
    TestID   -> "UsageData-Integration-Events@@Tests/UsageData.wlt:788,16-798,2"
]

skipIfScript @ VerificationTest[
    {
        $usageSession[ "ServerName" ],
        $usageSession[ "ClientInformation", "protocolVersion" ],
        StringQ @ $usageSession[ "MCPSessionID" ],
        FreeQ[ $usageSession, "Prime[1000]" ]
    },
    { "WolframLanguage", "2024-11-05", True, True },
    SameTest -> SameQ,
    TestID   -> "UsageData-Integration-Payload@@Tests/UsageData.wlt:800,16-810,2"
]

skipIfScript @ VerificationTest[
    StopMCPTestServer[ ];
    Quiet @ DeleteFile @ $usageFile;
    FileExistsQ @ $usageFile,
    False,
    SameTest -> SameQ,
    TestID   -> "UsageData-Integration-Cleanup@@Tests/UsageData.wlt:812,16-819,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Opted-Out Session*)
skipIfScript @ VerificationTest[
    $usageProcess = StartMCPTestServer[ "ServerName" -> "WolframLanguage" ]; (* SUBMIT_USAGE_DATA=false *)
    $usageClientName = "usage-data-test-" <> CreateUUID[ ];
    MCPInitialize[ "ClientName" -> $usageClientName ];
    SendMCPRequest[ "tools/call", <| "name" -> "WolframLanguageEvaluator", "arguments" -> <| "code" -> "1 + 1" |> |> ];
    StopMCPTestServer[ ];
    SelectFirst[
        FileNames[ "*.wxf", FileNameJoin @ { Wolfram`AgentTools`Common`$rootPath, "UsageData" } ],
        Quiet[ Developer`ReadWXFFile[ # ][ "ClientInformation", "clientInfo", "name" ] ] === $usageClientName &
    ],
    _Missing,
    SameTest -> MatchQ,
    TestID   -> "UsageData-Integration-OptedOutWritesNothing@@Tests/UsageData.wlt:824,16-837,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    DeleteObject @ $customServer,
    Null,
    SameTest -> MatchQ,
    TestID   -> "UsageData-Cleanup@@Tests/UsageData.wlt:842,1-847,2"
]

(* :!CodeAnalysis::EndBlock:: *)
