(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "RickHennigan`MCPServer`CreateMCPServer`" ];
Begin[ "`Private`" ];

Needs[ "RickHennigan`MCPServer`"        ];
Needs[ "RickHennigan`MCPServer`Common`" ];

(* TODO:
    - Add OverwriteTarget option
    - Add IncludeDefinitions option
    - Support "Remote" type (deploy as cloud API)
*)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
$serverVersion      = "1.0.0";
$overwriteTarget    = False;
$includeDefinitions = True;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*CreateMCPServer*)
CreateMCPServer // beginDefinition;
CreateMCPServer // Options = {
    OverwriteTarget    -> $overwriteTarget,
    IncludeDefinitions -> $includeDefinitions
};

CreateMCPServer[ name_String, opts: OptionsPattern[ ] ] :=
    catchMine @ CreateMCPServer[ name, $LLMEvaluator, opts ];

CreateMCPServer[ name_String, evaluator_LLMConfiguration, opts: OptionsPattern[ ] ] :=
    catchMine @ CreateMCPServer[ name, evaluator[ "Data" ], opts ];

CreateMCPServer[ name_String, evaluator_Association, opts: OptionsPattern[ ] ] :=
    catchMine @ Block[
        {
            $overwriteTarget    = TrueQ @ OptionValue @ OverwriteTarget,
            $includeDefinitions = TrueQ @ OptionValue @ IncludeDefinitions
        },
        createMCPServer[ name, evaluator ]
    ];

CreateMCPServer // endExportedDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*createMCPServer*)
createMCPServer // beginDefinition;

createMCPServer[ name_String, evaluator_Association ] := Enclose[
    Module[ { dir, path, exported, data, wxf },

        dir = ConfirmMatch[ mcpServerPath @ name, File[ _String ], "Directory" ];
        dir = ConfirmBy[ GeneralUtilities`EnsureDirectory @ First @ dir, DirectoryQ, "Directory" ];
        path = FileNameJoin @ { dir, URLEncode @ name <> ".wxf" };

        If[ ! $overwriteTarget && FileExistsQ @ path, throwFailure[ "MCPServerExists", name, OverwriteTarget -> True ] ];

        data = <|
            "Name"         -> name,
            "LLMEvaluator" -> evaluator,
            "Location"     -> File @ dir,
            "Type"         -> "Local",
            "Version"      -> $serverVersion
        |>;

        wxf = ConfirmBy[
            If[ TrueQ @ $includeDefinitions, binarySerializeWithDefinitions @ data, BinarySerialize @ data ],
            ByteArrayQ,
            "WXF"
        ];

        exported = ConfirmBy[ Export[ path, wxf, "Binary" ], FileExistsQ, "Exported" ];

        ConfirmBy[ MCPServerObject @ data, MCPServerObjectQ, "MCPServerObject" ]
    ],
    throwInternalFailure
];

createMCPServer // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*binarySerializeWithDefinitions*)
binarySerializeWithDefinitions // beginDefinition;
binarySerializeWithDefinitions[ data_Association ] := binarySerializeWithDefinitions0 @ unpackNoEntry @ data;
binarySerializeWithDefinitions // endDefinition;

importResourceFunction[ binarySerializeWithDefinitions0, "BinarySerializeWithDefinitions" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*unpackNoEntry*)
unpackNoEntry // beginDefinition;

unpackNoEntry[ as_Association ] :=
    Module[ { h },
        SetAttributes[ h, HoldAllComplete ];
        as /. e: f_[ a___ ] /; System`Private`HoldNoEntryQ @ e :> h[ f ][ a ] /. h[ f_ ] :> f
    ];

unpackNoEntry // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    Null
];

End[ ];
EndPackage[ ];
