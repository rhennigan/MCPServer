(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

BeginTestSection[ "MCPApps" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialize*)
Needs[ "Wolfram`MCPServer`" ];

$testAppsDir = PacletObject[ "Wolfram/MCPServer" ][ "AssetLocation", "Apps" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*clientSupportsUIQ*)

VerificationTest[
    Wolfram`MCPServer`Common`clientSupportsUIQ[ <|
        "params" -> <|
            "capabilities" -> <|
                "extensions" -> <|
                    "io.modelcontextprotocol/ui" -> <| "mimeTypes" -> { "text/html;profile=mcp-app" } |>
                |>
            |>
        |>
    |> ],
    True,
    TestID -> "clientSupportsUIQ-WithUI@@Tests/MCPApps.wlt:17,1-29,2"
];

VerificationTest[
    Wolfram`MCPServer`Common`clientSupportsUIQ[ <|
        "params" -> <|
            "capabilities" -> <| |>
        |>
    |> ],
    False,
    TestID -> "clientSupportsUIQ-WithoutUI@@Tests/MCPApps.wlt:31,1-39,2"
];

VerificationTest[
    Wolfram`MCPServer`Common`clientSupportsUIQ[ <| |> ],
    False,
    TestID -> "clientSupportsUIQ-EmptyMessage@@Tests/MCPApps.wlt:41,1-45,2"
];

VerificationTest[
    Wolfram`MCPServer`Common`clientSupportsUIQ[ "not an association" ],
    False,
    TestID -> "clientSupportsUIQ-InvalidInput@@Tests/MCPApps.wlt:47,1-51,2"
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*loadUIResource*)

VerificationTest[
    result = Wolfram`MCPServer`Common`loadUIResource[
        FileNameJoin[ { $testAppsDir, "wolframalpha-viewer.html" } ]
    ];
    MatchQ[ result, _Rule ],
    True,
    TestID -> "loadUIResource-WAViewer-ReturnsRule@@Tests/MCPApps.wlt:57,1-64,2"
];

VerificationTest[
    { uri, data } = List @@ result;
    uri,
    "ui://wolfram/wolframalpha-viewer",
    TestID -> "loadUIResource-WAViewer-URI@@Tests/MCPApps.wlt:66,1-71,2"
];

VerificationTest[
    data[ "mimeType" ],
    "text/html;profile=mcp-app",
    TestID -> "loadUIResource-WAViewer-MimeType@@Tests/MCPApps.wlt:73,1-77,2"
];

VerificationTest[
    StringQ @ data[ "html" ] && StringLength @ data[ "html" ] > 0,
    True,
    TestID -> "loadUIResource-WAViewer-HTMLLoaded@@Tests/MCPApps.wlt:79,1-83,2"
];

VerificationTest[
    AssociationQ @ data[ "meta" ],
    True,
    TestID -> "loadUIResource-WAViewer-MetaLoaded@@Tests/MCPApps.wlt:85,1-89,2"
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*initializeUIResources*)

VerificationTest[
    Wolfram`MCPServer`Common`initializeUIResources[ ];
    AssociationQ @ Wolfram`MCPServer`Common`$uiResourceRegistry,
    True,
    TestID -> "initializeUIResources-PopulatesRegistry@@Tests/MCPApps.wlt:95,1-100,2"
];

VerificationTest[
    Length @ Wolfram`MCPServer`Common`$uiResourceRegistry >= 2,
    True,
    TestID -> "initializeUIResources-LoadsMultipleResources@@Tests/MCPApps.wlt:102,1-106,2"
];

VerificationTest[
    KeyExistsQ[ Wolfram`MCPServer`Common`$uiResourceRegistry, "ui://wolfram/wolframalpha-viewer" ],
    True,
    TestID -> "initializeUIResources-ContainsWAViewer@@Tests/MCPApps.wlt:108,1-112,2"
];

VerificationTest[
    KeyExistsQ[ Wolfram`MCPServer`Common`$uiResourceRegistry, "ui://wolfram/evaluator-viewer" ],
    True,
    TestID -> "initializeUIResources-ContainsEvaluatorViewer@@Tests/MCPApps.wlt:114,1-118,2"
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*listUIResources*)

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        Wolfram`MCPServer`Common`listUIResources[ ]
    ],
    { __Association },
    SameTest -> MatchQ,
    TestID -> "listUIResources-UIClient-ReturnsList@@Tests/MCPApps.wlt:124,1-131,2"
];

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = False },
        Wolfram`MCPServer`Common`listUIResources[ ]
    ],
    { },
    TestID -> "listUIResources-NonUIClient-ReturnsEmpty@@Tests/MCPApps.wlt:133,1-139,2"
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*readUIResource*)

VerificationTest[
    Wolfram`MCPServer`Common`initializeUIResources[ ];
    readResult = Wolfram`MCPServer`Common`readUIResource[
        <| "params" -> <| "uri" -> "ui://wolfram/wolframalpha-viewer" |> |>,
        <| "jsonrpc" -> "2.0", "id" -> 1 |>
    ];
    MatchQ[ readResult, KeyValuePattern[ "contents" -> { KeyValuePattern[ "uri" -> _String ] } ] ],
    True,
    TestID -> "readUIResource-ValidURI-ReturnsContents@@Tests/MCPApps.wlt:145,1-154,2"
];

VerificationTest[
    readResult[[ "contents", 1, "mimeType" ]],
    "text/html;profile=mcp-app",
    TestID -> "readUIResource-ValidURI-CorrectMimeType@@Tests/MCPApps.wlt:156,1-160,2"
];

VerificationTest[
    StringQ @ readResult[[ "contents", 1, "text" ]],
    True,
    TestID -> "readUIResource-ValidURI-ContainsHTML@@Tests/MCPApps.wlt:162,1-166,2"
];

VerificationTest[
    Wolfram`MCPServer`Common`catchTop @
        Wolfram`MCPServer`Common`readUIResource[
            <| "params" -> <| "uri" -> "ui://wolfram/nonexistent" |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 2 |>
        ],
    _Failure,
    SameTest -> MatchQ,
    TestID -> "readUIResource-UnknownURI-ReturnsFailure@@Tests/MCPApps.wlt:168,1-177,2"
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*toolUIMetadata*)

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        Wolfram`MCPServer`Common`toolUIMetadata[ "WolframAlpha" ]
    ],
    { "_meta" -> KeyValuePattern[ "ui" -> KeyValuePattern[ "resourceUri" -> _String ] ] },
    SameTest -> MatchQ,
    TestID -> "toolUIMetadata-UIClient-WithAssociation@@Tests/MCPApps.wlt:183,1-190,2"
];

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        Wolfram`MCPServer`Common`toolUIMetadata[ "SomeOtherTool" ]
    ],
    { },
    TestID -> "toolUIMetadata-UIClient-NoAssociation@@Tests/MCPApps.wlt:192,1-198,2"
];

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = False },
        Wolfram`MCPServer`Common`toolUIMetadata[ "WolframAlpha" ]
    ],
    { },
    TestID -> "toolUIMetadata-NonUIClient-ReturnsEmpty@@Tests/MCPApps.wlt:200,1-206,2"
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Cleanup*)

EndTestSection[ ];

(* :!CodeAnalysis::EndBlock:: *)
