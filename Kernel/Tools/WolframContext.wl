(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`WolframContext`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompts*)
$wolframContextToolDescription = "\
Uses semantic search to retrieve any relevant information from Wolfram. Always use this tool at the start of \
new conversations or if the topic changes to ensure you have up-to-date relevant information. This uses semantic \
search, so the context argument should be written in natural language (not a search query) and contain as much detail \
as possible (up to 250 words).";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definition*)
$defaultMCPTools[ "WolframContext" ] := LLMTool @ <|
    "Name"           -> "WolframContext",
    "DisplayName"    -> "Wolfram Context",
    "Description"    -> $wolframContextToolDescription,
    "Function"       -> relatedWolframContext,
    "LLMKit"         -> "Suggested",
    "Initialization" :> initializeVectorDatabases[ ],
    "Options"        -> { },
    "Parameters"     -> {
        "context" -> <|
            "Interpreter" -> "String",
            "Help"        -> "A detailed summary of what the user is trying to achieve or learn about.",
            "Required"    -> True
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*relatedWolframContext*)
relatedWolframContext // beginDefinition;

relatedWolframContext[ KeyValuePattern[ "context" -> context_ ] ] :=
    relatedWolframContext @ context;

relatedWolframContext[ context_String ] := Enclose[
    Module[ { waPrompt, wlPrompt },
        waPrompt = ConfirmBy[ relatedWolframAlphaPrompt[ context, "Warning" ], StringQ, "WolframAlphaPrompt" ];
        wlPrompt = ConfirmBy[ relatedDocumentation @ context, StringQ, "WolframLanguagePrompt" ];
        ConfirmBy[
            StringRiffle[ DeleteCases[ StringTrim @ { waPrompt, wlPrompt }, "" ], "\n\n======\n\n" ],
            StringQ,
            "Result"
        ]
    ],
    throwInternalFailure
];

relatedWolframContext // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];