(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Prompts`Notebook`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"         ];
Needs[ "Wolfram`MCPServer`Common`"  ];
Needs[ "Wolfram`MCPServer`Prompts`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompt Descriptions*)
$notebookDescription =
    "Attaches the contents of a Wolfram notebook to the conversation context.";

$notebookArguments = {
    <|
        "Name"        -> "path",
        "Description" -> "Path to the notebook file (.nb)",
        "Required"    -> True
    |>
};

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompt Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Notebook*)
$defaultMCPPrompts[ "Notebook" ] := <|
    "Name"        -> "Notebook",
    "Description" -> $notebookDescription,
    "Arguments"   -> $notebookArguments,
    "Type"        -> "Function",
    "Content"     -> generateNotebookPrompt
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*formatNotebookPrompt*)
formatNotebookPrompt // beginDefinition;

formatNotebookPrompt[ path_String, markdown_String ] :=
    StringJoin[
        "<notebook-path>", path, "</notebook-path>\n",
        "<notebook-content>\n",
        markdown, "\n",
        "</notebook-content>"
    ];

formatNotebookPrompt // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*generateNotebookPrompt*)
generateNotebookPrompt // beginDefinition;

generateNotebookPrompt[ KeyValuePattern[ "path" -> path_String ] ] :=
    generateNotebookPrompt @ path;

generateNotebookPrompt[ path_String ] := Enclose[
    Catch @ Module[ { nb, markdown },
        If[ ! StringEndsQ[ path, ".nb", IgnoreCase -> True ],
            Throw[ "[Error] File is not a notebook (.nb): " <> path ]
        ];
        If[ ! FileExistsQ @ path,
            Throw[ "[Error] File does not exist: " <> path ]
        ];
        nb = Import[ path, "NB" ];
        If[ ! MatchQ[ nb, _Notebook ],
            Throw[ "[Error] File is not a valid Wolfram notebook: " <> path ]
        ];
        ConfirmMatch[ chatbookVersionCheck[ ], True, "ChatbookVersionCheck" ];
        markdown = ConfirmBy[ exportMarkdownString @ nb, StringQ, "Result" ];
        formatNotebookPrompt[ path, markdown ]
    ],
    throwInternalFailure
];

generateNotebookPrompt // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
