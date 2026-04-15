(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/StartMCPServer.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/StartMCPServer.wlt:11,1-16,2"
]

VerificationTest[
    Get[ FileNameJoin @ { DirectoryName @ $TestFileName, "MCPServerTestUtilities.wl" } ];
    (* Set the source directory so the test utilities can find Scripts/StartMCPServer.wls *)
    Wolfram`AgentToolsTests`MCPServerTestUtilities`$MCPTestSourceDirectory = DirectoryName[ $TestFileName, 2 ],
    _String? DirectoryQ,
    SameTest -> MatchQ,
    TestID   -> "LoadTestUtilities@@Tests/StartMCPServer.wlt:18,1-25,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*WolframLanguage Server Tests*)

(* Note: These integration tests spawn a subprocess to run the MCP server and communicate via JSON-RPC.
   They work reliably when run from the TestReport MCP tool or a notebook via TestReport["Tests/StartMCPServer.wlt"],
   but subprocess stdin/stdout handling behaves differently when run via wolframscript on Windows/CI environments.
   The skipIfScript wrapper skips these tests when running as a script while allowing notebook testing. *)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Server Lifecycle*)
skipIfScript @ VerificationTest[
    $process = StartMCPTestServer[ "ServerName" -> "WolframLanguage" ],
    _ProcessObject,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ServerStarts@@Tests/StartMCPServer.wlt:39,16-44,2"
]

skipIfScript @ VerificationTest[
    ProcessStatus @ $process,
    "Running",
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ServerRunning@@Tests/StartMCPServer.wlt:46,16-51,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Initialize Protocol*)
skipIfScript @ VerificationTest[
    $initResponse = MCPInitialize[ "ClientName" -> "test-client" ],
    KeyValuePattern[ "result" -> _Association ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-Initialize@@Tests/StartMCPServer.wlt:56,16-61,2"
]

skipIfScript @ VerificationTest[
    $initResponse[[ "result", "protocolVersion" ]],
    "2024-11-05",
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ProtocolVersion@@Tests/StartMCPServer.wlt:63,16-68,2"
]

skipIfScript @ VerificationTest[
    $initResponse[[ "result", "serverInfo", "name" ]],
    "WolframLanguage",
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ServerInfoName@@Tests/StartMCPServer.wlt:70,16-75,2"
]

skipIfScript @ VerificationTest[
    $initResponse[[ "result", "serverInfo", "version" ]],
    _String,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ServerInfoVersion@@Tests/StartMCPServer.wlt:77,16-82,2"
]

skipIfScript @ VerificationTest[
    KeyExistsQ[ $initResponse[[ "result", "capabilities" ]], "tools" ],
    True,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-CapabilitiesTools@@Tests/StartMCPServer.wlt:84,16-89,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Ping*)
skipIfScript @ VerificationTest[
    $pingResponse = SendMCPRequest[ "ping" ],
    KeyValuePattern[ "result" -> <| |> ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-Ping@@Tests/StartMCPServer.wlt:94,16-99,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tools Protocol*)
skipIfScript @ VerificationTest[
    $toolsResponse = SendMCPRequest[ "tools/list" ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "tools" -> { __Association } ] ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ToolsList@@Tests/StartMCPServer.wlt:104,16-109,2"
]

skipIfScript @ VerificationTest[
    MemberQ[ $toolsResponse[[ "result", "tools", All, "name" ]], "WolframLanguageEvaluator" ],
    True,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ToolsListContainsEvaluator@@Tests/StartMCPServer.wlt:111,16-116,2"
]

skipIfScript @ VerificationTest[
    $toolSchema = SelectFirst[ $toolsResponse[[ "result", "tools" ]], #name === "WolframLanguageEvaluator" & ];
    AllTrue[ { "name", "description", "inputSchema" }, KeyExistsQ[ $toolSchema, # ] & ],
    True,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ToolSchemaComplete@@Tests/StartMCPServer.wlt:118,16-124,2"
]

(* Regression: all 7 WolframLanguage server tools must be present (issue #155) *)
skipIfScript @ VerificationTest[
    Sort @ $toolsResponse[[ "result", "tools", All, "name" ]],
    Sort @ { "WolframLanguageContext", "WolframLanguageEvaluator", "ReadNotebook",
             "WriteNotebook", "SymbolDefinition", "CodeInspector", "TestReport" },
    TestID -> "WolframLanguage-ToolsListAllSeven@@Tests/StartMCPServer.wlt:128,16-133,2"
]

(* Regression: WolframLanguageEvaluator description must contain \[FreeformPrompt] as plain text
   (not as a PUA Unicode character which can produce invalid JSON escapes) *)
skipIfScript @ VerificationTest[
    StringContainsQ[ $toolSchema[ "description" ], "\\[FreeformPrompt]" ],
    True,
    TestID -> "WolframLanguage-EvaluatorDescriptionFreeformPrompt@@Tests/StartMCPServer.wlt:136,16-140,2"
]

(* Regression: the full tools/list JSON response must be valid and round-trip through a JSON parser *)
skipIfScript @ VerificationTest[
    AssociationQ @ Developer`ReadRawJSONString @ Developer`WriteRawJSONString[ $toolsResponse, "Compact" -> True ],
    True,
    TestID -> "WolframLanguage-ToolsListJSONParses@@Tests/StartMCPServer.wlt:143,16-147,2"
]

skipIfScript @ VerificationTest[
    $evalResponse = SendMCPRequest[
        "tools/call",
        <| "name" -> "WolframLanguageEvaluator", "arguments" -> <| "code" -> "1+1" |> |>
    ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "isError" -> False ] ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ToolCallSimple@@Tests/StartMCPServer.wlt:126,16-134,2"
]

skipIfScript @ VerificationTest[
    StringContainsQ[ $evalResponse[[ "result", "content", 1, "text" ]], "2" ],
    True,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ToolCallResult@@Tests/StartMCPServer.wlt:136,16-141,2"
]

skipIfScript @ VerificationTest[
    $evalResponse2 = SendMCPRequest[
        "tools/call",
        <| "name" -> "WolframLanguageEvaluator", "arguments" -> <| "code" -> "Prime[100]" |> |>
    ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "isError" -> False ] ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ToolCallComplex@@Tests/StartMCPServer.wlt:143,16-151,2"
]

skipIfScript @ VerificationTest[
    StringContainsQ[ $evalResponse2[[ "result", "content", 1, "text" ]], "541" ],
    True,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ToolCallComplexResult@@Tests/StartMCPServer.wlt:153,16-158,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Prompts Protocol*)
skipIfScript @ VerificationTest[
    $promptsResponse = SendMCPRequest[ "prompts/list" ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "prompts" -> _List ] ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-PromptsList@@Tests/StartMCPServer.wlt:163,16-168,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Handling*)
skipIfScript @ VerificationTest[
    $unknownMethodResponse = SendMCPRequest[ "unknown/method" ],
    KeyValuePattern[ "error" -> KeyValuePattern[ "code" -> -32601 ] ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-UnknownMethod@@Tests/StartMCPServer.wlt:173,16-178,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Regression: Non-existent Tool Returns Error*)
skipIfScript @ VerificationTest[
    $nonExistentToolResponse = SendMCPRequest[
        "tools/call",
        <| "name" -> "DoesNotExist", "arguments" -> <| |> |>
    ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "isError" -> True ] ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-NonExistentToolReturnsError@@Tests/StartMCPServer.wlt:183,16-191,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Regression: Print Output Captured*)
skipIfScript @ VerificationTest[
    $printResponse = SendMCPRequest[
        "tools/call",
        <| "name" -> "WolframLanguageEvaluator", "arguments" -> <| "code" -> "Print[\"TestOutput123\"]; 42" |> |>
    ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "isError" -> False ] ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-PrintOutputEvaluates@@Tests/StartMCPServer.wlt:196,16-204,2"
]

skipIfScript @ VerificationTest[
    StringContainsQ[ $printResponse[[ "result", "content", 1, "text" ]], "TestOutput123" ],
    True,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-PrintOutputCaptured@@Tests/StartMCPServer.wlt:206,16-211,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Server Cleanup*)
skipIfScript @ VerificationTest[
    StopMCPTestServer[ ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ServerStopped@@Tests/StartMCPServer.wlt:216,16-221,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Wolfram Server Tests (Smoke Tests)*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Server Lifecycle*)
skipIfScript @ VerificationTest[
    $processWolfram = StartMCPTestServer[ "ServerName" -> "Wolfram" ],
    _ProcessObject,
    SameTest -> MatchQ,
    TestID   -> "Wolfram-ServerStarts@@Tests/StartMCPServer.wlt:230,16-235,2"
]

skipIfScript @ VerificationTest[
    ProcessStatus @ $processWolfram,
    "Running",
    SameTest -> MatchQ,
    TestID   -> "Wolfram-ServerRunning@@Tests/StartMCPServer.wlt:237,16-242,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Initialize*)
skipIfScript @ VerificationTest[
    $initWolfram = MCPInitialize[ ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "protocolVersion" -> "2024-11-05" ] ],
    SameTest -> MatchQ,
    TestID   -> "Wolfram-Initialize@@Tests/StartMCPServer.wlt:247,16-252,2"
]

skipIfScript @ VerificationTest[
    $initWolfram[[ "result", "serverInfo", "name" ]],
    "Wolfram",
    SameTest -> MatchQ,
    TestID   -> "Wolfram-ServerInfoName@@Tests/StartMCPServer.wlt:254,16-259,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tools List*)
skipIfScript @ VerificationTest[
    $toolsWolfram = SendMCPRequest[ "tools/list" ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "tools" -> { __Association } ] ],
    SameTest -> MatchQ,
    TestID   -> "Wolfram-ToolsList@@Tests/StartMCPServer.wlt:264,16-269,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Server Cleanup*)
skipIfScript @ VerificationTest[
    StopMCPTestServer[ ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "Wolfram-ServerStopped@@Tests/StartMCPServer.wlt:274,16-279,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Paclet Resolution and Tool Initialization*)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Setup Mock Paclet*)
VerificationTest[
    $testResourceDirectory = FileNameJoin @ { DirectoryName[ $TestFileName, 2 ], "TestResources" };
    PacletDirectoryLoad @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletTest" };
    $mockPaclet = First @ PacletFind[ "MockMCPPacletTest" ];
    $mockPaclet[ "Name" ],
    "MockMCPPacletTest",
    SameTest -> MatchQ,
    TestID   -> "PacletInit-LoadMockPaclet@@Tests/StartMCPServer.wlt:291,1-299,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*runToolInitialization*)
VerificationTest[
    $initTestValue = 0;
    tool1 = LLMTool[ <|
        "Name" -> "InitTool1",
        "Description" -> "Tool with initialization",
        "Function" -> Identity,
        "Parameters" -> { },
        "Initialization" :> ($initTestValue += 1)
    |> ];
    tool2 = LLMTool[ <|
        "Name" -> "InitTool2",
        "Description" -> "Tool with initialization",
        "Function" -> Identity,
        "Parameters" -> { },
        "Initialization" :> ($initTestValue += 10)
    |> ];
    Wolfram`AgentTools`StartMCPServer`Private`runToolInitialization[ { tool1, tool2 } ];
    $initTestValue,
    11,
    SameTest -> MatchQ,
    TestID   -> "RunToolInitialization-RunsBothInits@@Tests/StartMCPServer.wlt:304,1-325,2"
]

VerificationTest[
    $initTestValue2 = 0;
    toolNoInit = LLMTool[ <|
        "Name" -> "NoInitTool",
        "Description" -> "Tool without initialization",
        "Function" -> Identity,
        "Parameters" -> { }
    |> ];
    Wolfram`AgentTools`StartMCPServer`Private`runToolInitialization[ { toolNoInit } ];
    $initTestValue2,
    0,
    SameTest -> MatchQ,
    TestID   -> "RunToolInitialization-NoInitIsNoOp@@Tests/StartMCPServer.wlt:327,1-340,2"
]

VerificationTest[
    Wolfram`AgentTools`StartMCPServer`Private`runToolInitialization[ { } ],
    { },
    SameTest -> MatchQ,
    TestID   -> "RunToolInitialization-EmptyListIsNoOp@@Tests/StartMCPServer.wlt:342,1-347,2"
]

VerificationTest[
    $initTestValue3 = 0;
    mixedTool1 = LLMTool[ <|
        "Name" -> "MixedInit",
        "Description" -> "Has init",
        "Function" -> Identity,
        "Parameters" -> { },
        "Initialization" :> ($initTestValue3 = 42)
    |> ];
    mixedTool2 = LLMTool[ <|
        "Name" -> "MixedNoInit",
        "Description" -> "No init",
        "Function" -> Identity,
        "Parameters" -> { }
    |> ];
    Wolfram`AgentTools`StartMCPServer`Private`runToolInitialization[ { mixedTool1, mixedTool2 } ];
    $initTestValue3,
    42,
    SameTest -> MatchQ,
    TestID   -> "RunToolInitialization-MixedInitAndNoInit@@Tests/StartMCPServer.wlt:349,1-369,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ensurePacletsForStart*)
VerificationTest[
    Wolfram`AgentTools`StartMCPServer`Private`ensurePacletsForStart[
        MCPServerObject[ "MockMCPPacletTest/TestServer" ]
    ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "EnsurePacletsForStart-InstalledPacletSucceeds@@Tests/StartMCPServer.wlt:374,1-381,2"
]

VerificationTest[
    Wolfram`AgentTools`StartMCPServer`Private`ensurePacletsForStart[
        MCPServerObject[ "WolframLanguage" ]
    ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "EnsurePacletsForStart-BuiltInServerSucceeds@@Tests/StartMCPServer.wlt:383,1-390,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ensureDependenciesForStart*)
VerificationTest[
    Wolfram`AgentTools`StartMCPServer`Private`ensureDependenciesForStart[
        MCPServerObject[ "MockMCPPacletTest/TestServer" ]
    ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "EnsureDependenciesForStart-InstalledPacletDeps@@Tests/StartMCPServer.wlt:395,1-402,2"
]

VerificationTest[
    Wolfram`AgentTools`StartMCPServer`Private`ensureDependenciesForStart[
        MCPServerObject[ "WolframLanguage" ]
    ],
    _MCPServerObject? MCPServerObjectQ,
    SameTest -> MatchQ,
    TestID   -> "EnsureDependenciesForStart-NoPacletDepsIsNoOp@@Tests/StartMCPServer.wlt:404,1-411,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*runServerInitialization*)
VerificationTest[
    builtInServerData = <|
        "Name" -> "WolframLanguage",
        "Location" -> "BuiltIn",
        "LLMEvaluator" -> <| "Tools" -> { "WolframLanguageEvaluator" } |>
    |>;
    Wolfram`AgentTools`StartMCPServer`Private`runServerInitialization[ builtInServerData ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "RunServerInitialization-BuiltInIsNoOp@@Tests/StartMCPServer.wlt:416,1-426,2"
]

VerificationTest[
    fileServerData = <|
        "Name" -> "UserServer",
        "Location" -> File[ "some/path" ],
        "LLMEvaluator" -> <| "Tools" -> { } |>
    |>;
    Wolfram`AgentTools`StartMCPServer`Private`runServerInitialization[ fileServerData ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "RunServerInitialization-FileBasedIsNoOp@@Tests/StartMCPServer.wlt:428,1-438,2"
]

VerificationTest[
    pacletServerData = <|
        "Name" -> "MockMCPPacletTest/TestServer",
        "Location" -> $mockPaclet,
        "LLMEvaluator" -> <|
            "Tools" -> { "MockMCPPacletTest/TestTool" },
            "MCPPrompts" -> { "MockMCPPacletTest/TestPrompt" }
        |>
    |>;
    (* TestServer definition has no Initialization key, so this should return Null *)
    Wolfram`AgentTools`StartMCPServer`Private`runServerInitialization[ pacletServerData ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "RunServerInitialization-PacletServerNoInit@@Tests/StartMCPServer.wlt:440,1-454,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*disambiguateToolNames*)
VerificationTest[
    Wolfram`AgentTools`StartMCPServer`Private`disambiguateToolNames[ { } ],
    <| |>,
    SameTest -> MatchQ,
    TestID   -> "DisambiguateToolNames-EmptyList@@Tests/StartMCPServer.wlt:459,1-464,2"
]

VerificationTest[
    toolA = LLMTool[ <| "Name" -> "Alpha", "Description" -> "Tool A", "Function" -> Identity, "Parameters" -> { } |> ];
    toolB = LLMTool[ <| "Name" -> "Beta", "Description" -> "Tool B", "Function" -> Identity, "Parameters" -> { } |> ];
    result = Wolfram`AgentTools`StartMCPServer`Private`disambiguateToolNames[ { toolA, toolB } ];
    Keys @ result,
    { "Alpha", "Beta" },
    SameTest -> MatchQ,
    TestID   -> "DisambiguateToolNames-NoCollisions@@Tests/StartMCPServer.wlt:466,1-474,2"
]

VerificationTest[
    toolS1 = LLMTool[ <| "Name" -> "Search", "Description" -> "Search JIRA", "Function" -> Identity, "Parameters" -> { } |> ];
    toolS2 = LLMTool[ <| "Name" -> "Search", "Description" -> "Search Slack", "Function" -> Identity, "Parameters" -> { } |> ];
    result = Wolfram`AgentTools`StartMCPServer`Private`disambiguateToolNames[ { toolS1, toolS2 } ];
    Keys @ result,
    { "Search1", "Search2" },
    SameTest -> MatchQ,
    TestID   -> "DisambiguateToolNames-TwoCollisions@@Tests/StartMCPServer.wlt:476,1-484,2"
]

VerificationTest[
    toolS1 = LLMTool[ <| "Name" -> "Search", "Description" -> "Search A", "Function" -> Identity, "Parameters" -> { } |> ];
    toolS2 = LLMTool[ <| "Name" -> "Search", "Description" -> "Search B", "Function" -> Identity, "Parameters" -> { } |> ];
    toolS3 = LLMTool[ <| "Name" -> "Search", "Description" -> "Search C", "Function" -> Identity, "Parameters" -> { } |> ];
    result = Wolfram`AgentTools`StartMCPServer`Private`disambiguateToolNames[ { toolS1, toolS2, toolS3 } ];
    Keys @ result,
    { "Search1", "Search2", "Search3" },
    SameTest -> MatchQ,
    TestID   -> "DisambiguateToolNames-ThreeCollisions@@Tests/StartMCPServer.wlt:486,1-495,2"
]

VerificationTest[
    toolA = LLMTool[ <| "Name" -> "Alpha", "Description" -> "Unique", "Function" -> Identity, "Parameters" -> { } |> ];
    toolS1 = LLMTool[ <| "Name" -> "Search", "Description" -> "Search A", "Function" -> Identity, "Parameters" -> { } |> ];
    toolB = LLMTool[ <| "Name" -> "Beta", "Description" -> "Unique", "Function" -> Identity, "Parameters" -> { } |> ];
    toolS2 = LLMTool[ <| "Name" -> "Search", "Description" -> "Search B", "Function" -> Identity, "Parameters" -> { } |> ];
    result = Wolfram`AgentTools`StartMCPServer`Private`disambiguateToolNames[ { toolA, toolS1, toolB, toolS2 } ];
    Keys @ result,
    { "Alpha", "Search1", "Beta", "Search2" },
    SameTest -> MatchQ,
    TestID   -> "DisambiguateToolNames-MixedCollisions@@Tests/StartMCPServer.wlt:497,1-507,2"
]

VerificationTest[
    toolS1 = LLMTool[ <| "Name" -> "Search", "Description" -> "Search JIRA", "Function" -> Identity, "Parameters" -> { } |> ];
    toolS2 = LLMTool[ <| "Name" -> "Search", "Description" -> "Search Slack", "Function" -> Identity, "Parameters" -> { } |> ];
    result = Wolfram`AgentTools`StartMCPServer`Private`disambiguateToolNames[ { toolS1, toolS2 } ];
    (* The values are the original LLMTool objects *)
    { result["Search1"]["Description"], result["Search2"]["Description"] },
    { "Search JIRA", "Search Slack" },
    SameTest -> MatchQ,
    TestID   -> "DisambiguateToolNames-ValuesPreserved@@Tests/StartMCPServer.wlt:509,1-518,2"
]

VerificationTest[
    toolA = LLMTool[ <| "Name" -> "Alpha", "Description" -> "Only tool", "Function" -> Identity, "Parameters" -> { } |> ];
    result = Wolfram`AgentTools`StartMCPServer`Private`disambiguateToolNames[ { toolA } ];
    Keys @ result,
    { "Alpha" },
    SameTest -> MatchQ,
    TestID   -> "DisambiguateToolNames-SingleTool@@Tests/StartMCPServer.wlt:520,1-527,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*createMCPToolData with name override*)
VerificationTest[
    tool = LLMTool[ <| "Name" -> "Search", "Description" -> "Search things", "Function" -> Identity, "Parameters" -> { } |> ];
    data = Wolfram`AgentTools`StartMCPServer`Private`createMCPToolData[ "Search1", tool ];
    data[ "name" ],
    "Search1",
    SameTest -> MatchQ,
    TestID   -> "CreateMCPToolData-NameOverride@@Tests/StartMCPServer.wlt:532,1-539,2"
]

VerificationTest[
    tool = LLMTool[ <| "Name" -> "Search", "Description" -> "Search things", "Function" -> Identity, "Parameters" -> { } |> ];
    data = Wolfram`AgentTools`StartMCPServer`Private`createMCPToolData[ "Search1", tool ];
    data[ "description" ],
    "Search things",
    SameTest -> MatchQ,
    TestID   -> "CreateMCPToolData-DescriptionPreserved@@Tests/StartMCPServer.wlt:541,1-548,2"
]

VerificationTest[
    tool = LLMTool[ <| "Name" -> "MyTool", "Description" -> "A tool", "Function" -> Identity, "Parameters" -> { } |> ];
    dataOriginal = Wolfram`AgentTools`StartMCPServer`Private`createMCPToolData[ tool ];
    dataOriginal[ "name" ],
    "MyTool",
    SameTest -> MatchQ,
    TestID   -> "CreateMCPToolData-SingleArgUsesToolName@@Tests/StartMCPServer.wlt:550,1-557,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Disambiguation integration with evaluateTool*)
VerificationTest[
    (* Build a disambiguated llmTools association and verify lookup works *)
    toolS1 = LLMTool[ <| "Name" -> "Search", "Description" -> "Search JIRA", "Function" -> Identity, "Parameters" -> { } |> ];
    toolS2 = LLMTool[ <| "Name" -> "Search", "Description" -> "Search Slack", "Function" -> Identity, "Parameters" -> { } |> ];
    disambiguated = Wolfram`AgentTools`StartMCPServer`Private`disambiguateToolNames[ { toolS1, toolS2 } ];
    (* evaluateTool looks up tools in $llmTools by the name the client sends *)
    (* Verify the disambiguated keys correctly map to different tools *)
    { disambiguated["Search1"]["Description"], disambiguated["Search2"]["Description"] },
    { "Search JIRA", "Search Slack" },
    SameTest -> MatchQ,
    TestID   -> "DisambiguateIntegration-LookupRouting@@Tests/StartMCPServer.wlt:562,1-573,2"
]

VerificationTest[
    (* Verify the tool data sent over MCP wire uses disambiguated names *)
    toolS1 = LLMTool[ <| "Name" -> "Search", "Description" -> "Search JIRA", "Function" -> Identity, "Parameters" -> { } |> ];
    toolS2 = LLMTool[ <| "Name" -> "Search", "Description" -> "Search Slack", "Function" -> Identity, "Parameters" -> { } |> ];
    disambiguated = Wolfram`AgentTools`StartMCPServer`Private`disambiguateToolNames[ { toolS1, toolS2 } ];
    toolDataList = KeyValueMap[ Wolfram`AgentTools`StartMCPServer`Private`createMCPToolData, disambiguated ];
    toolDataList[[ All, "name" ]],
    { "Search1", "Search2" },
    SameTest -> MatchQ,
    TestID   -> "DisambiguateIntegration-WireNames@@Tests/StartMCPServer.wlt:575,1-585,2"
]

VerificationTest[
    (* Multiple collision groups: two "Search" tools and two "Evaluate" tools *)
    toolS1 = LLMTool[ <| "Name" -> "Search", "Description" -> "S1", "Function" -> Identity, "Parameters" -> { } |> ];
    toolE1 = LLMTool[ <| "Name" -> "Evaluate", "Description" -> "E1", "Function" -> Identity, "Parameters" -> { } |> ];
    toolS2 = LLMTool[ <| "Name" -> "Search", "Description" -> "S2", "Function" -> Identity, "Parameters" -> { } |> ];
    toolE2 = LLMTool[ <| "Name" -> "Evaluate", "Description" -> "E2", "Function" -> Identity, "Parameters" -> { } |> ];
    toolU = LLMTool[ <| "Name" -> "Unique", "Description" -> "U", "Function" -> Identity, "Parameters" -> { } |> ];
    result = Wolfram`AgentTools`StartMCPServer`Private`disambiguateToolNames[ { toolS1, toolE1, toolS2, toolE2, toolU } ];
    Keys @ result,
    { "Search1", "Evaluate1", "Search2", "Evaluate2", "Unique" },
    SameTest -> MatchQ,
    TestID   -> "DisambiguateToolNames-MultipleGroups@@Tests/StartMCPServer.wlt:587,1-599,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Cleanup Mock Paclet*)
VerificationTest[
    PacletDirectoryUnload @ FileNameJoin @ { $testResourceDirectory, "MockMCPPacletTest" };
    Wolfram`AgentTools`Common`clearPacletDefinitionCache[ ];
    True,
    True,
    SameTest -> MatchQ,
    TestID   -> "PacletCleanup-UnloadMockPaclet@@Tests/StartMCPServer.wlt:604,1-611,2"
]

(* :!CodeAnalysis::EndBlock:: *)
