(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Exported Symbols*)
`$DefaultMCPPrompts;
`$DefaultMCPServers;
`$DefaultMCPTools;
`$LastMCPServerFailure;
`$SupportedMCPClients;
`$LastMCPServerFailureText;
`CodeInspectorToolFunction;
`CreateMCPServer;
`InstallMCPServer;
`MCPServer;
`MCPServerObject;
`MCPServerObjectQ;
`MCPServerObjects;
`StartMCPServer;
`TestReportToolFunction;
`UninstallMCPServer;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Begin Private Context*)
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`Common`" ];

(* Avoiding context aliasing due to bug 434990: *)
Needs[ "GeneralUtilities`" -> None ];

(* Clear subcontexts from `$Packages` to force `Needs` to run again: *)
WithCleanup[
    Unprotect @ $Packages,
    $Packages = Select[ $Packages, Not @* StringStartsQ[ "Wolfram`MCPServer`"~~__~~"`" ] ],
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
    "Wolfram`MCPServer`",
    "Wolfram`MCPServer`Common`",
    "Wolfram`MCPServer`CreateMCPServer`",
    "Wolfram`MCPServer`DefaultServers`",
    "Wolfram`MCPServer`Files`",
    "Wolfram`MCPServer`Formatting`",
    "Wolfram`MCPServer`InstallMCPServer`",
    "Wolfram`MCPServer`MCPServerObject`",
    "Wolfram`MCPServer`Prompts`",
    "Wolfram`MCPServer`StartMCPServer`",
    "Wolfram`MCPServer`TOML`",
    "Wolfram`MCPServer`Tools`",
    "Wolfram`MCPServer`Utilities`"
};

Scan[ Needs[ # -> None ] &, $MCPServerContexts ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Names*)
$MCPServerSymbolNames = $MCPServerSymbolNames =
    Block[ { $Context, $ContextPath },
        Union[ Names[ "Wolfram`MCPServer`*" ], Names[ "Wolfram`MCPServer`*`*" ] ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Protected Symbols*)
$MCPServerProtectedNames = "Wolfram`MCPServer`" <> # & /@ {
    "$DefaultMCPPrompts",
    "$DefaultMCPServers",
    "$DefaultMCPTools",
    "$LastMCPServerFailure",
    "$LastMCPServerFailureText",
    "$SupportedMCPClients",
    "CodeInspectorToolFunction",
    "CreateMCPServer",
    "InstallMCPServer",
    "MCPServer",
    "MCPServerObject",
    "MCPServerObjectQ",
    "MCPServerObjects",
    "StartMCPServer",
    "TestReportToolFunction",
    "UninstallMCPServer"
};

Scan[ Protect, $MCPServerProtectedNames ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    $MCPServerContexts;
    $MCPServerSymbolNames;
    SetAttributes[ Evaluate @ Names[ "Wolfram`MCPServer`*" ], ReadProtected ];
];

mxInitialize[ ];

End[ ];
EndPackage[ ];
