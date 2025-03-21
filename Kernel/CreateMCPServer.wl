(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "RickHennigan`MCPServer`CreateMCPServer`" ];
Begin[ "`Private`" ];

Needs[ "RickHennigan`MCPServer`"        ];
Needs[ "RickHennigan`MCPServer`Common`" ];

(* TODO:
    - Add OverwriteTarget option
*)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
$serverVersion = "1.0.0";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*CreateMCPServer*)
CreateMCPServer // beginDefinition;

CreateMCPServer[ name_String ] :=
    catchMine @ CreateMCPServer[ name, $LLMEvaluator ];

CreateMCPServer[ name_String, evaluator_LLMConfiguration ] :=
    catchMine @ CreateMCPServer[ name, evaluator[ "Data" ] ];

CreateMCPServer[ name_String, evaluator_Association ] :=
    catchMine @ createMCPServer[ name, evaluator ];

CreateMCPServer // endExportedDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*createMCPServer*)
createMCPServer // beginDefinition;

createMCPServer[ name_String, evaluator_Association ] := Enclose[
    Module[ { dir, path, exported, data },
        dir = ConfirmMatch[ mcpServerPath @ name, File[ _String ], "Directory" ];
        dir = ConfirmBy[ GeneralUtilities`EnsureDirectory @ First @ dir, DirectoryQ, "Directory" ];
        path = FileNameJoin @ { dir, URLEncode @ name <> ".wxf" };
        data = <| "Name" -> name, "LLMEvaluator" -> evaluator, "Location" -> File @ dir, "Version" -> $serverVersion |>;
        exported = ConfirmBy[ Developer`WriteWXFFile[ path, data ], FileExistsQ, "Exported" ];
        ConfirmBy[ MCPServerObject @ data, MCPServerObjectQ, "MCPServerObject" ]
    ],
    throwInternalFailure
];

createMCPServer // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
