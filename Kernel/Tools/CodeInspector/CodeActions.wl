(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`CodeInspector`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "CodeParser`" -> "cp`"      ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*formatCodeActions*)
formatCodeActions // beginDefinition;

formatCodeActions[ { } ] := "";

formatCodeActions[ actions_List ] :=
    Module[ { formatted },
        formatted = StringTrim @ Select[ formatSingleCodeAction /@ actions, StringQ ];
        formatted = DeleteCases[ formatted, "" ];
        If[ formatted === { },
            "",
            StringJoin[
                "\n**Suggested Fix",
                If[ Length @ formatted > 1, "es", "" ],
                ":**\n",
                StringRiffle[ formatted, "\n" ]
            ]
        ]
    ];

formatCodeActions // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*formatSingleCodeAction*)
formatSingleCodeAction // beginDefinition;

(* Standard CodeAction with label, command, and data *)
formatSingleCodeAction[ cp`CodeAction[ label_String, command_, data_Association ] ] :=
    formatSingleCodeAction[ label, command, data ];

(* Handle without CodeParser` context prefix *)
formatSingleCodeAction[ HoldPattern[ cp`CodeAction ][ label_String, command_, data_Association ] ] :=
    formatSingleCodeAction[ label, command, data ];

(* Internal formatting function *)
formatSingleCodeAction[ label_String, command_, data_Association ] :=
    Module[ { details },
        details = extractActionDetails[ command, data ];
        StringJoin[ "- ", cleanLabel @ label, If[ StringQ @ details && details =!= "", " " <> details, "" ] ]
    ];

(* Fallback for malformed CodeActions *)
formatSingleCodeAction[ _ ] := "";

formatSingleCodeAction // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*cleanLabel*)

(* Clean up the label - preserve double backticks if code contains backticks, otherwise convert to single backticks *)
cleanLabel // beginDefinition;

cleanLabel[ label_String ] :=
    StringReplace[ label, "``" ~~ text: Shortest[ __ ] ~~ "``" /; StringFreeQ[ text, "`" ] :> "`" <> text <> "`" ];

cleanLabel // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*codeActionCommandToString*)
codeActionCommandToString // beginDefinition;

(* Text operations *)
codeActionCommandToString[ cp`ReplaceText ] := "Replace with";
codeActionCommandToString[ cp`DeleteText  ] := "Delete";
codeActionCommandToString[ cp`InsertText  ] := "Insert";

(* Node operations *)
codeActionCommandToString[ cp`ReplaceNode     ] := "Replace with";
codeActionCommandToString[ cp`DeleteNode      ] := "Delete";
codeActionCommandToString[ cp`InsertNode      ] := "Insert";
codeActionCommandToString[ cp`InsertNodeAfter ] := "Insert after";

(* Fallback *)
codeActionCommandToString[ cmd_ ] := ToString @ cmd;

codeActionCommandToString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*extractActionDetails*)

(* Extract additional details from CodeAction data *)
extractActionDetails // beginDefinition;

(* For ReplaceNode, try to show the replacement *)
extractActionDetails[ cp`ReplaceNode, data_Association ] :=
    Module[ { replacement },
        replacement = Lookup[ data, "ReplacementNode", None ];
        If[ replacement === None,
            "",
            nodeToString @ replacement
        ]
    ];

(* For InsertNode, try to show what will be inserted *)
extractActionDetails[ cp`InsertNode | cp`InsertNodeAfter, data_Association ] :=
    Module[ { insertion },
        insertion = Lookup[ data, "InsertionNode", None ];
        If[ insertion === None,
            "",
            nodeToString @ insertion
        ]
    ];

(* For delete operations, no additional details needed - the label says what's being deleted *)
extractActionDetails[ cp`DeleteNode | cp`DeleteText, _ ] := "";

(* Fallback - no additional details *)
extractActionDetails[ _, _ ] := "";

extractActionDetails // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*nodeToString*)

(* Convert a CodeParser node to a displayable string *)
nodeToString // beginDefinition;

(* LeafNode contains the actual text representation *)
nodeToString[ cp`LeafNode[ _, text_String, _ ] ] := "";  (* Label already contains this info *)
nodeToString[ HoldPattern[ LeafNode ][ _, text_String, _ ] ] := "";

(* For other nodes, return empty string (label already contains the info) *)
nodeToString[ node_ ] := "";

nodeToString // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
