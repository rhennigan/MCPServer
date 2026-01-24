(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Prompts`" ];

(* Symbols shared in Prompts subcontexts: *)
`$defaultMCPPrompts;

Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Default Prompts*)
$DefaultMCPPrompts := WithCleanup[
    Unprotect @ $DefaultMCPPrompts,
    $DefaultMCPPrompts = AssociationMap[ Apply @ Rule, $defaultMCPPrompts ],
    Protect @ $DefaultMCPPrompts
];

(* $defaultMCPPrompts is an Association mapping prompt names to prompt definitions. *)
(* Prompt definitions are added in subcontext files loaded below.                   *)
$defaultMCPPrompts = <| |>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Load Subcontexts*)
$subcontexts = {
    "Wolfram`MCPServer`Prompts`Search`",
    "Wolfram`MCPServer`Prompts`Notebook`"
};

Scan[ Needs[ # -> None ] &, $subcontexts ];

$MCPServerContexts = Union[ $MCPServerContexts, $subcontexts ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    $DefaultMCPPrompts
];

End[ ];
EndPackage[ ];
