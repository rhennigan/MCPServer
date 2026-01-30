(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/StartMCPServer.wlt:4,1-9,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/StartMCPServer.wlt:11,1-16,2"
]

VerificationTest[
    Get[ FileNameJoin @ { DirectoryName @ $TestFileName, "MCPServerTestUtilities.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadTestUtilities@@Tests/StartMCPServer.wlt:18,1-23,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*WolframLanguage Server Tests*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Server Lifecycle*)
VerificationTest[
    $process = Wolfram`MCPServerTests`MCPServerTestUtilities`StartMCPTestServer[ "ServerName" -> "WolframLanguage" ],
    _ProcessObject,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ServerStarts@@Tests/StartMCPServer.wlt:32,1-37,2"
]

VerificationTest[
    ProcessStatus @ $process,
    "Running",
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ServerRunning@@Tests/StartMCPServer.wlt:39,1-44,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Initialize Protocol*)
VerificationTest[
    $initResponse = Wolfram`MCPServerTests`MCPServerTestUtilities`MCPInitialize[ "ClientName" -> "test-client" ],
    KeyValuePattern[ "result" -> _Association ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-Initialize@@Tests/StartMCPServer.wlt:49,1-54,2"
]

VerificationTest[
    $initResponse[[ "result", "protocolVersion" ]],
    "2024-11-05",
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ProtocolVersion@@Tests/StartMCPServer.wlt:56,1-61,2"
]

VerificationTest[
    $initResponse[[ "result", "serverInfo", "name" ]],
    "WolframLanguage",
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ServerInfoName@@Tests/StartMCPServer.wlt:63,1-68,2"
]

VerificationTest[
    $initResponse[[ "result", "serverInfo", "version" ]],
    _String,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ServerInfoVersion@@Tests/StartMCPServer.wlt:70,1-75,2"
]

VerificationTest[
    KeyExistsQ[ $initResponse[[ "result", "capabilities" ]], "tools" ],
    True,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-CapabilitiesTools@@Tests/StartMCPServer.wlt:77,1-82,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Ping*)
VerificationTest[
    $pingResponse = Wolfram`MCPServerTests`MCPServerTestUtilities`SendMCPRequest[ "ping" ],
    KeyValuePattern[ "result" -> <| |> ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-Ping@@Tests/StartMCPServer.wlt:87,1-92,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tools Protocol*)
VerificationTest[
    $toolsResponse = Wolfram`MCPServerTests`MCPServerTestUtilities`SendMCPRequest[ "tools/list" ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "tools" -> { __Association } ] ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ToolsList@@Tests/StartMCPServer.wlt:97,1-102,2"
]

VerificationTest[
    MemberQ[ $toolsResponse[[ "result", "tools", All, "name" ]], "WolframLanguageEvaluator" ],
    True,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ToolsListContainsEvaluator@@Tests/StartMCPServer.wlt:104,1-109,2"
]

VerificationTest[
    $toolSchema = SelectFirst[ $toolsResponse[[ "result", "tools" ]], #name === "WolframLanguageEvaluator" & ];
    AllTrue[ { "name", "description", "inputSchema" }, KeyExistsQ[ $toolSchema, # ] & ],
    True,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ToolSchemaComplete@@Tests/StartMCPServer.wlt:111,1-117,2"
]

VerificationTest[
    $evalResponse = Wolfram`MCPServerTests`MCPServerTestUtilities`SendMCPRequest[
        "tools/call",
        <| "name" -> "WolframLanguageEvaluator", "arguments" -> <| "code" -> "1+1" |> |>
    ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "isError" -> False ] ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ToolCallSimple@@Tests/StartMCPServer.wlt:119,1-127,2"
]

VerificationTest[
    StringContainsQ[ $evalResponse[[ "result", "content", 1, "text" ]], "2" ],
    True,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ToolCallResult@@Tests/StartMCPServer.wlt:129,1-134,2"
]

VerificationTest[
    $evalResponse2 = Wolfram`MCPServerTests`MCPServerTestUtilities`SendMCPRequest[
        "tools/call",
        <| "name" -> "WolframLanguageEvaluator", "arguments" -> <| "code" -> "Prime[100]" |> |>
    ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "isError" -> False ] ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ToolCallComplex@@Tests/StartMCPServer.wlt:136,1-144,2"
]

VerificationTest[
    StringContainsQ[ $evalResponse2[[ "result", "content", 1, "text" ]], "541" ],
    True,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ToolCallComplexResult@@Tests/StartMCPServer.wlt:146,1-151,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Prompts Protocol*)
VerificationTest[
    $promptsResponse = Wolfram`MCPServerTests`MCPServerTestUtilities`SendMCPRequest[ "prompts/list" ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "prompts" -> _List ] ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-PromptsList@@Tests/StartMCPServer.wlt:156,1-161,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Error Handling*)
VerificationTest[
    $unknownMethodResponse = Wolfram`MCPServerTests`MCPServerTestUtilities`SendMCPRequest[ "unknown/method" ],
    KeyValuePattern[ "error" -> KeyValuePattern[ "code" -> -32601 ] ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-UnknownMethod@@Tests/StartMCPServer.wlt:166,1-171,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Regression: Non-existent Tool Returns Error*)
VerificationTest[
    $nonExistentToolResponse = Wolfram`MCPServerTests`MCPServerTestUtilities`SendMCPRequest[
        "tools/call",
        <| "name" -> "DoesNotExist", "arguments" -> <| |> |>
    ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "isError" -> True ] ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-NonExistentToolReturnsError@@Tests/StartMCPServer.wlt:176,1-184,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Regression: Print Output Captured*)
VerificationTest[
    $printResponse = Wolfram`MCPServerTests`MCPServerTestUtilities`SendMCPRequest[
        "tools/call",
        <| "name" -> "WolframLanguageEvaluator", "arguments" -> <| "code" -> "Print[\"TestOutput123\"]; 42" |> |>
    ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "isError" -> False ] ],
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-PrintOutputEvaluates@@Tests/StartMCPServer.wlt:189,1-197,2"
]

VerificationTest[
    StringContainsQ[ $printResponse[[ "result", "content", 1, "text" ]], "TestOutput123" ],
    True,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-PrintOutputCaptured@@Tests/StartMCPServer.wlt:199,1-204,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Server Cleanup*)
VerificationTest[
    Wolfram`MCPServerTests`MCPServerTestUtilities`StopMCPTestServer[ ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "WolframLanguage-ServerStopped@@Tests/StartMCPServer.wlt:209,1-214,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Wolfram Server Tests (Smoke Tests)*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Server Lifecycle*)
VerificationTest[
    $processWolfram = Wolfram`MCPServerTests`MCPServerTestUtilities`StartMCPTestServer[ "ServerName" -> "Wolfram" ],
    _ProcessObject,
    SameTest -> MatchQ,
    TestID   -> "Wolfram-ServerStarts@@Tests/StartMCPServer.wlt:223,1-228,2"
]

VerificationTest[
    ProcessStatus @ $processWolfram,
    "Running",
    SameTest -> MatchQ,
    TestID   -> "Wolfram-ServerRunning@@Tests/StartMCPServer.wlt:230,1-235,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Initialize*)
VerificationTest[
    $initWolfram = Wolfram`MCPServerTests`MCPServerTestUtilities`MCPInitialize[ ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "protocolVersion" -> "2024-11-05" ] ],
    SameTest -> MatchQ,
    TestID   -> "Wolfram-Initialize@@Tests/StartMCPServer.wlt:240,1-245,2"
]

VerificationTest[
    $initWolfram[[ "result", "serverInfo", "name" ]],
    "Wolfram",
    SameTest -> MatchQ,
    TestID   -> "Wolfram-ServerInfoName@@Tests/StartMCPServer.wlt:247,1-252,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tools List*)
VerificationTest[
    $toolsWolfram = Wolfram`MCPServerTests`MCPServerTestUtilities`SendMCPRequest[ "tools/list" ],
    KeyValuePattern[ "result" -> KeyValuePattern[ "tools" -> { __Association } ] ],
    SameTest -> MatchQ,
    TestID   -> "Wolfram-ToolsList@@Tests/StartMCPServer.wlt:257,1-262,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Server Cleanup*)
VerificationTest[
    Wolfram`MCPServerTests`MCPServerTestUtilities`StopMCPTestServer[ ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "Wolfram-ServerStopped@@Tests/StartMCPServer.wlt:267,1-272,2"
]
