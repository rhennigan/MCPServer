(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`AgentTools`DefaultServers`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`AgentTools`"        ];
Needs[ "Wolfram`AgentTools`Common`" ];

Needs[ "Wolfram`AgentTools`CreateMCPServer`" -> None ];
Needs[ "Wolfram`Chatbook`" -> "cb`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Configuration*)
$defaultMCPServer = "Wolfram";

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*$DefaultMCPServers*)
$DefaultMCPServers := WithCleanup[
    Unprotect @ $DefaultMCPServers,
    $DefaultMCPServers = MCPServerObject /@ KeySort @ AssociationMap[ Apply @ Rule, $defaultMCPServers ],
    Protect @ $DefaultMCPServers
];

$defaultMCPServers = <| |>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Wolfram*)
$defaultMCPServers[ "Wolfram" ] := <|
    "Name"          -> "Wolfram",
    "MCPServerName" -> "Wolfram",
    "Location"      -> "BuiltIn",
    "Transport"     -> "StandardInputOutput",
    "ServerVersion" -> $pacletVersion,
    "ObjectVersion" -> $objectVersion,
    "LLMEvaluator"  -> <|
        "Tools" -> {
            "WolframContext",
            "WolframLanguageEvaluator",
            "WolframAlpha"
        },
        "MCPPrompts" -> { "WolframSearch" }
    |>
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframAlpha*)
$defaultMCPServers[ "WolframAlpha" ] := <|
    "Name"          -> "WolframAlpha",
    "MCPServerName" -> "Wolfram",
    "Location"      -> "BuiltIn",
    "Transport"     -> "StandardInputOutput",
    "ServerVersion" -> $pacletVersion,
    "ObjectVersion" -> $objectVersion,
    "LLMEvaluator"  -> <|
        "Tools" -> {
            "WolframAlphaContext",
            "WolframAlpha"
        },
        "MCPPrompts" -> { "WolframAlphaSearch" }
    |>
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframLanguage*)
$defaultMCPServers[ "WolframLanguage" ] := <|
    "Name"          -> "WolframLanguage",
    "MCPServerName" -> "Wolfram",
    "Location"      -> "BuiltIn",
    "Transport"     -> "StandardInputOutput",
    "ServerVersion" -> $pacletVersion,
    "ObjectVersion" -> $objectVersion,
    "LLMEvaluator"  -> <|
        "Tools" -> {
            "WolframLanguageContext",
            "WolframLanguageEvaluator",
            "ReadNotebook",
            "WriteNotebook",
            "SymbolDefinition",
            "CodeInspector",
            "TestReport"
        },
        "MCPPrompts" -> { "WolframLanguageSearch", "Notebook" }
    |>
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframPacletDevelopment*)
$defaultMCPServers[ "WolframPacletDevelopment" ] := <|
    "Name"          -> "WolframPacletDevelopment",
    "MCPServerName" -> "Wolfram",
    "Location"      -> "BuiltIn",
    "Transport"     -> "StandardInputOutput",
    "ServerVersion" -> $pacletVersion,
    "ObjectVersion" -> $objectVersion,
    "LLMEvaluator"  -> <|
        "Tools" -> {
            "WolframLanguageContext",
            "WolframLanguageEvaluator",
            "ReadNotebook",
            "WriteNotebook",
            "SymbolDefinition",
            "CodeInspector",
            "TestReport",
            "CreateSymbolDoc",
            "EditSymbolDoc",
            "EditSymbolDocExamples"
        },
        "MCPPrompts" -> { "WolframLanguageSearch", "Notebook" }
    |>
|>;

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    $DefaultMCPServers
];

End[ ];
EndPackage[ ];
