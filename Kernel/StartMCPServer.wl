(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`StartMCPServer`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"          ];
Needs[ "Wolfram`MCPServer`Common`"   ];
Needs[ "Wolfram`MCPServer`Graphics`" ];

Needs[ "Wolfram`Chatbook`" -> "cb`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
$protocolVersion    = "2024-11-05";
$toolWarmupDelay    = 5; (* seconds *)
$clientName         = None;
$currentMCPServer   = None;

$logTimeStamp := DateString[
    {
        "Year", "-", "Month", "-", "Day",
        "T",
        "Hour", ":", "Minute", ":", "Second", ".", "Millisecond",
        "Z"
    },
    TimeZone -> 0
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*StartMCPServer*)
StartMCPServer // beginDefinition;
StartMCPServer[ ] := stealthCatchTop @ StartMCPServer @ Environment[ "MCP_SERVER_NAME" ];
StartMCPServer[ $Failed ] := stealthCatchTop @ StartMCPServer @ $defaultMCPServer;
StartMCPServer[ name_String ] := stealthCatchTop @ StartMCPServer @ MCPServerObject @ name;
StartMCPServer[ obj_MCPServerObject ] := stealthCatchTop @ startMCPServer @ ensureMCPServerExists @ obj;
StartMCPServer // endExportedDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*stealthCatchTop*)
(* A version of `catchTop` that doesn't set the message symbol or interfere with inner calls to `catchTop`. *)
stealthCatchTop // beginDefinition;
stealthCatchTop // Attributes = { HoldFirst };
stealthCatchTop[ eval_ ] := Block[ { $catching = True }, Catch[ eval, $catchTopTag ] ];
stealthCatchTop // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*startMCPServer*)
startMCPServer // beginDefinition;

startMCPServer[ obj_ ] /; $Notebooks :=
    throwFailure[ "InvalidSession" ];

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
startMCPServer[ obj_MCPServerObject ] := Enclose[
    Block[ { $currentMCPServer = obj },
        superQuiet @ Module[ { logFile, llmTools, toolList, promptList, promptLookup, init, response },

        SetOptions[ First @ Streams[ "stdout" ], CharacterEncoding -> "UTF-8" ];
        SetOptions[ First @ Streams[ "stderr" ], CharacterEncoding -> "UTF-8" ];

        logFile = ConfirmBy[ ensureFilePath @ mcpServerLogFile @ obj, fileQ, "LogFile" ];
        If[ FileExistsQ @ logFile, DeleteFile @ logFile ];
        writeLog[ "LogFile" -> logFile ];

        llmTools = Association[ #[ "Name" ] -> # & /@ ConfirmMatch[ obj[ "Tools" ], { ___LLMTool }, "Tools" ] ];

        toolList = Map[
            <|
                "name"        -> safeString @ #[ "Name"        ],
                "description" -> safeString @ #[ "Description" ],
                "inputSchema" -> #[ "JSONSchema" ]
            |> &,
            Values @ llmTools
        ];

        promptList   = ConfirmMatch[ makePromptData @ obj[ "PromptData" ], { ___Association }, "PromptData" ];
        promptLookup = ConfirmBy[ makePromptLookup @ obj[ "PromptData" ], AssociationQ, "PromptLookup" ];
        init         = ConfirmBy[ initResponse @ obj, AssociationQ, "InitResponse" ];

        Block[
            {
                $initResult   = init,
                $toolList     = toolList,
                $llmTools     = llmTools,
                $promptList   = promptList,
                $promptLookup = promptLookup,
                $logFile      = logFile
            },
            While[ True,
                If[
                    And[
                        Or[ $OperatingSystem === "MacOSX", $OperatingSystem === "Unix" ],
                        $ParentProcessID === 1
                    ],
                    Exit[0]
                ];
                response = catchAlways @ processRequest[ ];
                If[ response =!= EndOfFile, writeLog[ "Response" -> response ] ];
                If[ AssociationQ @ response,
                    WriteLine[ "stdout", Developer`WriteRawJSONString[ response, "Compact" -> True ] ];
                    If[ TrueQ @ $warmupTools, toolWarmup @ $toolList ],
                    Pause[ 0.1 ]
                ]
            ]
        ]
    ]
    ],
    throwInternalFailure
];
(* :!CodeAnalysis::EndBlock:: *)

startMCPServer // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toolWarmup*)
toolWarmup // beginDefinition;
toolWarmup[ ] := toolWarmup @ $toolList;
toolWarmup[ tools_List ] := toolWarmup /@ tools;
toolWarmup[ KeyValuePattern[ "name" -> name_String ] ] := toolWarmup @ name;
toolWarmup[ "WolframContext" ] := toolWarmup @ { "WolframAlphaContext", "WolframLanguageContext" };
toolWarmup[ "WolframLanguageContext"|"WolframAlphaContext" ] := preinstallVectorDatabases[ ];
toolWarmup[ _ ] := Null;
toolWarmup // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*preinstallVectorDatabases*)
preinstallVectorDatabases // beginDefinition;

preinstallVectorDatabases[ ] := preinstallVectorDatabases[ ] = (
    debugPrint[ "Warming up vector databases" ];
    debugPrint[ "Warmed up vector databases: ", First @ AbsoluteTiming @ initializeVectorDatabases[ ] ]
);

preinstallVectorDatabases // endDefinition;

(* Test messages:

```
{"method":"initialize","params":{"clientInfo":{"name":"test-client"},"protocolVersion":"2024-11-05"},"jsonrpc":"2.0","id":0}
{"method":"tools/list","params":{},"jsonrpc":"2.0","id":1}
{"method":"tools/call","params":{"name":"WolframContext","arguments":{"context":"What's the 123456789th prime?"}},"jsonrpc":"2.0","id":2}
```
*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*initializeVectorDatabases*)
initializeVectorDatabases // beginDefinition;
initializeVectorDatabases[ ] := initializeVectorDatabases[ ] = cb`InstallVectorDatabases[ ];
initializeVectorDatabases // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makePromptLookup*)
makePromptLookup // beginDefinition;
makePromptLookup[ prompts: { ___Association } ] := Association[ #Name -> # & /@ prompts ];
makePromptLookup // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makePromptData*)
makePromptData // beginDefinition;
makePromptData[ prompts: { ___Association } ] := makePromptData0 /@ prompts;
makePromptData // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makePromptData0*)
makePromptData0 // beginDefinition;

makePromptData0[ prompt_Association ] := Enclose[
    Module[ { name, description, arguments },
        name = ConfirmBy[
            prompt[ "Name" ] /. _Missing :> prompt[ "name" ],
            StringQ,
            "Name"
        ];
        description = Replace[
            prompt[ "Description" ] /. _Missing :> prompt[ "description" ],
            Except[ _String ] :> ""
        ];
        arguments = Replace[
            prompt[ "Arguments" ] /. _Missing :> prompt[ "arguments" ],
            {
                args: { ___Association } :> normalizeArguments @ args,
                _ :> { }
            }
        ];
        <|
            "name"        -> name,
            "description" -> description,
            If[ Length @ arguments > 0, "arguments" -> arguments, Nothing ]
        |>
    ],
    throwInternalFailure
];

makePromptData0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*normalizeArguments*)
normalizeArguments // beginDefinition;
normalizeArguments[ args: { ___Association } ] := normalizeArgument /@ args;
normalizeArguments // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*normalizeArgument*)
normalizeArgument // beginDefinition;

normalizeArgument[ arg_Association ] := <|
    "name"        -> (arg[ "Name" ] /. _Missing :> arg[ "name" ]),
    "description" -> (arg[ "Description" ] /. _Missing :> arg[ "description" ]) /. _Missing :> "",
    "required"    -> (arg[ "Required" ] /. _Missing :> arg[ "required" ]) /. _Missing :> False
|>;

normalizeArgument // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*processRequest*)
processRequest // beginDefinition;

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
processRequest[ ] :=
    Catch @ Enclose @ Module[ { stdin, message, method, id, req, response },
        stdin = InputString[ "" ];
        If[ stdin === "Quit", Exit[ 0 ] ];
        If[ ! StringQ @ stdin || StringTrim @ stdin === "", Throw @ EndOfFile ];
        message = ConfirmBy[ Developer`ReadRawJSONString @ stdin, AssociationQ ];
        writeLog[ "Request" -> message ];
        method = Lookup[ message, "method", None ];
        id = Lookup[ message, "id", Null ];
        req = <| "jsonrpc" -> "2.0", "id" -> id |>;
        response = catchAlways @ handleMethod[ method, message, req ];
        If[ method === "tools/list", $warmupTools = True ];
        writeLog[ "Response" -> response ];
        If[ FailureQ @ response,
            <| req, "error" -> <| "code" -> -32603, "message" -> "Internal error" |> |>,
            response
        ]
    ];
(* :!CodeAnalysis::EndBlock:: *)

processRequest // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*handleMethod*)
handleMethod // beginDefinition;

(* TODO: if the client supports roots, we should query for them and set directory appropriately
   https://modelcontextprotocol.io/specification/2025-11-25/client/roots#protocol-messages *)
handleMethod[ "initialize", msg_, req_ ] := (
    $clientName = Replace[ msg[[ "params", "clientInfo", "name" ]], Except[ _String ] :> None ];
    If[ ! stderrEnabledQ[ ], $Messages = { } ];
    <| req, "result" -> $initResult |>
);

handleMethod[ "ping"          , msg_, req_ ] := <| req, "result" -> <| |> |>;
handleMethod[ "resources/list", msg_, req_ ] := <| req, "result" -> <| "resources" -> { } |> |>;
handleMethod[ "prompts/list"  , msg_, req_ ] := <| req, "result" -> <| "prompts" -> $promptList |> |>;
handleMethod[ "prompts/get"   , msg_, req_ ] := <| req, "result" -> getPrompt[ msg, req ] |>;
handleMethod[ "tools/list"    , msg_, req_ ] := <| req, "result" -> <| "tools" -> $toolList |> |>;
handleMethod[ "tools/call"    , msg_, req_ ] := <| req, "result" -> evaluateTool[ msg, req ] |>;

(* Ignored *)
handleMethod[ method_String, _, req_ ] /; StringStartsQ[ method, "notifications/" ] := Null;
handleMethod[ _, _, KeyValuePattern[ "id" -> Null ] ] := Null;

(* Unknown method *)
e: handleMethod[ method_, msg_, req_ ] := (
    writeError[ "Unhandled method: " <> ToString[ Unevaluated @ e, InputForm ] ];
    <| req, "error" -> <| "code" -> -32601, "message" -> "Unknown method" |> |>
);

handleMethod // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*getPrompt*)
getPrompt // beginDefinition;

getPrompt[ msg_, req_ ] := getPrompt[ msg, req, $promptLookup ];

getPrompt[ msg_Association, req_Association, prompts_Association ] := Enclose[
    Module[ { params, name, arguments, promptData, content, messages },
        params = ConfirmBy[ Lookup[ msg, "params" ], AssociationQ, "Parameters" ];
        name = ConfirmBy[ Lookup[ params, "name" ], StringQ, "Name" ];
        arguments = ConfirmBy[ Lookup[ params, "arguments", <| |> ], AssociationQ, "Arguments" ];
        promptData = ConfirmBy[ Lookup[ prompts, name ], AssociationQ, "PromptData" ];
        content = makePromptContent[ promptData, arguments ];
        messages = { <| "role" -> "user", "content" -> content |> };
        <| "messages" -> messages |>
    ],
    throwInternalFailure
];

getPrompt // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*consolidateTextContent*)

(* Consolidates content arrays into a single text object for client compatibility.
   Extracts all text items and merges them. Non-text items (images) are dropped
   since many MCP clients don't support multimodal prompt responses. *)
consolidateTextContent // beginDefinition;

consolidateTextContent[ content: { __Association } ] :=
    Module[ { textItems },
        textItems = Select[ content, MatchQ[ #, KeyValuePattern[ "type" -> "text" ] ] & ];
        <| "type" -> "text", "text" -> StringJoin @ Lookup[ textItems, "text", "" ] |>
    ];

consolidateTextContent // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makePromptContent*)
makePromptContent // beginDefinition;

(* Handle Function type - call the function with arguments *)
makePromptContent[ KeyValuePattern[ { "Type" -> "Function", "Content" -> func_ } ], arguments_ ] :=
    makePromptContent[ catchPromptFunction[ func, arguments ], arguments ];

(* Handle multimodal content - list of content items *)
(* Consolidate text-only arrays into a single text object for client compatibility *)
makePromptContent[ content: { __Association }, arguments_ ] :=
    consolidateTextContent @ content;

(* Handle structured content with "Content" key containing multimodal content *)
makePromptContent[ KeyValuePattern[ "Content" -> content: { __Association } ], arguments_ ] :=
    consolidateTextContent @ content;

(* Handle Text type with Content *)
makePromptContent[ KeyValuePattern[ "Content" -> content_ ], arguments_ ] :=
    makePromptContent[ content, arguments ];

(* Handle string content *)
makePromptContent[ content_String, arguments_ ] :=
    <| "type" -> "text", "text" -> content |>;

(* Handle template content *)
makePromptContent[ template_TemplateObject, arguments_Association ] :=
    makePromptContent[ TemplateApply[ template, arguments ], arguments ];

(* Fallback - convert to string *)
makePromptContent[ content_, arguments_ ] :=
    <| "type" -> "text", "text" -> ToString @ content |>;

makePromptContent // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*catchPromptFunction*)
catchPromptFunction // beginDefinition;

catchPromptFunction[ func_, arguments_ ] :=
    With[ { result = Quiet @ catchAlways @ func @ arguments },
        If[ FailureQ @ result,
            formatPromptError @ result,
            result
        ]
    ];

catchPromptFunction // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatPromptError*)
formatPromptError // beginDefinition;

formatPromptError[ failure_Failure ] :=
    With[ { msg = failure[ "Message" ] },
        If[ StringQ @ msg,
            "[Error] " <> msg,
            "[Error] Failed to generate prompt content."
        ]
    ];

formatPromptError[ _ ] := "[Error] Failed to generate prompt content.";

formatPromptError // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*graphicsToImageContent*)
graphicsToImageContent // beginDefinition;

graphicsToImageContent[ g_ ] := Enclose[
    Module[ { png, base64 },
        png = ConfirmBy[ Quiet @ ExportByteArray[ g, "PNG" ], ByteArrayQ, "PNG" ];
        base64 = ConfirmBy[ BaseEncode @ png, StringQ, "Base64" ];
        <| "type" -> "image", "data" -> base64, "mimeType" -> "image/png" |>
    ],
    $Failed &  (* Return $Failed on failure *)
];

graphicsToImageContent // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*extractWolframAlphaImages*)

(* Pattern for WolframAlpha image URLs in markdown *)
(* Matches: public6.wolframalpha.com, www6.wolframalpha.com, etc. *)
$$waImageURLPattern = Shortest[
    "![" ~~ Except[ "]" ]... ~~ "](" ~~
    url: ("https://" ~~ __ ~~ "wolframalpha.com/files/" ~~ __ ~~ (".gif" | ".png" | ".jpg" | ".jpeg")) ~~
    ")"
];

extractWolframAlphaImages // beginDefinition;

extractWolframAlphaImages[ str_String ] := Enclose[
    Catch @ Module[ { parts, hasImages, contentItems },

        (* Split string into text segments and URLs *)
        parts = StringSplit[ str, $$waImageURLPattern :> url ];

        (* If no images found, return plain text *)
        If[ Length @ parts === 1 && StringQ @ First @ parts,
            Throw @ str  (* Return plain string for backward compatibility *)
        ];

        hasImages = False;
        contentItems = Flatten @ Map[
            Function[ item,
                If[ StringQ @ item && ! StringStartsQ[ item, "https://" ],
                    (* Text segment: create text content *)
                    If[ StringLength @ item > 0,
                        { <| "type" -> "text", "text" -> item |> },
                        { }
                    ],
                    (* URL: import image and create both text + image content *)
                    hasImages = True;
                    Module[ { img, imageContent },
                        img = Quiet @ Import[ item, "Image" ];
                        imageContent = If[ ImageQ @ img, graphicsToImageContent @ img, $Failed ];
                        Flatten @ {
                            (* Always include the markdown link as text *)
                            <| "type" -> "text", "text" -> "![Image](" <> item <> ")" |>,
                            (* Add base64 image if import succeeded *)
                            If[ AssociationQ @ imageContent, imageContent, Nothing ]
                        }
                    ]
                ]
            ],
            parts
        ];

        (* If we successfully extracted images, return structured content *)
        If[ TrueQ @ hasImages && MatchQ[ contentItems, { __Association } ],
            <| "Content" -> contentItems |>,
            str  (* Fallback to plain string *)
        ]
    ],
    str &  (* On any error, return original string *)
];

extractWolframAlphaImages // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*extractImageContent*)
extractImageContent // beginDefinition;

extractImageContent[ g_? graphicsQ ] :=
    With[ { img = graphicsToImageContent @ g },
        If[ AssociationQ @ img, { img }, { } ]
    ];

extractImageContent[ list_List ] := Flatten[ extractImageContent /@ list, 1 ];
extractImageContent[ as_Association ] := extractImageContent @ Values @ as;
extractImageContent[ _Failure ] := { };
extractImageContent[ _String  ] := { };
extractImageContent[ _        ] := { };

extractImageContent // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*resultToContent*)
resultToContent // beginDefinition;

resultToContent[ result_ ] := Enclose[
    Module[ { textContent, imageContents },
        textContent = <| "type" -> "text", "text" -> ConfirmBy[ safeString @ result, StringQ ] |>;
        imageContents = ConfirmMatch[ extractImageContent @ result, { ___Association } ];
        Flatten @ { textContent, imageContents }
    ],
    throwInternalFailure
];

resultToContent // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*evaluateTool*)
evaluateTool // beginDefinition;

evaluateTool[ msg_, req_ ] := Enclose[
    Catch @ Module[ { params, toolName, args, tool, result, content },
        Quiet @ TaskRemove @ $warmupTask; (* We're in a tool call, so it no longer makes sense to warm up tools *)
        writeLog[ "ToolCall" -> msg ];
        params = ConfirmBy[ Lookup[ msg, "params", <| |> ], AssociationQ ];
        toolName = ConfirmBy[ Lookup[ params, "name" ], StringQ ];
        args = Lookup[ params, "arguments", <| |> ];

        (* Check if the tool exists before calling it *)
        tool = Lookup[ $llmTools, toolName, Missing[ "UnknownTool", toolName ] ];
        If[ MissingQ @ tool,
            Throw @ <|
                "content" -> { <| "type" -> "text", "text" -> "[Error] Unknown tool: " <> toolName |> },
                "isError" -> True
            |>
        ];

        result = stealthCatchTop @ tool @ args;

        content = Which[
            (* Structured result with Content key (from WolframLanguageEvaluator) *)
            AssociationQ @ result && KeyExistsQ[ result, "Content" ],
                result[ "Content" ],

            (* Legacy: result has String key *)
            StringQ @ result[ "String" ],
                resultToContent @ result[ "String" ],

            (* Default: auto-detect graphics *)
            True,
                resultToContent @ result
        ];

        <| "content" -> ConfirmMatch[ content, { __Association } ], "isError" -> FailureQ @ result |>
    ],
    throwInternalFailure
];

evaluateTool // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*safeString*)
safeString // beginDefinition;

(* Special handling for internal failures - format cleanly for MCP output *)
safeString[ failure: Failure[ "MCPServer::Internal" | "General::ChatbookInternal", _ ] ] :=
    With[ { formatted = formatInternalFailureForMCP @ failure },
        formatted /; StringQ @ formatted
    ];

safeString[ failure_Failure ] := With[ { s = failure[ "Message" ] }, "[Error] " <> safeString @ s /; StringQ @ s ];
safeString[ arg_ ] := convertPUACharacters @ ToString @ Unevaluated @ arg;
safeString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*convertPUACharacters*)
convertPUACharacters // beginDefinition;
convertPUACharacters[ str_String ] := StringJoin[ convertPUACharacters /@ ToCharacterCode @ str ];
convertPUACharacters[ n_Integer ] /; 57344 <= n <= 63743 := toPrintableASCII @ FromCharacterCode @ n;
convertPUACharacters[ n_Integer ] := FromCharacterCode @ n;
convertPUACharacters // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toPrintableASCII*)
toPrintableASCII // beginDefinition;
toPrintableASCII[ expr_ ] := ToString[ Unevaluated @ expr, CharacterEncoding -> "PrintableASCII" ];
toPrintableASCII // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*superQuiet*)
(* Nothing can be written to stdout while running as an MCP server, so we aggressively suppress output. *)
superQuiet // beginDefinition;
superQuiet // Attributes = { HoldFirst };

superQuiet[ eval_ ] :=
    Module[ { logFile, logStream },
        logFile = Quiet @ outputLogFile @ $currentMCPServer;
        logStream = If[ fileQ @ logFile,
            Quiet @ OpenWrite[ First @ logFile, CharacterEncoding -> "UTF-8" ],
            $Failed
        ];

        If[ MatchQ[ logStream, OutputStream[ _, _ ] ],
            (* Success: redirect to log file *)
            cleanupOldOutputLogs[ ];
            WithCleanup[
                Block[
                    {
                        $ProgressReporting = False,
                        $Messages = { logStream },
                        $Output   = { logStream }
                    },
                    (* We use a veto handler to prevent print output from being written to stdout/stderr.
                       We do this instead of redefining Print as a local symbol in Block because we need to let the
                       WL evaluator tool capture and include print outputs in the tool call response. *)
                    Internal`HandlerBlock[ { "Wolfram.System.Print.Veto", False & }, eval ]
                ],
                Quiet @ Close @ logStream
            ],
            (* Fallback: redirect to stderr as before *)
            Block[
                {
                    $ProgressReporting = False,
                    $Messages = Streams[ "stderr" ],
                    $Output   = Streams[ "stderr" ]
                },
                Internal`HandlerBlock[ { "Wolfram.System.Print.Veto", False & }, eval ]
            ]
        ]
    ];

superQuiet // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*initResponse*)
initResponse // beginDefinition;

initResponse[ obj_MCPServerObject ] :=
    initResponse[ obj[ "Name" ], obj[ "ServerVersion" ], obj[ "Tools" ], obj[ "Prompts" ] ];

initResponse[ name_String, version_String, tools0: { ___LLMTool }, prompts_ ] := Enclose[
    Module[ { tools, instructions },
        tools = If[ Length @ tools0 > 0, <| "listChanged" -> True |>, <| |> ];
        instructions = ConfirmMatch[ makeInstructions @ prompts, _Missing | _String, "Instructions" ];
        DeleteMissing @ <|
            "protocolVersion" -> $protocolVersion,
            "instructions"    -> instructions,
            "capabilities" -> <|
                (* TODO: support logging *)
                "prompts" -> <| |>,
                (* TODO: support resources *)
                "tools" -> tools
            |>,
            "serverInfo" -> <| "name" -> name, "version" -> version |>
        |>
    ],
    throwInternalFailure
];

initResponse // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*makeInstructions*)
makeInstructions // beginDefinition;

makeInstructions[ { } | "" ] :=
    Missing[ "NotAvailable" ];

makeInstructions[ prompt_String ] :=
    makeInstructions @ { prompt };

makeInstructions[ prompts: { __String } ] :=
    StringRiffle[ prompts, "\n\n" ];

makeInstructions[ prompts: { (_String|_TemplateObject)... } ] :=
    makeInstructions @ Select[
        Replace[
            prompts,
            t_TemplateObject :> TemplateApply @ t,
            { 1 }
        ],
        StringQ
    ];

makeInstructions[ _ ] :=
    Missing[ "NotAvailable" ];

makeInstructions // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*writeLog*)
writeLog // beginDefinition;
writeLog[ expr_ ] := writeLog[ expr, $logFile ];
writeLog[ expr_, File[ file_String ] ] := PutAppend[ expr, file ];
writeLog[ expr_, _ ] := Null;
writeLog // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*stderrEnabledQ*)
(* stderr output causes issues with several clients, so we disable it unless we know it's safe to use *)
stderrEnabledQ // beginDefinition;
stderrEnabledQ[ ] := stderrEnabledQ @ $clientName;
stderrEnabledQ[ "claude-code" ] := True;
stderrEnabledQ[ "claude-ai" ] := True;
stderrEnabledQ[ _ ] := False;
stderrEnabledQ // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*writeError*)
writeError // beginDefinition;

writeError[ args___ ] /; stderrEnabledQ[ ] :=
    With[ { time = $logTimeStamp },
        WriteLine[ "stderr", sequenceString[ time, " [Wolfram/MCPServer] [error] ", args ] ]
    ];

writeError[ ___ ] := Null;

writeError // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*debugEcho*)
debugEcho // beginDefinition;
debugEcho[ expr_ ] := (debugPrint @ Unevaluated @ expr; expr);
debugEcho // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*debugPrint*)
debugPrint // beginDefinition;

debugPrint[ args___ ] /; stderrEnabledQ[ ] :=
    With[ { time = $logTimeStamp },
        WriteLine[ "stderr", sequenceString[ time, " [Wolfram/MCPServer] [info] ", args ] ]
    ];

debugPrint[ ___ ] := Null;

debugPrint // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*sequenceString*)
sequenceString // beginDefinition;
sequenceString // Attributes = { HoldAll };
sequenceString[ args___ ] := ToString @ Unevaluated @ SequenceForm @ args;
sequenceString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
