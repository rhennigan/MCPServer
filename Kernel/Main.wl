(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`AgentTools`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*System Symbols*)
System`AgentToolsDeployment;
System`DeployedAgentTools;
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
`ValidateAgentToolsPacletExtension;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Begin Private Context*)
Begin[ "`Private`" ];

Needs[ "Wolfram`AgentTools`Common`" ];

(* Avoiding context aliasing due to bug 434990: *)
Needs[ "GeneralUtilities`" -> None ];

(* Clear subcontexts from `$Packages` to force `Needs` to run again: *)
WithCleanup[
    Unprotect @ $Packages,
    $Packages = Select[ $Packages, Not @* StringStartsQ[ "Wolfram`AgentTools`"~~__~~"`" ] ],
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
    "Wolfram`AgentTools`",
    "Wolfram`AgentTools`Common`",
    "Wolfram`AgentTools`CreateMCPServer`",
    "Wolfram`AgentTools`DefaultServers`",
    "Wolfram`AgentTools`DeployAgentTools`",
    "Wolfram`AgentTools`Files`",
    "Wolfram`AgentTools`Formatting`",
    "Wolfram`AgentTools`Graphics`",
    "Wolfram`AgentTools`InstallMCPServer`",
    "Wolfram`AgentTools`MCPServerObject`",
    "Wolfram`AgentTools`PacletExtension`",
    "Wolfram`AgentTools`Prompts`",
    "Wolfram`AgentTools`StartMCPServer`",
    "Wolfram`AgentTools`SupportedClients`",
    "Wolfram`AgentTools`TOML`",
    "Wolfram`AgentTools`Tools`",
    "Wolfram`AgentTools`UIResources`",
    "Wolfram`AgentTools`Utilities`",
    "Wolfram`AgentTools`ValidateAgentToolsPacletExtension`"
};

Scan[ Needs[ # -> None ] &, $MCPServerContexts ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Names*)
$MCPServerSymbolNames = $MCPServerSymbolNames =
    Block[ { $Context, $ContextPath },
        Union[ Names[ "Wolfram`AgentTools`*" ], Names[ "Wolfram`AgentTools`*`*" ] ]
    ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Protected Symbols*)
$MCPServerProtectedNames = "Wolfram`AgentTools`" <> # & /@ {
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
    "AgentTools",
    "MCPServerObject",
    "MCPServerObjectQ",
    "MCPServerObjects",
    "StartMCPServer",
    "TestReportToolFunction",
    "UninstallMCPServer",
    "ValidateAgentToolsPacletExtension"
};

Scan[ Protect, $MCPServerProtectedNames ];

SetAttributes[
    { AgentToolsDeployment, DeployedAgentTools, DeployAgentTools },
    { Protected, ReadProtected }
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    $MCPServerContexts;
    $MCPServerSymbolNames;
    SetAttributes[ Evaluate @ Names[ "Wolfram`AgentTools`*" ], ReadProtected ];
];

mxInitialize[ ];

End[ ];
EndPackage[ ];
