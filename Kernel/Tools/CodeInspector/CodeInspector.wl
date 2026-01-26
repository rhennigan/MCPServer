(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`CodeInspector`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)
$defaultConfidenceLevel    = 0.75;
$defaultSeverityExclusions = { "Formatting", "Remark", "Scoping" };
$defaultTagExclusions      = { };
$defaultLimit              = 100;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*CodeInspectorToolFunction*)
(* Exported for use in scripts *)
CodeInspectorToolFunction // beginDefinition;
CodeInspectorToolFunction[ parameters_Association ] := catchMine @ codeInspectorTool @ <| $defaults, parameters |>;
CodeInspectorToolFunction // endExportedDefinition;

$defaults = AssociationMap[
    Missing[ "NoInput" ] &,
    { "code", "file", "tagExclusions", "severityExclusions", "confidenceLevel", "limit" }
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Prompts*)
$codeInspectorDescription = "\
Inspects Wolfram Language code using the CodeInspector package and returns a formatted report of issues found. \
The tool supports inspecting code strings, individual files, or entire directories of Wolfram Language source files.";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definition*)
(* Add to $defaultMCPTools Association (initialized in Kernel/Tools/Tools.wl) *)
$defaultMCPTools[ "CodeInspector" ] := LLMTool @ <|
    "Name"        -> "CodeInspector",
    "DisplayName" -> "Code Inspector",
    "Description" -> $codeInspectorDescription,
    "Function"    -> CodeInspectorToolFunction,
    "Options"     -> { },
    "Parameters"  -> {
        "code" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Wolfram Language code string to inspect.",
            "Required"    -> False
        |>,
        "file" -> <|
            "Interpreter" -> "String",
            "Help"        -> "File or directory path to inspect. For directories, recursively inspects all .wl, .m, and .wls files.",
            "Required"    -> False
        |>,
        "tagExclusions" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Comma-separated list of tags to exclude (e.g., \"UnusedVariable,SuspiciousSessionSymbol\").",
            "Required"    -> False
        |>,
        "severityExclusions" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Comma-separated list of severities to exclude. Default: \"Formatting,Remark,Scoping\". Available: Fatal, Error, Warning, Scoping, Remark, Formatting.",
            "Required"    -> False
        |>,
        "confidenceLevel" -> <|
            "Interpreter" -> "Number",
            "Help"        -> "Minimum confidence level (0.0 to 1.0). Default: 0.75. Issues below this confidence are excluded.",
            "Required"    -> False
        |>,
        "limit" -> <|
            "Interpreter" -> "Integer",
            "Help"        -> "Maximum number of issues to display. Default: 100.",
            "Required"    -> False
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Main Entry Point*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*codeInspectorTool*)
codeInspectorTool // beginDefinition;

codeInspectorTool[ KeyValuePattern @ {
    "code"               -> code_,
    "file"               -> file_,
    "tagExclusions"      -> tagExclusions_,
    "severityExclusions" -> severityExclusions_,
    "confidenceLevel"    -> confidenceLevel_,
    "limit"              -> limit_
} ] := Enclose[
    Module[ { validatedInput, opts, inspections, result },

        (* Validate and normalize input *)
        validatedInput = ConfirmBy[
            validateAndNormalizeInput[ code, file ],
            Not @* FailureQ,
            "ValidateInput"
        ];

        (* Parse and normalize options *)
        opts = <|
            "tagExclusions"      -> parseExclusions @ tagExclusions,
            "severityExclusions" -> parseExclusions[ severityExclusions, $defaultSeverityExclusions ],
            "confidenceLevel"    -> parseConfidenceLevel @ confidenceLevel,
            "limit"              -> parseLimit @ limit
        |>;

        (* Run inspection *)
        inspections = ConfirmBy[
            runInspection[ validatedInput, opts ],
            Not @* FailureQ,
            "RunInspection"
        ];

        (* Format and return results *)
        result = ConfirmBy[
            inspectionsToMarkdown[ inspections, validatedInput, opts ],
            StringQ,
            "FormatResults"
        ];

        result
    ],
    throwInternalFailure
];

codeInspectorTool // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Input Validation*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*validateAndNormalizeInput*)
validateAndNormalizeInput // beginDefinition;

(* Neither code nor file provided *)
validateAndNormalizeInput[ _Missing, _Missing ] :=
    throwFailure[ "CodeInspectorNoInput" ];

(* Both code and file provided *)
validateAndNormalizeInput[ code_String, file_String ] :=
    throwFailure[ "CodeInspectorAmbiguousInput" ];

(* Code string provided *)
validateAndNormalizeInput[ code_String, _Missing ] := code;

(* File or directory path provided *)
validateAndNormalizeInput[ _Missing, file_String ] :=
    Which[
        DirectoryQ @ file,
            file,
        FileExistsQ @ file,
            File @ file,
        True,
            throwFailure[ "CodeInspectorFileNotFound", file ]
    ];

validateAndNormalizeInput // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Parameter Parsing*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseExclusions*)
parseExclusions // beginDefinition;

parseExclusions[ _Missing ] := { };
parseExclusions[ _Missing, default_List ] := default;
parseExclusions[ ""       ] := { };
parseExclusions[ "", default_List ] := default;

parseExclusions[ str_String ] :=
    StringTrim /@ StringSplit[ str, "," ];

parseExclusions[ str_String, _List ] :=
    parseExclusions @ str;

parseExclusions // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseConfidenceLevel*)
parseConfidenceLevel // beginDefinition;
parseConfidenceLevel[ _Missing ] := $defaultConfidenceLevel;
parseConfidenceLevel[ value_? NumericQ ] /; 0 <= value <= 1 := N @ value;
parseConfidenceLevel[ value_ ] := throwFailure[ "CodeInspectorInvalidConfidence", value ];
parseConfidenceLevel // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*parseLimit*)
parseLimit // beginDefinition;
parseLimit[ _Missing ] := $defaultLimit;
parseLimit[ n_Integer ] /; n > 0 := n;
parseLimit[ _ ] := $defaultLimit;
parseLimit // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Load Submodules*)

(* Inspection logic *)
<< Wolfram`MCPServer`Tools`CodeInspector`Inspection`;

(* Markdown formatting *)
<< Wolfram`MCPServer`Tools`CodeInspector`Formatting`;

(* CodeAction handling *)
<< Wolfram`MCPServer`Tools`CodeInspector`CodeActions`;

(* Extra inspection rules *)
<< Wolfram`MCPServer`Tools`CodeInspector`Rules`;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
