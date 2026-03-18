(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*System Symbols*)
System`AgentToolsDeployment;
System`AgentToolsDeployments;
System`DeployAgentTools;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Exported Symbols*)
`$DefaultMCPPrompts;
`$DefaultMCPServers;
`$DefaultMCPToolOptions;
`$DefaultMCPTools;
`$LastMCPServerFailure;
`$LastMCPServerFailureText;
`$SupportedMCPClients;
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
    "Wolfram`MCPServer`Graphics`",
    "Wolfram`MCPServer`InstallMCPServer`",
    "Wolfram`MCPServer`MCPServerObject`",
    "Wolfram`MCPServer`Prompts`",
    "Wolfram`MCPServer`StartMCPServer`",
    "Wolfram`MCPServer`SupportedClients`",
    "Wolfram`MCPServer`TOML`",
    "Wolfram`MCPServer`Tools`",
    "Wolfram`MCPServer`UIResources`",
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
    "$DefaultMCPToolOptions",
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

SetAttributes[
    { AgentToolsDeployment, AgentToolsDeployments, DeployAgentTools },
    { Protected, ReadProtected }
];

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
