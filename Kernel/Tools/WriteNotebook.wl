(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`WriteNotebook`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definition*)
$defaultMCPTools[ "WriteNotebook" ] := LLMTool @ <|
    "Name"        -> "WriteNotebook",
    "DisplayName" -> "Write Notebook",
    "Description" -> "Converts markdown text to a Wolfram notebook and saves it to a file.",
    "Function"    -> writeNotebook,
    "Options"     -> { },
    "Parameters"  -> {
        "file" -> <|
            "Interpreter" -> "String",
            "Help"        -> "The file to write the notebook to (must end in .nb).",
            "Required"    -> True
        |>,
        "overwrite" -> <|
            "Interpreter" -> "Boolean",
            "Help"        -> "Whether to overwrite an existing file (default is False).",
            "Required"    -> False
        |>,
        "markdown" -> <|
            "Interpreter" -> "String",
            "Help"        -> "The markdown text to write to a notebook.",
            "Required"    -> True
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*writeNotebook*)
writeNotebook // beginDefinition;

writeNotebook[ KeyValuePattern @ { "markdown" -> markdown_, "file" -> file_, "overwrite" -> overwrite_ } ] :=
    writeNotebook[ markdown, file, TrueQ @ overwrite ];

writeNotebook[ markdown_String, file_String, overwrite: True|False ] := Enclose[
    Catch @ Module[ { nb },
        If[ FileExistsQ @ file && ! overwrite, Throw[ "File already exists: " <> file ] ];
        ConfirmMatch[ chatbookVersionCheck[ ], True, "ChatbookVersionCheck" ];
        nb = ConfirmMatch[ importMarkdownString[ markdown, "Notebook" ], _Notebook, "Notebook" ];
        ConfirmBy[ Export[ file, nb, "NB" ], FileExistsQ, "File" ]
    ],
    throwInternalFailure
];

writeNotebook // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];