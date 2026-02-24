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
(*clientSupportsUIQ*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
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
    TestID   -> "ClientSupportsUIQ-UIClient@@Tests/MCPApps.wlt:28,1-46,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
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
    TestID   -> "ClientSupportsUIQ-NoExtensions@@Tests/MCPApps.wlt:51,1-63,2"
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
    TestID   -> "ClientSupportsUIQ-OtherExtension@@Tests/MCPApps.wlt:65,1-79,2"
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
    TestID   -> "ClientSupportsUIQ-NoCapabilities@@Tests/MCPApps.wlt:81,1-92,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`clientSupportsUIQ @ <| "method" -> "initialize" |>,
    False,
    SameTest -> Equal,
    TestID   -> "ClientSupportsUIQ-NoParams@@Tests/MCPApps.wlt:94,1-99,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Invalid Inputs*)
VerificationTest[
    Wolfram`MCPServer`Common`clientSupportsUIQ @ "not an association",
    False,
    SameTest -> Equal,
    TestID   -> "ClientSupportsUIQ-NonAssociation@@Tests/MCPApps.wlt:104,1-109,2"
]

VerificationTest[
    Wolfram`MCPServer`Common`clientSupportsUIQ @ Null,
    False,
    SameTest -> Equal,
    TestID   -> "ClientSupportsUIQ-Null@@Tests/MCPApps.wlt:111,1-116,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*initResponse*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
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
    TestID   -> "InitResponse-IncludesExtensions@@Tests/MCPApps.wlt:125,1-135,2"
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
    TestID   -> "InitResponse-ExtensionsStructure@@Tests/MCPApps.wlt:137,1-147,2"
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
    TestID   -> "InitResponse-ExtensionsMimeType@@Tests/MCPApps.wlt:149,1-159,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
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
    TestID   -> "InitResponse-OmitsExtensionsWhenFalse@@Tests/MCPApps.wlt:164,1-174,2"
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
    TestID   -> "InitResponse-OmitsExtensionsWhenUnset@@Tests/MCPApps.wlt:176,1-186,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
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
    TestID   -> "InitResponse-StandardFieldsPresent@@Tests/MCPApps.wlt:191,1-201,2"
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
    TestID   -> "InitResponse-ServerInfo@@Tests/MCPApps.wlt:203,1-213,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
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
    TestID   -> "InitResponse-BackwardCompat4Arg@@Tests/MCPApps.wlt:218,1-228,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Extension Negotiation Integration*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$clientSupportsUI Flag*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI },
        msg = <|
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
                "clientInfo" -> <| "name" -> "test-client" |>
            |>
        |>;
        Wolfram`MCPServer`Common`$clientSupportsUI = Wolfram`MCPServer`Common`clientSupportsUIQ @ msg;
        Wolfram`MCPServer`Common`$clientSupportsUI
    ],
    True,
    SameTest -> Equal,
    TestID   -> "Integration-UIClientSetsFlag@@Tests/MCPApps.wlt:237,1-259,2"
]

VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI },
        msg = <|
            "method" -> "initialize",
            "params" -> <|
                "protocolVersion" -> "2024-11-05",
                "clientInfo" -> <| "name" -> "test-client" |>
            |>
        |>;
        Wolfram`MCPServer`Common`$clientSupportsUI = Wolfram`MCPServer`Common`clientSupportsUIQ @ msg;
        Wolfram`MCPServer`Common`$clientSupportsUI
    ],
    False,
    SameTest -> Equal,
    TestID   -> "Integration-NonUIClientSetsFlag@@Tests/MCPApps.wlt:261,1-276,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Full Round-Trip*)
VerificationTest[
    Block[ { Wolfram`MCPServer`Common`$clientSupportsUI },
        uiMsg = <|
            "params" -> <|
                "capabilities" -> <|
                    "extensions" -> <| "io.modelcontextprotocol/ui" -> <| "mimeTypes" -> { "text/html;profile=mcp-app" } |> |>
                |>
            |>
        |>;
        Wolfram`MCPServer`Common`$clientSupportsUI = Wolfram`MCPServer`Common`clientSupportsUIQ @ uiMsg;
        uiResult = Wolfram`MCPServer`StartMCPServer`Private`initResponse[ "Test", "1.0", { }, { }, uiMsg ];

        Wolfram`MCPServer`Common`$clientSupportsUI = False;
        noUIResult = Wolfram`MCPServer`StartMCPServer`Private`initResponse[ "Test", "1.0", { }, { }, <| |> ];

        {
            ! MissingQ @ uiResult[ "capabilities", "extensions" ],
            MissingQ @ noUIResult[ "capabilities", "extensions" ]
        }
    ],
    { True, True },
    SameTest -> Equal,
    TestID   -> "Integration-FullRoundTrip@@Tests/MCPApps.wlt:281,1-304,2"
]

(* :!CodeAnalysis::EndBlock:: *)
