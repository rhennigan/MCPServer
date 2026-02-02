(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`WolframLanguageEvaluator`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"          ];
Needs[ "Wolfram`MCPServer`Common`"   ];
Needs[ "Wolfram`MCPServer`Graphics`" ];
Needs[ "Wolfram`MCPServer`Tools`"    ];

Needs[ "Wolfram`Chatbook`" -> "cb`" ];

System`HoldCompleteForm;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)
$cloudImagePath        := CloudObject[ "MCPServer/Images", Permissions -> $cloudImagePermissions ];
$cloudImagePermissions := If[ $imageExportMethod === "CloudPublic", "Public", "Private" ];
$line                   = 1;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Environment Variable Configuration*)
$evaluatorMethod := $evaluatorMethod =
    With[ { method = Environment[ "WOLFRAM_LANGUAGE_EVALUATOR_METHOD" ] },
        If[ StringQ @ method && method =!= "", method, "Session" ]
    ];

$imageExportMethod := $imageExportMethod =
    With[ { method = Environment[ "WOLFRAM_LANGUAGE_EVALUATOR_IMAGE_EXPORT_METHOD" ] },
        If[ StringQ @ method && method =!= "", method, "None" ]
    ];

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
        exported = ConfirmBy[ exportImages @ string, AssociationQ, "Exported" ];
        exported  (* Return the structured content *)
    ],
    throwInternalFailure
];

evaluateWolframLanguage // endDefinition;


evaluateWolframLanguage0 // beginDefinition;
(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)
evaluateWolframLanguage0[ code_String, timeConstraint_Integer ] :=
    Block[ (* FIXME: Expose this as an option in WolframLanguageToolEvaluate *)
        { Wolfram`Chatbook`Sandbox`Private`$includeDefinitions = False },
            catchAlways @ cb`WolframLanguageToolEvaluate[
            code,
            "String",
            "Line"                  -> $line++,
            "MaxCharacterCount"     -> 10000,
            "AppendRetryNotice"     -> False,
            "AppendURIInstructions" -> False,
            "Method"                -> $evaluatorMethod,
            "TimeConstraint"        -> timeConstraint
        ]
    ];
(* :!CodeAnalysis::EndBlock:: *)
evaluateWolframLanguage0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*exportImages*)
exportImages // beginDefinition;

exportImages[ str_String ] := Enclose[
    Module[ { parts, hasImages, contentItems },

        parts = ConfirmMatch[ cb`GetExpressionURIs @ str, { __ }, "Parts" ];

        hasImages = False;
        contentItems = Flatten @ Map[
            Function[ item,
                If[ StringQ @ item,
                    (* Text segment: create text content *)
                    { <| "type" -> "text", "text" -> item |> },
                    (* Graphics: create text content (with cloud URL) + image content (base64) *)
                    hasImages = True;
                    Module[ { cloudURL, imageContent },
                        cloudURL = ConfirmMatch[ exportImage @ item, _String|None, "CloudURL" ];  (* Returns "![Image](url)" *)
                        imageContent = graphicsToImageContent @ item;
                        Flatten @ {
                            If[ StringQ @ cloudURL, <| "type" -> "text", "text" -> cloudURL |>, Nothing ],
                            If[ AssociationQ @ imageContent, imageContent, Nothing ]
                        }
                    ]
                ]
            ],
            parts
        ];

        (* Append the image hint reminder if there were images *)
        If[ TrueQ @ hasImages && $imageExportMethod =!= "None",
            AppendTo[ contentItems, <| "type" -> "text", "text" -> "\n\n" <> $markdownImageHint |> ]
        ];

        <| "Content" -> ConfirmMatch[ contentItems, { __Association }, "ContentItems" ] |>
    ],
    throwInternalFailure
];

exportImages // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*exportImage*)
exportImage // beginDefinition;

exportImage[ expr_ ] := exportImage[ expr, $imageExportMethod ];

exportImage[ expr_, "Local" ] := Enclose[
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

exportImage[ expr_, "Cloud"|"CloudPublic" ] := Enclose[
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

exportImage[ expr_, _ ] := None;

exportImage // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Utilities*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*useEvaluatorKernel*)
useEvaluatorKernel // beginDefinition;
useEvaluatorKernel // Attributes = { HoldAllComplete };

(* Used for evaluations that need to be run in the same kernel as the evaluator tool (e.g. symbol definitions) *)
useEvaluatorKernel[ eval_ ] :=
    If[ $evaluatorMethod === "Local",
        evaluateInLocalKernel @ eval,
        eval
    ];

useEvaluatorKernel // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*evaluateInLocalKernel*)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

evaluateInLocalKernel // beginDefinition;

evaluateInLocalKernel[ eval_ ] :=
    Block[ (* FIXME: Expose this as an option in WolframLanguageToolEvaluate *)
        { Wolfram`Chatbook`Sandbox`Private`$includeDefinitions = False },
        evaluateInLocalKernel0 @ eval
    ];

evaluateInLocalKernel // endDefinition;


evaluateInLocalKernel0 // beginDefinition;
evaluateInLocalKernel0 // Attributes = { HoldAllComplete };

evaluateInLocalKernel0[ eval_ ] := Enclose[
    Module[ { heldResult, result },
        ConfirmMatch[ initializePacletInLocalKernel[ ], Null, "InitializePacletInLocalKernel" ];

        heldResult = cb`WolframLanguageToolEvaluate[
            HoldComplete @ WithCleanup[

                Block[ { $catching = True },
                    (* Since this is in another kernel, thrown errors won't propagate back to the top-level,
                        so we need to catch and identify them here to send them to the top if needed. *)
                    Catch[ eval, _, caughtWrapper ]
                ],

                (* Roll back the line number, since this isn't part of a tool evaluation *)
                $Line--
            ],
            "Result",
            "Method" -> "Local"
        ];

        result = Replace[
            heldResult,
            {
                (* Throw failures to the top-level *)
                (HoldForm|HoldCompleteForm)[ caughtWrapper[ failure_Failure, $catchTopTag ] ] :> throwFailure @ failure,
                (* Otherwise, release the hold *)
                (HoldForm|HoldCompleteForm)[ r_ ] :> r
            }
        ];

        result
    ],
    throwInternalFailure
];

evaluateInLocalKernel0 // endDefinition;

caughtWrapper // Attributes = { HoldAllComplete };

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*initializePacletInLocalKernel*)
initializePacletInLocalKernel // beginDefinition;

initializePacletInLocalKernel[ ] := Enclose[
    Module[ { pacletDir, result },
        pacletDir = ConfirmMatch[ $thisPaclet[ "Location" ], _? DirectoryQ, "PacletDir" ];

        result = With[ { dir = pacletDir },
            cb`WolframLanguageToolEvaluate[
                HoldComplete @ WithCleanup[
                    PacletDirectoryLoad @ dir;
                    Block[ { $ContextPath }, Get[ "Wolfram`MCPServer`" ] ],
                    $Line--
                ],
                "Result",
                "Method" -> "Local"
            ]
        ];

        initializePacletInLocalKernel[ ] = ConfirmMatch[ ReleaseHold @ result, Null, "Result" ]
    ],
    throwInternalFailure
];

initializePacletInLocalKernel // endDefinition;

(* :!CodeAnalysis::EndBlock:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];