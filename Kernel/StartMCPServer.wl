(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "RickHennigan`MCPServer`StartMCPServer`" ];
Begin[ "`Private`" ];

Needs[ "RickHennigan`MCPServer`"        ];
Needs[ "RickHennigan`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
$protocolVersion = "2024-11-05";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*$MCPEvaluationEnvironment*)
$MCPEvaluationEnvironment = None;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*StartMCPServer*)
StartMCPServer // beginDefinition;
StartMCPServer[ ___ ] /; $Notebooks := catchMine @ throwFailure[ "InvalidSession" ];
StartMCPServer[ ] := inStdIO @ StartMCPServer @ Environment[ "MCP_SERVER_NAME" ];
StartMCPServer[ $Failed ] := inStdIO @ StartMCPServer @ $defaultMCPServer;
StartMCPServer[ name_String ] := inStdIO @ StartMCPServer @ MCPServerObject @ name;
StartMCPServer[ obj_MCPServerObject ] := inStdIO @ startMCPServer @ ensureMCPServerExists @ obj;
StartMCPServer // endExportedDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inStdIO*)
inStdIO // beginDefinition;
inStdIO // Attributes = { HoldFirst };

inStdIO[ eval_ ] :=
    Block[ { $MCPEvaluationEnvironment = "StandardInputOutput", inStdIO = # & },
        catchTop[ eval, StartMCPServer ]
    ];

inStdIO // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*startMCPServer*)
startMCPServer // beginDefinition;

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
startMCPServer[ obj_MCPServerObject ] := Enclose[
    superQuiet @ Module[ { logFile, llmTools, toolList, promptList, promptLookup, init, response },

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

        promptList = ConfirmMatch[ makePromptData @ obj[ "PromptData" ], { ___Association }, "PromptData" ];
        writeError[ "promptList: " <> ToString[ promptList, InputForm ] ];

        promptLookup = ConfirmBy[ makePromptLookup @ obj[ "PromptData" ], AssociationQ, "PromptLookup" ];
        writeError[ "promptLookup: " <> ToString[ promptLookup, InputForm ] ];

        init = ConfirmBy[ initResponse @ obj, AssociationQ, "InitResponse" ];

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
                    WriteLine[ "stdout", Developer`WriteRawJSONString[ response, "Compact" -> True ] ],
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
    Catch @ Enclose @ Module[ { stdin, message, method, id, response },
        stdin = InputString[ "" ];
        If[ stdin === "Quit", Exit[ 0 ] ];
        If[ ! StringQ @ stdin, Throw @ EndOfFile ];
        message = ConfirmBy[ Developer`ReadRawJSONString @ stdin, AssociationQ ];
        writeLog[ "Request" -> message ];
        method = Lookup[ message, "method", None ];
        id = Lookup[ message, "id", Null ];
        response = handleMethod[ method, message, <| "jsonrpc" -> "2.0", "id" -> id |> ];
        writeLog[ "Response" -> response ];
        response
    ];
(* :!CodeAnalysis::EndBlock:: *)

processRequest // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*handleMethod*)
handleMethod // beginDefinition;

handleMethod[ "initialize"    , msg_, req_ ] := <| req, "result" -> $initResult |>;
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
    <| "type" -> "text", "text" -> content |>

makePromptContent[ template_TemplateObject, arguments_Association ] :=
    makePromptContent[ TemplateApply[ template, arguments ], arguments ];

makePromptContent // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*evaluateTool*)
evaluateTool // beginDefinition;

evaluateTool[ msg_, req_ ] := Enclose[
    Catch @ Module[ { params, toolName, args, result, string },
        writeLog[ "ToolCall" -> msg ];
        params = ConfirmBy[ Lookup[ msg, "params", <| |> ], AssociationQ ];
        toolName = ConfirmBy[ Lookup[ params, "name" ], StringQ ];
        args = Lookup[ params, "arguments", <| |> ];
        result = $llmTools[ toolName ][ args ];
        If[ StringQ @ result[ "String" ], result = result[ "String" ] ];
        string = ConfirmBy[ safeString @ result, StringQ, "String" ];
        <| "content" -> { <| "type" -> "text", "text" -> string |> } |>
    ],
    throwInternalFailure
];

evaluateTool // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*safeString*)
safeString // beginDefinition;
safeString[ arg_ ] := ToString[ arg, CharacterEncoding -> "PrintableASCII" ];
safeString // endDefinition;

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
(*writeError*)
writeError // beginDefinition;
writeError[ str_String ] := WriteLine[ "stderr", str ];
writeError[ expr_ ] := WriteLine[ "stderr", ToString[ Unevaluated @ expr, InputForm ] ];
writeError // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
