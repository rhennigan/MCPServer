#!/usr/bin/env wolframscript

BeginPackage[ "RickHennigan`MCPServerScripts`" ];

If[ ! TrueQ @ $loadedDefinitions, Get @ FileNameJoin @ { DirectoryName @ $InputFileName, "Common.wl" } ];

Needs[ "PacletResource`" -> None ];
SetOptions[ PacletResource`Notebooks`ProcessNotebookForEmbedding, "EmbeddedHTMLImages" -> True ];

result = checkResult @ Wolfram`PacletCICD`SubmitPaclet[ $defNB, "ExitOnFail" -> True ];

EndPackage[ ];

RickHennigan`MCPServerScripts`result