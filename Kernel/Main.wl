(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "RickHennigan`MCPServer`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Exported Symbols*)
`$DefaultMCPServers;
`$LastMCPServerFailure;
`$LastMCPServerFailureText;
`CreateMCPServer;
`InstallMCPServer;
`MCPServer;
`MCPServerObject;
`MCPServerObjectQ;
`MCPServerObjects;
`StartMCPServer;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Begin Private Context*)
Begin[ "`Private`" ];

Needs[ "RickHennigan`MCPServer`Common`" ];

(* Avoiding context aliasing due to bug 434990: *)
Needs[ "GeneralUtilities`" -> None ];

(* Clear subcontexts from `$Packages` to force `Needs` to run again: *)
WithCleanup[
    Unprotect @ $Packages,
    $Packages = Select[ $Packages, Not @* StringStartsQ[ "RickHennigan`MCPServer`"~~__~~"`" ] ],
    Protect @ $Packages
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Usage Messages*)
GeneralUtilities`SetUsage[ MCPServer, "MCPServer is a symbol for miscellaneous messages." ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Load Files*)
$MCPServerContexts = {
    "RickHennigan`MCPServer`",
    "RickHennigan`MCPServer`Common`",
    "RickHennigan`MCPServer`CreateMCPServer`",
    "RickHennigan`MCPServer`DefaultServers`",
    "RickHennigan`MCPServer`Files`",
    "RickHennigan`MCPServer`Formatting`",
    "RickHennigan`MCPServer`InstallMCPServer`",
    "RickHennigan`MCPServer`MCPServerObject`",
    "RickHennigan`MCPServer`StartMCPServer`"
};

Scan[ Needs[ # -> None ] &, $MCPServerContexts ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Names*)
$MCPServerSymbolNames = $MCPServerSymbolNames =
    Block[ { $Context, $ContextPath },
        Union[ Names[ "RickHennigan`MCPServer`*" ], Names[ "RickHennigan`MCPServer`*`*" ] ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Protected Symbols*)
$MCPServerProtectedNames = "RickHennigan`MCPServer`" <> # & /@ {
    "$DefaultMCPServers",
    "$LastMCPServerFailure",
    "$LastMCPServerFailureText",
    "CreateMCPServer",
    "InstallMCPServer",
    "MCPServer",
    "MCPServerObject",
    "MCPServerObjectQ",
    "MCPServerObjects",
    "StartMCPServer"
};

(* ::**************************************************************************************************************:: *)
(*Package Footer*)
addToMXInitialization[
    $MCPServerContexts;
    $MCPServerSymbolNames;
    SetAttributes[ Evaluate @ Names[ "RickHennigan`MCPServer`*" ], ReadProtected ];
];

mxInitialize[ ];

End[ ];
EndPackage[ ];
