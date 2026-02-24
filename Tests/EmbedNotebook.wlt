(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/EmbedNotebook.wlt:7,1-12,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/EmbedNotebook.wlt:14,1-19,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Registration*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Registered in $DefaultMCPTools*)
VerificationTest[
    KeyExistsQ[ $DefaultMCPTools, "EmbedNotebook" ],
    True,
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-RegisteredInDefaultTools@@Tests/EmbedNotebook.wlt:28,1-33,2"
]

VerificationTest[
    Head @ $DefaultMCPTools[ "EmbedNotebook" ],
    LLMTool,
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-IsLLMTool@@Tests/EmbedNotebook.wlt:35,1-40,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Function*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Returns Correct Structure*)
VerificationTest[
    result = Wolfram`MCPServer`Tools`EmbedNotebook`Private`embedNotebookEvaluate[
        <| "url" -> "https://www.wolframcloud.com/obj/test/notebook" |>
    ];
    MatchQ[ result, <| "Content" -> { _Association } |> ],
    True,
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-ReturnsContentStructure@@Tests/EmbedNotebook.wlt:49,1-57,2"
]

VerificationTest[
    result = Wolfram`MCPServer`Tools`EmbedNotebook`Private`embedNotebookEvaluate[
        <| "url" -> "https://www.wolframcloud.com/obj/test/notebook" |>
    ];
    result[[ "Content", 1, "type" ]],
    "text",
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-ContentTypeIsText@@Tests/EmbedNotebook.wlt:59,1-67,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Response JSON Contains URL*)
VerificationTest[
    result = Wolfram`MCPServer`Tools`EmbedNotebook`Private`embedNotebookEvaluate[
        <| "url" -> "https://www.wolframcloud.com/obj/test/notebook" |>
    ];
    json = Developer`ReadRawJSONString @ result[[ "Content", 1, "text" ]];
    json[ "url" ],
    "https://www.wolframcloud.com/obj/test/notebook",
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-ResponseContainsURL@@Tests/EmbedNotebook.wlt:72,1-81,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Response JSON Contains allowInteract*)
VerificationTest[
    result = Wolfram`MCPServer`Tools`EmbedNotebook`Private`embedNotebookEvaluate[
        <| "url" -> "https://www.wolframcloud.com/obj/test/notebook" |>
    ];
    json = Developer`ReadRawJSONString @ result[[ "Content", 1, "text" ]];
    json[ "allowInteract" ],
    True,
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-DefaultAllowInteract@@Tests/EmbedNotebook.wlt:86,1-95,2"
]

VerificationTest[
    result = Wolfram`MCPServer`Tools`EmbedNotebook`Private`embedNotebookEvaluate[
        <| "url" -> "https://www.wolframcloud.com/obj/test/notebook", "allowInteract" -> False |>
    ];
    json = Developer`ReadRawJSONString @ result[[ "Content", 1, "text" ]];
    json[ "allowInteract" ],
    False,
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-ExplicitAllowInteractFalse@@Tests/EmbedNotebook.wlt:97,1-106,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Response JSON Contains maxHeight*)
VerificationTest[
    result = Wolfram`MCPServer`Tools`EmbedNotebook`Private`embedNotebookEvaluate[
        <| "url" -> "https://www.wolframcloud.com/obj/test/notebook" |>
    ];
    json = Developer`ReadRawJSONString @ result[[ "Content", 1, "text" ]];
    MissingQ @ json[ "maxHeight" ],
    True,
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-DefaultOmitsMaxHeight@@Tests/EmbedNotebook.wlt:111,1-120,2"
]

VerificationTest[
    result = Wolfram`MCPServer`Tools`EmbedNotebook`Private`embedNotebookEvaluate[
        <| "url" -> "https://www.wolframcloud.com/obj/test/notebook", "maxHeight" -> 1200 |>
    ];
    json = Developer`ReadRawJSONString @ result[[ "Content", 1, "text" ]];
    json[ "maxHeight" ],
    1200,
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-ExplicitMaxHeight@@Tests/EmbedNotebook.wlt:122,1-131,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Optional Parameters Handled*)
VerificationTest[
    result = Wolfram`MCPServer`Tools`EmbedNotebook`Private`embedNotebookEvaluate[
        <| "url" -> "https://www.wolframcloud.com/obj/test/notebook", "allowInteract" -> Missing[ "NoInput" ] |>
    ];
    json = Developer`ReadRawJSONString @ result[[ "Content", 1, "text" ]];
    json[ "allowInteract" ],
    True,
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-MissingAllowInteractDefaultsToTrue@@Tests/EmbedNotebook.wlt:136,1-145,2"
]

VerificationTest[
    result = Wolfram`MCPServer`Tools`EmbedNotebook`Private`embedNotebookEvaluate[
        <| "url" -> "https://www.wolframcloud.com/obj/test/notebook", "maxHeight" -> Missing[ "NoInput" ] |>
    ];
    json = Developer`ReadRawJSONString @ result[[ "Content", 1, "text" ]];
    MissingQ @ json[ "maxHeight" ],
    True,
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-MissingMaxHeightOmitsKey@@Tests/EmbedNotebook.wlt:147,1-156,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*UI Resource Integration*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tool UI Associations*)
VerificationTest[
    KeyExistsQ[ Wolfram`MCPServer`Common`$toolUIAssociations, "EmbedNotebook" ],
    True,
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-InToolUIAssociations@@Tests/EmbedNotebook.wlt:165,1-170,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`$toolUIAssociations[ "EmbedNotebook" ],
    "ui://wolfram/notebook-viewer",
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-CorrectResourceURI@@Tests/EmbedNotebook.wlt:172,1-177,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toolUIMetadata*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        meta = Wolfram`MCPServer`Common`toolUIMetadata[ "EmbedNotebook" ];
        ("_meta" /. meta)[ "ui", "resourceUri" ]
    ],
    "ui://wolfram/notebook-viewer",
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-ToolUIMetadataResourceURI@@Tests/EmbedNotebook.wlt:182,1-190,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        meta = Wolfram`MCPServer`Common`toolUIMetadata[ "EmbedNotebook" ];
        ("_meta" /. meta)[ "ui", "visibility" ]
    ],
    { "model", "app" },
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-ToolUIMetadataVisibility@@Tests/EmbedNotebook.wlt:192,1-200,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Resource Registry*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$uiResourceRegistry },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        KeyExistsQ[ Wolfram`MCPServer`Common`$uiResourceRegistry, "ui://wolfram/notebook-viewer" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-InResourceRegistry@@Tests/EmbedNotebook.wlt:205,1-213,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$uiResourceRegistry },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`Common`$uiResourceRegistry[ "ui://wolfram/notebook-viewer", "mimeType" ]
    ],
    "text/html;profile=mcp-app",
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-ResourceMimeType@@Tests/EmbedNotebook.wlt:215,1-223,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readUIResource*)
VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        result = Wolfram`MCPServer`Common`readUIResource[
            <| "params" -> <| "uri" -> "ui://wolfram/notebook-viewer" |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 1 |>
        ];
        StringContainsQ[ result[[ "contents", 1, "text" ]], "WolframNotebookEmbedder" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-ReadUIResourceContainsEmbedder@@Tests/EmbedNotebook.wlt:228,1-243,2"
]

VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        result = Wolfram`MCPServer`Common`readUIResource[
            <| "params" -> <| "uri" -> "ui://wolfram/notebook-viewer" |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 1 |>
        ];
        result[[ "contents", 1, "mimeType" ]]
    ],
    "text/html;profile=mcp-app",
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-ReadUIResourceMimeType@@Tests/EmbedNotebook.wlt:245,1-260,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*JSON Metadata*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$uiResourceRegistry },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`Common`$uiResourceRegistry[ "ui://wolfram/notebook-viewer", "meta" ]
    ],
    KeyValuePattern[ "ui" -> KeyValuePattern[ "prefersBorder" -> True ] ],
    SameTest -> MatchQ,
    TestID   -> "EmbedNotebook-JSONMetadataLoaded@@Tests/EmbedNotebook.wlt:265,1-273,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$uiResourceRegistry },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`Common`$uiResourceRegistry[
            "ui://wolfram/notebook-viewer", "meta", "ui", "csp", "frameDomains"
        ]
    ],
    { "https://www.wolframcloud.com", "https://wolfr.am" },
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-CSPFrameDomains@@Tests/EmbedNotebook.wlt:275,1-285,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$uiResourceRegistry },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`Common`$uiResourceRegistry[
            "ui://wolfram/notebook-viewer", "meta", "ui", "csp", "resourceDomains"
        ]
    ],
    { "https://unpkg.com", "https://www.wolframcloud.com" },
    SameTest -> Equal,
    TestID   -> "EmbedNotebook-CSPResourceDomains@@Tests/EmbedNotebook.wlt:287,1-297,2"
]

(* :!CodeAnalysis::EndBlock:: *)
