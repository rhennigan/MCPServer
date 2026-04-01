(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/CreateMCPServer.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/CreateMCPServer.wlt:11,1-16,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Basic Examples*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Basic Creation, Retrieval, and Deletion*)
VerificationTest[
    name = CreateUUID[ ];
    server = CreateMCPServer[
        name,
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "PrimeFinder", { "n" -> "Integer" }, Prime[ #n ] & ] } |>
    ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-BasicExample@@Tests/CreateMCPServer.wlt:25,1-34,2"
]

VerificationTest[
    MCPServerObject @ name,
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-CheckRetrieval@@Tests/CreateMCPServer.wlt:36,1-41,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-DeleteObject@@Tests/CreateMCPServer.wlt:43,1-48,2"
]

VerificationTest[
    MCPServerObject @ name,
    _Failure,
    { MCPServerObject::MCPServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-DeletionCheck@@Tests/CreateMCPServer.wlt:50,1-56,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Options*)
VerificationTest[
    name = CreateUUID[ ];
    server = CreateMCPServer[
        name,
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "Doubler", { "x" -> "Number" }, 2 * #x & ] } |>,
        OverwriteTarget -> False
    ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-OverwriteOptionFalse@@Tests/CreateMCPServer.wlt:61,1-71,2"
]

VerificationTest[
    CreateMCPServer[
        name,
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "Tripler", { "x" -> "Number" }, 3 * #x & ] } |>,
        OverwriteTarget -> False
    ],
    _Failure,
    { CreateMCPServer::MCPServerExists },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-ExistingServerNoOverwrite@@Tests/CreateMCPServer.wlt:73,1-83,2"
]

VerificationTest[
    newServer = CreateMCPServer[
        name,
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "Tripler", { "x" -> "Number" }, 3 * #x & ] } |>,
        OverwriteTarget -> True
    ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-OverwriteOptionTrue@@Tests/CreateMCPServer.wlt:85,1-94,2"
]

VerificationTest[
    newServer["Tools"][[1]]["Name"],
    "Tripler",
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-VerifyOverwrite@@Tests/CreateMCPServer.wlt:96,1-101,2"
]

VerificationTest[
    DeleteObject @ newServer,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-OptionsCleanup@@Tests/CreateMCPServer.wlt:103,1-108,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Server Properties*)
VerificationTest[
    name = CreateUUID[ ];
    server = CreateMCPServer[
        name,
        LLMConfiguration @ <|
            "Tools" -> { LLMTool[ "StringReverse", { "text" -> "String" }, StringReverse[ #text ] & ] },
            "Temperature" -> 0.7,
            "MaxTokens" -> 1000
        |>
    ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-WithProperties@@Tests/CreateMCPServer.wlt:113,1-126,2"
]

VerificationTest[
    server["Temperature"],
    0.7,
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-VerifyTemperature@@Tests/CreateMCPServer.wlt:128,1-133,2"
]

VerificationTest[
    server["MaxTokens"],
    1000,
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-VerifyMaxTokens@@Tests/CreateMCPServer.wlt:135,1-140,2"
]

VerificationTest[
    server["ServerVersion"],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-ServerVersion@@Tests/CreateMCPServer.wlt:142,1-147,2"
]

VerificationTest[
    server["Location"],
    _File? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-VerifyLocation@@Tests/CreateMCPServer.wlt:149,1-154,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-PropertiesCleanup@@Tests/CreateMCPServer.wlt:156,1-161,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*LLMConfiguration Conversion*)
VerificationTest[
    name = CreateUUID[ ];
    config = <| "Tools" -> { LLMTool[ "Identity", { "x" -> "Expression" }, #x & ] } |>;
    server = CreateMCPServer[name, config],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-FromAssociation@@Tests/CreateMCPServer.wlt:166,1-173,2"
]

VerificationTest[
    server["LLMConfiguration"],
    _LLMConfiguration,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-LLMConfigurationProperty@@Tests/CreateMCPServer.wlt:175,1-180,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-ConfigCleanup@@Tests/CreateMCPServer.wlt:182,1-187,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Chatbook Tool Rewriting*)

(* Test that LLMConfiguration with string tool names produces equivalent results to association input *)
VerificationTest[
    name1 = CreateUUID[ ];
    name2 = CreateUUID[ ];
    server1 = CreateMCPServer[ name1, LLMConfiguration @ <| "Tools" -> { "WolframLanguageEvaluator" } |> ];
    server2 = CreateMCPServer[ name2, <| "Tools" -> { "WolframLanguageEvaluator" } |> ];
    SameQ[ server1[ "Tools" ], server2[ "Tools" ] ],
    True,
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-WLEvaluatorEquivalence@@Tests/CreateMCPServer.wlt:194,1-203,2"
]

VerificationTest[
    { DeleteObject @ server1, DeleteObject @ server2 },
    { Null, Null },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-WLEvaluatorCleanup@@Tests/CreateMCPServer.wlt:205,1-210,2"
]

VerificationTest[
    name1 = CreateUUID[ ];
    name2 = CreateUUID[ ];
    server1 = CreateMCPServer[ name1, LLMConfiguration @ <| "Tools" -> { "WolframAlpha" } |> ];
    server2 = CreateMCPServer[ name2, <| "Tools" -> { "WolframAlpha" } |> ];
    SameQ[ server1[ "Tools" ], server2[ "Tools" ] ],
    True,
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-WolframAlphaEquivalence@@Tests/CreateMCPServer.wlt:212,1-221,2"
]

VerificationTest[
    { DeleteObject @ server1, DeleteObject @ server2 },
    { Null, Null },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-WolframAlphaCleanup@@Tests/CreateMCPServer.wlt:223,1-228,2"
]

(* Test that both tools together are rewritten correctly *)
VerificationTest[
    name1 = CreateUUID[ ];
    name2 = CreateUUID[ ];
    server1 = CreateMCPServer[ name1, LLMConfiguration @ <| "Tools" -> { "WolframLanguageEvaluator", "WolframAlpha" } |> ];
    server2 = CreateMCPServer[ name2, <| "Tools" -> { "WolframLanguageEvaluator", "WolframAlpha" } |> ];
    SameQ[ server1[ "Tools" ], server2[ "Tools" ] ],
    True,
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-BothToolsEquivalence@@Tests/CreateMCPServer.wlt:231,1-240,2"
]

VerificationTest[
    { DeleteObject @ server1, DeleteObject @ server2 },
    { Null, Null },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-BothToolsCleanup@@Tests/CreateMCPServer.wlt:242,1-247,2"
]

(* Test that custom tools are not affected by the rewriting *)
VerificationTest[
    name1 = CreateUUID[ ];
    name2 = CreateUUID[ ];
    customTool = LLMTool[ "CustomTool", { "x" -> "Integer" }, #x^2 & ];
    server1 = CreateMCPServer[ name1, LLMConfiguration @ <| "Tools" -> { customTool, "WolframLanguageEvaluator" } |> ];
    server2 = CreateMCPServer[ name2, <| "Tools" -> { customTool, "WolframLanguageEvaluator" } |> ];
    SameQ[ server1[ "Tools" ], server2[ "Tools" ] ],
    True,
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-CustomToolPreserved@@Tests/CreateMCPServer.wlt:250,1-260,2"
]

VerificationTest[
    server1[ "Tools" ][[ 1 ]][ "Name" ],
    "CustomTool",
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-CustomToolName@@Tests/CreateMCPServer.wlt:262,1-267,2"
]

VerificationTest[
    { DeleteObject @ server1, DeleteObject @ server2 },
    { Null, Null },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-CustomToolCleanup@@Tests/CreateMCPServer.wlt:269,1-274,2"
]