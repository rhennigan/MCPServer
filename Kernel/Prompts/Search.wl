(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Prompts`Search`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"               ];
Needs[ "Wolfram`MCPServer`Common`"        ];
Needs[ "Wolfram`MCPServer`Prompts`"       ];
Needs[ "Wolfram`MCPServer`Tools`Context`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompt Descriptions*)
$searchDescription =
    "Searches for relevant Wolfram information to help answer a query.";

$wlSearchDescription =
    "Searches Wolfram Language documentation for relevant information.";

$waSearchDescription =
    "Searches Wolfram Alpha knowledge base for relevant information.";

$searchArguments = {
    <|
        "Name"        -> "query",
        "Description" -> "The search query",
        "Required"    -> True
    |>
};

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompt Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframSearch*)
$defaultMCPPrompts[ "WolframSearch" ] := <|
    "Name"        -> "Search",
    "Description" -> $searchDescription,
    "Arguments"   -> $searchArguments,
    "Type"        -> "Function",
    "Content"     -> generateWolframSearchPrompt
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframLanguageSearch*)
$defaultMCPPrompts[ "WolframLanguageSearch" ] := <|
    "Name"        -> "Search",
    "Description" -> $wlSearchDescription,
    "Arguments"   -> $searchArguments,
    "Type"        -> "Function",
    "Content"     -> generateWLSearchPrompt
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframAlphaSearch*)
$defaultMCPPrompts[ "WolframAlphaSearch" ] := <|
    "Name"        -> "Search",
    "Description" -> $waSearchDescription,
    "Arguments"   -> $searchArguments,
    "Type"        -> "Function",
    "Content"     -> generateWASearchPrompt
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateWolframSearchPrompt*)
generateWolframSearchPrompt // beginDefinition;

generateWolframSearchPrompt[ KeyValuePattern[ "query" -> query_String ] ] :=
    generateWolframSearchPrompt @ query;

generateWolframSearchPrompt[ query_String ] := Enclose[
    Module[ { result },
        (* relatedWolframContext is from Tools`Context` *)
        result = ConfirmBy[
            relatedWolframContext[ <| "context" -> query |> ],
            StringQ,
            "Result"
        ];
        StringJoin[ result, "\n\n", query ]
    ],
    throwInternalFailure
];

generateWolframSearchPrompt // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateWLSearchPrompt*)
generateWLSearchPrompt // beginDefinition;

generateWLSearchPrompt[ KeyValuePattern[ "query" -> query_String ] ] :=
    generateWLSearchPrompt @ query;

generateWLSearchPrompt[ query_String ] := Enclose[
    Module[ { result },
        (* relatedDocumentation is from Tools`Context` *)
        result = ConfirmBy[
            relatedDocumentation[ <| "context" -> query |> ],
            StringQ,
            "Result"
        ];
        StringJoin[ result, "\n\n", query ]
    ],
    throwInternalFailure
];

generateWLSearchPrompt // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateWASearchPrompt*)
generateWASearchPrompt // beginDefinition;

generateWASearchPrompt[ KeyValuePattern[ "query" -> query_String ] ] :=
    generateWASearchPrompt @ query;

generateWASearchPrompt[ query_String ] := Enclose[
    Module[ { result },
        (* relatedWolframAlphaResults is from Tools`Context` *)
        result = ConfirmBy[
            relatedWolframAlphaResults[ <| "context" -> query |> ],
            StringQ,
            "Result"
        ];
        StringJoin[ result, "\n\n", query ]
    ],
    throwInternalFailure
];

generateWASearchPrompt // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
