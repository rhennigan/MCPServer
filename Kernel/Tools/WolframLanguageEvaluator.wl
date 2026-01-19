(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`WolframLanguageEvaluator`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];

Needs[ "Wolfram`Chatbook`" -> "cb`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)
$imageExportMethod      = "CloudPublic";
$cloudImagePath        := CloudObject[ "MCPServer/Images", Permissions -> $cloudImagePermissions ];
$cloudImagePermissions := If[ $imageExportMethod === "CloudPublic", "Public", "Private" ];
$line                   = 1;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompts*)
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

$markdownImageHint = "\
<system-reminder>The user does not see the images in the tool response. \
Use the markdown image in your response to show them.</system-reminder>";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definition*)
(* Add to $defaultMCPTools Association (initialized in Kernel/Tools/Tools.wl) *)
$defaultMCPTools[ "WolframLanguageEvaluator" ] := LLMTool @ <|
    "Name"        -> "WolframLanguageEvaluator",
    "DisplayName" -> "Wolfram Language Evaluator",
    "Description" -> $wolframLanguageEvaluatorToolDescription,
    "Function"    -> evaluateWolframLanguage,
    "Options"     -> { },
    "Parameters"  -> {
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
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*evaluateWolframLanguage*)
evaluateWolframLanguage // beginDefinition;

evaluateWolframLanguage[ KeyValuePattern @ { "code" -> code_, "timeConstraint" -> timeConstraint_ } ] :=
    evaluateWolframLanguage[ code, timeConstraint ];

evaluateWolframLanguage[ code_String, _Missing ] :=
    evaluateWolframLanguage[ code, 60 ];

evaluateWolframLanguage[ code_String, timeConstraint_Integer ] := Enclose[
    Module[ { string, exported },
        ConfirmMatch[ chatbookVersionCheck[ ], True, "ChatbookVersionCheck" ];
        string   = ConfirmBy[ evaluateWolframLanguage0[ code, timeConstraint ], StringQ, "Result" ];
        exported = ConfirmBy[ exportImages @ string, StringQ, "Result" ];
        StringTrim @ exported
    ],
    throwInternalFailure
];

evaluateWolframLanguage // endDefinition;


evaluateWolframLanguage0 // beginDefinition;

evaluateWolframLanguage0[ code_String, timeConstraint_Integer ] :=
    catchAlways @ cb`WolframLanguageToolEvaluate[
        code,
        "String",
        "Line"                  -> $line++,
        "MaxCharacterCount"     -> 10000,
        "AppendRetryNotice"     -> False,
        "AppendURIInstructions" -> False,
        "Method"                -> $evaluatorMethod,
        "TimeConstraint"        -> timeConstraint
    ];

evaluateWolframLanguage0 // endDefinition;


$evaluatorMethod :=
    With[ { method = Environment[ "WOLFRAM_LANGUAGE_EVALUATOR_METHOD" ] },
        If[ StringQ @ method && method =!= "", method, "Session" ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*exportImages*)
exportImages // beginDefinition;

exportImages[ str_String ] := Enclose[
    Module[ { content, hasImages, exported, result },

        content = ConfirmMatch[ cb`GetExpressionURIs @ str, { __ }, "Content" ];

        hasImages = False;
        exported = ConfirmMatch[
            Replace[ content, expr: Except[ _String ] :> (hasImages = True; exportImage @ expr), { 1 } ],
            { __String },
            "Exported"
        ];

        result = ConfirmBy[ StringJoin @ exported, StringQ, "Result" ];

        If[ TrueQ @ hasImages,
            result <> "\n\n" <> $markdownImageHint,
            result
        ]
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
(*Package Footer*)
End[ ];
EndPackage[ ];