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
(*$$validSearchResult*)
$$validSearchResult = _String | KeyValuePattern[ "Content" -> { __Association } ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatSearchPrompt*)
formatSearchPrompt // beginDefinition;

formatSearchPrompt[ query_String, results_String ] :=
    StringJoin[
        "<search-query>", query, "</search-query>\n",
        "<search-results>\n",
        results, "\n",
        "</search-results>\n",
        "Use the above search results to answer the user's query below.\n",
        "<user-query>", query, "</user-query>"
    ];

(* Handle multimodal content *)
formatSearchPrompt[ query_String, results_Association ] /; KeyExistsQ[ results, "Content" ] :=
    formatSearchPromptMultimodal[ query, results[ "Content" ] ];

formatSearchPrompt // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatSearchPromptMultimodal*)
formatSearchPromptMultimodal // beginDefinition;

formatSearchPromptMultimodal[ query_String, content: { __Association } ] :=
    Module[ { textParts, imageParts, textContent, formattedText },
        textParts = Cases[ content, KeyValuePattern[ "type" -> "text" ] ];
        imageParts = Cases[ content, KeyValuePattern[ "type" -> "image" ] ];
        textContent = StringJoin[ Lookup[ textParts, "text", "" ] ];

        formattedText = StringJoin[
            "<search-query>", query, "</search-query>\n",
            "<search-results>\n",
            textContent, "\n",
            "</search-results>\n",
            "Use the above search results to answer the user's query below.\n",
            "<user-query>", query, "</user-query>"
        ];

        (* Return array: text content followed by images *)
        Flatten @ { <| "type" -> "text", "text" -> formattedText |>, imageParts }
    ];

formatSearchPromptMultimodal // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateWolframSearchPrompt*)
generateWolframSearchPrompt // beginDefinition;

generateWolframSearchPrompt[ KeyValuePattern[ "query" -> query_String ] ] :=
    generateWolframSearchPrompt @ query;

generateWolframSearchPrompt[ query_String ] := Enclose[
    Module[ { result },
        (* relatedWolframContext is from Tools`Context` *)
        result = ConfirmMatch[
            relatedWolframContext[ <| "context" -> query |> ],
            $$validSearchResult,
            "Result"
        ];
        formatSearchPrompt[ query, result ]
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
        result = ConfirmMatch[
            relatedDocumentation[ <| "context" -> query |> ],
            $$validSearchResult,
            "Result"
        ];
        formatSearchPrompt[ query, result ]
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
        result = ConfirmMatch[
            relatedWolframAlphaResults[ <| "context" -> query |> ],
            $$validSearchResult,
            "Result"
        ];
        formatSearchPrompt[ query, result ]
    ],
    throwInternalFailure
];

generateWASearchPrompt // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
