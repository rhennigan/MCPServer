(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`Context`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];

Needs[ "Wolfram`Chatbook`" -> "cb`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompts*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframContext*)
$wolframContextToolDescription = "\
Uses semantic search to retrieve any relevant information from Wolfram. Always use this tool at the start of \
new conversations or if the topic changes to ensure you have up-to-date relevant information. This uses semantic \
search, so the context argument should be written in natural language (not a search query) and contain as much detail \
as possible (up to 250 words).";

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframAlphaContext*)
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
(* ::Subsection::Closed:: *)
(*WolframLanguageContext*)
$wlContextToolDescription = "\
Uses semantic search to retrieve information from various sources that can be used to help write Wolfram Language \
code. Always use this tool at the start of new conversations or if the topic changes to ensure you have up-to-date \
relevant information. This uses semantic search, so the context argument should be written in natural language \
(not a search query) and contain as much detail as possible.";

$documentationPromptHeader = "\
IMPORTANT: Here are some Wolfram documentation snippets that you should use to respond:\n\n";

$snippetTemplate = StringTemplate[ "<result url='`URI`'>\n\n`Text`\n\n</result>" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definitions*)

(* Add to $defaultMCPTools Association (initialized in Kernel/Tools/Tools.wl) *)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframContext*)
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
(* ::Subsection::Closed:: *)
(*WolframAlphaContext*)
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
(* ::Subsection::Closed:: *)
(*WolframLanguageContext*)
$defaultMCPTools[ "WolframLanguageContext" ] := LLMTool @ <|
    "Name"           -> "WolframLanguageContext",
    "DisplayName"    -> "Wolfram Language Context",
    "Description"    -> $wlContextToolDescription,
    "Function"       -> relatedDocumentation,
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
(* ::Subsection::Closed:: *)
(*relatedDocumentation*)
relatedDocumentation // beginDefinition;

relatedDocumentation[ KeyValuePattern[ "context" -> context_ ] ] :=
    relatedDocumentation @ context;

relatedDocumentation[ context_String ] := Enclose[
    Module[ { prompt, formatted },

        ConfirmMatch[ chatbookVersionCheck[ ], True, "ChatbookVersionCheck" ];

        prompt = ConfirmBy[ relatedDocumentation0 @ context, StringQ, "Prompt" ];

        formatted = If[ StringTrim @ prompt === "",
                        "",
                        $documentationPromptHeader <> formatDocumentationSnippets @ prompt
                    ];

        ConfirmBy[ formatted, StringQ, "Result" ]
    ],
    throwInternalFailure
];

relatedDocumentation // endDefinition;


relatedDocumentation0 // beginDefinition;

relatedDocumentation0[ context_ ] :=
    relatedDocumentation0[ context, llmKitSubscribedQ[ ] ];

relatedDocumentation0[ context_, True ] :=
    Block[ { $EvaluationEnvironment = "Script" },
        cb`RelatedDocumentation[ context, "Prompt", "PromptHeader" -> False, "FilterResults" -> True, MaxItems -> 50 ]
    ];

relatedDocumentation0[ context_, False ] :=
    Block[ { $EvaluationEnvironment = "Script" },
        cb`RelatedDocumentation[ context, "Prompt", "PromptHeader" -> False, "FilterResults" -> False, MaxItems -> 10 ]
    ];

relatedDocumentation0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatDocumentationSnippets*)
formatDocumentationSnippets // beginDefinition;

formatDocumentationSnippets[ s_String ] := Enclose[
    Module[ { string },
        string = ConfirmBy[
            If[ StringContainsQ[ s, "\n\n======\n\n" ],
                formatDocumentationSnippets @ StringSplit[ s, "\n======\n" ],
                s
            ],
            StringQ,
            "String"
        ];

        StringReplace[
            string,
            {
                Shortest[ "\\!\\(\\*MarkdownImageBox[\"![" ~~ label: Except[ "]" ]... ~~ "](" ~~ __ ~~ ")\"]\\)" ] :>
                    "Image[...]",

                Shortest[ "[" ~~ label: Except[ "]" ]... ~~ "](paclet:" ~~ uri: Except[ ")" ].. ~~ ")" ] :>
                    "["<>label<>"](https://reference.wolfram.com/language/"<>uri<>")"
            }
        ]
    ],
    throwInternalFailure
];

formatDocumentationSnippets[ snippets: { __String } ] := Enclose[
	StringRiffle[
        ConfirmMatch[ toSnippetString /@ snippets, { __String }, "SnippetStrings" ],
        "\n\n"
    ],
    throwInternalFailure
];

formatDocumentationSnippets // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toSnippetString*)
toSnippetString // beginDefinition;

toSnippetString[ snippet_String ] :=
    toSnippetString @ StringSplit[ StringTrim @ snippet, s: "\n".. :> s ];

toSnippetString[ { header_, "\n", uri0_String, rest___String } ] /; StringContainsQ[ uri0, ":" ] := Enclose[
    Module[ { uri, text },
        uri  = ConfirmBy[ toDocumentationURL @ uri0, StringQ, "URI" ];
        text = ConfirmBy[ header <> "\n\n" <> StringTrim @ StringJoin @ rest, StringQ, "Text" ];
        ConfirmBy[ TemplateApply[ $snippetTemplate, <| "URI" -> uri, "Text" -> text |> ], StringQ, "Result" ]
    ],
    throwInternalFailure
];

toSnippetString[ { other__String } ] :=
    StringTrim @ StringJoin @ other;

toSnippetString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*toDocumentationURL*)
toDocumentationURL // beginDefinition;

toDocumentationURL[ uri_String ] := StringReplace[
    uri,
    StartOfString~~"paclet:" -> "https://reference.wolfram.com/language/"
];

toDocumentationURL // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];