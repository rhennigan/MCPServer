#!/usr/bin/env wolframscript

BeginPackage[ "RickHennigan`MCPServerScripts`" ];

If[ ! TrueQ @ $loadedDefinitions, Get @ FileNameJoin @ { DirectoryName @ $InputFileName, "Common.wl" } ];

SetOptions[ TestReport, ProgressReporting -> False ];

result = UsingFrontEnd @ checkResult @ Wolfram`PacletCICD`TestPaclet @ $defNB;

EndPackage[ ];

RickHennigan`MCPServerScripts`result