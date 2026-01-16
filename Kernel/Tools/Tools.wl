(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`" ];

(* Symbols shared in Tools subcontexts: *)
`$defaultMCPTools;
`exportMarkdownString;
`importMarkdownString;
`relatedDocumentation;
`relatedWolframAlphaPrompt;

Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Default Tools*)
$DefaultMCPTools := WithCleanup[
    Unprotect @ $DefaultMCPTools,
    $DefaultMCPTools = AssociationMap[ Apply @ Rule, $defaultMCPTools ],
    Protect @ $DefaultMCPTools
];

$defaultMCPTools = <| |>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Shared Resource Functions*)
importResourceFunction[ exportMarkdownString, "ExportMarkdownString" ];
importResourceFunction[ importMarkdownString, "ImportMarkdownString" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Load Subcontexts*)
$subcontexts = {
    "Wolfram`MCPServer`Tools`ReadNotebook`",
    "Wolfram`MCPServer`Tools`WolframAlpha`",
    "Wolfram`MCPServer`Tools`WolframAlphaContext`",
    "Wolfram`MCPServer`Tools`WolframContext`",
    "Wolfram`MCPServer`Tools`WolframLanguageContext`",
    "Wolfram`MCPServer`Tools`WolframLanguageEvaluator`",
    "Wolfram`MCPServer`Tools`WriteNotebook`"
};

Scan[ Needs[ # -> None ] &, $subcontexts ];

$MCPServerContexts = Union[ $MCPServerContexts, $subcontexts ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    $DefaultMCPTools
];

End[ ];
EndPackage[ ];
