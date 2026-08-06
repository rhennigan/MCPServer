#!/usr/bin/env wolframscript

BeginPackage[ "Wolfram`MCPServerScripts`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
If[ ! TrueQ @ $loadedDefinitions, Get @ FileNameJoin @ { DirectoryName @ $InputFileName, "Common.wl" } ];
If[ ! StringQ @ Environment[ "GITHUB_ACTIONS" ], System`$PublisherID = "Wolfram" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Arguments*)
$check   = getBooleanArgument[ { "c", "check"    }, True  ];
$install = getBooleanArgument[ { "i", "install"  }, False ];
$mx      = getBooleanArgument[ { "m", "mx"       }, True  ];
$keepMX  = getBooleanArgument[ { "k", "keep-mx"  }, StringQ @ Environment[ "GITHUB_ACTIONS" ] ];
$debug   = getBooleanArgument[ { "d", "debug"    }, StringQ @ Environment[ "GITHUB_ACTIONS" ] ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Optional Dependencies*)
If[ $mx   , Get @ cFile @ FileNameJoin @ { $scriptDir, "BuildMX.wls" } ];
If[ $check, Get @ cFile @ FileNameJoin @ { $scriptDir, "Resources", "CodeInspectorRules.wl" } ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Other*)
Needs[ "Wolfram`PacletCICD`" -> "cicd`" ];
Needs[ "PacletTools`"        -> None ];
Needs[ "DocumentationBuild`" -> None ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Definitions*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*debugDocBuild*)
debugDocBuild // ClearAll;
debugDocBuild // Attributes = { HoldFirst };

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
(* :!CodeAnalysis::Disable::GlobalSymbol:: *)
debugDocBuild[ eval_ ] /; $debug := (
    Block[ { Global`AntLog },
        (* Documentation build uses this symbol throughout for debug logging, which is normally undefined: *)
        Global`AntLog[ args___ ] := Print[ "[DocumentationBuild] ", args ];

        overrideNotebookExport @ eval
    ]
);
(* :!CodeAnalysis::EndBlock:: *)

debugDocBuild[ eval_ ] := overrideNotebookExport @ eval;

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*overrideNotebookExport*)
overrideNotebookExport // ClearAll;
overrideNotebookExport // Attributes = { HoldFirst };

overrideNotebookExport[ eval_ ] /; StringQ @ Environment[ "GITHUB_ACTIONS" ] := (
    Block[ { DocumentationBuild`Utils`SafeNotebookExport },
        (* SafeNotebookExport tries to use parallel kernels for exporting, which we can't use in GitHub actions,
            so we redefine it to be a simple Export instead: *)
        DocumentationBuild`Utils`SafeNotebookExport[ file_, expr_, ___ ] := Export[ file, expr, "NB" ];

        eval
    ]
);

overrideNotebookExport[ eval_ ] := eval;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Run*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Build*)
result = Quiet[
    debugDocBuild @ checkResult @ cicd`BuildPaclet[
        $defNB,
        "Check"      -> $check,
        "ExitOnFail" -> True,
        "Target"     -> "Submit"
    ],
    {
        (* :!CodeAnalysis::BeginBlock:: *)
        (* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)
        CloudObject`Private`webLoginDialogInput::ninit,
        DocumentationSearch`Skeletonizer`Private`convertToString::unke,
        DocumentationSearch`Skeletonizer`Private`skeletonizeFiles::msgs
        (* :!CodeAnalysis::EndBlock:: *)
    }
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Install*)
If[ $install,
    archive = cFile @ result[ "PacletArchive" ];
    cicd`ConsoleNotice @ SequenceForm[ "Installing paclet file: ", archive ];
    installed = cicd`ScriptConfirmBy[ PacletInstall[ archive, ForceVersionInstall -> True ], PacletObjectQ ];
    cicd`ConsoleNotice @ SequenceForm[ "Installed paclet: ", cDir @ installed[ "Location" ] ];
];

(* Remove the built MX file if running locally: *)
If[ $mx && ! $keepMX,
    mxDir = FileNameJoin @ { $pacletDir, "Kernel", ToString @ $SystemWordLength <> "Bit" };
    cicd`ConsoleNotice @ SequenceForm[ "Removing MX directory: ", mxDir ];
    DeleteDirectory[ mxDir, DeleteContents -> True ]
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
EndPackage[ ];

Wolfram`MCPServerScripts`result