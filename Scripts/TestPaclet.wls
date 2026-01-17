#!/usr/bin/env wolframscript

BeginPackage[ "Wolfram`MCPServerScripts`" ];

If[ ! TrueQ @ $loadedDefinitions, Get @ FileNameJoin @ { DirectoryName @ $InputFileName, "Common.wl" } ];

Needs[ "Wolfram`PacletCICD`" -> "cicd`" ];

SetOptions[ TestReport, ProgressReporting -> False ];

(* FIXME: The sample tests in Resources are getting run as part of this test suite and causing false failures since
   Wolfram`PacletCICD`TestPaclet seeks test files recursively. The Resources directory should be moved outside of
   the Tests directory to prevent this. *)

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
If[ StringQ @ Environment[ "GITHUB_ACTIONS" ]
    ,
    result = UsingFrontEnd @ Block[ { messagePrint }, checkResult @ Wolfram`PacletCICD`TestPaclet @ $defNB ]
    ,
    report = UsingFrontEnd @ Block[ { messagePrint }, TestReport @ FileNames[ "*.wlt", FileNameJoin @ { $pacletDir, "Tests" } ] ];
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