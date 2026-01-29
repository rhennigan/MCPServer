(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`CodeInspector`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "CodeInspector`" -> "ci`"   ];
Needs[ "CodeParser`"    -> "cp`"   ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)
$wlFilePatterns = { "*.wl", "*.m", "*.wls" };

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*codeInspect*)
codeInspect // beginDefinition;

codeInspect[ code: _String | File[ _String ], opts_Association ] := Enclose[
    Module[ { abstractRules, concreteRules, aggregateRules, tagExclusions, severityExclusions, confidenceLevel },

        (* We need to make sure CodeInspector is loaded at runtime, since we might be running from an MX build *)
        Needs[ "CodeInspector`" -> None ];
        Needs[ "CodeParser`"    -> None ];

        abstractRules  = ConfirmBy[ $abstractRules , AssociationQ, "AbstractRules"  ];
        concreteRules  = ConfirmBy[ $concreteRules , AssociationQ, "ConcreteRules"  ];
        aggregateRules = ConfirmBy[ $aggregateRules, AssociationQ, "AggregateRules" ];

        tagExclusions      = ConfirmMatch[ opts[ "tagExclusions"      ], { ___String }, "TagExclusions"      ];
        severityExclusions = ConfirmMatch[ opts[ "severityExclusions" ], { ___String }, "SeverityExclusions" ];
        confidenceLevel    = ConfirmMatch[ opts[ "confidenceLevel"    ], _Real        , "ConfidenceLevel"    ];

        tagExclusions = StringSplit[ #, "::" ] & /@ tagExclusions;

        ci`CodeInspect[
            code,
            "AbstractRules"      -> abstractRules,
            "ConcreteRules"      -> concreteRules,
            "AggregateRules"     -> aggregateRules,
            "TagExclusions"      -> tagExclusions,
            "SeverityExclusions" -> severityExclusions,
            "ConfidenceLevel"    -> confidenceLevel
        ]
    ],
    throwInternalFailure
];

codeInspect // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*runInspection*)
runInspection // beginDefinition;

(* Inspect a code string or file *)
runInspection[ code: _String | File[ _String ], opts_Association ] := Enclose[
    ConfirmMatch[ codeInspect[ code, opts ], { ___ci`InspectionObject }, "CodeInspect" ],
    throwInternalFailure
];

(* Inspect a directory - returns association of file -> inspections *)
runInspection[ dir_String, opts_Association ] /; DirectoryQ @ dir := Enclose[
    runInspectionOnDirectory[ dir, opts ],
    throwInternalFailure
];

runInspection // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*runInspectionOnDirectory*)
runInspectionOnDirectory // beginDefinition;

runInspectionOnDirectory[ dir_String, opts_Association ] := Enclose[
    Module[ { files },

        (* Find all WL files recursively *)
        files = FileNames[ $wlFilePatterns, dir, Infinity ];

        (* Check if any files were found, return failure if not *)
        If[ files === { },
            throwFailure[ "CodeInspectorNoFilesFound", dir ],
            (* Inspect each file and collect results *)
            Association @ Map[
                Function[ file,
                    file -> ConfirmMatch[
                        inspectSingleFile[ file, opts ],
                        { ___ci`InspectionObject },
                        "InspectFile"
                    ]
                ],
                files
            ]
        ]
    ],
    throwInternalFailure
];

runInspectionOnDirectory // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*inspectSingleFile*)
inspectSingleFile // beginDefinition;

inspectSingleFile[ file_String, opts_Association ] :=
    Module[ { rawInspections },
        rawInspections = Quiet[
            codeInspect[ File @ file, opts ],
            { CodeInspector::InternalUnhandled }
        ];
        (* Handle cases where CodeInspect fails *)
        If[ MatchQ[ rawInspections, { ___ci`InspectionObject } ],
            rawInspections,
            { } (* Return empty list if inspection fails for a file *)
        ]
    ];

inspectSingleFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
