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
(*Default Tools and Options*)
$DefaultMCPTools := WithCleanup[
    Unprotect @ $DefaultMCPTools,
    $DefaultMCPTools = insertCatchTop @ KeySort @ AssociationMap[ Apply @ Rule, $defaultMCPTools ],
    Protect @ $DefaultMCPTools
];

$DefaultMCPToolOptions := WithCleanup[
    Unprotect @ $DefaultMCPToolOptions,
    $DefaultMCPToolOptions = KeySort @ AssociationMap[ Apply @ Rule, $defaultToolOptions ],
    Protect @ $DefaultMCPToolOptions
];

(* $defaultMCPTools is an Association mapping tool names to LLMTool definitions. *)
(* Tool definitions and default options are added in subcontext files loaded below. *)
$defaultMCPTools    = <| |>;
$defaultToolOptions = <| |>;

(* Set at server startup from MCP_TOOL_OPTIONS environment variable: *)
$toolOptions = <| |>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*insertCatchTop*)
(* Ensures tool function calls are wrapped in `catchTop` in case they are evaluated separately *)
insertCatchTop // beginDefinition;

insertCatchTop[ tools_Association ] :=
    insertCatchTop /@ tools;

insertCatchTop[ HoldPattern @ LLMTool[ as: KeyValuePattern[ "Function" -> f_ ], rest___ ] ] :=
    LLMTool[ <| as, "Function" -> Function[ args, catchTop @ f @ args, HoldAllComplete ] |>, rest ];

insertCatchTop // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*toolOptionValue*)
toolOptionValue // beginDefinition;

toolOptionValue[ toolName_String, optionName_String ] := Enclose[
    Catch @ Module[ { options },
        options = ConfirmBy[ Lookup[ $toolOptions, toolName, <| |> ], AssociationQ, "ToolOptions" ];
        Lookup[
            options,
            optionName,
            Lookup[
                ConfirmBy[ Lookup[ $defaultToolOptions, toolName, <| |> ], AssociationQ, "Defaults" ],
                optionName,
                Missing[ "ToolOption", { toolName, optionName } ]
            ]
        ]
    ],
    throwInternalFailure
];

toolOptionValue // endDefinition;

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

    (* Tools: NotebookViewer *)
    "Wolfram`MCPServer`Tools`NotebookViewer`",

    (* Tools: MCPAppsTest *)
    "Wolfram`MCPServer`Tools`MCPAppsTest`",

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
    $DefaultMCPTools;
    $DefaultMCPToolOptions;
];

End[ ];
EndPackage[ ];
