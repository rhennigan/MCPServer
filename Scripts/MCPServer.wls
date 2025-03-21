#!/usr/bin/env wolframscript

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
$logFile       = FileNameJoin @ { DirectoryName[ $InputFileName, 2 ], "log.wl" };
$selectedTools = { "WolframLanguageEvaluator", "WolframAlpha", "DocumentationSearcher" };

(* REQUIRED: *)
$ProgressReporting = False;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Tools*)
llmTools = <| #[ "Name" ] -> # & /@ Lookup[ Wolfram`Chatbook`$DefaultTools, $selectedTools ] |>;

toolList = Map[
    <|
        "name"        -> #[ "Name" ],
        "description" -> If[ #[ "Name" ] === "wolfram_language_evaluator",
                             "Evaluate Wolfram Language code",
                             #[ "Description" ]
                         ],
        "inputSchema" -> #[ "JSONSchema" ]
    |> &,
    Values @ llmTools
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Messages*)
$initResult = <|
    "protocolVersion" -> "2024-11-05",
    "capabilities" -> <|
        "logging"   -> <| |>,
        "prompts"   -> <| |>,
        "resources" -> <| |>,
        "tools"     -> <| "listChanged" -> True |>
    |>,
    "serverInfo" -> <| "name" -> "WL", "version" -> "1.0.0" |>
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*runMCPServer*)
runMCPServer[ ] := Quiet @ Block[ { PrintTemporary },
    Module[ { response },
        Put[ "Server started", $logFile ];
        While[ True,
            response = processRequest[ ];
            If[ AssociationQ @ response,
                WriteLine[ "stdout", Developer`WriteRawJSONString[ response, "Compact" -> True ] ],
                Pause[ 0.1 ]
            ]
        ]
    ]
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*processRequest*)
processRequest[ ] :=
    Catch @ Enclose @ Module[ { stdin, message, method, id, response },
        stdin = InputString[ "" ];
        If[ ! StringQ @ stdin, Throw @ EndOfFile ];
        message = ConfirmBy[ Developer`ReadRawJSONString @ stdin, AssociationQ ];
        PutAppend[ "Request" -> message, $logFile ];
        method = Lookup[ message, "method", None ];
        id = Lookup[ message, "id", Null ];
        response = handleMethod[ method, message, <| "jsonrpc" -> "2.0", "id" -> id |> ];
        PutAppend[ "Response" -> response, $logFile ];
        response
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*handleMethod*)
handleMethod[ "initialize"    , msg_, req_ ] := <| req, "result" -> $initResult |>;
handleMethod[ "resources/list", msg_, req_ ] := <| req, "result" -> <| "resources" -> { } |> |>;
handleMethod[ "prompts/list"  , msg_, req_ ] := <| req, "result" -> <| "prompts" -> { } |> |>;
handleMethod[ "tools/list"    , msg_, req_ ] := <| req, "result" -> <| "tools" -> toolList |> |>;
handleMethod[ "tools/call"    , msg_, req_ ] := <| req, "result" -> evaluateTool[ msg, req ] |>;

(* Ignored *)
handleMethod[ method_String, _, req_ ] /; StringStartsQ[ method, "notifications/" ] := Null;
handleMethod[ _, _, KeyValuePattern[ "id" -> Null ] ] := Null;

(* Unknown method *)
handleMethod[ _, _, req_ ] := <| req, "error" -> <| "code" -> -32601, "message" -> "Unknown method" |> |>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*evaluateTool*)
evaluateTool[ msg_, req_ ] :=
    Catch @ Enclose @ Module[ { params, toolName, args, result, string },
        PutAppend[ "ToolCall" -> msg, $logFile ];
        params = ConfirmBy[ Lookup[ msg, "params", <| |> ], AssociationQ ];
        toolName = ConfirmBy[ Lookup[ params, "name" ], StringQ ];
        args = Lookup[ params, "arguments", <| |> ];
        result = llmTools[ toolName ][ args ];
        If[ StringQ @ result[ "String" ], result = result[ "String" ] ];
        string = ToString[ result, CharacterEncoding -> "PrintableASCII" ];
        <| "content" -> { <| "type" -> "text", "text" -> string |> } |>
    ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Run*)
runMCPServer[ ]