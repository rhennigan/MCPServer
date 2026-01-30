(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`StartMCPServer`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

Needs[ "Wolfram`Chatbook`" -> "cb`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
$protocolVersion = "2024-11-05";
$toolWarmupDelay = 5; (* seconds *)
$clientName      = None;

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
(*makePromptContent*)
makePromptContent // beginDefinition;

(* Handle Function type - call the function with arguments *)
makePromptContent[ KeyValuePattern[ { "Type" -> "Function", "Content" -> func_ } ], arguments_ ] :=
    makePromptContent[ catchPromptFunction[ func, arguments ], arguments ];

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
(*evaluateTool*)
evaluateTool // beginDefinition;

evaluateTool[ msg_, req_ ] := Enclose[
    Catch @ Module[ { params, toolName, args, result, string },
        Quiet @ TaskRemove @ $warmupTask; (* We're in a tool call, so it no longer makes sense to warm up tools *)
        writeLog[ "ToolCall" -> msg ];
        params = ConfirmBy[ Lookup[ msg, "params", <| |> ], AssociationQ ];
        toolName = ConfirmBy[ Lookup[ params, "name" ], StringQ ];
        args = Lookup[ params, "arguments", <| |> ];
        result = stealthCatchTop @ $llmTools[ toolName ][ args ];
        If[ StringQ @ result[ "String" ], result = result[ "String" ] ];
        (* TODO: return multimodal content here when appropriate *)
        (* TODO: convert internal errors to more useful text *)
        string = ConfirmBy[ safeString @ result, StringQ, "String" ];
        <|
            "content" -> { <| "type" -> "text", "text" -> string |> },
            "isError" -> FailureQ @ result
        |>
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
    Block[
        {
            (* Prevent progress reporting from writing excessive updates to stdout/stderr: *)
            $ProgressReporting = False,
            (* Redirect both $Output and $Messages to stderr to keep stdout clean for MCP: *)
            $Messages = Streams[ "stderr" ],
            $Output   = Streams[ "stderr" ]
        },
        (* We use a veto handler to prevent print output from being written to stdout/stderr.
           We do this instead of redefining Print as a local symbol in Block because we need to let the
           the WL evaluator tool capture and include print outputs in the tool call response. *)
        Internal`HandlerBlock[ { "Wolfram.System.Print.Veto", False & }, eval ]
    ];

superQuiet // endDefinition;

(* TODO:
  - We should OpenWrite a log file in `FileNameJoin @ { $UserBaseDirectory, "Logs", "MCPServer", "Output", file }`
  - We should redirect both $Output and $Messages to the log file
  - Also catch and redirect explicit Write/WriteString/BinaryWrite calls that try to write to stdout/stderr?
  - We need actual tests of the running MCP server via StartProcess/WriteString/ReadString
*)

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
                "logging"   -> <| |>, (* TODO: support logging *)
                "prompts"   -> <| |>, (* TODO: support prompts *)
                "resources" -> <| |>, (* TODO: support resources *)
                "tools"     -> tools
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
