(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`ReadNotebook`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definition*)
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
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];