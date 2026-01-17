(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`DefaultServers`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

Needs[ "Wolfram`MCPServer`CreateMCPServer`" -> None ];
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
    $DefaultMCPServers = MCPServerObject /@ AssociationMap[ Apply @ Rule, $defaultMCPServers ],
    Protect @ $DefaultMCPServers
];

$defaultMCPServers = <| |>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*Wolfram*)
$defaultMCPServers[ "Wolfram" ] := <|
    "Name"          -> "Wolfram",
    "Location"      -> "BuiltIn",
    "Transport"     -> "StandardInputOutput",
    "ServerVersion" -> $pacletVersion,
    "ObjectVersion" -> $objectVersion,
    "LLMEvaluator"  -> <|
        "Tools" -> {
            "WolframContext",
            "WolframLanguageEvaluator",
            "WolframAlpha"
        }
    |>
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframAlpha*)
$defaultMCPServers[ "WolframAlpha" ] := <|
    "Name"          -> "WolframAlpha",
    "Location"      -> "BuiltIn",
    "Transport"     -> "StandardInputOutput",
    "ServerVersion" -> $pacletVersion,
    "ObjectVersion" -> $objectVersion,
    "LLMEvaluator"  -> <|
        "Tools" -> {
            "WolframAlphaContext",
            "WolframAlpha"
        }
    |>
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*WolframLanguage*)
$defaultMCPServers[ "WolframLanguage" ] := <|
    "Name"          -> "WolframLanguage",
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
            "TestReport"
        }
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
