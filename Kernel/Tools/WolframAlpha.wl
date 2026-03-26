(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`AgentTools`Tools`WolframAlpha`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`AgentTools`"        ];
Needs[ "Wolfram`AgentTools`Common`" ];
Needs[ "Wolfram`AgentTools`Tools`"  ];

Needs[ "Wolfram`Chatbook`" -> "cb`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)

(* Cloud path root for deployed WA notebooks *)
$deployedNotebookRoot = "MCPServer/Notebooks";

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

wolframAlphaToolEvaluate[ as_ ] := (
    If[ TrueQ @ $clientSupportsUI && TrueQ @ $CloudConnected (* must be connected to deploy notebooks *),
        wolframAlphaToolEvaluateUI @ as,
        wolframAlphaToolEvaluate[ as, cb`$DefaultTools[ "WolframAlpha" ][ as ] ]
    ]
);

wolframAlphaToolEvaluate[ as_, result_String ] := extractWolframAlphaImages @ result;
wolframAlphaToolEvaluate[ as_, KeyValuePattern[ "String" -> result_String ] ] := extractWolframAlphaImages @ result;
wolframAlphaToolEvaluate // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*wolframAlphaToolEvaluateUI*)
wolframAlphaToolEvaluateUI // beginDefinition;

wolframAlphaToolEvaluateUI[ as_ ] :=
    Module[ { result, uiResult },

        result = Block[
            {
                (* Call Chatbook with $ChatNotebookEvaluation = True to get rich result *)
                cb`$ChatNotebookEvaluation = True,
                (* Set $CloudEvaluation to True since we're creating a notebook for the cloud *)
                $CloudEvaluation = True
            },
            cb`$DefaultTools[ "WolframAlpha" ][ as ]
        ];

        (* Try to create UI-enhanced result with cloud notebook *)
        uiResult = Quiet @ makeUIResult[ as, result ];

        (* If UI result succeeded, return it; otherwise fall back to standard behavior *)
        If[ MatchQ[ uiResult, KeyValuePattern[ "Content" -> { __Association } ] ],
            uiResult,
            wolframAlphaToolEvaluate[ as, result ]
        ]
    ];

wolframAlphaToolEvaluateUI // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*makeUIResult*)
makeUIResult // beginDefinition;

makeUIResult[ as_, KeyValuePattern[ { "Result" -> waResult_, "String" -> stringResult_String } ] ] := Enclose[
    Module[ { textContent, formatted, nb, query, target, deployed, notebookUrl },

        textContent = ConfirmMatch[
            toContentList @ extractWolframAlphaImages @ stringResult,
            { __Association },
            "TextContent"
        ];

        formatted = Block[
            {
                (* Format WA pods into notebook cells with FoldPods=True for compact display *)
                cb`$DefaultToolOptions = <| cb`$DefaultToolOptions, "WolframAlpha" -> <| "FoldPods" -> True |> |>,
                (* Set $CloudEvaluation to True since we're creating a notebook for the cloud *)
                $CloudEvaluation = True
            },
            Confirm[ cb`FormatWolframAlphaPods @ waResult, "Formatted" ]
        ];

        nb = Notebook @ {
            Cell[
                BoxData @ ToBoxes @ formatted,
                "Output",
                CellMargins     -> { { 20, 20 }, { 20, 20 } },
                FontColor       -> Black,
                ShowCellBracket -> False
            ]
        };

        query = ConfirmBy[ as[ "query" ], StringQ, "Query" ];

        target = ConfirmMatch[
            FileNameJoin @ {
                CloudObject[ $deployedNotebookRoot, Permissions -> { "All" -> { "Read", "Interact" } } ],
                "WolframAlpha",
                Hash[ query, Automatic, "HexString" ] <> ".nb"
            },
            _CloudObject,
            "Target"
        ];

        deployed = ConfirmMatch[
            CloudDeploy[
                nb,
                target,
                Permissions       -> { "All" -> { "Read", "Interact" } },
                AppearanceElements -> None,
                AutoRemove         -> True,
                IconRules          -> { }
            ],
            _CloudObject,
            "CloudDeploy"
        ];

        notebookUrl = ConfirmBy[ First @ deployed, StringQ, "NotebookURL" ];

        <| "Content" -> textContent, "_meta" -> <| "notebookUrl" -> notebookUrl |> |>
    ],
    throwInternalFailure
];

makeUIResult // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toContentList*)
toContentList // beginDefinition;
toContentList[ KeyValuePattern[ "Content" -> items_List ] ] := items;
toContentList[ items_List ] := items;
toContentList[ str_String ] := { <| "type" -> "text", "text" -> str |> };
toContentList // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
