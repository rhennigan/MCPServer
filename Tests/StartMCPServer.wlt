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
    Get[ FileNameJoin @ { DirectoryName @ $TestFileName, "MCPServerTestUtilities.wl" } ];
    (* Set the source directory so the test utilities can find Scripts/StartMCPServer.wls *)
    Wolfram`MCPServerTests`MCPServerTestUtilities`$MCPTestSourceDirectory = DirectoryName[ $TestFileName, 2 ],
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
