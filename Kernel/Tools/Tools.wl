(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`" ];

(* Symbols shared in Tools subcontexts: *)
`$defaultMCPTools;
`importMarkdownString;
`useEvaluatorKernel;

Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*TODO*)
(*
    - BuildPaclet tool
    - ReloadPaclet tool
    - Log tool calls (and generate a notebook)
    - Add optional "description" parameter to evaluator tool (maybe all tools?)
    - Support image outputs from tools according to MCP spec
    - A RestartMCPServer tool? Is this possible?
    - A tool to open notebooks for the user, e.g. UsingFrontEnd[SystemOpen[notebookPath]]?
    - Group similar tools into groups and have another tool to activate them when needed to save on token usage
    - Documentation editing tools should have examples evaluation be optional
*)

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Default Tools*)
$DefaultMCPTools := WithCleanup[
    Unprotect @ $DefaultMCPTools,
    $DefaultMCPTools = KeySort @ AssociationMap[ Apply @ Rule, $defaultMCPTools ],
    Protect @ $DefaultMCPTools
];

(* $defaultMCPTools is an Association mapping tool names to LLMTool definitions. *)
(* Tool definitions are added in subcontext files loaded below.                  *)
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
    (* Tools: CodeInspector *)
    "Wolfram`MCPServer`Tools`CodeInspector`",

    (* Tools: WolframContext, WolframAlphaContext, WolframLanguageContext *)
    "Wolfram`MCPServer`Tools`Context`",

    (* Tools: ReadNotebook, WriteNotebook *)
    "Wolfram`MCPServer`Tools`Notebooks`",

    (* Tools: CreateSymbolPacletDocumentation, EditSymbolPacletDocumentation *)
    "Wolfram`MCPServer`Tools`PacletDocumentation`",

    (* Tools: SymbolDefinition *)
    "Wolfram`MCPServer`Tools`SymbolDefinition`",

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
