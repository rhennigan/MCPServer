(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "RickHennigan`MCPServer`DefaultServers`" ];
Begin[ "`Private`" ];

Needs[ "RickHennigan`MCPServer`"        ];
Needs[ "RickHennigan`MCPServer`Common`" ];

Needs[ "RickHennigan`MCPServer`CreateMCPServer`" -> None ];
Needs[ "Wolfram`Chatbook`" -> "cb`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
$defaultMCPServer       = "Wolfram";
$imageExportMethod      = "CloudPublic";
$cloudImagePath        := CloudObject[ "MCPServer/Images", Permissions -> $cloudImagePermissions ];
$cloudImagePermissions := If[ $imageExportMethod === "CloudPublic", "Public", "Private" ];
$line                   = 1;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Prompts*)
$wolframAlphaToolDescription = StringJoin[
    cb`$DefaultTools[ "WolframAlpha" ][ "Description" ],
    "\n",
    "Always use the Wolfram context tool before using this tool to make sure you have the most up-to-date information."
];

$wolframLanguageEvaluatorToolDescription = "\
Evaluates Wolfram Language code for the user in a Wolfram Language kernel.
The user does not automatically see the result, so you must include the result in your response \
in order for them to see it.
If a formatted result is provided as a markdown link, use that in your response instead of typing out the output.
Do not ask permission to evaluate code.
You have read access to local files.
Parse natural language input with `\[FreeformPrompt][\"query\"]`, which is analogous to ctrl-= input in notebooks.
Natural language input is parsed before evaluation, so it works like macro expansion.
You should ALWAYS use this natural language input to obtain things like `Quantity`, `DateObject`, `Entity`, etc.
\[FreeformPrompt] should be written as \\uf351 in JSON.
Always use the Wolfram context tool before using this tool to make sure you have the most up-to-date information.";

$wolframContextToolDescription = "\
Uses semantic search to retrieve any relevant information from Wolfram. Always use this tool at the start of \
new conversations or if the topic changes to ensure you have up-to-date relevant information. This uses semantic \
search, so the context argument should be written in natural language (not a search query) and contain as much detail \
as possible.";

$waContextToolDescription = "\
Uses semantic search to retrieve any relevant information from Wolfram Alpha. Always use this tool at the start of \
new conversations or if the topic changes to ensure you have up-to-date relevant information. This uses semantic \
search, so the context argument should be written in natural language (not a search query) and contain as much detail \
as possible.";

$wlContextToolDescription = "\
Uses semantic search to retrieve information from various sources that can be used to help write Wolfram Language \
code. Always use this tool at the start of new conversations or if the topic changes to ensure you have up-to-date \
relevant information. This uses semantic search, so the context argument should be written in natural language \
(not a search query) and contain as much detail as possible.";

$documentationPromptHeader = "\
IMPORTANT: Here are some Wolfram documentation snippets that you should use to respond.\n\n======\n\n";

$snippetTemplate = StringTemplate[ "<result url='`URI`'>\n\n`Text`\n\n</result>" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Standard Tools*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframAlpha*)
$wolframAlphaTool = LLMTool[
    { "WolframAlpha", $wolframAlphaToolDescription },
    { "query" -> <| "Interpreter" -> "String", "Help" -> "the input", "Required" -> True |> },
    cb`$DefaultTools[ "WolframAlpha" ][ "Function" ]
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframLanguageEvaluator*)
$wolframLanguageEvaluatorTool = LLMTool[
    { "WolframLanguageEvaluator", $wolframLanguageEvaluatorToolDescription },
    {
        "code" -> <|
            "Interpreter" -> "String",
            "Help"        -> "The Wolfram Language code to evaluate.",
            "Required"    -> True
        |>,
        "timeConstraint" -> <|
            "Interpreter" -> "Integer",
            "Help"        -> "The time constraint for the evaluation (default is 60 seconds).",
            "Required"    -> False
        |>
    },
    evaluateWolframLanguage
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*evaluateWolframLanguage*)
evaluateWolframLanguage // beginDefinition;

evaluateWolframLanguage[ KeyValuePattern @ { "code" -> code_, "timeConstraint" -> timeConstraint_ } ] :=
    evaluateWolframLanguage[ code, timeConstraint ];

evaluateWolframLanguage[ code_String, _Missing ] :=
    evaluateWolframLanguage[ code, 60 ];

evaluateWolframLanguage[ code_String, timeConstraint_Integer ] := Enclose[
    Module[ { string, exported },
        string   = ConfirmBy[ evaluateWolframLanguage0[ code, timeConstraint ], StringQ, "Result" ];
        exported = ConfirmBy[ exportImages @ string, StringQ, "Result" ];
        StringTrim @ exported
    ],
    throwInternalFailure
];

evaluateWolframLanguage // endDefinition;


evaluateWolframLanguage0 // beginDefinition;

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
evaluateWolframLanguage0[ code_String, timeConstraint_Integer ] :=
    Block[
        {
            Wolfram`Chatbook`Sandbox`Private`$evaluatorMethod          = "Session",
            Wolfram`Chatbook`Sandbox`Private`appendURIInstructions     = # &,
            Wolfram`Chatbook`Sandbox`Private`appendRetryNotice         = # &,
            Wolfram`Chatbook`Common`$toolResultStringLength            = 10000,
            Wolfram`Chatbook`Sandbox`Private`$sandboxEvaluationTimeout = timeConstraint,
            $Line = $line++
        },
        Wolfram`Chatbook`Common`catchTop @ Wolfram`Chatbook`Common`sandboxEvaluate[ code ][ "String" ]
    ];
(* :!CodeAnalysis::EndBlock:: *)

evaluateWolframLanguage0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*exportImages*)
exportImages // beginDefinition;

exportImages[ str_String ] := Enclose[
    Module[ { content, exported },

        content = ConfirmMatch[ cb`GetExpressionURIs @ str, { __ }, "Content" ];

        exported = ConfirmMatch[
            Replace[ content, expr: Except[ _String ] :> exportImage @ expr, { 1 } ],
            { __String },
            "Exported"
        ];

        ConfirmBy[ StringJoin @ exported, StringQ, "Result" ]
    ],
    throwInternalFailure
];

exportImages // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*exportImage*)
exportImage // beginDefinition;

exportImage[ expr_ ] /; $imageExportMethod === "Local" := Enclose[
    Module[ { hash, file, png, lo, uri },
        hash = ConfirmBy[ Hash[ expr, Automatic, "HexString" ], StringQ, "Hash" ];
        file = ConfirmBy[ fileNameJoin[ $imagePath, StringTake[ hash, 3 ], hash <> ".png" ], fileQ, "File" ];
        png  = ConfirmBy[ Export[ file, expr, "PNG" ], FileExistsQ, "PNG" ];
        lo   = ConfirmMatch[ LocalObject @ png, HoldPattern @ LocalObject[ _String, ___ ], "LocalObject" ];
        uri  = ConfirmBy[ First @ lo, StringQ, "URI" ];
        "![Image]("<>uri<>")"
    ],
    throwInternalFailure
];

exportImage[ expr_ ] := Enclose[
    Module[ { hash, root, file, png, uri },

        hash = ConfirmBy[ Hash[ expr, Automatic, "HexString" ], StringQ, "Hash" ];
        root = ConfirmMatch[ $cloudImagePath, CloudObject[ _String, ___ ], "Root" ];

        file = ConfirmMatch[
            FileNameJoin @ { root, StringTake[ hash, 3 ], hash <> ".png" },
            _CloudObject,
            "File"
        ];

        png = ConfirmBy[ Export[ file, expr, "PNG" ], FileExistsQ, "PNG" ];

        uri = First @ ConfirmMatch[
            CloudObject[ png, CloudObjectNameFormat -> "UUID" ],
            CloudObject[ _String, ___ ],
            "URI"
        ];

        "![Image]("<>uri<>")"
    ],
    throwInternalFailure
];

exportImage // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*RAG Tools*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframContext*)
$wolframContextTool = LLMTool[
    { "WolframContext", $wolframContextToolDescription },
    {
        "context" -> <|
            "Interpreter" -> "String",
            "Help"        -> "A detailed summary of what the user is trying to achieve or learn about.",
            "Required"    -> True
        |>
    },
    relatedWolframContext
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*relatedWolframContext*)
relatedWolframContext // beginDefinition;

relatedWolframContext[ KeyValuePattern[ "context" -> context_ ] ] :=
    relatedWolframContext @ context;

relatedWolframContext[ context_String ] := Enclose[
    Module[ { waPrompt, wlPrompt },
        waPrompt = ConfirmBy[ relatedWolframAlphaResults @ context, StringQ, "WolframAlphaPrompt" ];
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
$wolframAlphaContextTool = LLMTool[
    { "WolframAlphaContext", $waContextToolDescription },
    {
        "context" -> <|
            "Interpreter" -> "String",
            "Help"        -> "A detailed summary of what the user is trying to achieve or learn about.",
            "Required"    -> True
        |>
    },
    relatedWolframAlphaResults
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*relatedWolframAlphaResults*)
relatedWolframAlphaResults // beginDefinition;

relatedWolframAlphaResults[ KeyValuePattern[ "context" -> context_ ] ] :=
    relatedWolframAlphaResults @ context;

relatedWolframAlphaResults[ context_String ] := Enclose[
    Module[ { prompt },
        prompt = ConfirmBy[ cb`RelatedWolframAlphaResults[ context, "Prompt" ], StringQ, "Prompt" ];
        StringTrim @ prompt
    ],
    throwInternalFailure
];

relatedWolframAlphaResults // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframLanguageContext*)
$wolframLanguageContextTool = LLMTool[
    { "WolframLanguageContext", $wlContextToolDescription },
    {
        "context" -> <|
            "Interpreter" -> "String",
            "Help"        -> "A detailed summary of what the user is trying to achieve or learn about.",
            "Required"    -> True
        |>
    },
    relatedDocumentation
];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*relatedDocumentation*)
relatedDocumentation // beginDefinition;

relatedDocumentation[ KeyValuePattern[ "context" -> context_ ] ] :=
    relatedDocumentation @ context;

relatedDocumentation[ context_String ] := Enclose[
    Module[ { prompt, formatted },

        prompt = ConfirmBy[ cb`RelatedDocumentation[ context, "Prompt", "PromptHeader" -> False ], StringQ, "Prompt" ];

        formatted = If[ StringTrim @ prompt === "",
                        "",
                        $documentationPromptHeader <> formatDocumentationSnippets @ prompt
                    ];

        ConfirmBy[ formatted, StringQ, "Result" ]
    ],
    throwInternalFailure
];

relatedDocumentation // endDefinition;

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
(*$DefaultMCPServers*)
$DefaultMCPServers := $DefaultMCPServers = MCPServerObject /@ $defaultMCPServers;

$defaultMCPServers = <| |>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Wolfram*)
$defaultMCPServers[ "Wolfram" ] = <|
    "Name"          -> "Wolfram",
    "Location"      -> "BuiltIn",
    "Transport"     -> "StandardInputOutput",
    "ServerVersion" -> "1.0.0",
    "ObjectVersion" -> $objectVersion,
    "LLMEvaluator"  -> <|
        "Tools" -> {
            $wolframContextTool,
            $wolframLanguageEvaluatorTool,
            $wolframAlphaTool
        }
    |>
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframAlpha*)
$defaultMCPServers[ "WolframAlpha" ] = <|
    "Name"          -> "WolframAlpha",
    "Location"      -> "BuiltIn",
    "Transport"     -> "StandardInputOutput",
    "ServerVersion" -> "1.0.0",
    "ObjectVersion" -> $objectVersion,
    "LLMEvaluator"  -> <|
        "Tools" -> {
            $wolframAlphaContextTool,
            $wolframAlphaTool
        }
    |>
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframLanguage*)
$defaultMCPServers[ "WolframLanguage" ] = <|
    "Name"          -> "WolframLanguage",
    "Location"      -> "BuiltIn",
    "Transport"     -> "StandardInputOutput",
    "ServerVersion" -> "1.0.0",
    "ObjectVersion" -> $objectVersion,
    "LLMEvaluator"  -> <|
        "Tools" -> {
            $wolframLanguageContextTool,
            $wolframLanguageEvaluatorTool
        }
    |>
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    $DefaultMCPServers
];

End[ ];
EndPackage[ ];
