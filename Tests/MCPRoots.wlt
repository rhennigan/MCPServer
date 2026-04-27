(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/MCPRoots.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/MCPRoots.wlt:11,1-16,2"
]

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Session State*)

VerificationTest[
    BooleanQ @ Wolfram`AgentTools`Common`$clientSupportsRoots,
    True,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-ClientSupportsRootsIsBoolean@@Tests/MCPRoots.wlt:25,1-30,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`$mcpRoot === None || StringQ @ Wolfram`AgentTools`Common`$mcpRoot,
    True,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-McpRootIsNoneOrString@@Tests/MCPRoots.wlt:32,1-37,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*rootURIToPath*)

(* file:// URIs are expanded to native paths via ExpandFileName[LocalObject[uri]]. *)
VerificationTest[
    StringQ @ Wolfram`AgentTools`MCPRoots`Private`rootURIToPath[
        "file:///" <> StringReplace[ $TemporaryDirectory, "\\" -> "/" ]
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-RootURIToPathFileScheme@@Tests/MCPRoots.wlt:44,1-51,2"
]

(* Non-file URIs are rejected. *)
VerificationTest[
    Wolfram`AgentTools`MCPRoots`Private`rootURIToPath[ "https://example.com/path" ],
    None,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-RootURIToPathNonFileScheme@@Tests/MCPRoots.wlt:54,1-59,2"
]

(* Non-strings are rejected. *)
VerificationTest[
    Wolfram`AgentTools`MCPRoots`Private`rootURIToPath[ 42 ],
    None,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-RootURIToPathNonString@@Tests/MCPRoots.wlt:62,1-67,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*pickFirstValidRoot*)

(* A single valid root is returned as-is. *)
VerificationTest[
    Module[ { tmpDir, uri, result, ok },
        tmpDir = CreateDirectory[ ];
        uri = "file:///" <> StringReplace[ tmpDir, "\\" -> "/" ];
        WithCleanup[
            result = Wolfram`AgentTools`MCPRoots`Private`pickFirstValidRoot[
                { <| "uri" -> uri, "name" -> "tmp" |> }
            ];
            ok = StringQ @ result && DirectoryQ @ result,
            DeleteDirectory[ tmpDir, DeleteContents -> True ]
        ];
        ok
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-PickFirstValidRootSingle@@Tests/MCPRoots.wlt:74,1-90,2"
]

(* The first invalid root is skipped, and the second valid root is returned. *)
VerificationTest[
    Module[ { tmpDir, validURI, result, ok },
        tmpDir = CreateDirectory[ ];
        validURI = "file:///" <> StringReplace[ tmpDir, "\\" -> "/" ];
        WithCleanup[
            result = Wolfram`AgentTools`MCPRoots`Private`pickFirstValidRoot[
                {
                    <| "uri" -> "file:///nonexistent/path/that/does/not/exist", "name" -> "stale" |>,
                    <| "uri" -> validURI, "name" -> "good" |>
                }
            ];
            ok = StringQ @ result && DirectoryQ @ result,
            DeleteDirectory[ tmpDir, DeleteContents -> True ]
        ];
        ok
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-PickFirstValidRootMultiFallback@@Tests/MCPRoots.wlt:93,1-112,2"
]

(* An empty list returns None. *)
VerificationTest[
    Wolfram`AgentTools`MCPRoots`Private`pickFirstValidRoot[ { } ],
    None,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-PickFirstValidRootEmpty@@Tests/MCPRoots.wlt:115,1-120,2"
]

(* Entries without "uri" are skipped. *)
VerificationTest[
    Wolfram`AgentTools`MCPRoots`Private`pickFirstValidRoot[
        { <| "name" -> "missing-uri" |> }
    ],
    None,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-PickFirstValidRootNoURIKey@@Tests/MCPRoots.wlt:123,1-130,2"
]

(* Non-file:// schemes are skipped. *)
VerificationTest[
    Wolfram`AgentTools`MCPRoots`Private`pickFirstValidRoot[
        { <| "uri" -> "https://example.com/", "name" -> "web" |> }
    ],
    None,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-PickFirstValidRootNonFileScheme@@Tests/MCPRoots.wlt:133,1-140,2"
]

(* All-invalid lists return None. *)
VerificationTest[
    Wolfram`AgentTools`MCPRoots`Private`pickFirstValidRoot[
        {
            <| "uri" -> "file:///nonexistent/aaaa", "name" -> "a" |>,
            <| "uri" -> "file:///nonexistent/bbbb", "name" -> "b" |>
        }
    ],
    None,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-PickFirstValidRootAllInvalid@@Tests/MCPRoots.wlt:143,1-153,2"
]

(* Non-list inputs return None. *)
VerificationTest[
    Wolfram`AgentTools`MCPRoots`Private`pickFirstValidRoot[ "not a list" ],
    None,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-PickFirstValidRootNonList@@Tests/MCPRoots.wlt:156,1-161,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*handleRootsListResponse*)

(* A successful response with a valid root invokes applyMCPRoot. The nested
   "result"."roots" path is read via Part-style chaining (response[ "result", "roots" ])
   rather than Lookup with a list-key, so this also serves as the regression test
   that the nested-association lookup keeps working. *)
VerificationTest[
    Module[ { tmpDir, uri, applied, response, ok },
        tmpDir = CreateDirectory[ ];
        uri = "file:///" <> StringReplace[ tmpDir, "\\" -> "/" ];
        applied = None;
        response = <|
            "jsonrpc" -> "2.0",
            "id"      -> "test-uuid",
            "result"  -> <| "roots" -> { <| "uri" -> uri, "name" -> "tmp" |> } |>
        |>;
        WithCleanup[
            Block[
                {
                    Wolfram`AgentTools`MCPRoots`Private`applyMCPRoot =
                        Function[ root, applied = root ]
                },
                Wolfram`AgentTools`MCPRoots`Private`handleRootsListResponse[
                    <| "method" -> "roots/list" |>,
                    response
                ]
            ];
            ok = StringQ @ applied && DirectoryQ @ applied,
            DeleteDirectory[ tmpDir, DeleteContents -> True ]
        ];
        ok
    ],
    True,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-HandleRootsListResponseSuccess@@Tests/MCPRoots.wlt:171,1-200,2"
]

(* An error response logs the error and does not apply a root. *)
VerificationTest[
    Module[ { applied, response },
        applied = None;
        response = <|
            "jsonrpc" -> "2.0",
            "id"      -> "test-uuid",
            "error"   -> <| "code" -> -32601, "message" -> "Method not found" |>
        |>;
        Block[
            {
                Wolfram`AgentTools`MCPRoots`Private`applyMCPRoot =
                    Function[ root, applied = root ]
            },
            Wolfram`AgentTools`MCPRoots`Private`handleRootsListResponse[
                <| "method" -> "roots/list" |>,
                response
            ]
        ];
        applied
    ],
    None,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-HandleRootsListResponseError@@Tests/MCPRoots.wlt:203,1-226,2"
]

(* An empty roots list does not apply a root. *)
VerificationTest[
    Module[ { applied, response },
        applied = None;
        response = <|
            "jsonrpc" -> "2.0",
            "id"      -> "test-uuid",
            "result"  -> <| "roots" -> { } |>
        |>;
        Block[
            {
                Wolfram`AgentTools`MCPRoots`Private`applyMCPRoot =
                    Function[ root, applied = root ]
            },
            Wolfram`AgentTools`MCPRoots`Private`handleRootsListResponse[
                <| "method" -> "roots/list" |>,
                response
            ]
        ];
        applied
    ],
    None,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-HandleRootsListResponseEmpty@@Tests/MCPRoots.wlt:229,1-252,2"
]

(* All roots invalid - no root applied. *)
VerificationTest[
    Module[ { applied, response },
        applied = None;
        response = <|
            "jsonrpc" -> "2.0",
            "id"      -> "test-uuid",
            "result"  -> <| "roots" -> {
                <| "uri" -> "file:///nonexistent/aaaa", "name" -> "a" |>,
                <| "uri" -> "https://example.com",     "name" -> "b" |>
            } |>
        |>;
        Block[
            {
                Wolfram`AgentTools`MCPRoots`Private`applyMCPRoot =
                    Function[ root, applied = root ]
            },
            Wolfram`AgentTools`MCPRoots`Private`handleRootsListResponse[
                <| "method" -> "roots/list" |>,
                response
            ]
        ];
        applied
    ],
    None,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-HandleRootsListResponseAllInvalid@@Tests/MCPRoots.wlt:255,1-281,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*onClientInitialized*)

(* When the client did not advertise roots, no request is sent. *)
VerificationTest[
    Module[ { sent, savedFlag },
        savedFlag = Wolfram`AgentTools`Common`$clientSupportsRoots;
        sent = None;
        WithCleanup[
            Wolfram`AgentTools`Common`$clientSupportsRoots = False,
            Block[
                {
                    Wolfram`AgentTools`Common`sendClientRequest =
                        Function[ { method, params, handler }, sent = method ]
                },
                Wolfram`AgentTools`Common`onClientInitialized[ <| |> ]
            ],
            Wolfram`AgentTools`Common`$clientSupportsRoots = savedFlag
        ];
        sent
    ],
    None,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-OnClientInitializedNoCapability@@Tests/MCPRoots.wlt:288,1-308,2"
]

(* When the client advertised roots, a roots/list request is sent. *)
VerificationTest[
    Module[ { sent, savedFlag },
        savedFlag = Wolfram`AgentTools`Common`$clientSupportsRoots;
        sent = None;
        WithCleanup[
            Wolfram`AgentTools`Common`$clientSupportsRoots = True,
            Block[
                {
                    Wolfram`AgentTools`Common`sendClientRequest =
                        Function[ { method, params, handler }, sent = method ]
                },
                Wolfram`AgentTools`Common`onClientInitialized[ <| |> ]
            ],
            Wolfram`AgentTools`Common`$clientSupportsRoots = savedFlag
        ];
        sent
    ],
    "roots/list",
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-OnClientInitializedSendsRequest@@Tests/MCPRoots.wlt:311,1-331,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*onRootsListChanged*)

(* When the client did not advertise roots, list_changed does not trigger a request. *)
VerificationTest[
    Module[ { sent, savedFlag },
        savedFlag = Wolfram`AgentTools`Common`$clientSupportsRoots;
        sent = None;
        WithCleanup[
            Wolfram`AgentTools`Common`$clientSupportsRoots = False,
            Block[
                {
                    Wolfram`AgentTools`Common`sendClientRequest =
                        Function[ { method, params, handler }, sent = method ]
                },
                Wolfram`AgentTools`Common`onRootsListChanged[ <| |> ]
            ],
            Wolfram`AgentTools`Common`$clientSupportsRoots = savedFlag
        ];
        sent
    ],
    None,
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-OnRootsListChangedNoCapability@@Tests/MCPRoots.wlt:338,1-358,2"
]

(* When the client advertised roots, list_changed triggers a fresh roots/list request. *)
VerificationTest[
    Module[ { sent, savedFlag },
        savedFlag = Wolfram`AgentTools`Common`$clientSupportsRoots;
        sent = None;
        WithCleanup[
            Wolfram`AgentTools`Common`$clientSupportsRoots = True,
            Block[
                {
                    Wolfram`AgentTools`Common`sendClientRequest =
                        Function[ { method, params, handler }, sent = method ]
                },
                Wolfram`AgentTools`Common`onRootsListChanged[ <| |> ]
            ],
            Wolfram`AgentTools`Common`$clientSupportsRoots = savedFlag
        ];
        sent
    ],
    "roots/list",
    SameTest -> MatchQ,
    TestID   -> "MCPRoots-OnRootsListChangedSendsRequest@@Tests/MCPRoots.wlt:361,1-381,2"
]

(* :!CodeAnalysis::EndBlock:: *)
