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
(*StartMCPServer*)
(* FIXME: This should fail if evaluated in an interactive session *)
StartMCPServer // beginDefinition;

StartMCPServer[ ] :=
    StartMCPServer @ Environment[ "MCP_SERVER_NAME" ];

StartMCPServer[ name_String ] :=
    With[ { obj = MCPServerObject @ name },
        StartMCPServer @ obj
    ];

StartMCPServer[ obj_MCPServerObject? MCPServerObjectQ ] :=
    catchMine @ superQuiet @ startMCPServer @ obj;

StartMCPServer // endExportedDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*startMCPServer*)
startMCPServer // beginDefinition;

startMCPServer[ obj_MCPServerObject? MCPServerObjectQ ] := Enclose[
    Module[ { logFile, llmTools, toolList, init, response },

        logFile = ConfirmMatch[ mcpServerLogFile @ obj, File[ _String ], "LogFile" ];
        ConfirmBy[ GeneralUtilities`EnsureDirectory @ DirectoryName @ logFile, DirectoryQ, "LogFileDirectory" ];
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

        init = ConfirmBy[ initResponse @ obj, AssociationQ, "InitResponse" ];

        Block[ { $initResult = init, $toolList = toolList, $llmTools = llmTools, $logFile = logFile },
            While[ True,
                response = catchAlways @ processRequest[ ];
                writeLog[ "Response" -> response ];
                If[ AssociationQ @ response,
                    WriteLine[ "stdout", Developer`WriteRawJSONString[ response, "Compact" -> True ] ],
                    Pause[ 0.1 ]
                ]
            ]
        ]
    ],
    throwInternalFailure
];

startMCPServer // endDefinition;

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
handleMethod[ "prompts/list"  , msg_, req_ ] := <| req, "result" -> <| "prompts" -> { } |> |>;
handleMethod[ "tools/list"    , msg_, req_ ] := <| req, "result" -> <| "tools" -> $toolList |> |>;
handleMethod[ "tools/call"    , msg_, req_ ] := <| req, "result" -> evaluateTool[ msg, req ] |>;

(* Ignored *)
handleMethod[ method_String, _, req_ ] /; StringStartsQ[ method, "notifications/" ] := Null;
handleMethod[ _, _, KeyValuePattern[ "id" -> Null ] ] := Null;

(* Unknown method *)
handleMethod[ _, _, req_ ] := <| req, "error" -> <| "code" -> -32601, "message" -> "Unknown method" |> |>;

handleMethod // endDefinition;

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
superQuiet[ eval_ ] := Block[ { PrintTemporary, Print = Null &, $ProgressReporting = False }, Quiet @ eval ];
(* :!CodeAnalysis::EndBlock:: *)
superQuiet // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*initResponse*)
initResponse // beginDefinition;

initResponse[ obj_MCPServerObject ] :=
    initResponse[ obj[ "Name" ], obj[ "Version" ], obj[ "Tools" ] ];

initResponse[ name_String, version_String, tools: { ___LLMTool } ] := <|
    "protocolVersion" -> $protocolVersion,
    "capabilities" -> <|
        "logging"   -> <| |>, (* TODO: support logging *)
        "prompts"   -> <| |>, (* TODO: support prompts *)
        "resources" -> <| |>, (* TODO: support resources *)
        "tools"     -> If[ Length @ tools > 0, <| "listChanged" -> True |>, <| |> ]
    |>,
    "serverInfo" -> <| "name" -> name, "version" -> version |>
|>;

initResponse // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*writeLog*)
writeLog // beginDefinition;
writeLog[ expr_ ] := writeLog[ expr, $logFile ];
writeLog[ expr_, File[ file_String ] ] := PutAppend[ expr, file ];
writeLog[ expr_, _ ] := Null;
writeLog // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
