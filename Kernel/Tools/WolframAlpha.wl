(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`WolframAlpha`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];

Needs[ "Wolfram`Chatbook`" -> "cb`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompts*)
(* TODO: multiple queries aren't supported until the next Chatbook paclet update *)
(* $wolframAlphaToolDescription = "\
Use natural language queries with Wolfram|Alpha to get up-to-date computational results about entities in \
chemistry, physics, geography, history, art, astronomy, and more.
Always use the Wolfram context tool before using this tool to make sure you have the most up-to-date information.
IMPORTANT: If you need the results of multiple queries, it's important that you combine them into a single tool call \
whenever possible to save on token usage and time.";

$wolframAlphaToolQueryHelp = "\
The query (or queries) to send to Wolfram|Alpha. Separate multiple queries with tab characters (\\t)."; *)

$wolframAlphaToolDescription = "\
Use natural language queries with Wolfram|Alpha to get up-to-date computational results about entities in \
chemistry, physics, geography, history, art, astronomy, and more.
Always use the Wolfram context tool before using this tool to make sure you have the most up-to-date information.";

$wolframAlphaToolQueryHelp = "The query to send to Wolfram|Alpha.";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definition*)
(* Add to $defaultMCPTools Association (initialized in Kernel/Tools/Tools.wl) *)
$defaultMCPTools[ "WolframAlpha" ] := LLMTool @ <|
    "Name"        -> "WolframAlpha",
    "DisplayName" -> "Wolfram|Alpha",
    "Description" -> $wolframAlphaToolDescription,
    "Function"    -> wolframAlphaToolEvaluate,
    "Options"     -> { },
    "Parameters"  -> {
        "query" -> <|
            "Interpreter" -> "String",
            "Help"        -> $wolframAlphaToolQueryHelp,
            "Required"    -> True
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*wolframAlphaToolEvaluate*)
wolframAlphaToolEvaluate // beginDefinition;
wolframAlphaToolEvaluate[ as_ ] := wolframAlphaToolEvaluate[ as, cb`$DefaultTools[ "WolframAlpha" ][ as ] ];
wolframAlphaToolEvaluate[ as_, result_String ] := result;
wolframAlphaToolEvaluate[ as_, KeyValuePattern[ "String" -> result_String ] ] := result;
wolframAlphaToolEvaluate // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];