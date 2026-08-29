(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/ToolOverrides.wlt:7,1-12,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/ToolOverrides.wlt:14,1-19,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*$MCPEvaluationEnvironment and $MCPTransport*)

(* Outside a server session neither descriptor is bound. *)
VerificationTest[
    { $MCPEvaluationEnvironment, $MCPTransport },
    { None, None },
    SameTest -> MatchQ,
    TestID   -> "MCPEnvironment-DefaultsToNone@@Tests/ToolOverrides.wlt:26,1-31,2"
]

VerificationTest[
    AllTrue[
        { "Wolfram`AgentTools`$MCPEvaluationEnvironment", "Wolfram`AgentTools`$MCPTransport" },
        MemberQ[ Wolfram`AgentTools`$AgentToolsProtectedNames, # ] &
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "MCPEnvironment-Exported-Protected@@Tests/ToolOverrides.wlt:33,1-41,2"
]

VerificationTest[
    { MemberQ[ Attributes @ $MCPEvaluationEnvironment, Protected ], MemberQ[ Attributes @ $MCPTransport, Protected ] },
    { True, True },
    SameTest -> MatchQ,
    TestID   -> "MCPEnvironment-Attributes-Protected@@Tests/ToolOverrides.wlt:43,1-48,2"
]

(* The transports bind the descriptors with Block, which works despite Protected. *)
VerificationTest[
    Block[ { $MCPTransport = "StreamableHTTP", $MCPEvaluationEnvironment = "Cloud" }, { $MCPTransport, $MCPEvaluationEnvironment } ],
    { "StreamableHTTP", "Cloud" },
    SameTest -> MatchQ,
    TestID   -> "MCPEnvironment-Blockable@@Tests/ToolOverrides.wlt:51,1-56,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*applyToolOverrides*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Fixtures*)
applyOverrides = Wolfram`AgentTools`Server`Shared`Private`applyToolOverrides;

overridesParameter[ name_String, help_String ] :=
    name -> <| "Interpreter" -> "String", "Help" -> help, "Required" -> True |>;

(* No "Overrides" key at all. *)
overridesBaseTool = LLMTool @ <|
    "Name"        -> "OverridesBase",
    "Description" -> "Local description.",
    "Function"    -> Identity,
    "Parameters"  -> { overridesParameter[ "x", "The x argument." ] }
|>;

(* Unconditional overrides: whole properties are replaced, the rest is kept. *)
overridesStaticTool = LLMTool @ <|
    "Name"        -> "OverridesStatic",
    "Description" -> "Local description.",
    "Function"    -> Identity,
    "Parameters"  -> { overridesParameter[ "x", "The x argument." ] },
    "Overrides"   -> <|
        "Description" -> "Overridden description.",
        "Parameters"  -> { overridesParameter[ "y", "The y argument." ] }
    |>
|>;

overridesNoneTool = LLMTool @ <|
    "Name"        -> "OverridesNone",
    "Description" -> "Local description.",
    "Function"    -> Identity,
    "Parameters"  -> { overridesParameter[ "x", "The x argument." ] },
    "Overrides"   -> None
|>;

overridesCloudFunction[ args_Association ] := "cloud";

(* Environment-dependent overrides, the way the built-in tools use the mechanism. *)
overridesDelayedTool = LLMTool @ <|
    "Name"        -> "OverridesDelayed",
    "Description" -> "Local description.",
    "Function"    -> Identity,
    "Parameters"  -> { overridesParameter[ "x", "The x argument." ] },
    "Overrides"   :> If[ $MCPEvaluationEnvironment === "Cloud",
                         <| "Description" -> "Cloud description.", "Function" -> overridesCloudFunction |>,
                         <| |>
                     ]
|>;

overridesInvalidTool = LLMTool @ <|
    "Name"        -> "OverridesInvalid",
    "Description" -> "Local description.",
    "Function"    -> Identity,
    "Parameters"  -> { overridesParameter[ "x", "The x argument." ] },
    "Overrides"   -> "not an association"
|>;

$overridesEvaluationCount = 0;

overridesCountingTool = LLMTool @ <|
    "Name"        -> "OverridesCounting",
    "Description" -> "Local description.",
    "Function"    -> Identity,
    "Parameters"  -> { overridesParameter[ "x", "The x argument." ] },
    "Overrides"   :> ( $overridesEvaluationCount++; <| |> )
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*No-op cases*)
VerificationTest[
    applyOverrides[ { } ],
    { },
    SameTest -> MatchQ,
    TestID   -> "ApplyToolOverrides-EmptyList@@Tests/ToolOverrides.wlt:133,1-138,2"
]

VerificationTest[
    applyOverrides @ overridesBaseTool,
    overridesBaseTool,
    SameTest -> SameQ,
    TestID   -> "ApplyToolOverrides-NoOverridesKey-Unchanged@@Tests/ToolOverrides.wlt:140,1-145,2"
]

VerificationTest[
    applyOverrides @ overridesNoneTool,
    overridesNoneTool,
    SameTest -> SameQ,
    TestID   -> "ApplyToolOverrides-None-Unchanged@@Tests/ToolOverrides.wlt:147,1-152,2"
]

VerificationTest[
    applyOverrides @ overridesDelayedTool,
    overridesDelayedTool,
    SameTest -> SameQ,
    TestID   -> "ApplyToolOverrides-Delayed-DefaultEnvironment-Unchanged@@Tests/ToolOverrides.wlt:154,1-159,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Merging*)
VerificationTest[
    applyOverrides[ overridesStaticTool ][ "Description" ],
    "Overridden description.",
    SameTest -> MatchQ,
    TestID   -> "ApplyToolOverrides-Static-ReplacesDescription@@Tests/ToolOverrides.wlt:164,1-169,2"
]

(* Properties are replaced wholesale: the original parameter list is gone, not merged. *)
VerificationTest[
    applyOverrides[ overridesStaticTool ][ "Parameters" ][[ All, 1 ]],
    { "y" },
    SameTest -> MatchQ,
    TestID   -> "ApplyToolOverrides-Static-ReplacesParameters@@Tests/ToolOverrides.wlt:172,1-177,2"
]

VerificationTest[
    { applyOverrides[ overridesStaticTool ][ "Name" ], applyOverrides[ overridesStaticTool ][ "Function" ] },
    { "OverridesStatic", Identity },
    SameTest -> MatchQ,
    TestID   -> "ApplyToolOverrides-Static-KeepsOtherProperties@@Tests/ToolOverrides.wlt:179,1-184,2"
]

VerificationTest[
    KeyExistsQ[ applyOverrides[ overridesStaticTool ][ "Data" ], "Overrides" ],
    True,
    SameTest -> MatchQ,
    TestID   -> "ApplyToolOverrides-Static-KeepsOverridesKey@@Tests/ToolOverrides.wlt:186,1-191,2"
]

VerificationTest[
    applyOverrides @ applyOverrides @ overridesStaticTool,
    applyOverrides @ overridesStaticTool,
    SameTest -> SameQ,
    TestID   -> "ApplyToolOverrides-Idempotent@@Tests/ToolOverrides.wlt:193,1-198,2"
]

VerificationTest[
    #[ "Description" ] & /@ applyOverrides @ { overridesStaticTool, overridesBaseTool, overridesNoneTool },
    { "Overridden description.", "Local description.", "Local description." },
    SameTest -> MatchQ,
    TestID   -> "ApplyToolOverrides-List@@Tests/ToolOverrides.wlt:200,1-205,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Environment-dependent overrides*)
VerificationTest[
    Block[ { $MCPEvaluationEnvironment = "Local" }, applyOverrides[ overridesDelayedTool ][ "Description" ] ],
    "Local description.",
    SameTest -> MatchQ,
    TestID   -> "ApplyToolOverrides-Delayed-Local@@Tests/ToolOverrides.wlt:210,1-215,2"
]

VerificationTest[
    Block[ { $MCPEvaluationEnvironment = "Cloud" }, applyOverrides[ overridesDelayedTool ][ "Description" ] ],
    "Cloud description.",
    SameTest -> MatchQ,
    TestID   -> "ApplyToolOverrides-Delayed-Cloud-Description@@Tests/ToolOverrides.wlt:217,1-222,2"
]

VerificationTest[
    Block[ { $MCPEvaluationEnvironment = "Cloud" }, applyOverrides[ overridesDelayedTool ][ "Function" ] ],
    overridesCloudFunction,
    SameTest -> SameQ,
    TestID   -> "ApplyToolOverrides-Delayed-Cloud-Function@@Tests/ToolOverrides.wlt:224,1-229,2"
]

(* Properties the override does not mention are kept. *)
VerificationTest[
    Block[ { $MCPEvaluationEnvironment = "Cloud" }, applyOverrides[ overridesDelayedTool ][ "Parameters" ][[ All, 1 ]] ],
    { "x" },
    SameTest -> MatchQ,
    TestID   -> "ApplyToolOverrides-Delayed-Cloud-KeepsParameters@@Tests/ToolOverrides.wlt:232,1-237,2"
]

(* The overridden function is what the tool then calls. *)
VerificationTest[
    Block[ { $MCPEvaluationEnvironment = "Cloud" }, applyOverrides[ overridesDelayedTool ][ <| "x" -> "value" |> ] ],
    "cloud",
    SameTest -> MatchQ,
    TestID   -> "ApplyToolOverrides-Delayed-Cloud-Callable@@Tests/ToolOverrides.wlt:240,1-245,2"
]

(* A delayed "Overrides" value is evaluated when the overrides are applied, not when the tool is defined. *)
VerificationTest[
    $overridesEvaluationCount,
    0,
    SameTest -> MatchQ,
    TestID   -> "ApplyToolOverrides-Delayed-NotEvaluatedAtDefinition@@Tests/ToolOverrides.wlt:248,1-253,2"
]

VerificationTest[
    applyOverrides @ overridesCountingTool;
    $overridesEvaluationCount,
    1,
    SameTest -> MatchQ,
    TestID   -> "ApplyToolOverrides-Delayed-EvaluatedOnApply@@Tests/ToolOverrides.wlt:255,1-261,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Invalid overrides*)
VerificationTest[
    Wolfram`AgentTools`Common`catchTop @ applyOverrides @ overridesInvalidTool,
    _Failure,
    { General::AgentToolsInternal },
    SameTest -> MatchQ,
    TestID   -> "ApplyToolOverrides-Invalid-InternalFailure@@Tests/ToolOverrides.wlt:266,1-272,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*initializeServerState*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Fixtures*)

(* An in-memory server (no disk persistence) with a built-in tool that overrides itself in the cloud
   (WriteNotebook) and the environment-dependent custom tool above. *)
overridesServer = MCPServerObject[ <|
    "Name"         -> "OverridesServer",
    "Location"     -> "BuiltIn",
    "LLMEvaluator" -> <| "Tools" -> { "WriteNotebook", overridesDelayedTool } |>
|> ];

(* Build the transport-agnostic server state the way both transports do. *)
overridesServerState[ ] := Block[ { Wolfram`AgentTools`Server`$currentMCPServer = overridesServer },
    Wolfram`AgentTools`Common`initializeServerState @ overridesServer
];

overridesToolEntry[ state_Association, name_String ] :=
    FirstCase[ state[ "ToolList" ], KeyValuePattern[ "name" -> name ] ];

VerificationTest[
    MCPServerObjectQ @ overridesServer,
    True,
    SameTest -> MatchQ,
    TestID   -> "InitializeServerState-Fixture-ServerValid@@Tests/ToolOverrides.wlt:298,1-303,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Default environment*)
VerificationTest[
    $overridesLocalState = overridesServerState[ ],
    KeyValuePattern[ "ToolList" -> { __Association } ],
    SameTest -> MatchQ,
    TestID   -> "InitializeServerState-Local-Builds@@Tests/ToolOverrides.wlt:308,1-313,2"
]

VerificationTest[
    Keys @ overridesToolEntry[ $overridesLocalState, "WriteNotebook" ][ "inputSchema", "properties" ],
    { "file", "overwrite", "markdown" },
    SameTest -> MatchQ,
    TestID   -> "InitializeServerState-Local-WriteNotebookSchema@@Tests/ToolOverrides.wlt:315,1-320,2"
]

VerificationTest[
    overridesToolEntry[ $overridesLocalState, "WriteNotebook" ][ "description" ],
    _String? (StringContainsQ[ "saves it to a file" ]),
    SameTest -> MatchQ,
    TestID   -> "InitializeServerState-Local-WriteNotebookDescription@@Tests/ToolOverrides.wlt:322,1-327,2"
]

VerificationTest[
    $overridesLocalState[ "LLMTools", "WriteNotebook" ][ "Function" ],
    Except[ Wolfram`AgentTools`Tools`Notebooks`Private`writeCloudNotebook ],
    SameTest -> MatchQ,
    TestID   -> "InitializeServerState-Local-WriteNotebookFunction@@Tests/ToolOverrides.wlt:329,1-334,2"
]

VerificationTest[
    overridesToolEntry[ $overridesLocalState, "OverridesDelayed" ][ "description" ],
    "Local description.",
    SameTest -> MatchQ,
    TestID   -> "InitializeServerState-Local-CustomToolDescription@@Tests/ToolOverrides.wlt:336,1-341,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cloud environment*)
VerificationTest[
    $overridesCloudState = Block[ { $MCPEvaluationEnvironment = "Cloud", $MCPTransport = "StreamableHTTP" }, overridesServerState[ ] ],
    KeyValuePattern[ "ToolList" -> { __Association } ],
    SameTest -> MatchQ,
    TestID   -> "InitializeServerState-Cloud-Builds@@Tests/ToolOverrides.wlt:346,1-351,2"
]

VerificationTest[
    Keys @ overridesToolEntry[ $overridesCloudState, "WriteNotebook" ][ "inputSchema", "properties" ],
    { "path", "permissions", "overwrite", "markdown" },
    SameTest -> MatchQ,
    TestID   -> "InitializeServerState-Cloud-WriteNotebookSchema@@Tests/ToolOverrides.wlt:353,1-358,2"
]

VerificationTest[
    overridesToolEntry[ $overridesCloudState, "WriteNotebook" ][ "inputSchema", "required" ],
    { "markdown" },
    SameTest -> MatchQ,
    TestID   -> "InitializeServerState-Cloud-WriteNotebookRequired@@Tests/ToolOverrides.wlt:360,1-365,2"
]

VerificationTest[
    overridesToolEntry[ $overridesCloudState, "WriteNotebook" ][ "description" ],
    _String? (StringContainsQ[ "cloud object" ]),
    SameTest -> MatchQ,
    TestID   -> "InitializeServerState-Cloud-WriteNotebookDescription@@Tests/ToolOverrides.wlt:367,1-372,2"
]

VerificationTest[
    $overridesCloudState[ "LLMTools", "WriteNotebook" ][ "Function" ],
    Wolfram`AgentTools`Tools`Notebooks`Private`writeCloudNotebook,
    SameTest -> SameQ,
    TestID   -> "InitializeServerState-Cloud-WriteNotebookFunction@@Tests/ToolOverrides.wlt:374,1-379,2"
]

VerificationTest[
    overridesToolEntry[ $overridesCloudState, "OverridesDelayed" ][ "description" ],
    "Cloud description.",
    SameTest -> MatchQ,
    TestID   -> "InitializeServerState-Cloud-CustomToolDescription@@Tests/ToolOverrides.wlt:381,1-386,2"
]

(* The tool name is unchanged by the override, so clients address it the same way in both environments. *)
VerificationTest[
    Keys @ $overridesCloudState[ "LLMTools" ],
    Keys @ $overridesLocalState[ "LLMTools" ],
    SameTest -> MatchQ,
    TestID   -> "InitializeServerState-Cloud-SameToolNames@@Tests/ToolOverrides.wlt:389,1-394,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Transports*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cloud (RunCloudMCPServer)*)

(* A tool that reports the descriptors it observes while being evaluated. *)
overridesProbeTool = LLMTool[
    "EnvProbe",
    { },
    StringRiffle[ ToString /@ { $MCPTransport, $MCPEvaluationEnvironment }, "/" ] &
];

overridesCloudServer = MCPServerObject[ <|
    "Location"     -> "BuiltIn",
    "LLMEvaluator" -> <| "Tools" -> { "WriteNotebook", overridesProbeTool } |>
|> ];

(* A mock request shaped like HTTPRequestData[] (see CloudDeployment.wlt) driving the internal handler. *)
overridesCloudRun[ method_String, id_Integer, params_Association ] :=
    Wolfram`AgentTools`Server`Cloud`Private`runCloudMCPServer[
        overridesCloudServer,
        <|
            "Method"        -> "POST",
            "Headers"       -> { "accept" -> "application/json" },
            "BodyByteArray" -> StringToByteArray @ Developer`WriteRawJSONString @ <|
                "jsonrpc" -> "2.0",
                "id"      -> id,
                "method"  -> method,
                "params"  -> params
            |>
        |>
    ];

overridesCloudJSON[ resp_HTTPResponse ] := Developer`ReadRawJSONString @ resp[ "Body" ];

VerificationTest[
    $overridesProbeResponse = overridesCloudRun[ "tools/call", 1, <| "name" -> "EnvProbe", "arguments" -> <| |> |> ],
    _HTTPResponse? (#[ "StatusCode" ] === 200 &),
    SameTest -> MatchQ,
    TestID   -> "CloudTransport-ProbeCall-Succeeds@@Tests/ToolOverrides.wlt:434,1-439,2"
]

VerificationTest[
    overridesCloudJSON[ $overridesProbeResponse ][[ "result", "content", 1, "text" ]],
    "StreamableHTTP/Cloud",
    SameTest -> MatchQ,
    TestID   -> "CloudTransport-BindsTransportAndEnvironment@@Tests/ToolOverrides.wlt:441,1-446,2"
]

(* The bindings are per request: nothing leaks out of the handler. *)
VerificationTest[
    { $MCPTransport, $MCPEvaluationEnvironment },
    { None, None },
    SameTest -> MatchQ,
    TestID   -> "CloudTransport-RestoredAfterRequest@@Tests/ToolOverrides.wlt:449,1-454,2"
]

VerificationTest[
    Keys @ FirstCase[
        overridesCloudJSON[ overridesCloudRun[ "tools/list", 2, <| |> ] ][[ "result", "tools" ]],
        KeyValuePattern[ "name" -> "WriteNotebook" ]
    ][ "inputSchema", "properties" ],
    { "path", "permissions", "overwrite", "markdown" },
    SameTest -> MatchQ,
    TestID   -> "CloudTransport-ToolsList-UsesCloudOverrides@@Tests/ToolOverrides.wlt:456,1-464,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Local (StartMCPServer)*)

(* The stdio read loop cannot run in-process (it blocks on stdin), so check the bindings it establishes
   structurally: startMCPServer Blocks both descriptors around the whole session. *)
VerificationTest[
    With[ { dv = DownValues @ Wolfram`AgentTools`Server`Local`Private`startMCPServer },
        {
            ! FreeQ[ dv, HoldPattern[ $MCPTransport = "StandardInputOutput" ] ],
            ! FreeQ[ dv, HoldPattern[ $MCPEvaluationEnvironment = "Local" ] ]
        }
    ],
    { True, True },
    SameTest -> MatchQ,
    TestID   -> "LocalTransport-BindsTransportAndEnvironment@@Tests/ToolOverrides.wlt:472,1-482,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cloud landing page (/api/info)*)

(* The /api/info tool list is generated at deploy time; it must describe the tools as the cloud endpoint
   will list them, i.e. with the cloud overrides applied. *)
overridesInfo = Wolfram`AgentTools`Server`Cloud`Private`cloudMCPServerInfo[
    overridesServer,
    "https://www.wolframcloud.com/obj/user/dir/mcp"
];

VerificationTest[
    FirstCase[ overridesInfo[ "tools" ], KeyValuePattern[ "name" -> "WriteNotebook" ] ][ "description" ],
    _String? (StringContainsQ[ "cloud object" ]),
    SameTest -> MatchQ,
    TestID   -> "CloudMCPServerInfo-WriteNotebook-CloudDescription@@Tests/ToolOverrides.wlt:495,1-500,2"
]

VerificationTest[
    FirstCase[ overridesInfo[ "tools" ], KeyValuePattern[ "name" -> "OverridesDelayed" ] ][ "description" ],
    "Cloud description.",
    SameTest -> MatchQ,
    TestID   -> "CloudMCPServerInfo-CustomTool-CloudDescription@@Tests/ToolOverrides.wlt:502,1-507,2"
]

(* serverToolListData itself honors whatever environment the caller has bound (none here). *)
VerificationTest[
    FirstCase[ Wolfram`AgentTools`Server`serverToolListData @ overridesServer, KeyValuePattern[ "name" -> "OverridesDelayed" ] ][ "description" ],
    "Local description.",
    SameTest -> MatchQ,
    TestID   -> "ServerToolListData-DefaultEnvironment@@Tests/ToolOverrides.wlt:510,1-515,2"
]

VerificationTest[
    FirstCase[ Wolfram`AgentTools`Server`serverToolListData @ { overridesStaticTool }, KeyValuePattern[ "name" -> "OverridesStatic" ] ][ "description" ],
    "Overridden description.",
    SameTest -> MatchQ,
    TestID   -> "ServerToolListData-AppliesOverrides@@Tests/ToolOverrides.wlt:517,1-522,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Deployment payloads*)

(* The functions a cloud override swaps in are only referenced from inside the tool's delayed "Overrides"
   value, so they must still be captured by the definition gather that embeds the server in the deployed
   /mcp expression. The heavy (self-contained) payload must carry the built-in cloud writer; both payloads
   must carry the user's custom override function. *)
overridesHeavyPayload = Wolfram`AgentTools`Server`Cloud`Private`cloudMCPServerPayload[ overridesServer, False ];
overridesLightPayload = Wolfram`AgentTools`Server`Cloud`Private`cloudMCPServerPayload[ overridesServer, True ];

overridesPayloadDefinitionCount[ payload_, sym_, type_ ] :=
    Cases[ payload, HoldPattern[ HoldForm[ sym ] -> defs_ ] :> Length @ Lookup[ defs, type ], Infinity ];

VerificationTest[
    overridesPayloadDefinitionCount[ overridesHeavyPayload, Wolfram`AgentTools`Tools`Notebooks`Private`writeCloudNotebook, DownValues ],
    { _Integer? Positive },
    SameTest -> MatchQ,
    TestID   -> "CloudPayload-Heavy-CarriesWriteCloudNotebook@@Tests/ToolOverrides.wlt:538,1-543,2"
]

VerificationTest[
    Cases[
        overridesHeavyPayload,
        HoldPattern[ HoldForm[ Wolfram`AgentTools`Tools`Notebooks`Private`$writeNotebookCloudOverrides ] -> defs_ ] :>
            Length @ Lookup[ defs, OwnValues ],
        Infinity
    ],
    { _Integer? Positive },
    SameTest -> MatchQ,
    TestID   -> "CloudPayload-Heavy-CarriesWriteNotebookCloudOverrides@@Tests/ToolOverrides.wlt:545,1-555,2"
]

VerificationTest[
    overridesPayloadDefinitionCount[ overridesHeavyPayload, overridesCloudFunction, DownValues ],
    { _Integer? Positive },
    SameTest -> MatchQ,
    TestID   -> "CloudPayload-Heavy-CarriesCustomOverrideFunction@@Tests/ToolOverrides.wlt:557,1-562,2"
]

VerificationTest[
    overridesPayloadDefinitionCount[ overridesLightPayload, overridesCloudFunction, DownValues ],
    { _Integer? Positive },
    SameTest -> MatchQ,
    TestID   -> "CloudPayload-Light-CarriesCustomOverrideFunction@@Tests/ToolOverrides.wlt:564,1-569,2"
]

VerificationTest[
    FreeQ[ overridesLightPayload, Wolfram`AgentTools`Tools`Notebooks`Private`writeCloudNotebook ],
    True,
    SameTest -> MatchQ,
    TestID   -> "CloudPayload-Light-ReliesOnCloudPaclet@@Tests/ToolOverrides.wlt:571,1-576,2"
]

(* :!CodeAnalysis::EndBlock:: *)
