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
    HandlerFunctionsKeys -> { "Outcome", "TestFileName", "TestObject" },
    ProgressReporting    -> False
];

checkTestResult[ as_Association ] :=
    Catch @ Module[ { outcome, testObject, testID, string },
        outcome = as[ "Outcome" ];
        If[ outcome =!= "Success",
            testObject = as[ "TestObject" ];
            If[ MemberQ[ FileNameSplit @ testObject[ "TestFileName" ], "TestResources" ], Throw @ Null ];
            testID = testObject[ "TestID" ];
            cicd`ConsoleError[ SequenceForm[ "\tTest failed: (", outcome, ") ", testID ], "Fatal" -> False ];
            If[ StringQ @ Environment[ "GITHUB_ACTIONS" ],
                string = ToString[
                    ReplaceAll[
                        testObject,
                        Hyperlink[ label_String, url_String ] /; And[
                            StringStartsQ[ label, "Report this issue" ],
                            StringStartsQ[ url, "https://github.com/" ~~ __ ~~ "/issues/new?" ]
                        ] :> RuleCondition @ Hyperlink[ label, First @ StringSplit[ url, "?" ] ]
                    ],
                    InputForm,
                    PageWidth -> Infinity
                ];
                If[ StringLength @ string > 5000, string = StringTake[ string, 5000 ] <> " ..." ];
                cicd`ConsoleLog @ string
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