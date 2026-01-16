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
$wolframAlphaToolDescription = "\
Use natural language queries with Wolfram|Alpha to get up-to-date computational results about entities in \
chemistry, physics, geography, history, art, astronomy, and more.
Always use the Wolfram context tool before using this tool to make sure you have the most up-to-date information.";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definition*)
$defaultMCPTools[ "WolframAlpha" ] := LLMTool @ <|
    "Name"        -> "WolframAlpha",
    "DisplayName" -> "Wolfram|Alpha",
    "Description" -> $wolframAlphaToolDescription,
    "Function"    -> Function[ cb`$DefaultTools[ "WolframAlpha" ][ # ][ "String" ] ],
    "Options"     -> { },
    "Parameters"  -> {
        "query" -> <|
            "Interpreter" -> "String",
            "Help"        -> "the input",
            "Required"    -> True
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];