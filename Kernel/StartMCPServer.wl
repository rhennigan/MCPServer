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
makePromptData[ prompts: { ___Association } ] := KeyMap[ ToLowerCase ] @* KeyTake[ $promptKeys ] /@ prompts;
makePromptData // endDefinition;

$promptKeys = { "Name", "Description", "Arguments" };

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
        If[ ! StringQ @ stdin, Throw @ EndOfFile ];
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

makePromptContent[ KeyValuePattern[ "Content" -> content_ ], arguments_ ] :=
    makePromptContent[ content, arguments ];

makePromptContent[ content_String, arguments_ ] :=
    <| "type" -> "text", "text" -> content |>;

makePromptContent[ template_TemplateObject, arguments_Association ] :=
    makePromptContent[ TemplateApply[ template, arguments ], arguments ];

makePromptContent // endDefinition;

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
(* TODO: add message handler to log messages to a file *)
superQuiet // beginDefinition;
superQuiet // Attributes = { HoldFirst };
(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
superQuiet[ eval_ ] :=
    Block[
        {
            $ProgressReporting = False,
            Print              = Null &,
            PrintTemporary     = Null &,
            $Messages          = Streams[ "stderr" ]
        },
        eval
    ];
(* :!CodeAnalysis::EndBlock:: *)
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
stderrEnabledQ // beginDefinition;
stderrEnabledQ[ ] := $clientName =!= "antigravity-client";
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
