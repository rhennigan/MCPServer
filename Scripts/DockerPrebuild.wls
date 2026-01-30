#!/usr/bin/env wolframscript

(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::SuspiciousSessionSymbol:: *)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*About*)

(*
    This script runs during the Docker build to pre-install dependencies into the image.
    It installs required paclets and vector databases so they don't need to be downloaded at runtime.
    This is necessary because the container runs with -pacletreadonly to prevent runtime modifications.
*)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Config*)
(* Paclets that need to be updated in the Docker image: *)
$pacletNames = { "Wolfram/Chatbook" -> "2.5.0", "Wolfram/LLMFunctions" -> "2.2.6" };

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Update Paclets*)
PacletSiteUpdate @ PacletSites[ ];
paclets = PacletInstall /@ $pacletNames;

If[ ! MatchQ[ paclets, { __PacletObject } ],
    Print[ "[ERROR] Failed to install paclets: ", ToString[ paclets, InputForm ] ];
    Exit[ 1 ]
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Install Vector Databases and Related Resources*)
<< Wolfram`Chatbook`;
installed = Wolfram`Chatbook`InstallVectorDatabases[ ];

If[ ! MatchQ[ installed, _Success ],
    Print[ "[ERROR] Failed to install vector databases: ", ToString[ installed, InputForm ] ];
    Exit[ 1 ]
];

(* Performs a search using the vector databases, installing any additional dependencies in the process: *)
uris = Wolfram`Chatbook`RelatedDocumentation[ "Test prompt, please ignore" ];
If[ ! MatchQ[ uris, { __URL } ],
    Print[ "[ERROR] Failed to get related documentation: ", ToString[ uris, InputForm ] ];
    Exit[ 1 ]
];

Exit[ 0 ];

(* :!CodeAnalysis::EndBlock:: *)