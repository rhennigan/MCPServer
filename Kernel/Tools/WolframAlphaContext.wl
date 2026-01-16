(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`WolframAlphaContext`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];

Needs[ "Wolfram`Chatbook`" -> "cb`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompts*)
$waContextToolDescription = "\
Uses semantic search to retrieve any relevant information from Wolfram Alpha. Always use this tool at the start of \
new conversations or if the topic changes to ensure you have up-to-date relevant information. This uses semantic \
search, so the context argument should be written in natural language (not a search query) and contain as much detail \
as possible (up to 250 words).";

$wolframAlphaMissingLLMKitTemplate = StringTemplate[ "\
`Level`: Unable to generate Wolfram|Alpha context due to missing LLMKit subscription. \
Inform the user that they can subscribe at the following URL in order to improve the quality of the results: `URL`" ];

$wolframAlphaNoCloudTemplate = StringTemplate[ "\
`Level`: Unable to generate Wolfram|Alpha context due to missing cloud connection." ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definition*)
$defaultMCPTools[ "WolframAlphaContext" ] := LLMTool @ <|
    "Name"           -> "WolframAlphaContext",
    "DisplayName"    -> "Wolfram|Alpha Context",
    "Description"    -> $waContextToolDescription,
    "Function"       -> relatedWolframAlphaPrompt,
    "LLMKit"         -> "Required",
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
(*relatedWolframAlphaPrompt*)
relatedWolframAlphaPrompt // beginDefinition;

relatedWolframAlphaPrompt[ context_ ] :=
    relatedWolframAlphaPrompt[ context, "Error" ];

relatedWolframAlphaPrompt[ context_, level_ ] :=
    relatedWolframAlphaPrompt[ context, level, llmKitSubscribedQ[ ] ];

relatedWolframAlphaPrompt[ context_, level_, True ] :=
    relatedWolframAlphaResults @ context;

relatedWolframAlphaPrompt[ context_, level_, False ] := Enclose[
    Module[ { info, url, connected, template },
        info      = ConfirmBy[ getLLMKitInfo[ ], AssociationQ, "LLMKitInfo" ];
        url       = ConfirmBy[ info[ "buyNowUrl" ], StringQ, "BuyNowURL" ];
        connected = ConfirmBy[ info[ "connected" ], BooleanQ, "Connected" ];
        template  = If[ connected, $wolframAlphaMissingLLMKitTemplate, $wolframAlphaNoCloudTemplate ];
        ConfirmBy[ TemplateApply[ template, <| "URL" -> url, "Level" -> level |> ], StringQ, "Result" ]
    ],
    throwInternalFailure
];

relatedWolframAlphaPrompt // endDefinition;


(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*relatedWolframAlphaResults*)
relatedWolframAlphaResults // beginDefinition;

relatedWolframAlphaResults[ KeyValuePattern[ "context" -> context_ ] ] :=
    relatedWolframAlphaResults @ context;

relatedWolframAlphaResults[ context_String ] := Enclose[
    Module[ { prompt },
        ConfirmMatch[ chatbookVersionCheck[ ], True, "ChatbookVersionCheck" ];
        prompt = ConfirmBy[ cb`RelatedWolframAlphaResults[ context, "Prompt" ], StringQ, "Prompt" ];
        StringTrim @ prompt
    ],
    throwInternalFailure
];

relatedWolframAlphaResults // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];