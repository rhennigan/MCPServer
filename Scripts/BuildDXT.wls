#!/usr/bin/env wolframscript

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)
If[ ! PacletObjectQ @ PacletObject[ "Wolfram/PacletCICD" ],
    PacletInstall[ "https://github.com/WolframResearch/PacletCICD/releases/download/v0.36.2/Wolfram__PacletCICD-0.36.2.paclet" ]
];
Needs[ "Wolfram`PacletCICD`" -> "cicd`" ];

pacletDir    = cicd`ScriptConfirmBy[ DirectoryName[ $InputFileName, 2 ], DirectoryQ ];
dxtSourceDir = cicd`ScriptConfirmBy[ FileNameJoin @ { pacletDir, "DXT" }, DirectoryQ ];
buildDir     = cicd`ScriptConfirmBy[ GeneralUtilities`EnsureDirectory @ { pacletDir, "build", "dxt" }, DirectoryQ ];

Quiet @ DeleteDirectory[ buildDir, DeleteContents -> True ];
cicd`ScriptConfirmBy[ CreateDirectory[ buildDir, CreateIntermediateDirectories -> True ], DirectoryQ ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Manifest*)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Template Parameters*)

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*PacletVersion*)
paclet  = cicd`ScriptConfirmBy[ PacletObject @ File @ pacletDir, PacletObjectQ ];
version = cicd`ScriptConfirmBy[ paclet[ "Version" ], StringQ ];

(* ::**************************************************************************************************************:: *)
(* ::Subsubsection::Closed:: *)
(*LongDescription*)
longDescription = cicd`ScriptConfirmBy[
    ByteArrayToString @ ReadByteArray @ FileNameJoin @ { dxtSourceDir, "Description.md" },
    StringQ
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Template*)
manifestTemplate = cicd`ScriptConfirmBy[ Get @ FileNameJoin @ { dxtSourceDir, "Manifest.wl" }, AssociationQ ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Generate Manifest*)
manifest = cicd`ScriptConfirmBy[
    TemplateApply[ manifestTemplate, <| "PacletVersion" -> version, "LongDescription" -> longDescription |> ],
    AssociationQ
];

manifestJSON = StringReplace[
    cicd`ScriptConfirmBy[ Developer`WriteRawJSONString @ manifest, StringQ ],
    "\\/" -> "/"
];

Print @ manifestJSON;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Generate Files*)
builtManifest = cicd`ScriptConfirmBy[
    Export[ FileNameJoin @ { buildDir, "manifest.json" }, StringToByteArray @ manifestJSON, "Binary" ],
    FileExistsQ
];

CreateFile[ FileNameJoin @ { buildDir, "server", "empty" }, CreateIntermediateDirectories -> True ];

cicd`ScriptConfirmBy[
    CopyDirectory[ FileNameJoin @ { dxtSourceDir, "Images" }, FileNameJoin @ { buildDir, "Images" } ],
    DirectoryQ
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Build DXT Package*)
zip = cicd`ScriptConfirmBy[
    CreateArchive[
        FileNames[ All, buildDir ],
        FileNameJoin @ { DirectoryName @ buildDir, "wolfram-engine.zip" },
        OverwriteTarget -> True
    ],
    FileExistsQ
];

builtDXT = CopyFile[ zip, StringReplace[ zip, ".zip"~~EndOfString -> ".dxt" ], OverwriteTarget -> True ];

cicd`ConsoleLog @ SequenceForm[ "Built DXT package: ", ToString @ builtDXT ];
(* :!CodeAnalysis::EndBlock:: *)