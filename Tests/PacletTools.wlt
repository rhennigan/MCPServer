(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`AgentToolsTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/PacletTools.wlt:7,1-12,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/PacletTools.wlt:14,1-19,2"
]

VerificationTest[
    Needs[ "Wolfram`AgentTools`Tools`PacletTools`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadPacletToolsContext@@Tests/PacletTools.wlt:21,1-26,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Registration*)
VerificationTest[
    $checkPacletTool = $DefaultMCPTools[ "CheckPaclet" ],
    _LLMTool,
    SameTest -> MatchQ,
    TestID   -> "GetCheckPacletTool@@Tests/PacletTools.wlt:31,1-36,2"
]

VerificationTest[
    $checkPacletTool[ "Name" ],
    "CheckPaclet",
    SameTest -> SameQ,
    TestID   -> "CheckPacletToolName@@Tests/PacletTools.wlt:38,1-43,2"
]

VerificationTest[
    StringQ @ $checkPacletTool[ "Description" ],
    True,
    SameTest -> SameQ,
    TestID   -> "CheckPacletToolDescription@@Tests/PacletTools.wlt:45,1-50,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*validatePacletPath*)
VerificationTest[
    Wolfram`AgentTools`Tools`PacletTools`Private`validatePacletPath @ DirectoryName[ $TestFileName, 2 ],
    File[ _String ],
    SameTest -> MatchQ,
    TestID   -> "ValidatePacletPath-ExistingDirectory@@Tests/PacletTools.wlt:55,1-60,2"
]

VerificationTest[
    Wolfram`AgentTools`Tools`PacletTools`Private`validatePacletPath @ $TestFileName,
    File[ _String ],
    SameTest -> MatchQ,
    TestID   -> "ValidatePacletPath-ExistingFile@@Tests/PacletTools.wlt:62,1-67,2"
]

VerificationTest[
    Wolfram`AgentTools`Common`catchTop @ Wolfram`AgentTools`Tools`PacletTools`Private`validatePacletPath[ "/nonexistent/path/to/paclet" ],
    _Failure,
    { AgentTools::PacletToolsInvalidPath },
    SameTest -> MatchQ,
    TestID   -> "ValidatePacletPath-MissingPath@@Tests/PacletTools.wlt:69,1-75,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*formatCheckResult*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Empty Dataset*)
VerificationTest[
    Wolfram`AgentTools`Tools`PacletTools`Private`formatCheckResult @ Dataset @ { },
    _String? (StringContainsQ[ "No issues found" ]),
    SameTest -> MatchQ,
    TestID   -> "FormatCheckResult-EmptyDataset@@Tests/PacletTools.wlt:84,1-89,2"
]

VerificationTest[
    Wolfram`AgentTools`Tools`PacletTools`Private`formatCheckResult @ { },
    _String? (StringContainsQ[ "No issues found" ]),
    SameTest -> MatchQ,
    TestID   -> "FormatCheckResult-EmptyList@@Tests/PacletTools.wlt:91,1-96,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Mixed Severity Dataset*)
VerificationTest[
    $mixedRows = {
        <| "Level" -> "Error",      "Tag" -> "MissingPublisherID", "Message" -> "No publisher ID specified",       "CellID" -> 1 |>,
        <| "Level" -> "Error",      "Tag" -> "InvalidVersion",     "Message" -> "Version string is invalid",       "CellID" -> 2 |>,
        <| "Level" -> "Warning",    "Tag" -> "VersionUnchanged",   "Message" -> "Version has not changed",         "CellID" -> 3 |>,
        <| "Level" -> "Suggestion", "Tag" -> "MissingTests",       "Message" -> "No test files found",             "CellID" -> 4 |>,
        <| "Level" -> "Suggestion", "Tag" -> "MissingReadme",      "Message" -> "No README file found",            "CellID" -> 5 |>,
        <| "Level" -> "Suggestion", "Tag" -> "MissingDocs",        "Message" -> "No documentation pages found",    "CellID" -> 6 |>
    };
    $mixedResult = Wolfram`AgentTools`Tools`PacletTools`Private`formatCheckResult @ $mixedRows;
    StringQ @ $mixedResult,
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-MixedSeverity-IsString@@Tests/PacletTools.wlt:101,1-115,2"
]

VerificationTest[
    StringContainsQ[ $mixedResult, "# Paclet Check Results" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-MixedSeverity-HasHeader@@Tests/PacletTools.wlt:117,1-122,2"
]

VerificationTest[
    StringContainsQ[ $mixedResult, "## Summary" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-MixedSeverity-HasSummary@@Tests/PacletTools.wlt:124,1-129,2"
]

VerificationTest[
    StringContainsQ[ $mixedResult, "| Error | 2 |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-MixedSeverity-ErrorCount@@Tests/PacletTools.wlt:131,1-136,2"
]

VerificationTest[
    StringContainsQ[ $mixedResult, "| Warning | 1 |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-MixedSeverity-WarningCount@@Tests/PacletTools.wlt:138,1-143,2"
]

VerificationTest[
    StringContainsQ[ $mixedResult, "| Suggestion | 3 |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-MixedSeverity-SuggestionCount@@Tests/PacletTools.wlt:145,1-150,2"
]

VerificationTest[
    StringContainsQ[ $mixedResult, "## Errors" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-MixedSeverity-HasErrorsSection@@Tests/PacletTools.wlt:152,1-157,2"
]

VerificationTest[
    StringContainsQ[ $mixedResult, "## Warnings" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-MixedSeverity-HasWarningsSection@@Tests/PacletTools.wlt:159,1-164,2"
]

VerificationTest[
    StringContainsQ[ $mixedResult, "## Suggestions" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-MixedSeverity-HasSuggestionsSection@@Tests/PacletTools.wlt:166,1-171,2"
]

VerificationTest[
    StringContainsQ[ $mixedResult, "**MissingPublisherID**: No publisher ID specified" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-MixedSeverity-ErrorItem@@Tests/PacletTools.wlt:173,1-178,2"
]

VerificationTest[
    StringContainsQ[ $mixedResult, "**VersionUnchanged**: Version has not changed" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-MixedSeverity-WarningItem@@Tests/PacletTools.wlt:180,1-185,2"
]

VerificationTest[
    StringContainsQ[ $mixedResult, "**MissingTests**: No test files found" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-MixedSeverity-SuggestionItem@@Tests/PacletTools.wlt:187,1-192,2"
]

(* Verify CellID is not in the output *)
VerificationTest[
    StringFreeQ[ $mixedResult, "CellID" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-MixedSeverity-NoCellID@@Tests/PacletTools.wlt:195,1-200,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Dataset Input*)
VerificationTest[
    Wolfram`AgentTools`Tools`PacletTools`Private`formatCheckResult @ Dataset @ $mixedRows,
    $mixedResult,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-DatasetMatchesList@@Tests/PacletTools.wlt:205,1-210,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Single Level Only*)
VerificationTest[
    With[
        { result = Wolfram`AgentTools`Tools`PacletTools`Private`formatCheckResult @ {
            <| "Level" -> "Warning", "Tag" -> "SomeWarning", "Message" -> "A warning", "CellID" -> 1 |>
        } },
        StringContainsQ[ result, "## Warnings" ] && StringFreeQ[ result, "## Errors" ] && StringFreeQ[ result, "## Suggestions" ]
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatCheckResult-SingleLevelOnly@@Tests/PacletTools.wlt:215,1-225,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*formatBuildResult*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Build Success*)
VerificationTest[
    $buildSuccessResult = Wolfram`AgentTools`Tools`PacletTools`Private`formatBuildResult @
        Success[ "PacletBuild", <|
            "PacletArchive" -> "C:/Users/dev/MyPaclet/build/DevPublisher__MyPaclet-1.0.0.paclet"
        |> ];
    StringQ @ $buildSuccessResult,
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-Success-IsString@@Tests/PacletTools.wlt:234,1-243,2"
]

VerificationTest[
    StringContainsQ[ $buildSuccessResult, "# Paclet Build Successful" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-Success-HasHeader@@Tests/PacletTools.wlt:245,1-250,2"
]

VerificationTest[
    StringContainsQ[ $buildSuccessResult, "| Paclet | DevPublisher/MyPaclet |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-Success-HasPacletName@@Tests/PacletTools.wlt:252,1-257,2"
]

VerificationTest[
    StringContainsQ[ $buildSuccessResult, "| Version | 1.0.0 |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-Success-HasVersion@@Tests/PacletTools.wlt:259,1-264,2"
]

VerificationTest[
    StringContainsQ[ $buildSuccessResult, "DevPublisher__MyPaclet-1.0.0.paclet" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-Success-HasArchivePath@@Tests/PacletTools.wlt:266,1-271,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Build Aborted by Check*)
VerificationTest[
    $buildAbortedResult = Wolfram`AgentTools`Tools`PacletTools`Private`formatBuildResult @
        Failure[ "CheckPaclet::errors", <|
            "CheckResult" -> {
                <| "Level" -> "Error", "Tag" -> "MissingPublisherID", "Message" -> "No publisher ID specified", "CellID" -> 1 |>,
                <| "Level" -> "Error", "Tag" -> "InvalidVersion",     "Message" -> "Version string is invalid",  "CellID" -> 2 |>
            }
        |> ];
    StringQ @ $buildAbortedResult,
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-CheckAborted-IsString@@Tests/PacletTools.wlt:276,1-288,2"
]

VerificationTest[
    StringContainsQ[ $buildAbortedResult, "# Paclet Build Aborted" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-CheckAborted-HasHeader@@Tests/PacletTools.wlt:290,1-295,2"
]

VerificationTest[
    StringContainsQ[ $buildAbortedResult, "pre-build check found errors" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-CheckAborted-HasExplanation@@Tests/PacletTools.wlt:297,1-302,2"
]

VerificationTest[
    StringContainsQ[ $buildAbortedResult, "## Summary" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-CheckAborted-HasSummary@@Tests/PacletTools.wlt:304,1-309,2"
]

VerificationTest[
    StringContainsQ[ $buildAbortedResult, "| Error | 2 |" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-CheckAborted-ErrorCount@@Tests/PacletTools.wlt:311,1-316,2"
]

VerificationTest[
    StringContainsQ[ $buildAbortedResult, "## Errors" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-CheckAborted-HasErrorsSection@@Tests/PacletTools.wlt:318,1-323,2"
]

VerificationTest[
    StringContainsQ[ $buildAbortedResult, "**MissingPublisherID**: No publisher ID specified" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-CheckAborted-HasErrorItem@@Tests/PacletTools.wlt:325,1-330,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Build Aborted by Check - Dataset Input*)
VerificationTest[
    $buildAbortedDatasetResult = Wolfram`AgentTools`Tools`PacletTools`Private`formatBuildResult @
        Failure[ "CheckPaclet::errors", <|
            "CheckResult" -> Dataset @ {
                <| "Level" -> "Error", "Tag" -> "MissingPublisherID", "Message" -> "No publisher ID specified", "CellID" -> 1 |>,
                <| "Level" -> "Error", "Tag" -> "InvalidVersion",     "Message" -> "Version string is invalid",  "CellID" -> 2 |>
            }
        |> ];
    StringQ @ $buildAbortedDatasetResult,
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-CheckAbortedDataset-IsString@@Tests/PacletTools.wlt:335,1-347,2"
]

VerificationTest[
    StringContainsQ[ $buildAbortedDatasetResult, "# Paclet Build Aborted" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-CheckAbortedDataset-HasHeader@@Tests/PacletTools.wlt:349,1-354,2"
]

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Build Failed - Generic Failure*)
VerificationTest[
    $buildFailedResult = Wolfram`AgentTools`Tools`PacletTools`Private`formatBuildResult @
        Failure[ "BuildPacletFailure", <|
            "MessageTemplate" -> "Something went wrong during build"
        |> ];
    StringQ @ $buildFailedResult,
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-GenericFailure-IsString@@Tests/PacletTools.wlt:359,1-368,2"
]

VerificationTest[
    StringContainsQ[ $buildFailedResult, "# Paclet Build Failed" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-GenericFailure-HasHeader@@Tests/PacletTools.wlt:370,1-375,2"
]

VerificationTest[
    StringContainsQ[ $buildFailedResult, "Something went wrong during build" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatBuildResult-GenericFailure-HasMessage@@Tests/PacletTools.wlt:377,1-382,2"
]

(* :!CodeAnalysis::EndBlock:: *)
