#!/usr/bin/env wolframscript

BeginPackage[ "Wolfram`MCPServerScripts`" ];

If[ ! TrueQ @ $loadedDefinitions, Get @ FileNameJoin @ { DirectoryName @ $InputFileName, "Common.wl" } ];

Needs[ "Wolfram`PacletCICD`" -> "cicd`" ];

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
(* Improve readability of GitHub Actions output by writing some test events to stdout. *)
SetOptions[
    TestReport,
    HandlerFunctions -> <|
        "FileStarted"   -> Function @ Print[ "Starting test file: ", #[ "TestFileName" ] ],
        "FileFinished"  -> Function @ Print[ "Finished test file: ", #[ "TestFileName" ] ],
        "TestCreated"   -> Function @ Print[ "\tCurrent test: " , #[ "TestObject" ][ "TestID" ] ],
        "TestEvaluated" -> checkTestResult
    |>,
    HandlerFunctionsKeys -> { "TestFileName", "TestObject" },
    ProgressReporting    -> False
];

checkTestResult[ as_Association ] :=
    Module[ { outcome, testObject, testID },
        outcome = as[ "Outcome" ];
        If[ outcome =!= "Success",
            testObject = as[ "TestObject" ];
            testID = testObject[ "TestID" ];
            cicd`ConsoleError[ SequenceForm[ "\tTest failed: (", outcome, ") ", testID ], "Fatal" -> False ];
            If[ StringQ @ Environment[ "GITHUB_ACTIONS" ],
                cicd`ConsoleLog @ ToString[ testObject, InputForm, PageWidth -> Infinity ]
            ]
        ]
    ];

$testDirectory = FileNameJoin @ { $pacletDir, "Tests" };
If[ StringQ @ Environment[ "GITHUB_ACTIONS" ]
    ,
    result = UsingFrontEnd @ Block[ { messagePrint }, checkResult @ Wolfram`PacletCICD`TestPaclet @ $testDirectory ]
    ,
    report = UsingFrontEnd @ Block[ { messagePrint }, TestReport @ FileNames[ "*.wlt", $testDirectory ] ];
    failed = Cases[ report[ "TestsFailed" ], _TestObject, Infinity ];
    If[ Length @ failed === 0, Exit[ 0 ] ];
    Print[ "Failed tests: " ];
    Cases[
        failed,
        t_TestObject :> Print[ "\n\t", t[ "TestID" ], ": ", ToString[ t, InputForm ] ],
        Infinity
    ];
    Exit[ 1 ]
];
(* :!CodeAnalysis::EndBlock:: *)

EndPackage[ ];

Wolfram`MCPServerScripts`result