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
(*Create MCP Server from Default $LLMEvaluator*)
VerificationTest[
    Block[{$LLMEvaluator = LLMConfiguration @ <| "Tools" -> { LLMTool[ "Calculator", { "expr" -> "String" }, ToExpression[ #expr ] & ] } |>},
        name = CreateUUID[ ];
        server = CreateMCPServer[name]
    ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-FromDefaultEvaluator@@Tests/CreateMCPServer.wlt:61,1-69,2"
]

VerificationTest[
    server["Tools"],
    { _LLMTool },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-DefaultEvaluatorTools@@Tests/CreateMCPServer.wlt:71,1-76,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-DefaultEvaluatorCleanup@@Tests/CreateMCPServer.wlt:78,1-83,2"
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
    TestID   -> "CreateMCPServer-OverwriteOptionFalse@@Tests/CreateMCPServer.wlt:88,1-98,2"
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
    TestID   -> "CreateMCPServer-ExistingServerNoOverwrite@@Tests/CreateMCPServer.wlt:100,1-110,2"
]

VerificationTest[
    newServer = CreateMCPServer[
        name,
        LLMConfiguration @ <| "Tools" -> { LLMTool[ "Tripler", { "x" -> "Number" }, 3 * #x & ] } |>,
        OverwriteTarget -> True
    ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-OverwriteOptionTrue@@Tests/CreateMCPServer.wlt:112,1-121,2"
]

VerificationTest[
    newServer["Tools"][[1]]["Name"],
    "Tripler",
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-VerifyOverwrite@@Tests/CreateMCPServer.wlt:123,1-128,2"
]

VerificationTest[
    DeleteObject @ newServer,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-OptionsCleanup@@Tests/CreateMCPServer.wlt:130,1-135,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Initialization Option*)

(* Default Initialization is None *)
VerificationTest[
    name = CreateUUID[ ];
    server = CreateMCPServer[
        name,
        <| "Tools" -> { LLMTool[ "Echo", { "x" -> "String" }, #x & ] } |>
    ];
    server[ "Data" ][ "Initialization" ],
    None,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-InitializationDefaultNone@@Tests/CreateMCPServer.wlt:142,1-152,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-InitializationDefaultCleanup@@Tests/CreateMCPServer.wlt:154,1-159,2"
]

(* Initialization expression is held during creation when using RuleDelayed *)
VerificationTest[
    $mcpTestInitRan = False;
    name = CreateUUID[ ];
    server = CreateMCPServer[
        name,
        <| "Tools" -> { LLMTool[ "Echo", { "x" -> "String" }, #x & ] } |>,
        Initialization :> ($mcpTestInitRan = True)
    ];
    { MCPServerObjectQ @ server, $mcpTestInitRan },
    { True, False },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-InitializationHeld@@Tests/CreateMCPServer.wlt:162,1-174,2"
]

(* Initialization is present in server data *)
VerificationTest[
    server[ "Data" ],
    KeyValuePattern[ "Initialization" :> ($mcpTestInitRan = True) ],
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-InitializationInData@@Tests/CreateMCPServer.wlt:177,1-182,2"
]

VerificationTest[
    DeleteObject @ server;
    ClearAll @ $mcpTestInitRan,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-InitializationHeldCleanup@@Tests/CreateMCPServer.wlt:184,1-190,2"
]

(* Explicit Initialization -> None is stored correctly *)
VerificationTest[
    name = CreateUUID[ ];
    server = CreateMCPServer[
        name,
        <| "Tools" -> { LLMTool[ "Echo", { "x" -> "String" }, #x & ] } |>,
        Initialization -> None
    ];
    server[ "Data" ],
    KeyValuePattern[ "Initialization" -> None ],
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-InitializationExplicitNone@@Tests/CreateMCPServer.wlt:193,1-204,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-InitializationExplicitNoneCleanup@@Tests/CreateMCPServer.wlt:206,1-211,2"
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
    TestID   -> "CreateMCPServer-WithProperties@@Tests/CreateMCPServer.wlt:216,1-229,2"
]

VerificationTest[
    server["Temperature"],
    0.7,
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-VerifyTemperature@@Tests/CreateMCPServer.wlt:231,1-236,2"
]

VerificationTest[
    server["MaxTokens"],
    1000,
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-VerifyMaxTokens@@Tests/CreateMCPServer.wlt:238,1-243,2"
]

VerificationTest[
    server["ServerVersion"],
    _String? StringQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-ServerVersion@@Tests/CreateMCPServer.wlt:245,1-250,2"
]

VerificationTest[
    server["Location"],
    _File? FileExistsQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-VerifyLocation@@Tests/CreateMCPServer.wlt:252,1-257,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-PropertiesCleanup@@Tests/CreateMCPServer.wlt:259,1-264,2"
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
    TestID   -> "CreateMCPServer-FromAssociation@@Tests/CreateMCPServer.wlt:269,1-276,2"
]

VerificationTest[
    server["LLMConfiguration"],
    _LLMConfiguration,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-LLMConfigurationProperty@@Tests/CreateMCPServer.wlt:278,1-283,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-ConfigCleanup@@Tests/CreateMCPServer.wlt:285,1-290,2"
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
    TestID   -> "CreateMCPServer-RewriteChatbookTools-WLEvaluatorEquivalence@@Tests/CreateMCPServer.wlt:297,1-306,2"
]

VerificationTest[
    { DeleteObject @ server1, DeleteObject @ server2 },
    { Null, Null },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-WLEvaluatorCleanup@@Tests/CreateMCPServer.wlt:308,1-313,2"
]

VerificationTest[
    name1 = CreateUUID[ ];
    name2 = CreateUUID[ ];
    server1 = CreateMCPServer[ name1, LLMConfiguration @ <| "Tools" -> { "WolframAlpha" } |> ];
    server2 = CreateMCPServer[ name2, <| "Tools" -> { "WolframAlpha" } |> ];
    SameQ[ server1[ "Tools" ], server2[ "Tools" ] ],
    True,
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-WolframAlphaEquivalence@@Tests/CreateMCPServer.wlt:315,1-324,2"
]

VerificationTest[
    { DeleteObject @ server1, DeleteObject @ server2 },
    { Null, Null },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-WolframAlphaCleanup@@Tests/CreateMCPServer.wlt:326,1-331,2"
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
    TestID   -> "CreateMCPServer-RewriteChatbookTools-BothToolsEquivalence@@Tests/CreateMCPServer.wlt:334,1-343,2"
]

VerificationTest[
    { DeleteObject @ server1, DeleteObject @ server2 },
    { Null, Null },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-BothToolsCleanup@@Tests/CreateMCPServer.wlt:345,1-350,2"
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
    TestID   -> "CreateMCPServer-RewriteChatbookTools-CustomToolPreserved@@Tests/CreateMCPServer.wlt:353,1-363,2"
]

VerificationTest[
    server1[ "Tools" ][[ 1 ]][ "Name" ],
    "CustomTool",
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-CustomToolName@@Tests/CreateMCPServer.wlt:365,1-370,2"
]

VerificationTest[
    { DeleteObject @ server1, DeleteObject @ server2 },
    { Null, Null },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-RewriteChatbookTools-CustomToolCleanup@@Tests/CreateMCPServer.wlt:372,1-377,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Paclet-Qualified Tool Names*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Three-Segment Paclet-Qualified Tool Name*)
VerificationTest[
    name = CreateUUID[ ];
    server = CreateMCPServer[ name, <|
        "Tools" -> { "TestPublisher/TestPaclet/SomeTool" }
    |> ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-PacletQualifiedToolName@@Tests/CreateMCPServer.wlt:386,1-394,2"
]

VerificationTest[
    server[ "Data" ][ "LLMEvaluator" ][ "Tools" ],
    { "TestPublisher/TestPaclet/SomeTool" },
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-PacletToolPreservedInData@@Tests/CreateMCPServer.wlt:396,1-401,2"
]

VerificationTest[
    Module[ { wxfPath, wxfData },
        wxfPath = FileNameJoin @ { First @ server[ "Location" ], "Metadata.wxf" };
        wxfData = Developer`ReadWXFFile @ wxfPath;
        wxfData[ "LLMEvaluator" ][ "Tools" ]
    ],
    { "TestPublisher/TestPaclet/SomeTool" },
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-PacletToolPreservedInWXF@@Tests/CreateMCPServer.wlt:403,1-412,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-PacletToolCleanup@@Tests/CreateMCPServer.wlt:414,1-419,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Two-Segment Paclet-Qualified Tool Name*)
VerificationTest[
    name = CreateUUID[ ];
    server = CreateMCPServer[ name, <|
        "Tools" -> { "SimplePaclet/MyTool" }
    |> ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-TwoSegmentPacletName@@Tests/CreateMCPServer.wlt:424,1-432,2"
]

VerificationTest[
    server[ "Data" ][ "LLMEvaluator" ][ "Tools" ],
    { "SimplePaclet/MyTool" },
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-TwoSegmentPreserved@@Tests/CreateMCPServer.wlt:434,1-439,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-TwoSegmentCleanup@@Tests/CreateMCPServer.wlt:441,1-446,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Mixed Tool Types*)
VerificationTest[
    name = CreateUUID[ ];
    customTool = LLMTool[ "CustomTool", { "x" -> "Integer" }, #x^2 & ];
    server = CreateMCPServer[ name, <|
        "Tools" -> {
            customTool,
            "TestPublisher/TestPaclet/ToolA",
            "OtherPaclet/ToolB"
        }
    |> ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-MixedToolTypes@@Tests/CreateMCPServer.wlt:451,1-464,2"
]

VerificationTest[
    With[ { tools = server[ "Data" ][ "LLMEvaluator" ][ "Tools" ] },
        {
            MatchQ[ tools[[ 1 ]], _LLMTool ],
            tools[[ 2 ]],
            tools[[ 3 ]]
        }
    ],
    { True, "TestPublisher/TestPaclet/ToolA", "OtherPaclet/ToolB" },
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-MixedToolTypesPreserved@@Tests/CreateMCPServer.wlt:466,1-477,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-MixedToolTypesCleanup@@Tests/CreateMCPServer.wlt:479,1-484,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Multiple Paclet-Qualified Tool Names*)
VerificationTest[
    name = CreateUUID[ ];
    server = CreateMCPServer[ name, <|
        "Tools" -> {
            "Publisher/PacletA/Tool1",
            "Publisher/PacletA/Tool2",
            "PacletB/Tool3"
        }
    |> ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-MultiplePacletTools@@Tests/CreateMCPServer.wlt:489,1-501,2"
]

VerificationTest[
    server[ "Data" ][ "LLMEvaluator" ][ "Tools" ],
    { "Publisher/PacletA/Tool1", "Publisher/PacletA/Tool2", "PacletB/Tool3" },
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-MultiplePacletToolsPreserved@@Tests/CreateMCPServer.wlt:503,1-508,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-MultiplePacletToolsCleanup@@Tests/CreateMCPServer.wlt:510,1-515,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Paclet-Qualified Prompt Names*)
VerificationTest[
    name = CreateUUID[ ];
    server = CreateMCPServer[ name, <|
        "Tools" -> { LLMTool[ "SimpleTool", { "x" -> "String" }, #x & ] },
        "MCPPrompts" -> { "TestPublisher/TestPaclet/SomePrompt" }
    |> ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-PacletPromptName@@Tests/CreateMCPServer.wlt:520,1-529,2"
]

VerificationTest[
    server[ "Data" ][ "LLMEvaluator" ][ "MCPPrompts" ],
    { "TestPublisher/TestPaclet/SomePrompt" },
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-PacletPromptPreservedInData@@Tests/CreateMCPServer.wlt:531,1-536,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-PacletPromptCleanup@@Tests/CreateMCPServer.wlt:538,1-543,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Paclet Tool Resolution with Mock Paclet*)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

$testResourceDirectory = FileNameJoin @ { DirectoryName[ $TestFileName, 2 ], "TestResources" };

VerificationTest[
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletTest" };
    $mockPaclet = First @ PacletFind[ "MockMCPPacletTest" ];
    $mockPaclet[ "Name" ],
    "MockMCPPacletTest",
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-MockPacletSetup@@Tests/CreateMCPServer.wlt:554,1-561,2"
]

VerificationTest[
    name = CreateUUID[ ];
    server = CreateMCPServer[ name, <|
        "Tools" -> { "MockMCPPacletTest/TestTool" }
    |> ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-WithMockPacletTool@@Tests/CreateMCPServer.wlt:563,1-571,2"
]

(* Raw data has string *)
VerificationTest[
    server[ "Data" ][ "LLMEvaluator" ][ "Tools" ],
    { "MockMCPPacletTest/TestTool" },
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-MockPacletToolStringInData@@Tests/CreateMCPServer.wlt:574,1-579,2"
]

(* Tools property resolves to LLMTool *)
VerificationTest[
    server[ "Tools" ],
    { _LLMTool },
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-MockPacletToolResolves@@Tests/CreateMCPServer.wlt:582,1-587,2"
]

VerificationTest[
    server[ "Tools" ][[ 1 ]][ "Name" ],
    "TestTool",
    SameTest -> Equal,
    TestID   -> "CreateMCPServer-MockPacletToolResolvedName@@Tests/CreateMCPServer.wlt:589,1-594,2"
]

VerificationTest[
    DeleteObject @ server,
    Null,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-MockPacletToolCleanup@@Tests/CreateMCPServer.wlt:596,1-601,2"
]

VerificationTest[
    PacletDirectoryUnload @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletTest" };
    Wolfram`MCPServer`Common`clearPacletDefinitionCache[ ],
    <| |>,
    SameTest -> MatchQ,
    TestID   -> "CreateMCPServer-MockPacletCleanup@@Tests/CreateMCPServer.wlt:603,1-609,2"
]

(* :!CodeAnalysis::EndBlock:: *)