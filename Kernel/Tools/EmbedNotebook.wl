(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`EmbedNotebook`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompts*)
$embedNotebookDescription = "\
Embed an interactive Wolfram Cloud notebook inline. Provide a cloud notebook URL and the notebook will be rendered \
using the Wolfram Notebook Embedder, allowing the user to view and interact with the notebook directly.";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definition*)
(* Add to $defaultMCPTools Association (initialized in Kernel/Tools/Tools.wl) *)
$defaultMCPTools[ "EmbedNotebook" ] := LLMTool @ <|
    "Name"        -> "EmbedNotebook",
    "DisplayName" -> "Embed Notebook",
    "Description" -> $embedNotebookDescription,
    "Function"    -> embedNotebookEvaluate,
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
(*embedNotebookEvaluate*)
embedNotebookEvaluate // beginDefinition;

embedNotebookEvaluate[ args_Association ] := Enclose[
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

embedNotebookEvaluate // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
