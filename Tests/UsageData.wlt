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
getGlobalUsageDataSetting = Wolfram`AgentTools`Common`getGlobalUsageDataSetting;
setGlobalUsageDataSetting = Wolfram`AgentTools`Common`setGlobalUsageDataSetting;

usageStatsFile[ ] := Wolfram`AgentTools`Server`UsageData`Private`$usageStatsFile;
usageDataPath[ ]  := Wolfram`AgentTools`Server`UsageData`Private`$usageDataPath;
sessionData[ ]    := Developer`ReadWXFFile @ usageStatsFile[ ];
usageEvents[ ]    := Internal`BagPart[ Wolfram`AgentTools`Server`$usageEvents, All ];
globalSettingsFile[ ] := Wolfram`AgentTools`Common`$globalSettingsFile;

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
    TestID   -> "UsageData-Endpoint@@Tests/UsageData.wlt:118,1-123,2"
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
    TestID   -> "UsageData-DisabledOutsideServer@@Tests/UsageData.wlt:126,1-135,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Global Setting*)
(* The preferences panel's checkbox stores its state as the "SubmitUsageData" entry of the global settings file
   ($rootPath/GlobalSettings.wxf), which is read again by every server session when it starts. *)

(* Nothing stored means the default: usage data is shared, and no file is created just by asking *)
VerificationTest[
    withTemporaryRoot @ { getGlobalUsageDataSetting[ ], FileExistsQ @ globalSettingsFile[ ] },
    { True, False },
    SameTest -> SameQ,
    TestID   -> "GlobalUsageDataSetting-Default@@Tests/UsageData.wlt:144,1-149,2"
]

(* Opting out and back in *)
VerificationTest[
    withTemporaryRoot @ {
        setGlobalUsageDataSetting[ False ],
        getGlobalUsageDataSetting[ ],
        Developer`ReadWXFFile @ globalSettingsFile[ ],
        setGlobalUsageDataSetting[ True ],
        getGlobalUsageDataSetting[ ],
        Developer`ReadWXFFile @ globalSettingsFile[ ]
    },
    { False, False, <| "SubmitUsageData" -> False |>, True, True, <| "SubmitUsageData" -> True |> },
    SameTest -> SameQ,
    TestID   -> "GlobalUsageDataSetting-SetAndGet@@Tests/UsageData.wlt:152,1-164,2"
]

(* Other global settings in the file are left alone *)
VerificationTest[
    withTemporaryRoot @ (
        Wolfram`AgentTools`Common`setGlobalSetting[ "Other", 1 ];
        setGlobalUsageDataSetting[ False ];
        Developer`ReadWXFFile @ globalSettingsFile[ ]
    ),
    <| "Other" -> 1, "SubmitUsageData" -> False |>,
    SameTest -> SameQ,
    TestID   -> "GlobalUsageDataSetting-PreservesOtherSettings@@Tests/UsageData.wlt:167,1-176,2"
]

(* Only an explicit False opts out *)
VerificationTest[
    withTemporaryRoot @ (
        Wolfram`AgentTools`Common`setGlobalSetting[ "SubmitUsageData", "no" ];
        getGlobalUsageDataSetting[ ]
    ),
    True,
    SameTest -> SameQ,
    TestID   -> "GlobalUsageDataSetting-NonBooleanIgnored@@Tests/UsageData.wlt:179,1-187,2"
]

(* The setting can only be set to a boolean *)
VerificationTest[
    withTemporaryRoot @ Wolfram`AgentTools`Common`catchTop @ setGlobalUsageDataSetting[ "no" ],
    Failure[ "AgentTools::Internal", _ ],
    { General::AgentToolsInternal },
    SameTest -> MatchQ,
    TestID   -> "GlobalUsageDataSetting-InvalidValue@@Tests/UsageData.wlt:190,1-196,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*usageDataEnabledQ*)
VerificationTest[
    booleanString /@ { "true", "TRUE", " yes ", "on", "1", "false", "No", "off", "0", "", "maybe", 1, None },
    { True, True, True, True, True, False, False, False, False, None, None, None, None },
    SameTest -> SameQ,
    TestID   -> "UsageData-BooleanString@@Tests/UsageData.wlt:201,1-206,2"
]

$customServer = CreateMCPServer[
    "TestServer_UsageData_" <> CreateUUID[ ],
    LLMConfiguration @ <| "Tools" -> { $testTool } |>
];

(* Without SUBMIT_USAGE_DATA (and without a global opt-out) the server's "EnableUsageData" property decides *)
VerificationTest[
    withTemporaryRoot @ environmentBlock[ "SUBMIT_USAGE_DATA" -> None,
        {
            usageDataEnabledQ @ MCPServerObject[ "Wolfram" ],
            AllTrue[ Values @ $DefaultMCPServers, usageDataEnabledQ ],
            usageDataEnabledQ @ $customServer,
            usageDataEnabledQ @ None
        }
    ],
    { True, True, False, False },
    SameTest -> SameQ,
    TestID   -> "UsageDataEnabledQ-Property@@Tests/UsageData.wlt:214,1-226,2"
]

(* An explicit boolean in SUBMIT_USAGE_DATA takes precedence over the property in both directions *)
VerificationTest[
    environmentBlock[ "SUBMIT_USAGE_DATA" -> "false",
        { usageDataEnabledQ @ MCPServerObject[ "Wolfram" ], usageDataEnabledQ @ $customServer }
    ],
    { False, False },
    SameTest -> SameQ,
    TestID   -> "UsageDataEnabledQ-EnvironmentFalse@@Tests/UsageData.wlt:229,1-236,2"
]

VerificationTest[
    environmentBlock[ "SUBMIT_USAGE_DATA" -> "true",
        { usageDataEnabledQ @ MCPServerObject[ "Wolfram" ], usageDataEnabledQ @ $customServer }
    ],
    { True, True },
    SameTest -> SameQ,
    TestID   -> "UsageDataEnabledQ-EnvironmentTrue@@Tests/UsageData.wlt:238,1-245,2"
]

(* A value that is not a boolean is ignored *)
VerificationTest[
    withTemporaryRoot @ environmentBlock[ "SUBMIT_USAGE_DATA" -> "maybe",
        { usageDataEnabledQ @ MCPServerObject[ "Wolfram" ], usageDataEnabledQ @ $customServer }
    ],
    { True, False },
    SameTest -> SameQ,
    TestID   -> "UsageDataEnabledQ-EnvironmentNonBoolean@@Tests/UsageData.wlt:248,1-255,2"
]

(* A global opt-out (the preferences panel's checkbox) turns tracking off for the built-in servers... *)
VerificationTest[
    withTemporaryRoot @ (
        setGlobalUsageDataSetting[ False ];
        environmentBlock[ "SUBMIT_USAGE_DATA" -> None,
            {
                usageDataEnabledQ @ MCPServerObject[ "Wolfram" ],
                AnyTrue[ Values @ $DefaultMCPServers, usageDataEnabledQ ],
                usageDataEnabledQ @ $customServer
            }
        ]
    ),
    { False, False, False },
    SameTest -> SameQ,
    TestID   -> "UsageDataEnabledQ-GlobalOptOut@@Tests/UsageData.wlt:258,1-272,2"
]

(* ...but an explicit boolean in SUBMIT_USAGE_DATA still takes precedence over it *)
VerificationTest[
    withTemporaryRoot @ (
        setGlobalUsageDataSetting[ False ];
        {
            environmentBlock[ "SUBMIT_USAGE_DATA" -> "true",
                { usageDataEnabledQ @ MCPServerObject[ "Wolfram" ], usageDataEnabledQ @ $customServer }
            ],
            environmentBlock[ "SUBMIT_USAGE_DATA" -> "maybe",
                { usageDataEnabledQ @ MCPServerObject[ "Wolfram" ], usageDataEnabledQ @ $customServer }
            ]
        }
    ),
    { { True, True }, { False, False } },
    SameTest -> SameQ,
    TestID   -> "UsageDataEnabledQ-GlobalOptOutEnvironmentPrecedence@@Tests/UsageData.wlt:275,1-290,2"
]

(* Opting back in restores the default *)
VerificationTest[
    withTemporaryRoot @ (
        setGlobalUsageDataSetting[ False ];
        setGlobalUsageDataSetting[ True ];
        environmentBlock[ "SUBMIT_USAGE_DATA" -> None,
            { usageDataEnabledQ @ MCPServerObject[ "Wolfram" ], usageDataEnabledQ @ $customServer }
        ]
    ),
    { True, False },
    SameTest -> SameQ,
    TestID   -> "UsageDataEnabledQ-GlobalOptIn@@Tests/UsageData.wlt:293,1-304,2"
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
    TestID   -> "InitializeUsageData-Enabled@@Tests/UsageData.wlt:311,1-345,2"
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
    TestID   -> "InitializeUsageData-Disabled@@Tests/UsageData.wlt:348,1-369,2"
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
    TestID   -> "InitializeUsageData-OptedOut@@Tests/UsageData.wlt:372,1-387,2"
]

(* A global opt-out (the preferences panel's checkbox) is read when the server starts *)
VerificationTest[
    withTemporaryRoot @ Block[
        {
            Wolfram`AgentTools`Server`$usageDataEnabled                     = False,
            Wolfram`AgentTools`Server`$mcpSessionID                         = None,
            Wolfram`AgentTools`Server`UsageData`Private`$usageKeepAliveTask = None,
            Wolfram`AgentTools`Server`UsageData`Private`$usageSubmitTask    = None
        },
        setGlobalUsageDataSetting[ False ];
        environmentBlock[ "SUBMIT_USAGE_DATA" -> None,
            {
                initializeUsageData @ MCPServerObject[ "Wolfram" ],
                Wolfram`AgentTools`Server`$usageDataEnabled,
                StringQ @ Wolfram`AgentTools`Server`$mcpSessionID,
                Wolfram`AgentTools`Server`UsageData`Private`$usageKeepAliveTask,
                Wolfram`AgentTools`Server`UsageData`Private`$usageSubmitTask
            }
        ]
    ],
    { False, False, True, None, None },
    SameTest -> SameQ,
    TestID   -> "InitializeUsageData-GlobalOptOut@@Tests/UsageData.wlt:390,1-412,2"
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
    TestID   -> "InitializeUsageData-InvalidServer@@Tests/UsageData.wlt:415,1-428,2"
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
    TestID   -> "RecordUsageData-Initialize@@Tests/UsageData.wlt:437,1-460,2"
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
    TestID   -> "RecordUsageData-SessionFileLocation@@Tests/UsageData.wlt:463,1-475,2"
]

(* Malformed initialize parameters are stored as Null rather than failing *)
VerificationTest[
    withUsageSession[
        recordUsageData[ "initialize", <| "method" -> "initialize", "params" -> "bogus" |>, $initResponse ];
        sessionData[ ][ "ClientInformation" ]
    ],
    Null,
    SameTest -> SameQ,
    TestID   -> "RecordUsageData-InitializeInvalidParams@@Tests/UsageData.wlt:478,1-486,2"
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
    TestID   -> "RecordUsageData-ToolCallSuccess@@Tests/UsageData.wlt:491,1-499,2"
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
    TestID   -> "RecordUsageData-ToolCallEventShape@@Tests/UsageData.wlt:501,1-511,2"
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
    TestID   -> "RecordUsageData-ToolCallNoParameters@@Tests/UsageData.wlt:514,1-524,2"
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
    TestID   -> "RecordUsageData-ToolCallFailures@@Tests/UsageData.wlt:527,1-539,2"
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
    TestID   -> "RecordUsageData-EventsAccumulate@@Tests/UsageData.wlt:542,1-553,2"
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
    TestID   -> "RecordUsageData-Prompts@@Tests/UsageData.wlt:558,1-569,2"
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
    TestID   -> "RecordUsageData-OtherMethodsIgnored@@Tests/UsageData.wlt:574,1-586,2"
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
    TestID   -> "RecordUsageData-DisabledRecordsNothing@@Tests/UsageData.wlt:588,1-604,2"
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
    TestID   -> "RecordUsageData-EventLimit@@Tests/UsageData.wlt:607,1-617,2"
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
    TestID   -> "RecordUsageData-FailuresAreIsolated@@Tests/UsageData.wlt:621,1-630,2"
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
    TestID   -> "UsageData-JSONPayload@@Tests/UsageData.wlt:635,1-657,2"
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
    TestID   -> "UsageData-JSONRoundTrip@@Tests/UsageData.wlt:660,1-671,2"
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
    TestID   -> "UsageData-KeepAliveTouchesFile@@Tests/UsageData.wlt:676,1-690,2"
]

VerificationTest[
    withUsageSession[ { touchUsageStatsFile[ ], FileExistsQ @ usageStatsFile[ ] } ],
    { Null, False },
    SameTest -> SameQ,
    TestID   -> "UsageData-KeepAliveWithoutFile@@Tests/UsageData.wlt:692,1-697,2"
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
    TestID   -> "UsageData-StaleUsageFileQ@@Tests/UsageData.wlt:702,1-719,2"
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
    TestID   -> "SubmitUsageData-SubmitsFinishedSessions@@Tests/UsageData.wlt:727,1-754,2"
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
    TestID   -> "SubmitUsageData-FailureStopsBatch@@Tests/UsageData.wlt:757,1-779,2"
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
    TestID   -> "SubmitUsageData-LockHeld@@Tests/UsageData.wlt:782,1-804,2"
]

VerificationTest[
    submitUsageData @ FileNameJoin @ { $TemporaryDirectory, "does-not-exist-" <> CreateUUID[ ] },
    { },
    SameTest -> SameQ,
    TestID   -> "SubmitUsageData-NoDirectory@@Tests/UsageData.wlt:806,1-811,2"
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
    TestID   -> "SubmitUsageData-CurrentSessionExcluded@@Tests/UsageData.wlt:814,1-829,2"
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
    TestID   -> "SubmitUsagePayload-Unreachable@@Tests/UsageData.wlt:836,1-847,2"
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
    TestID   -> "SubmitUsagePayload-Endpoint@@Tests/UsageData.wlt:850,23-864,2"
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
    TestID   -> "UsageData-Integration-ServerStarts@@Tests/UsageData.wlt:877,16-885,2"
]

skipIfScript @ VerificationTest[
    $usageClientName = "usage-data-test-" <> CreateUUID[ ];
    MCPInitialize[ "ClientName" -> $usageClientName ],
    KeyValuePattern[ "result" -> _Association ],
    SameTest -> MatchQ,
    TestID   -> "UsageData-Integration-Initialize@@Tests/UsageData.wlt:887,16-893,2"
]

skipIfScript @ VerificationTest[
    SendMCPRequest[ "tools/call", <| "name" -> "WolframLanguageEvaluator", "arguments" -> <| "code" -> "Prime[1000]" |> |> ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "isError" -> False ] ],
    SameTest -> MatchQ,
    TestID   -> "UsageData-Integration-ToolCall@@Tests/UsageData.wlt:895,16-900,2"
]

skipIfScript @ VerificationTest[
    SendMCPRequest[ "tools/call", <| "name" -> "NoSuchTool", "arguments" -> <| |> |> ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "isError" -> True ] ],
    SameTest -> MatchQ,
    TestID   -> "UsageData-Integration-UnknownToolCall@@Tests/UsageData.wlt:902,16-907,2"
]

skipIfScript @ VerificationTest[
    SendMCPRequest[ "prompts/get", <| "name" -> "NoSuchPrompt", "arguments" -> <| |> |> ],
    KeyValuePattern[ "error" -> _Association ],
    SameTest -> MatchQ,
    TestID   -> "UsageData-Integration-UnknownPrompt@@Tests/UsageData.wlt:909,16-914,2"
]

skipIfScript @ VerificationTest[
    $usageFile = SelectFirst[
        FileNames[ "*.wxf", FileNameJoin @ { Wolfram`AgentTools`Common`$rootPath, "UsageData" } ],
        Quiet[ Developer`ReadWXFFile[ # ][ "ClientInformation", "clientInfo", "name" ] ] === $usageClientName &
    ],
    _String? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "UsageData-Integration-SessionFileWritten@@Tests/UsageData.wlt:916,16-924,2"
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
    TestID   -> "UsageData-Integration-Events@@Tests/UsageData.wlt:926,16-936,2"
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
    TestID   -> "UsageData-Integration-Payload@@Tests/UsageData.wlt:938,16-948,2"
]

skipIfScript @ VerificationTest[
    StopMCPTestServer[ ];
    Quiet @ DeleteFile @ $usageFile;
    FileExistsQ @ $usageFile,
    False,
    SameTest -> SameQ,
    TestID   -> "UsageData-Integration-Cleanup@@Tests/UsageData.wlt:950,16-957,2"
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
    TestID   -> "UsageData-Integration-OptedOutWritesNothing@@Tests/UsageData.wlt:962,16-975,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)
VerificationTest[
    DeleteObject @ $customServer,
    Null,
    SameTest -> MatchQ,
    TestID   -> "UsageData-Cleanup@@Tests/UsageData.wlt:980,1-985,2"
]

(* :!CodeAnalysis::EndBlock:: *)
