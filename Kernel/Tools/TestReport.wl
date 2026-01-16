(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`TestReport`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];

System`HoldCompleteForm;
System`TestObject;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)
$$size = _Number? Positive | Infinity;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Tool Definition*)
$defaultMCPTools[ "TestReport" ] := LLMTool @ <|
    "Name"        -> "TestReport",
    "DisplayName" -> "Test Report",
    "Description" -> "Runs Wolfram Language test files (.wlt) and returns a report of the results",
    "Function"    -> testReport,
    "Options"     -> { },
    "Parameters"  -> {
        "paths" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Comma separated list of paths to Wolfram Language test files (.wlt) or directories of test files",
            "Required"    -> True
        |>,
        "timeConstraint" -> <|
            "Interpreter" -> "Integer",
            "Help"        -> "An optional time constraint (in seconds) for each test file",
            "Required"    -> False
        |>,
        "memoryConstraint" -> <|
            "Interpreter" -> "Integer",
            "Help"        -> "An optional memory constraint (in bytes) for each test file",
            "Required"    -> False
        |>
    }
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*testReport*)
testReport // beginDefinition;

testReport[ as_Association ] := catchTop @ testReport[
    validatePath @ as[ "paths" ],
    validateTimeConstraint @ as[ "timeConstraint" ],
    validateMemoryConstraint @ as[ "memoryConstraint" ]
];

testReport[ files: { __String }, timeConstraint: $$size, memoryConstraint: $$size ] := Enclose[
    Module[ { results, markdown },
        results = AssociationMap[ testReport1[ #, timeConstraint, memoryConstraint ] &, files ];
        markdown = ConfirmBy[ testResultsToMarkdown @ results, StringQ, "Markdown" ];
        markdown
    ],
    throwInternalFailure
];

testReport // endDefinition;


testReport1 // beginDefinition;

testReport1[ file_String, timeConstraint: $$size, memoryConstraint: $$size ] := Enclose[
    Module[ { result },
        result = TestReport[ file, TimeConstraint -> timeConstraint, MemoryConstraint -> memoryConstraint ];
        If[ ! MatchQ[ result, _TestReportObject ], throwFailure[ "InvalidTestFile", file ] ];
        If[ result[ "TestResults" ] === <| |>, throwFailure[ "NoTestsInFile", file ] ];
        result
    ],
    throwInternalFailure
];

testReport1 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*validatePath*)
validatePath // beginDefinition;
validatePath[ paths_String ] := Flatten[ validatePath0 /@ StringSplit[ paths, "," ] ];
validatePath // endDefinition;

validatePath0 // beginDefinition;
validatePath0[ dir_String? DirectoryQ ] := FileNames[ "*.wlt", dir, Infinity ];
validatePath0[ file_String ] := If[ FileExistsQ @ file, file, throwFailure[ "TestFileNotFound", file ] ];
validatePath0 // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*validateTimeConstraint*)
validateTimeConstraint // beginDefinition;
validateTimeConstraint[ _Missing ] := Infinity;
validateTimeConstraint[ time: $$size ] := time;
validateTimeConstraint // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*validateMemoryConstraint*)
validateMemoryConstraint // beginDefinition;
validateMemoryConstraint[ _Missing ] := Infinity;
validateMemoryConstraint[ memory: $$size ] := memory;
validateMemoryConstraint // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*testResultsToMarkdown*)
testResultsToMarkdown // beginDefinition;

testResultsToMarkdown[ resultsByFile_Association ] := Enclose[
    Module[ { overall, fileSections },
        overall      = overallSummaryMarkdown @ resultsByFile;
        fileSections = KeyValueMap[ fileResultsMarkdown, resultsByFile ];
        StringRiffle[ Flatten @ { overall, fileSections }, "\n\n" ]
    ],
    throwInternalFailure
];

testResultsToMarkdown // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*overallSummaryMarkdown*)
overallSummaryMarkdown // beginDefinition;

overallSummaryMarkdown[ resultsByFile_Association ] := Enclose[
    Module[
        {
            reports, totalFiles, totalTests, totalPassed, totalFailed,
            totalTime, passPercent, failPercent, outcome
        },

        reports     = Values @ resultsByFile;
        totalFiles  = Length @ reports;
        totalTests  = Total[ #[ "TestsSucceededCount" ] + #[ "TestsFailedCount" ] & /@ reports ];
        totalPassed = Total[ #[ "TestsSucceededCount" ] & /@ reports ];
        totalFailed = Total[ #[ "TestsFailedCount" ] & /@ reports ];
        totalTime   = Total[ #[ "TimeElapsed" ] & /@ reports ];
        passPercent = If[ totalTests > 0, Round[ 100.0 * totalPassed / totalTests, 0.1 ], 0 ];
        failPercent = If[ totalTests > 0, Round[ 100.0 * totalFailed / totalTests, 0.1 ], 0 ];
        outcome     = If[ totalFailed === 0, "Success", "Failure" ];

        StringJoin[
            "# Test Results Summary\n\n",
            "| Metric | Value |\n",
            "| --- | --- |\n",
            "| **Overall Result** | ", outcome, " |\n",
            "| **Total Files** | ", ToString @ totalFiles, " |\n",
            "| **Total Tests** | ", ToString @ totalTests, " |\n",
            "| **Passed** | ", ToString @ totalPassed, " (", formatPercent @ passPercent, ") |\n",
            "| **Failed** | ", ToString @ totalFailed, " (", formatPercent @ failPercent, ") |\n",
            "| **Total Time** | ", formatTime @ totalTime, " |"
        ]
    ],
    throwInternalFailure
];

overallSummaryMarkdown // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*fileResultsMarkdown*)
fileResultsMarkdown // beginDefinition;

fileResultsMarkdown[ file_String, report_TestReportObject ] := Enclose[
    Module[
        {
            fileName, passed, failed, total, time,
            passPercent, failPercent, summaryTable, failedTests, failedSection
        },

        fileName    = FileNameTake @ file;
        passed      = report[ "TestsSucceededCount" ];
        failed      = report[ "TestsFailedCount" ];
        total       = passed + failed;
        time        = report[ "TimeElapsed" ];
        passPercent = If[ total > 0, Round[ 100.0 * passed / total, 0.1 ], 0 ];
        failPercent = If[ total > 0, Round[ 100.0 * failed / total, 0.1 ], 0 ];

        summaryTable = StringJoin[
            "## ", fileName, "\n\n",
            "| Metric | Value |\n",
            "| --- | --- |\n",
            "| **Tests** | ", ToString @ total, " |\n",
            "| **Passed** | ", ToString @ passed, " (", formatPercent @ passPercent, ") |\n",
            "| **Failed** | ", ToString @ failed, " (", formatPercent @ failPercent, ") |\n",
            "| **Time** | ", formatTime @ time, " |"
        ];

        failedTests = DeleteCases[ report[ "TestsFailed" ], <||> ];

        If[ Length @ Flatten @ Values @ failedTests === 0,
            summaryTable,
            failedSection = StringRiffle[
                Flatten @ {
                    failedTestsSection[ "Wrong Results", failedTests[ "TestsFailedWrongResults" ] ],
                    failedTestsSection[ "Message Failures", failedTests[ "TestsFailedWithMessages" ] ],
                    failedTestsSection[ "Errors", failedTests[ "TestsFailedWithErrors" ] ]
                },
                "\n\n"
            ];
            StringJoin[ summaryTable, "\n\n", failedSection ]
        ]
    ],
    throwInternalFailure
];

fileResultsMarkdown // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*failedTestsSection*)
failedTestsSection // beginDefinition;

failedTestsSection[ _, { } | <||> | _Missing ] := Nothing;

failedTestsSection[ title_String, tests_Association ] :=
    failedTestsSection[ title, Values @ tests ];

failedTestsSection[ title_String, tests_List ] := Enclose[
    Module[ { header, testDetails },
        header      = "### " <> title;
        testDetails = failedTestMarkdown /@ tests;
        StringRiffle[ Prepend[ testDetails, header ], "\n\n" ]
    ],
    throwInternalFailure
];

failedTestsSection // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*failedTestMarkdown*)
failedTestMarkdown // beginDefinition;

failedTestMarkdown[ test: (_TestResultObject | _TestObject) ] := Enclose[
    Module[ { testID, outcome, time, memory, input, expected, actual, expectedMsg, actualMsg, details },

        testID      = test[ "TestID" ];
        outcome     = test[ "Outcome" ];
        time        = formatTime @ test[ "AbsoluteTimeUsed" ];
        memory      = formatMemory @ test[ "MemoryUsed" ];
        input       = formatHeldCode @ test[ "Input" ];
        expected    = formatHeldCode @ test[ "ExpectedOutput" ];
        actual      = formatHeldCode @ test[ "ActualOutput" ];
        expectedMsg = formatHeldCode @ test[ "ExpectedMessages" ];
        actualMsg   = formatHeldCode @ test[ "ActualMessages" ];

        details = {
            "#### " <> ToString @ testID,
            "| Property | Value |",
            "| --- | --- |",
            "| **Outcome** | " <> ToString @ outcome <> " |",
            "| **Time** | " <> time <> " |",
            "| **Memory** | " <> memory <> " |",
            "",
            "**Input:**",
            "```wl",
            input,
            "```",
            "",
            "**Expected Output:**",
            "```wl",
            expected,
            "```",
            "",
            "**Actual Output:**",
            "```wl",
            actual,
            "```"
        };

        If[ expectedMsg =!= "{ }" && actualMsg =!= "{ }",
            details = Join[ details, {
                "",
                "**Expected Messages:**",
                "```wl",
                expectedMsg,
                "```",
                "",
                "**Actual Messages:**",
                "```wl",
                actualMsg,
                "```"
            } ]
        ];

        StringRiffle[ details, "\n" ]
    ],
    throwInternalFailure
];

failedTestMarkdown // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Formatters*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatPercent*)
formatPercent // beginDefinition;
formatPercent[ n_? NumericQ ] := StringReplace[ ToString @ Round[ n, 0.1 ] <> "%", ".%" -> "%" ];
formatPercent // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatTime*)
formatTime // beginDefinition;

formatTime[ sec_? NumericQ ] :=
    Which[
        sec < 0.001, "< 1 ms",
        sec < 1,     ToString @ Round[ 1000 * sec ] <> " ms",
        sec < 60,    ToString @ Round[ sec, 0.1 ] <> " s",
        sec < 3600,  ToString @ Round[ sec / 60, 0.1 ] <> " min",
        True,        ToString @ Round[ sec / 3600, 0.1 ] <> " h"
    ];

formatTime[ Quantity[ val_, _ ] ] := formatTime @ val; (* FIXME: UnitConvert/QuantityMagnitude to get proper units *)

formatTime[ _ ] := "N/A";

formatTime // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatMemory*)
formatMemory // beginDefinition;

formatMemory[ bytes_? NumericQ ] :=
    Which[
        bytes < 1024,   ToString @ Round @ bytes <> " B",
        bytes < 1024^2, ToString @ Round[ bytes / 1024.0, 0.1 ] <> " KB",
        bytes < 1024^3, ToString @ Round[ bytes / 1024.0^2, 0.01 ] <> " MB",
        True,           ToString @ Round[ bytes / 1024.0^3, 0.001 ] <> " GB"
    ];

formatMemory[ Quantity[ val_, _ ] ] := formatMemory @ val; (* FIXME: UnitConvert/QuantityMagnitude to get proper units *)

formatMemory[ _ ] := "N/A";

formatMemory // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*formatHeldCode*)
formatHeldCode // beginDefinition;

formatHeldCode[ (HoldForm | HoldCompleteForm)[ expr_ ] ] :=
    Module[ { str },
        (* str = ToString @ Wolfram`PacletCICD`ReadableForm[ Unevaluated @ expr, TimeConstraint -> 3 ]; *)
        (* TODO: implement a version of ReadableForm in this paclet (for now, just use InputForm) *)
        str = ToString[ Unevaluated @ expr, InputForm ];
        If[ StringLength @ str > 500,
            StringTake[ str, 250 ] <> " ... " <> StringTake[ str, -250 ],
            str
        ]
    ];

formatHeldCode[ expr_ ] :=
    formatHeldCode @ HoldForm @ expr;

formatHeldCode // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];