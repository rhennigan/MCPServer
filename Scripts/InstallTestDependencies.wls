#!/usr/bin/env wolframscript

BeginPackage[ "Wolfram`MCPServerScripts`" ];

If[ ! TrueQ @ $loadedDefinitions, Get @ FileNameJoin @ { DirectoryName @ $InputFileName, "Common.wl" } ];

Needs[ "Wolfram`PacletCICD`" -> "cicd`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Run*)
cicd`ScriptConfirmBy[ PacletInstall[ "Wolfram/Chatbook", UpdatePacletSites -> True ], PacletObjectQ ];
cicd`ScriptConfirmMatch[ Get[ "Wolfram`Chatbook`" ], Null ];
result = cicd`ScriptConfirmMatch[ Wolfram`Chatbook`InstallVectorDatabases[ ], _Success ];

EndPackage[ ];

Wolfram`MCPServerScripts`result