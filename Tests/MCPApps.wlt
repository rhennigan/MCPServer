(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/MCPApps.wlt:7,1-12,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/MCPApps.wlt:14,1-19,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Unit Tests*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*clientSupportsUIQ*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*UI-Capable Clients*)
VerificationTest[
    Wolfram`MCPServer`Common`clientSupportsUIQ @ <|
        "method" -> "initialize",
        "params" -> <|
            "protocolVersion" -> "2024-11-05",
            "capabilities" -> <|
                "extensions" -> <|
                    "io.modelcontextprotocol/ui" -> <|
                        "mimeTypes" -> { "text/html;profile=mcp-app" }
                    |>
                |>
            |>,
            "clientInfo" -> <| "name" -> "claude-desktop", "version" -> "1.0.0" |>
        |>
    |>,
    True,
    SameTest -> Equal,
    TestID   -> "ClientSupportsUIQ-UIClient@@Tests/MCPApps.wlt:32,1-50,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Non-UI Clients*)
VerificationTest[
    Wolfram`MCPServer`Common`clientSupportsUIQ @ <|
        "method" -> "initialize",
        "params" -> <|
            "protocolVersion" -> "2024-11-05",
            "capabilities" -> <| |>,
            "clientInfo" -> <| "name" -> "test-client" |>
        |>
    |>,
    False,
    SameTest -> Equal,
    TestID   -> "ClientSupportsUIQ-NoExtensions@@Tests/MCPApps.wlt:55,1-67,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`clientSupportsUIQ @ <|
        "method" -> "initialize",
        "params" -> <|
            "protocolVersion" -> "2024-11-05",
            "capabilities" -> <|
                "extensions" -> <| "other/extension" -> <| |> |>
            |>,
            "clientInfo" -> <| "name" -> "test-client" |>
        |>
    |>,
    False,
    SameTest -> Equal,
    TestID   -> "ClientSupportsUIQ-OtherExtension@@Tests/MCPApps.wlt:69,1-83,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`clientSupportsUIQ @ <|
        "method" -> "initialize",
        "params" -> <|
            "protocolVersion" -> "2024-11-05",
            "clientInfo" -> <| "name" -> "test-client" |>
        |>
    |>,
    False,
    SameTest -> Equal,
    TestID   -> "ClientSupportsUIQ-NoCapabilities@@Tests/MCPApps.wlt:85,1-96,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`clientSupportsUIQ @ <| "method" -> "initialize" |>,
    False,
    SameTest -> Equal,
    TestID   -> "ClientSupportsUIQ-NoParams@@Tests/MCPApps.wlt:98,1-103,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Invalid Inputs*)
VerificationTest[
    Wolfram`MCPServer`Common`clientSupportsUIQ @ "not an association",
    False,
    SameTest -> Equal,
    TestID   -> "ClientSupportsUIQ-NonAssociation@@Tests/MCPApps.wlt:108,1-113,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`clientSupportsUIQ @ Null,
    False,
    SameTest -> Equal,
    TestID   -> "ClientSupportsUIQ-Null@@Tests/MCPApps.wlt:115,1-120,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*initResponse*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Extensions Included for UI Clients*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        result = Wolfram`MCPServer`StartMCPServer`Private`initResponse[
            "TestServer", "1.0.0", { }, { }, <| |>
        ];
        ! MissingQ @ result[ "capabilities", "extensions", "io.modelcontextprotocol/ui" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InitResponse-IncludesExtensions@@Tests/MCPApps.wlt:129,1-139,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        result = Wolfram`MCPServer`StartMCPServer`Private`initResponse[
            "TestServer", "1.0.0", { }, { }, <| |>
        ];
        result[ "capabilities", "extensions", "io.modelcontextprotocol/ui" ]
    ],
    <| "mimeTypes" -> { "text/html;profile=mcp-app" } |>,
    SameTest -> MatchQ,
    TestID   -> "InitResponse-ExtensionsStructure@@Tests/MCPApps.wlt:141,1-151,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        result = Wolfram`MCPServer`StartMCPServer`Private`initResponse[
            "TestServer", "1.0.0", { }, { }, <| |>
        ];
        result[ "capabilities", "extensions", "io.modelcontextprotocol/ui", "mimeTypes" ]
    ],
    { "text/html;profile=mcp-app" },
    SameTest -> MatchQ,
    TestID   -> "InitResponse-ExtensionsMimeType@@Tests/MCPApps.wlt:153,1-163,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Extensions Omitted for Non-UI Clients*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = False },
        result = Wolfram`MCPServer`StartMCPServer`Private`initResponse[
            "TestServer", "1.0.0", { }, { }, <| |>
        ];
        MissingQ @ result[ "capabilities", "extensions" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InitResponse-OmitsExtensionsWhenFalse@@Tests/MCPApps.wlt:168,1-178,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI },
        result = Wolfram`MCPServer`StartMCPServer`Private`initResponse[
            "TestServer", "1.0.0", { }, { }, <| |>
        ];
        MissingQ @ result[ "capabilities", "extensions" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InitResponse-OmitsExtensionsWhenUnset@@Tests/MCPApps.wlt:180,1-190,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Standard Response Fields*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        result = Wolfram`MCPServer`StartMCPServer`Private`initResponse[
            "TestServer", "1.0.0", { }, { }, <| |>
        ];
        { KeyExistsQ[ result, "protocolVersion" ], KeyExistsQ[ result, "capabilities" ], KeyExistsQ[ result, "serverInfo" ] }
    ],
    { True, True, True },
    SameTest -> Equal,
    TestID   -> "InitResponse-StandardFieldsPresent@@Tests/MCPApps.wlt:195,1-205,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = False },
        result = Wolfram`MCPServer`StartMCPServer`Private`initResponse[
            "TestServer", "1.0.0", { }, { }, <| |>
        ];
        result[ "serverInfo" ]
    ],
    <| "name" -> "TestServer", "version" -> "1.0.0" |>,
    SameTest -> MatchQ,
    TestID   -> "InitResponse-ServerInfo@@Tests/MCPApps.wlt:207,1-217,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Backward Compatibility*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = False },
        result = Wolfram`MCPServer`StartMCPServer`Private`initResponse[
            "TestServer", "1.0.0", { }, { }
        ];
        AssociationQ @ result && KeyExistsQ[ result, "protocolVersion" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InitResponse-BackwardCompat4Arg@@Tests/MCPApps.wlt:222,1-232,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*loadUIResource*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*HTML File Without JSON Metadata*)
VerificationTest[
    Module[ { dir, htmlFile, result },
        dir = CreateDirectory[ ];
        htmlFile = FileNameJoin[ { dir, "test-app.html" } ];
        WriteString[ htmlFile, "<!DOCTYPE html><html><body>Test</body></html>" ];
        Close @ htmlFile;
        result = Wolfram`MCPServer`Common`loadUIResource @ htmlFile;
        DeleteDirectory[ dir, DeleteContents -> True ];
        result
    ],
    "ui://wolfram/test-app" -> KeyValuePattern[ {
        "uri"      -> "ui://wolfram/test-app",
        "name"     -> "test-app",
        "mimeType" -> "text/html;profile=mcp-app",
        "html"     -> "<!DOCTYPE html><html><body>Test</body></html>",
        "meta"     -> _Association
    } ],
    SameTest -> MatchQ,
    TestID   -> "LoadUIResource-HTMLOnly@@Tests/MCPApps.wlt:241,1-260,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*HTML File With JSON Metadata*)
VerificationTest[
    Module[ { dir, htmlFile, jsonFile, result },
        dir = CreateDirectory[ ];
        htmlFile = FileNameJoin[ { dir, "test-app.html" } ];
        jsonFile = FileNameJoin[ { dir, "test-app.json" } ];
        WriteString[ htmlFile, "<html><body>Hello</body></html>" ];
        Close @ htmlFile;
        WriteString[ jsonFile, "{\"ui\":{\"prefersBorder\":true,\"csp\":{\"connectDomains\":[]}}}" ];
        Close @ jsonFile;
        result = Wolfram`MCPServer`Common`loadUIResource @ htmlFile;
        DeleteDirectory[ dir, DeleteContents -> True ];
        result
    ],
    "ui://wolfram/test-app" -> KeyValuePattern[ {
        "uri"      -> "ui://wolfram/test-app",
        "name"     -> "test-app",
        "mimeType" -> "text/html;profile=mcp-app",
        "html"     -> "<html><body>Hello</body></html>",
        "meta"     -> KeyValuePattern[ "ui" -> _Association ]
    } ],
    SameTest -> MatchQ,
    TestID   -> "LoadUIResource-WithJSON@@Tests/MCPApps.wlt:265,1-287,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*URI Derivation From File Name*)
VerificationTest[
    Module[ { dir, htmlFile, result },
        dir = CreateDirectory[ ];
        htmlFile = FileNameJoin[ { dir, "wolframalpha-viewer.html" } ];
        WriteString[ htmlFile, "<html></html>" ];
        Close @ htmlFile;
        result = Wolfram`MCPServer`Common`loadUIResource @ htmlFile;
        DeleteDirectory[ dir, DeleteContents -> True ];
        First @ result
    ],
    "ui://wolfram/wolframalpha-viewer",
    SameTest -> Equal,
    TestID   -> "LoadUIResource-URIFromFileName@@Tests/MCPApps.wlt:292,1-305,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Meta Is Empty Association When No JSON*)
VerificationTest[
    Module[ { dir, htmlFile, result },
        dir = CreateDirectory[ ];
        htmlFile = FileNameJoin[ { dir, "no-meta.html" } ];
        WriteString[ htmlFile, "<html></html>" ];
        Close @ htmlFile;
        result = Wolfram`MCPServer`Common`loadUIResource @ htmlFile;
        DeleteDirectory[ dir, DeleteContents -> True ];
        Last[ result ][ "meta" ]
    ],
    <| |>,
    SameTest -> MatchQ,
    TestID   -> "LoadUIResource-EmptyMeta@@Tests/MCPApps.wlt:310,1-323,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*initializeUIResources*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Loads From Paclet Assets*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$uiResourceRegistry },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        AssociationQ @ Wolfram`MCPServer`Common`$uiResourceRegistry
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InitializeUIResources-ReturnsAssociation@@Tests/MCPApps.wlt:332,1-340,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$uiResourceRegistry },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Sort @ Keys @ Wolfram`MCPServer`Common`$uiResourceRegistry
    ],
    { "ui://wolfram/evaluator-viewer", "ui://wolfram/wolframalpha-viewer" },
    SameTest -> Equal,
    TestID   -> "InitializeUIResources-LoadsBothApps@@Tests/MCPApps.wlt:342,1-350,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$uiResourceRegistry },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        StringQ @ Wolfram`MCPServer`Common`$uiResourceRegistry[ "ui://wolfram/wolframalpha-viewer", "html" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "InitializeUIResources-HTMLIsString@@Tests/MCPApps.wlt:352,1-360,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$uiResourceRegistry },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`Common`$uiResourceRegistry[ "ui://wolfram/wolframalpha-viewer", "mimeType" ]
    ],
    "text/html;profile=mcp-app",
    SameTest -> Equal,
    TestID   -> "InitializeUIResources-MimeType@@Tests/MCPApps.wlt:362,1-370,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*JSON Metadata Loaded*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$uiResourceRegistry },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`Common`$uiResourceRegistry[ "ui://wolfram/evaluator-viewer", "meta" ]
    ],
    KeyValuePattern[ "ui" -> KeyValuePattern[ "csp" -> _Association ] ],
    SameTest -> MatchQ,
    TestID   -> "InitializeUIResources-MetadataLoaded@@Tests/MCPApps.wlt:375,1-383,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$uiResourceRegistry },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`Common`$uiResourceRegistry[
            "ui://wolfram/evaluator-viewer", "meta", "ui", "csp", "frameDomains"
        ]
    ],
    { "https://www.wolframcloud.com", "https://wolfr.am" },
    SameTest -> Equal,
    TestID   -> "InitializeUIResources-EvaluatorFrameDomains@@Tests/MCPApps.wlt:385,1-395,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Graceful Fallback*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$uiResourceRegistry },
        (* Use Block to temporarily override the paclet lookup to simulate missing assets *)
        Block[ { PacletObject },
            PacletObject[ "Wolfram/MCPServer" ][ "AssetLocation", "Apps" ] := $Failed;
            Wolfram`MCPServer`Common`initializeUIResources[ ]
        ];
        Wolfram`MCPServer`Common`$uiResourceRegistry
    ],
    <| |>,
    SameTest -> MatchQ,
    TestID   -> "InitializeUIResources-GracefulFallback@@Tests/MCPApps.wlt:400,1-412,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*listUIResources*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Returns Resources When UI Supported*)
VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`Common`listUIResources[ ]
    ],
    { KeyValuePattern[ { "uri" -> _String, "name" -> _String, "mimeType" -> _String } ].. },
    SameTest -> MatchQ,
    TestID   -> "ListUIResources-ReturnsWhenUISupported@@Tests/MCPApps.wlt:421,1-432,2"
]

VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Length @ Wolfram`MCPServer`Common`listUIResources[ ]
    ],
    2,
    SameTest -> Equal,
    TestID   -> "ListUIResources-ReturnsTwoResources@@Tests/MCPApps.wlt:434,1-445,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Returns Empty When UI Not Supported*)
VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = False,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`Common`listUIResources[ ]
    ],
    { },
    SameTest -> Equal,
    TestID   -> "ListUIResources-EmptyWhenNoUI@@Tests/MCPApps.wlt:450,1-461,2"
]

VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`Common`listUIResources[ ]
    ],
    { },
    SameTest -> Equal,
    TestID   -> "ListUIResources-EmptyWhenUnset@@Tests/MCPApps.wlt:463,1-474,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Resource Structure*)
VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Sort @ Map[ #[ "uri" ] &, Wolfram`MCPServer`Common`listUIResources[ ] ]
    ],
    { "ui://wolfram/evaluator-viewer", "ui://wolfram/wolframalpha-viewer" },
    SameTest -> Equal,
    TestID   -> "ListUIResources-CorrectURIs@@Tests/MCPApps.wlt:479,1-490,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*readUIResource*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Valid URI Returns Content*)
VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`Common`readUIResource[
            <| "params" -> <| "uri" -> "ui://wolfram/wolframalpha-viewer" |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 1 |>
        ]
    ],
    KeyValuePattern[ "contents" -> { KeyValuePattern[ {
        "uri"      -> "ui://wolfram/wolframalpha-viewer",
        "mimeType" -> "text/html;profile=mcp-app",
        "text"     -> _String,
        "_meta"    -> _Association
    } ] } ],
    SameTest -> MatchQ,
    TestID   -> "ReadUIResource-ValidURI@@Tests/MCPApps.wlt:499,1-518,2"
]

VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        result = Wolfram`MCPServer`Common`readUIResource[
            <| "params" -> <| "uri" -> "ui://wolfram/evaluator-viewer" |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 2 |>
        ];
        result[[ "contents", 1, "text" ]]
    ],
    _String? (StringContainsQ[ "<!DOCTYPE html>" | "<html" ]),
    SameTest -> MatchQ,
    TestID   -> "ReadUIResource-HTMLContent@@Tests/MCPApps.wlt:520,1-535,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Unknown URI Returns Failure*)
VerificationTest[
    Quiet @ Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`Common`readUIResource[
            <| "params" -> <| "uri" -> "ui://wolfram/nonexistent" |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 3 |>
        ]
    ],
    _Failure,
    SameTest -> MatchQ,
    TestID   -> "ReadUIResource-UnknownURI@@Tests/MCPApps.wlt:540,1-554,2"
]

VerificationTest[
    Quiet @ Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`Common`readUIResource[
            <| "params" -> <| "uri" -> 123 |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 4 |>
        ]
    ],
    _Failure,
    SameTest -> MatchQ,
    TestID   -> "ReadUIResource-InvalidURIType@@Tests/MCPApps.wlt:556,1-570,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*handleResourceRead*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Valid URI Returns Result*)
VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`StartMCPServer`Private`handleResourceRead[
            <| "params" -> <| "uri" -> "ui://wolfram/wolframalpha-viewer" |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 1 |>
        ]
    ],
    KeyValuePattern[ {
        "jsonrpc" -> "2.0",
        "id"      -> 1,
        "result"  -> KeyValuePattern[ "contents" -> { _Association.. } ]
    } ],
    SameTest -> MatchQ,
    TestID   -> "HandleResourceRead-ValidURI@@Tests/MCPApps.wlt:579,1-597,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Unknown URI Returns Error With Code -32602*)
VerificationTest[
    Quiet @ Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`StartMCPServer`Private`handleResourceRead[
            <| "params" -> <| "uri" -> "ui://wolfram/nonexistent" |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 2 |>
        ]
    ],
    KeyValuePattern[ {
        "jsonrpc" -> "2.0",
        "id"      -> 2,
        "error"   -> KeyValuePattern[ {
            "code"    -> -32602,
            "message" -> _String? (StringContainsQ[ "ui://wolfram/nonexistent" ])
        } ]
    } ],
    SameTest -> MatchQ,
    TestID   -> "HandleResourceRead-UnknownURIError@@Tests/MCPApps.wlt:602,1-623,2"
]

VerificationTest[
    Quiet @ Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        response = Wolfram`MCPServer`StartMCPServer`Private`handleResourceRead[
            <| "params" -> <| "uri" -> "ui://wolfram/nonexistent" |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 5 |>
        ];
        response[ "error", "code" ]
    ],
    -32602,
    SameTest -> Equal,
    TestID   -> "HandleResourceRead-ErrorCodeIs32602@@Tests/MCPApps.wlt:625,1-640,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Invalid Params Returns Error*)
VerificationTest[
    Quiet @ Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        response = Wolfram`MCPServer`StartMCPServer`Private`handleResourceRead[
            <| "params" -> <| "uri" -> 999 |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 6 |>
        ];
        KeyExistsQ[ response, "error" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "HandleResourceRead-InvalidParamsError@@Tests/MCPApps.wlt:645,1-660,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*handleMethod - resources/list Integration*)

VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`StartMCPServer`Private`handleMethod[
            "resources/list",
            <| "method" -> "resources/list", "params" -> <| |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 1 |>
        ]
    ],
    KeyValuePattern[ {
        "result" -> KeyValuePattern[ "resources" -> { __Association } ]
    } ],
    SameTest -> MatchQ,
    TestID   -> "HandleMethod-ResourcesList-UIClient@@Tests/MCPApps.wlt:666,1-683,2"
]

VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = False,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`StartMCPServer`Private`handleMethod[
            "resources/list",
            <| "method" -> "resources/list", "params" -> <| |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 1 |>
        ]
    ],
    KeyValuePattern[ {
        "result" -> KeyValuePattern[ "resources" -> { } ]
    } ],
    SameTest -> MatchQ,
    TestID   -> "HandleMethod-ResourcesList-NonUIClient@@Tests/MCPApps.wlt:685,1-702,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*handleMethod - resources/read Integration*)

VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`StartMCPServer`Private`handleMethod[
            "resources/read",
            <| "method" -> "resources/read", "params" -> <| "uri" -> "ui://wolfram/wolframalpha-viewer" |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 2 |>
        ]
    ],
    KeyValuePattern[ {
        "result" -> KeyValuePattern[ "contents" -> { KeyValuePattern[ {
            "uri"      -> "ui://wolfram/wolframalpha-viewer",
            "mimeType" -> "text/html;profile=mcp-app",
            "text"     -> _String
        } ] } ]
    } ],
    SameTest -> MatchQ,
    TestID   -> "HandleMethod-ResourcesRead-ValidURI@@Tests/MCPApps.wlt:708,1-729,2"
]

VerificationTest[
    Quiet @ Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`Common`$uiResourceRegistry
    },
        Wolfram`MCPServer`Common`initializeUIResources[ ];
        Wolfram`MCPServer`StartMCPServer`Private`handleMethod[
            "resources/read",
            <| "method" -> "resources/read", "params" -> <| "uri" -> "ui://wolfram/unknown" |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 3 |>
        ]
    ],
    KeyValuePattern[ {
        "error" -> KeyValuePattern[ {
            "code"    -> -32602,
            "message" -> _String? (StringContainsQ[ "ui://wolfram/unknown" ])
        } ]
    } ],
    SameTest -> MatchQ,
    TestID   -> "HandleMethod-ResourcesRead-UnknownURI@@Tests/MCPApps.wlt:731,1-751,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toolUIMetadata*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Returns _meta for Known Tool When UI Supported*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        Wolfram`MCPServer`Common`toolUIMetadata[ "WolframAlpha" ]
    ],
    { "_meta" -> _Association },
    SameTest -> MatchQ,
    TestID   -> "ToolUIMetadata-KnownToolWithUI@@Tests/MCPApps.wlt:760,1-767,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        meta = Wolfram`MCPServer`Common`toolUIMetadata[ "WolframAlpha" ];
        ("_meta" /. meta)[ "ui", "resourceUri" ]
    ],
    "ui://wolfram/wolframalpha-viewer",
    SameTest -> Equal,
    TestID   -> "ToolUIMetadata-CorrectResourceURI@@Tests/MCPApps.wlt:769,1-777,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        meta = Wolfram`MCPServer`Common`toolUIMetadata[ "WolframAlpha" ];
        ("_meta" /. meta)[ "ui", "visibility" ]
    ],
    { "model", "app" },
    SameTest -> Equal,
    TestID   -> "ToolUIMetadata-CorrectVisibility@@Tests/MCPApps.wlt:779,1-787,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        Wolfram`MCPServer`Common`toolUIMetadata[ "WolframLanguageEvaluator" ]
    ],
    { "_meta" -> KeyValuePattern[ "ui" -> KeyValuePattern[ "resourceUri" -> "ui://wolfram/evaluator-viewer" ] ] },
    SameTest -> MatchQ,
    TestID   -> "ToolUIMetadata-EvaluatorTool@@Tests/MCPApps.wlt:789,1-796,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Returns Empty for Unknown or Unsupported Tools*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        Wolfram`MCPServer`Common`toolUIMetadata[ "UnknownTool" ]
    ],
    { },
    SameTest -> Equal,
    TestID   -> "ToolUIMetadata-UnknownTool@@Tests/MCPApps.wlt:801,1-808,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = False },
        Wolfram`MCPServer`Common`toolUIMetadata[ "WolframAlpha" ]
    ],
    { },
    SameTest -> Equal,
    TestID   -> "ToolUIMetadata-KnownToolNoUI@@Tests/MCPApps.wlt:810,1-817,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI },
        Wolfram`MCPServer`Common`toolUIMetadata[ "WolframAlpha" ]
    ],
    { },
    SameTest -> Equal,
    TestID   -> "ToolUIMetadata-KnownToolUIUnset@@Tests/MCPApps.wlt:819,1-826,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*withToolUIMetadata*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Adds _meta When UI Supported*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        tools = {
            <| "name" -> "WolframAlpha", "description" -> "test", "inputSchema" -> <| |> |>,
            <| "name" -> "OtherTool",    "description" -> "test", "inputSchema" -> <| |> |>
        };
        result = Wolfram`MCPServer`Common`withToolUIMetadata @ tools;
        KeyExistsQ[ result[[ 1 ]], "_meta" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "WithToolUIMetadata-AddsMetaToKnownTool@@Tests/MCPApps.wlt:835,1-847,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        tools = {
            <| "name" -> "WolframAlpha", "description" -> "test", "inputSchema" -> <| |> |>,
            <| "name" -> "OtherTool",    "description" -> "test", "inputSchema" -> <| |> |>
        };
        result = Wolfram`MCPServer`Common`withToolUIMetadata @ tools;
        KeyExistsQ[ result[[ 2 ]], "_meta" ]
    ],
    False,
    SameTest -> Equal,
    TestID   -> "WithToolUIMetadata-NoMetaForUnknownTool@@Tests/MCPApps.wlt:849,1-861,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        tools = {
            <| "name" -> "WolframAlpha", "description" -> "test", "inputSchema" -> <| |> |>
        };
        result = Wolfram`MCPServer`Common`withToolUIMetadata @ tools;
        result[[ 1, "_meta", "ui", "resourceUri" ]]
    ],
    "ui://wolfram/wolframalpha-viewer",
    SameTest -> Equal,
    TestID   -> "WithToolUIMetadata-CorrectMetaContent@@Tests/MCPApps.wlt:863,1-874,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*No Changes When UI Not Supported*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = False },
        tools = {
            <| "name" -> "WolframAlpha", "description" -> "test", "inputSchema" -> <| |> |>
        };
        Wolfram`MCPServer`Common`withToolUIMetadata @ tools
    ],
    { <| "name" -> "WolframAlpha", "description" -> "test", "inputSchema" -> <| |> |> },
    SameTest -> Equal,
    TestID   -> "WithToolUIMetadata-NoChangesWhenNoUI@@Tests/MCPApps.wlt:879,1-889,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*Preserves Existing Fields*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI = True },
        tools = {
            <| "name" -> "WolframAlpha", "description" -> "WA tool", "inputSchema" -> <| "type" -> "object" |> |>
        };
        result = Wolfram`MCPServer`Common`withToolUIMetadata @ tools;
        { result[[ 1, "name" ]], result[[ 1, "description" ]], result[[ 1, "inputSchema" ]] }
    ],
    { "WolframAlpha", "WA tool", <| "type" -> "object" |> },
    SameTest -> Equal,
    TestID   -> "WithToolUIMetadata-PreservesExistingFields@@Tests/MCPApps.wlt:894,1-905,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*handleMethod - tools/list Integration*)

VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`StartMCPServer`Private`$toolList = {
            <| "name" -> "WolframAlpha", "description" -> "test", "inputSchema" -> <| |> |>,
            <| "name" -> "OtherTool",    "description" -> "test", "inputSchema" -> <| |> |>
        }
    },
        result = Wolfram`MCPServer`StartMCPServer`Private`handleMethod[
            "tools/list",
            <| "method" -> "tools/list", "params" -> <| |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 1 |>
        ];
        waTool = SelectFirst[ result[ "result", "tools" ], #[ "name" ] === "WolframAlpha" & ];
        KeyExistsQ[ waTool, "_meta" ]
    ],
    True,
    SameTest -> Equal,
    TestID   -> "HandleMethod-ToolsList-UIMetaPresent@@Tests/MCPApps.wlt:911,1-930,2"
]

VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = True,
        Wolfram`MCPServer`StartMCPServer`Private`$toolList = {
            <| "name" -> "WolframAlpha", "description" -> "test", "inputSchema" -> <| |> |>,
            <| "name" -> "OtherTool",    "description" -> "test", "inputSchema" -> <| |> |>
        }
    },
        result = Wolfram`MCPServer`StartMCPServer`Private`handleMethod[
            "tools/list",
            <| "method" -> "tools/list", "params" -> <| |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 1 |>
        ];
        otherTool = SelectFirst[ result[ "result", "tools" ], #[ "name" ] === "OtherTool" & ];
        KeyExistsQ[ otherTool, "_meta" ]
    ],
    False,
    SameTest -> Equal,
    TestID   -> "HandleMethod-ToolsList-NoMetaForUnlinkedTool@@Tests/MCPApps.wlt:932,1-951,2"
]

VerificationTest[
    Block[ {
        Wolfram`MCPServer`Common`$clientSupportsUI = False,
        Wolfram`MCPServer`StartMCPServer`Private`$toolList = {
            <| "name" -> "WolframAlpha", "description" -> "test", "inputSchema" -> <| |> |>
        }
    },
        result = Wolfram`MCPServer`StartMCPServer`Private`handleMethod[
            "tools/list",
            <| "method" -> "tools/list", "params" -> <| |> |>,
            <| "jsonrpc" -> "2.0", "id" -> 1 |>
        ];
        waTool = First @ result[ "result", "tools" ];
        KeyExistsQ[ waTool, "_meta" ]
    ],
    False,
    SameTest -> Equal,
    TestID   -> "HandleMethod-ToolsList-NoMetaWhenNoUI@@Tests/MCPApps.wlt:953,1-971,2"
]

(* :!CodeAnalysis::EndBlock:: *)
