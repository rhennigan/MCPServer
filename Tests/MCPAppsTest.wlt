(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/MCPAppsTest.wlt:7,1-12,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/MCPAppsTest.wlt:14,1-19,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Registration*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Registered in $DefaultMCPTools*)
VerificationTest[
    KeyExistsQ[ $DefaultMCPTools, "MCPAppsTest" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-RegisteredInDefaultTools@@Tests/MCPAppsTest.wlt:28,1-33,2"
]

VerificationTest[
    Head @ $DefaultMCPTools[ "MCPAppsTest" ],
    LLMTool,
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-IsLLMTool@@Tests/MCPAppsTest.wlt:35,1-40,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Function*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Returns Correct Structure*)
VerificationTest[
    result = Wolfram`AgentTools`Tools`MCPAppsTest`Private`mcpAppsTestEvaluate[
        <| "message" -> "hello world" |>
    ];
    MatchQ[ result, <| "Content" -> { _Association } |> ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-ReturnsContentStructure@@Tests/MCPAppsTest.wlt:49,1-57,2"
]

VerificationTest[
    result = Wolfram`AgentTools`Tools`MCPAppsTest`Private`mcpAppsTestEvaluate[
        <| "message" -> "hello world" |>
    ];
    result[[ "Content", 1, "type" ]],
    "text",
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-ContentTypeIsText@@Tests/MCPAppsTest.wlt:59,1-67,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Echoes Message*)
VerificationTest[
    result = Wolfram`AgentTools`Tools`MCPAppsTest`Private`mcpAppsTestEvaluate[
        <| "message" -> "test echo" |>
    ];
    json = Developer`ReadRawJSONString @ result[[ "Content", 1, "text" ]];
    json[ "echo" ],
    "test echo",
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-EchoesMessage@@Tests/MCPAppsTest.wlt:72,1-81,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Contains Timestamp*)
VerificationTest[
    result = Wolfram`AgentTools`Tools`MCPAppsTest`Private`mcpAppsTestEvaluate[
        <| "message" -> "ts test" |>
    ];
    json = Developer`ReadRawJSONString @ result[[ "Content", 1, "text" ]];
    StringQ @ json[ "timestamp" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-ContainsTimestamp@@Tests/MCPAppsTest.wlt:86,1-95,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Contains Server Info*)
VerificationTest[
    result = Wolfram`AgentTools`Tools`MCPAppsTest`Private`mcpAppsTestEvaluate[
        <| "message" -> "server info test" |>
    ];
    json = Developer`ReadRawJSONString @ result[[ "Content", 1, "text" ]];
    AssociationQ @ json[ "server" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-ContainsServerInfo@@Tests/MCPAppsTest.wlt:100,1-109,2"
]

VerificationTest[
    result = Wolfram`AgentTools`Tools`MCPAppsTest`Private`mcpAppsTestEvaluate[
        <| "message" -> "version test" |>
    ];
    json = Developer`ReadRawJSONString @ result[[ "Content", 1, "text" ]];
    { StringQ @ json[ "server", "name" ], StringQ @ json[ "server", "version" ], NumberQ @ json[ "server", "kernel" ] },
    { True, True, True },
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-ServerInfoFields@@Tests/MCPAppsTest.wlt:111,1-120,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*UI Resource Integration*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tool UI Associations*)
VerificationTest[
    KeyExistsQ[ Wolfram`AgentTools`Common`$toolUIAssociations, "MCPAppsTest" ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-InToolUIAssociations@@Tests/MCPAppsTest.wlt:129,1-134,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`$toolUIAssociations[ "MCPAppsTest" ],
    "ui://wolfram/mcp-apps-test",
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-CorrectResourceURI@@Tests/MCPAppsTest.wlt:136,1-141,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toolUIMetadata*)
VerificationTest[
    Block[ { Wolfram`AgentTools`Common`$clientSupportsUI = True },
        meta = Wolfram`AgentTools`Common`toolUIMetadata[ "MCPAppsTest" ];
        ("_meta" /. meta)[ "ui", "resourceUri" ]
    ],
    "ui://wolfram/mcp-apps-test",
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-ToolUIMetadataResourceURI@@Tests/MCPAppsTest.wlt:146,1-154,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`Common`$clientSupportsUI = True },
        meta = Wolfram`AgentTools`Common`toolUIMetadata[ "MCPAppsTest" ];
        ("_meta" /. meta)[ "ui", "visibility" ]
    ],
    { "model", "app" },
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-ToolUIMetadataVisibility@@Tests/MCPAppsTest.wlt:156,1-164,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Resource Registry*)
VerificationTest[
    Block[ { Wolfram`AgentTools`Common`$uiResourceRegistry },
        Wolfram`AgentTools`Common`initializeUIResources[ ];
        KeyExistsQ[ Wolfram`AgentTools`Common`$uiResourceRegistry, "ui://wolfram/mcp-apps-test" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-InResourceRegistry@@Tests/MCPAppsTest.wlt:169,1-177,2"
]

VerificationTest[
    Block[ { Wolfram`AgentTools`Common`$uiResourceRegistry },
        Wolfram`AgentTools`Common`initializeUIResources[ ];
        Wolfram`AgentTools`Common`$uiResourceRegistry[ "ui://wolfram/mcp-apps-test", "mimeType" ]
    ],
    "text/html;profile=mcp-app",
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-ResourceMimeType@@Tests/MCPAppsTest.wlt:179,1-187,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readUIResource*)
VerificationTest[
    Block[ {
        Wolfram`AgentTools`Common`$clientSupportsUI = True,
        Wolfram`AgentTools`Common`$uiResourceRegistry
    },
        Wolfram`AgentTools`Common`initializeUIResources[ ];
        result = Wolfram`AgentTools`Common`readUIResource[
            <| "params" -> <| "uri" -> "ui://wolfram/mcp-apps-test" |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 1 |>
        ];
        StringContainsQ[ result[[ "contents", 1, "text" ]], "MCPAppsTest" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-ReadUIResourceContainsMCPAppsTest@@Tests/MCPAppsTest.wlt:192,1-207,2"
]

VerificationTest[
    Block[ {
        Wolfram`AgentTools`Common`$clientSupportsUI = True,
        Wolfram`AgentTools`Common`$uiResourceRegistry
    },
        Wolfram`AgentTools`Common`initializeUIResources[ ];
        result = Wolfram`AgentTools`Common`readUIResource[
            <| "params" -> <| "uri" -> "ui://wolfram/mcp-apps-test" |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 1 |>
        ];
        result[[ "contents", 1, "mimeType" ]]
    ],
    "text/html;profile=mcp-app",
    SameTest -> Equal,
    TestID   -> "MCPAppsTest-ReadUIResourceMimeType@@Tests/MCPAppsTest.wlt:209,1-224,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*JSON Metadata*)
VerificationTest[
    Block[ { Wolfram`AgentTools`Common`$uiResourceRegistry },
        Wolfram`AgentTools`Common`initializeUIResources[ ];
        Wolfram`AgentTools`Common`$uiResourceRegistry[ "ui://wolfram/mcp-apps-test", "meta" ]
    ],
    KeyValuePattern[ "ui" -> KeyValuePattern[ "prefersBorder" -> True ] ],
    SameTest -> MatchQ,
    TestID   -> "MCPAppsTest-JSONMetadataLoaded@@Tests/MCPAppsTest.wlt:229,1-237,2"
]

(* :!CodeAnalysis::EndBlock:: *)
