(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`AgentTools`Tools`MCPAppsTest`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`AgentTools`"        ];
Needs[ "Wolfram`AgentTools`Common`" ];
Needs[ "Wolfram`AgentTools`Tools`"  ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompts*)
$mcpAppsTestDescription = "\
A diagnostic tool for testing the MCP Apps pipeline. Echoes the input message back along with server metadata.";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definition*)
(* Add to $defaultMCPTools Association (initialized in Kernel/Tools/Tools.wl) *)
$defaultMCPTools[ "MCPAppsTest" ] := LLMTool @ <|
    "Name"        -> "MCPAppsTest",
    "DisplayName" -> "MCP Apps Test",
    "Description" -> $mcpAppsTestDescription,
    "Function"    -> mcpAppsTestEvaluate,
    "Options"     -> { },
    "Parameters"  -> {
        "message" -> <|
            "Interpreter" -> "String",
            "Help"        -> "A message to echo back for testing.",
            "Required"    -> True
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*mcpAppsTestEvaluate*)
mcpAppsTestEvaluate // beginDefinition;

mcpAppsTestEvaluate[ KeyValuePattern[ "message" -> message_String ] ] := Enclose[
    Module[ { responseData, json },
        responseData = <|
            "echo"      -> message,
            "timestamp" -> DateString[ "ISODateTime" ],
            "server"    -> <|
                "name"    -> "Wolfram MCP Server",
                "version" -> $pacletVersion,
                "kernel"  -> $VersionNumber
            |>
        |>;
        json = ConfirmBy[ Developer`WriteRawJSONString @ responseData, StringQ, "JSON" ];
        <| "Content" -> { <| "type" -> "text", "text" -> json |> } |>
    ],
    throwInternalFailure
];

mcpAppsTestEvaluate // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
