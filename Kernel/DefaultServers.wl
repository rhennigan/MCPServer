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
(* The built-in servers set "EnableUsageData" -> True, which enables usage tracking for their local
   sessions unless an installation opts out via the "SubmitUsageData" option (see docs/usage-data.md). *)
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
    "Name"            -> "Wolfram",
    "MCPServerName"   -> "Wolfram",
    "Location"        -> "BuiltIn",
    "Transport"       -> "StandardInputOutput",
    "ServerVersion"   -> $pacletVersion,
    "ObjectVersion"   -> $objectVersion,
    "EnableUsageData" -> True,
    "LLMEvaluator"    -> <|
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
    "Name"            -> "WolframAlpha",
    "MCPServerName"   -> "Wolfram",
    "Location"        -> "BuiltIn",
    "Transport"       -> "StandardInputOutput",
    "ServerVersion"   -> $pacletVersion,
    "ObjectVersion"   -> $objectVersion,
    "EnableUsageData" -> True,
    "LLMEvaluator"    -> <|
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
    "Name"            -> "WolframLanguage",
    "MCPServerName"   -> "Wolfram",
    "Location"        -> "BuiltIn",
    "Transport"       -> "StandardInputOutput",
    "ServerVersion"   -> $pacletVersion,
    "ObjectVersion"   -> $objectVersion,
    "EnableUsageData" -> True,
    "LLMEvaluator"    -> <|
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
    "Name"            -> "WolframPacletDevelopment",
    "MCPServerName"   -> "Wolfram",
    "Location"        -> "BuiltIn",
    "Transport"       -> "StandardInputOutput",
    "ServerVersion"   -> $pacletVersion,
    "ObjectVersion"   -> $objectVersion,
    "EnableUsageData" -> True,
    "LLMEvaluator"    -> <|
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
            "EditSymbolDocExamples",
            "CheckPaclet",
            "BuildPaclet",
            "SubmitPaclet"
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
