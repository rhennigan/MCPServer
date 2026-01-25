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
(*runInspection*)
runInspection // beginDefinition;

(* Inspect a code string *)
runInspection[ code_String, opts_Association ] := Enclose[
    Module[ { rawInspections, filtered },
        rawInspections = ConfirmMatch[
            ci`CodeInspect @ code,
            { ___ci`InspectionObject },
            "CodeInspect"
        ];
        filtered = filterInspections[ rawInspections, opts ];
        filtered
    ],
    throwInternalFailure
];

(* Inspect a single file *)
runInspection[ File[ path_String ], opts_Association ] := Enclose[
    Module[ { rawInspections, filtered },
        rawInspections = ConfirmMatch[
            ci`CodeInspect @ File @ path,
            { ___ci`InspectionObject },
            "CodeInspect"
        ];
        filtered = filterInspections[ rawInspections, opts ];
        filtered
    ],
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
            ci`CodeInspect @ File @ file,
            { CodeInspector::InternalUnhandled }
        ];
        (* Handle cases where CodeInspect fails *)
        If[ MatchQ[ rawInspections, { ___ci`InspectionObject } ],
            filterInspections[ rawInspections, opts ],
            { } (* Return empty list if inspection fails for a file *)
        ]
    ];

inspectSingleFile // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*filterInspections*)
filterInspections // beginDefinition;

filterInspections[ inspections_List, opts_Association ] :=
    Module[ { tagExclusions, severityExclusions, confidenceLevel },
        tagExclusions      = Lookup[ opts, "tagExclusions", { } ];
        severityExclusions = Lookup[ opts, "severityExclusions", { } ];
        confidenceLevel    = Lookup[ opts, "confidenceLevel", 0.75 ];

        Select[
            inspections,
            passesFilters[ #, tagExclusions, severityExclusions, confidenceLevel ] &
        ]
    ];

filterInspections // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*passesFilters*)
passesFilters // beginDefinition;

passesFilters[
    ci`InspectionObject[ tag_String, description_, severity_String, data_Association ],
    tagExclusions_List,
    severityExclusions_List,
    minConfidence_
] :=
    And[
        (* Tag not in exclusions *)
        ! MemberQ[ tagExclusions, tag ],
        (* Severity not in exclusions *)
        ! MemberQ[ severityExclusions, severity ],
        (* Confidence level meets threshold *)
        Lookup[ data, ConfidenceLevel, 1.0 ] >= minConfidence
    ];

(* Handle unexpected InspectionObject format gracefully *)
passesFilters[ _ci`InspectionObject, _, _, _ ] := False;

passesFilters // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
