(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`AgentTools`Tools`NotebookViewer`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`AgentTools`"        ];
Needs[ "Wolfram`AgentTools`Common`" ];
Needs[ "Wolfram`AgentTools`Tools`"  ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompts*)
$notebookViewerDescription = "\
View an interactive Wolfram Cloud notebook inline. Provide a cloud notebook URL and the notebook will be rendered \
using the Wolfram Notebook Embedder, allowing the user to view and interact with the notebook directly.";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definition*)
(* Add to $defaultMCPTools Association (initialized in Kernel/Tools/Tools.wl) *)
$defaultMCPTools[ "NotebookViewer" ] := LLMTool @ <|
    "Name"        -> "NotebookViewer",
    "DisplayName" -> "Notebook Viewer",
    "Description" -> $notebookViewerDescription,
    "Function"    -> notebookViewerEvaluate,
    "Options"     -> { },
    "Parameters"  -> {
        "url" -> <|
            "Interpreter" -> "String",
            "Help"        -> "The Wolfram Cloud notebook URL to embed.",
            "Required"    -> True
        |>,
        "allowInteract" -> <|
            "Interpreter" -> "Boolean",
            "Help"        -> "Whether to enable interactivity in the embedded notebook (default: true).",
            "Required"    -> False
        |>,
        "maxHeight" -> <|
            "Interpreter" -> "Integer",
            "Help"        -> "Maximum height in pixels. If omitted, the notebook sizes to fit its content.",
            "Required"    -> False
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*notebookViewerEvaluate*)
notebookViewerEvaluate // beginDefinition;

notebookViewerEvaluate[ args_Association ] := Enclose[
    Module[ { url, allowInteract, maxHeight, responseData, json },
        url            = ConfirmBy[ args[ "url" ], StringQ, "URL" ];
        allowInteract  = Replace[ args[ "allowInteract" ], Except[ True | False ] -> True ];
        maxHeight      = Replace[ args[ "maxHeight" ], Except[ _Integer?Positive ] -> Automatic ];
        responseData   = <|
            "url"            -> url,
            "allowInteract"  -> allowInteract,
            If[ IntegerQ @ maxHeight, "maxHeight" -> maxHeight, Nothing ]
        |>;
        json = ConfirmBy[ Developer`WriteRawJSONString @ responseData, StringQ, "JSON" ];
        <| "Content" -> { <| "type" -> "text", "text" -> json |> } |>
    ],
    throwInternalFailure
];

notebookViewerEvaluate // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
