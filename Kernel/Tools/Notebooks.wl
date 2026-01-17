(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`Notebooks`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ReadNotebook*)
$defaultMCPTools[ "ReadNotebook" ] := LLMTool @ <|
    "Name"        -> "ReadNotebook",
    "DisplayName" -> "Read Notebook",
    "Description" -> "Reads the contents of a Wolfram notebook (.nb) as markdown text.",
    "Function"    -> readNotebook,
    "Options"     -> { },
    "Parameters"  -> {
        "notebook" -> <|
            "Interpreter" -> "String",
            "Help"        -> "The Wolfram notebook to read, specified as a file path or a NotebookObject[...]",
            "Required"    -> True
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WriteNotebook*)
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
(*readNotebook*)
readNotebook // beginDefinition;

readNotebook[ KeyValuePattern[ "notebook" -> notebook_ ] ] :=
    readNotebook @ notebook;

readNotebook[ file_String ] /; FileExistsQ @ file := Enclose[
    Catch @ Module[ { nb },
        nb = Import[ file, "NB" ];
        If[ ! MatchQ[ nb, _Notebook ], Throw[ "File is not a valid Wolfram notebook: " <> file ] ];
        ConfirmMatch[ chatbookVersionCheck[ ], True, "ChatbookVersionCheck" ];
        ConfirmBy[ exportMarkdownString @ nb, StringQ, "Result" ]
    ],
    throwInternalFailure
];

readNotebook[ nbo0_String ] := Enclose[
    Catch @ Module[ { held, nbo },
        held = Quiet @ ToExpression[ nbo0, InputForm, HoldComplete ];
        If[ ! MatchQ[ held, HoldComplete[ NotebookObject[ __String ] ] ],
            Throw[ "Invalid notebook specification: " <> nbo0 ]
        ];
        nbo = ConfirmMatch[ ReleaseHold @ held, NotebookObject[ __String ], "NotebookObject" ];
        ConfirmMatch[ chatbookVersionCheck[ ], True, "ChatbookVersionCheck" ];
        ConfirmBy[ exportMarkdownString @ nbo, StringQ, "Result" ]
    ],
    throwInternalFailure
];

readNotebook // endDefinition;

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