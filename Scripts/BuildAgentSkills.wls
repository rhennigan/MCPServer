#!/usr/bin/env wolframscript

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
If[ ! PacletObjectQ @ PacletObject[ "Wolfram/PacletCICD" ],
    PacletInstall[ "https://github.com/WolframResearch/PacletCICD/releases/download/v0.36.2/Wolfram__PacletCICD-0.36.2.paclet" ]
];
Needs[ "Wolfram`PacletCICD`" -> "cicd`" ];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Paths*)
pacletDir     = cicd`ScriptConfirmBy[ DirectoryName[ $InputFileName, 2 ], DirectoryQ ];
agentSkillDir = cicd`ScriptConfirmBy[ GeneralUtilities`EnsureDirectory @ { pacletDir, "AgentSkills" }, DirectoryQ ];
manifestFile  = cicd`ScriptConfirmBy[ FileNameJoin @ { agentSkillDir, "Manifest.wl" }, FileExistsQ ];
manifest      = cicd`ScriptConfirmBy[ Get @ manifestFile, AssociationQ ];

(* TODO: Create a temporary build directory for scripts *)

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Load Paclet*)
cicd`ScriptConfirmBy[ PacletDirectoryLoad @ pacletDir, MemberQ @ pacletDir ];
cicd`ScriptConfirmMatch[ Get[ "Wolfram`MCPServer`" ], Null ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Build Agent Skill Scripts*)

(* TODO:
  - Build scripts from $DefaultMCPTools and save to temporary build directory
  - Copy scripts to the appropriate location for each skill declared in Manifest.wl
  - Delete the temporary build directory
*)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Build Agent Skills*)

(* TODO: Create distributable agent skills from the skills declared in Manifest.wl *)