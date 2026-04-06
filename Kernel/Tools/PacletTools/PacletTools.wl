(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`AgentTools`Tools`PacletTools`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`AgentTools`"        ];
Needs[ "Wolfram`AgentTools`Common`" ];
Needs[ "Wolfram`AgentTools`Tools`"  ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Shared Helpers*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*ensurePacletCICD*)
ensurePacletCICD // beginDefinition;

ensurePacletCICD[] := ensurePacletCICD[] = Enclose[
    Module[ { paclet },
        paclet = PacletInstall[ "Wolfram/PacletCICD" ];

        If[ ! MatchQ[ paclet, _PacletObject ],
            throwFailure[ "PacletCICDLoadFailed" ]
        ];

        Needs[ "Wolfram`PacletCICD`" -> None ];
        Null
    ],
    throwInternalFailure
];

ensurePacletCICD // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validatePacletPath*)
validatePacletPath // beginDefinition;

validatePacletPath[ path_String ] :=
    Module[ { expanded },
        expanded = ExpandFileName @ path;

        If[ DirectoryQ @ expanded || FileExistsQ @ expanded,
            File @ expanded,
            throwFailure[ "PacletToolsInvalidPath", path ]
        ]
    ];

validatePacletPath // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompts*)
$checkPacletDescription = "\
Checks a Wolfram Language paclet for issues such as missing metadata, \
invalid structure, or other problems that would prevent successful building or submission. \
Returns a summary of issues organized by severity (Error, Warning, Suggestion). \
Use this tool before BuildPaclet or SubmitPaclet to identify and fix problems early. \
The path should be an absolute path to either the paclet root directory or \
the definition notebook (.nb) file.";

$buildPacletDescription = "\
Builds a Wolfram Language paclet, producing a .paclet archive file. \
This can be a long-running operation, especially for paclets with extensive documentation. \
Optionally runs CheckPaclet first to validate the paclet before building. \
The path should be an absolute path to either the paclet root directory or \
the definition notebook (.nb) file.";

$submitPacletDescription = "\
Submits a Wolfram Language paclet to the Wolfram Language Paclet Repository (paclets.com). \
This builds the paclet and then submits it for review. \
Requires prior authentication via $PublisherID or an active Wolfram Cloud connection. \
Use CheckPaclet first to verify the paclet is ready for submission. \
This is a long-running operation that involves building and uploading. \
The path should be an absolute path to either the paclet root directory or \
the definition notebook (.nb) file.";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*CheckPaclet*)
$defaultMCPTools[ "CheckPaclet" ] := LLMTool @ <|
    "Name"        -> "CheckPaclet",
    "DisplayName" -> "Check Paclet",
    "Description" -> $checkPacletDescription,
    "Function"    -> checkPacletTool,
    "Options"     -> { },
    "Parameters"  -> {
        "path" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Absolute path to the paclet directory or definition notebook (.nb) file.",
            "Required"    -> True
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*BuildPaclet*)
$defaultMCPTools[ "BuildPaclet" ] := LLMTool @ <|
    "Name"        -> "BuildPaclet",
    "DisplayName" -> "Build Paclet",
    "Description" -> $buildPacletDescription,
    "Function"    -> buildPacletTool,
    "Options"     -> { },
    "Parameters"  -> {
        "path" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Absolute path to the paclet directory or definition notebook (.nb) file.",
            "Required"    -> True
        |>,
        "check" -> <|
            "Interpreter" -> "Boolean",
            "Help"        -> "Whether to run CheckPaclet before building (default: false).",
            "Required"    -> False
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*SubmitPaclet*)
$defaultMCPTools[ "SubmitPaclet" ] := LLMTool @ <|
    "Name"        -> "SubmitPaclet",
    "DisplayName" -> "Submit Paclet",
    "Description" -> $submitPacletDescription,
    "Function"    -> submitPacletTool,
    "Options"     -> { },
    "Parameters"  -> {
        "path" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Absolute path to the paclet directory or definition notebook (.nb) file.",
            "Required"    -> True
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Submodules*)
<< Wolfram`AgentTools`Tools`PacletTools`CheckPaclet`;
<< Wolfram`AgentTools`Tools`PacletTools`BuildPaclet`;
<< Wolfram`AgentTools`Tools`PacletTools`SubmitPaclet`;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
