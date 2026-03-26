(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`AgentTools`Prompts`" ];

(* Symbols shared in Prompts subcontexts: *)
`$defaultMCPPrompts;

Begin[ "`Private`" ];

Needs[ "Wolfram`AgentTools`"        ];
Needs[ "Wolfram`AgentTools`Common`" ];

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
    "Wolfram`AgentTools`Prompts`Search`",
    "Wolfram`AgentTools`Prompts`Notebook`"
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
