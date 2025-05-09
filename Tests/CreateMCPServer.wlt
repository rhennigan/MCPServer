(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    If[ ! TrueQ @ RickHennigan`MCPServerTests`$TestDefinitionsLoaded,
        Get @ FileNameJoin @ { DirectoryName[ $TestFileName ], "Common.wl" }
    ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/CreateMCPServer.wlt:4,1-11,2"
]

VerificationTest[
    Needs[ "RickHennigan`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/CreateMCPServer.wlt:13,1-18,2"
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
    TestID   -> "CreateMCPServer-BasicExample@@Tests/CreateMCPServer.wlt:27,1-36,2"
]

VerificationTest[
    MCPServerObject @ name,
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-CheckRetrieval@@Tests/CreateMCPServer.wlt:38,1-43,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-DeleteObject@@Tests/CreateMCPServer.wlt:45,1-50,2"
]

VerificationTest[
    MCPServerObject @ name,
    _Failure,
    { MCPServerObject::MCPServerNotFound },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-DeletionCheck@@Tests/CreateMCPServer.wlt:52,1-58,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Create MCP Server from Default $LLMEvaluator*)
VerificationTest[
    Block[{$LLMEvaluator = LLMConfiguration @ <| "Tools" -> { LLMTool[ "Calculator", { "expr" -> "String" }, ToExpression[ #expr ] & ] } |>},
        name = CreateUUID[ ];
        server = CreateMCPServer[name]
    ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-FromDefaultEvaluator@@Tests/CreateMCPServer.wlt:63,1-71,2"
]

VerificationTest[
    server["Tools"],
    { _LLMTool },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-DefaultEvaluatorTools@@Tests/CreateMCPServer.wlt:73,1-78,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-DefaultEvaluatorCleanup@@Tests/CreateMCPServer.wlt:80,1-85,2"
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
    TestID   -> "CreateMCPServer-OverwriteOptionFalse@@Tests/CreateMCPServer.wlt:90,1-100,2"
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
    TestID   -> "CreateMCPServer-ExistingServerNoOverwrite@@Tests/CreateMCPServer.wlt:102,1-112,2"
]

VerificationTest[
    newServer = CreateMCPServer[
        name,
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "Tripler", { "x" -> "Number" }, 3 * #x & ] } |>,
        OverwriteTarget -> True
    ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-OverwriteOptionTrue@@Tests/CreateMCPServer.wlt:114,1-123,2"
]

VerificationTest[
    newServer["Tools"][[1]]["Name"],
    "Tripler",
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-VerifyOverwrite@@Tests/CreateMCPServer.wlt:125,1-130,2"
]

VerificationTest[
    DeleteObject @ newServer,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-OptionsCleanup@@Tests/CreateMCPServer.wlt:132,1-137,2"
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
    TestID   -> "CreateMCPServer-WithProperties@@Tests/CreateMCPServer.wlt:142,1-155,2"
]

VerificationTest[
    server["Temperature"],
    0.7,
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-VerifyTemperature@@Tests/CreateMCPServer.wlt:157,1-162,2"
]

VerificationTest[
    server["MaxTokens"],
    1000,
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-VerifyMaxTokens@@Tests/CreateMCPServer.wlt:164,1-169,2"
]

VerificationTest[
    server["ServerVersion"],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-ServerVersion@@Tests/CreateMCPServer.wlt:171,1-176,2"
]

VerificationTest[
    server["Location"],
    _File? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-VerifyLocation@@Tests/CreateMCPServer.wlt:178,1-183,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-PropertiesCleanup@@Tests/CreateMCPServer.wlt:185,1-190,2"
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
    TestID   -> "CreateMCPServer-FromAssociation@@Tests/CreateMCPServer.wlt:195,1-202,2"
]

VerificationTest[
    server["LLMConfiguration"],
    _LLMConfiguration,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-LLMConfigurationProperty@@Tests/CreateMCPServer.wlt:204,1-209,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-ConfigCleanup@@Tests/CreateMCPServer.wlt:211,1-216,2"
]