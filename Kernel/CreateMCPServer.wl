(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "RickHennigan`MCPServer`CreateMCPServer`" ];
Begin[ "`Private`" ];

Needs[ "RickHennigan`MCPServer`"        ];
Needs[ "RickHennigan`MCPServer`Common`" ];

(* TODO:
    - Support "Remote" type (deploy as cloud API)
    - Add Initialization option
    - Add developer mode option to start from script instead
*)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
$serverVersion      = "1.0.0";
$objectVersion      = 1;
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
    Module[ { path, data, wxf, exported },

        path = ConfirmBy[ mcpServerFile @ name, fileQ, "Path" ];
        If[ ! $overwriteTarget && FileExistsQ @ path,
            throwFailure[ "MCPServerExists", name, OverwriteTarget -> True ]
        ];

        data = ConfirmBy[ createMCPServerData[ name, evaluator ], AssociationQ, "Data" ];

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
(*createMCPServerData*)
createMCPServerData // beginDefinition;

createMCPServerData[ name_String, evaluator_Association ] := Enclose[
    Module[ { dir, validated },
        dir = ConfirmBy[ ensureDirectory @ mcpServerDirectory @ name, directoryQ, "Directory" ];
        validated = catchAlways @ validateMCPServerObjectData @ <|
            "Name"          -> name,
            "LLMEvaluator"  -> evaluator,
            "Location"      -> dir,
            "Transport"     -> "StandardInputOutput",
            "ServerVersion" -> $serverVersion,
            "ObjectVersion" -> $objectVersion
        |>;
        If[ AssociationQ @ validated,
            validated,
            DeleteDirectory[ dir, DeleteContents -> True ];
            throwTop @ validated
        ]
    ],
    throwInternalFailure
];

createMCPServerData // endDefinition;

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
