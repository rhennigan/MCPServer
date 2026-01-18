(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`" ];

(* Symbols shared in Tools subcontexts: *)
`$defaultMCPTools;
`exportMarkdownString;
`importMarkdownString;

Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*TODO*)
(*
    - CodeInspector tool
    - BuildPaclet tool
    - ReloadPaclet tool
    - DefinitionViewer tool
    - Log tool calls (and generate a notebook)
    - Add optional "description" parameter to evaluator tool (maybe all tools?)
    - Support setting sandbox directory for evaluator tool via environment variable
*)

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
    (* Tools: WolframContext, WolframAlphaContext, WolframLanguageContext *)
    "Wolfram`MCPServer`Tools`Context`",

    (* Tools: ReadNotebook, WriteNotebook *)
    "Wolfram`MCPServer`Tools`Notebooks`",

    (* Tools: CreateSymbolPacletDocumentation, EditSymbolPacletDocumentation *)
    "Wolfram`MCPServer`Tools`PacletDocumentation`",

    (* Tools: TestReport *)
    "Wolfram`MCPServer`Tools`TestReport`",

    (* Tools: WolframAlpha *)
    "Wolfram`MCPServer`Tools`WolframAlpha`",

    (* Tools: WolframLanguageEvaluator *)
    "Wolfram`MCPServer`Tools`WolframLanguageEvaluator`"
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
