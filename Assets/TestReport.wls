#!/usr/bin/env wolframscript

(* This script allows running the TestReport MCP tool with a new kernel each time it is called. This is especially
   important for self-testing this paclet, because we don't want running tests to interfere with the operation of the
   currently running MCP server. *)

$stdOut = First @ Streams[ "stdout" ];
SetOptions[ $stdOut, PageWidth -> Infinity ];

$inputFileName    = $InputFileName;
$pacletDir        = DirectoryName[ $inputFileName, 2 ];
$paths            = $CommandLine[[ -3 ]];
$timeConstraint   = $CommandLine[[ -2 ]];
$memoryConstraint = $CommandLine[[ -1 ]];

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
If[ ! (StringQ @ $paths && StringQ @ $timeConstraint && StringQ @ $memoryConstraint), Exit[ 1 ] ];
If[ ! StringMatchQ[ $timeConstraint  , "Infinity"|NumberString ], Exit[ 1 ] ];
If[ ! StringMatchQ[ $memoryConstraint, "Infinity"|NumberString ], Exit[ 1 ] ];
(* :!CodeAnalysis::EndBlock:: *)

PacletDirectoryLoad @ DirectoryName[ $inputFileName, 2 ];
<< Wolfram`MCPServer`;

markdown = Wolfram`MCPServer`TestReportToolFunction[
    <|
        "paths"            -> $paths,
        "timeConstraint"   -> ToExpression @ $timeConstraint,
        "memoryConstraint" -> ToExpression @ $memoryConstraint
    |>,
    "External" -> False
];

WriteString[ $stdOut, markdown ]