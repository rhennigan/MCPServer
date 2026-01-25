(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::Section:: *)
(* Initialization *)

VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/Prompts.wlt:7,1-12,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/Prompts.wlt:14,1-19,2"
]

(* ::Section:: *)
(* $DefaultMCPPrompts *)

VerificationTest[
    $DefaultMCPPrompts,
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "DefaultMCPPrompts-IsAssociation@@Tests/Prompts.wlt:24,1-29,2"
]

VerificationTest[
    Sort @ Keys @ $DefaultMCPPrompts,
    { "Notebook", "WolframAlphaSearch", "WolframLanguageSearch", "WolframSearch" },
    SameTest -> SameQ,
    TestID   -> "DefaultMCPPrompts-Keys@@Tests/Prompts.wlt:31,1-36,2"
]

VerificationTest[
    AllTrue[ Values @ $DefaultMCPPrompts, AssociationQ ],
    True,
    SameTest -> SameQ,
    TestID   -> "DefaultMCPPrompts-AllAssociations@@Tests/Prompts.wlt:38,1-43,2"
]

(* ::Section:: *)
(* Prompt Properties *)

VerificationTest[
    AllTrue[ $DefaultMCPPrompts, StringQ @ #[ "Name" ] & ],
    True,
    SameTest -> SameQ,
    TestID   -> "PromptProperties-AllHaveNames@@Tests/Prompts.wlt:48,1-53,2"
]

VerificationTest[
    AllTrue[ $DefaultMCPPrompts, StringQ @ #[ "Description" ] & ],
    True,
    SameTest -> SameQ,
    TestID   -> "PromptProperties-AllHaveDescriptions@@Tests/Prompts.wlt:55,1-60,2"
]

VerificationTest[
    AllTrue[ $DefaultMCPPrompts, MemberQ[ { "Function", "Text" }, #[ "Type" ] ] & ],
    True,
    SameTest -> SameQ,
    TestID   -> "PromptProperties-AllHaveValidType@@Tests/Prompts.wlt:62,1-67,2"
]

VerificationTest[
    AllTrue[ $DefaultMCPPrompts, MatchQ[ #[ "Arguments" ], { ___Association } ] & ],
    True,
    SameTest -> SameQ,
    TestID   -> "PromptProperties-AllHaveArguments@@Tests/Prompts.wlt:69,1-74,2"
]

VerificationTest[
    AllTrue[ $DefaultMCPPrompts, MatchQ[ #[ "Content" ], _Symbol | _Function ] & ],
    True,
    SameTest -> MatchQ,
    TestID   -> "PromptProperties-AllHaveContent@@Tests/Prompts.wlt:76,1-81,2"
]

(* ::Section:: *)
(* MCP Name Mapping *)

VerificationTest[
    Union @ Map[ #[ "Name" ] &, Values @ $DefaultMCPPrompts ],
    { "Notebook", "Search" },
    SameTest -> SameQ,
    TestID   -> "MCPNameMapping-PromptNames@@Tests/Prompts.wlt:86,1-91,2"
]

(* ::Section:: *)
(* Individual Prompt Definitions *)

VerificationTest[
    $DefaultMCPPrompts[ "WolframSearch" ][ "Name" ],
    "Search",
    SameTest -> SameQ,
    TestID   -> "WolframSearch-HasCorrectName@@Tests/Prompts.wlt:96,1-101,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframSearch" ][ "Type" ],
    "Function",
    SameTest -> SameQ,
    TestID   -> "WolframSearch-HasCorrectType@@Tests/Prompts.wlt:103,1-108,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframLanguageSearch" ][ "Name" ],
    "Search",
    SameTest -> SameQ,
    TestID   -> "WolframLanguageSearch-HasCorrectName@@Tests/Prompts.wlt:110,1-115,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframLanguageSearch" ][ "Type" ],
    "Function",
    SameTest -> SameQ,
    TestID   -> "WolframLanguageSearch-HasCorrectType@@Tests/Prompts.wlt:117,1-122,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframAlphaSearch" ][ "Name" ],
    "Search",
    SameTest -> SameQ,
    TestID   -> "WolframAlphaSearch-HasCorrectName@@Tests/Prompts.wlt:124,1-129,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframAlphaSearch" ][ "Type" ],
    "Function",
    SameTest -> SameQ,
    TestID   -> "WolframAlphaSearch-HasCorrectType@@Tests/Prompts.wlt:131,1-136,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "Notebook" ][ "Name" ],
    "Notebook",
    SameTest -> SameQ,
    TestID   -> "Notebook-HasCorrectName@@Tests/Prompts.wlt:138,1-143,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "Notebook" ][ "Type" ],
    "Function",
    SameTest -> SameQ,
    TestID   -> "Notebook-HasCorrectType@@Tests/Prompts.wlt:145,1-150,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "Notebook" ][ "Arguments" ],
    { KeyValuePattern @ { "Name" -> "path", "Required" -> True } },
    SameTest -> MatchQ,
    TestID   -> "Notebook-HasPathArgument@@Tests/Prompts.wlt:152,1-157,2"
]

(* ::Section:: *)
(* Argument Specifications *)

VerificationTest[
    $DefaultMCPPrompts[ "WolframSearch" ][ "Arguments" ],
    { KeyValuePattern @ { "Name" -> "query", "Required" -> True } },
    SameTest -> MatchQ,
    TestID   -> "WolframSearch-HasQueryArgument@@Tests/Prompts.wlt:162,1-167,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframLanguageSearch" ][ "Arguments" ],
    { KeyValuePattern @ { "Name" -> "query", "Required" -> True } },
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageSearch-HasQueryArgument@@Tests/Prompts.wlt:169,1-174,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframAlphaSearch" ][ "Arguments" ],
    { KeyValuePattern @ { "Name" -> "query", "Required" -> True } },
    SameTest -> MatchQ,
    TestID   -> "WolframAlphaSearch-HasQueryArgument@@Tests/Prompts.wlt:176,1-181,2"
]

(* ::Section:: *)
(* Validation Functions *)

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ "WolframSearch" ],
    { "WolframSearch" },
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompts-SingleString@@Tests/Prompts.wlt:186,1-191,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ { "WolframSearch", "WolframLanguageSearch" } ],
    { "WolframSearch", "WolframLanguageSearch" },
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompts-ListOfStrings@@Tests/Prompts.wlt:193,1-198,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ { <| "Name" -> "Custom" |> } ],
    { <| "Name" -> "Custom" |> },
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompts-InlineAssociation@@Tests/Prompts.wlt:200,1-205,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ { "WolframSearch", <| "Name" -> "Custom" |> } ],
    { "WolframSearch", <| "Name" -> "Custom" |> },
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompts-MixedList@@Tests/Prompts.wlt:207,1-212,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ "NonExistentPrompt" ],
    _Failure,
    { MCPServer::PromptNameNotFound, MCPServer::InvalidMCPPromptsSpecification },
    SameTest -> MatchQ,
    TestID   -> "ValidateMCPPrompts-InvalidName@@Tests/Prompts.wlt:214,1-220,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ 123 ],
    _Failure,
    { MCPServer::InvalidMCPPromptsSpecification },
    SameTest -> MatchQ,
    TestID   -> "ValidateMCPPrompts-InvalidType@@Tests/Prompts.wlt:222,1-228,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompt[ "WolframSearch" ],
    "WolframSearch",
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompt-ValidString@@Tests/Prompts.wlt:230,1-235,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompt[ <| "Name" -> "Custom" |> ],
    <| "Name" -> "Custom" |>,
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompt-Association@@Tests/Prompts.wlt:237,1-242,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompt[ "NonExistent" ],
    _Failure,
    { MCPServer::PromptNameNotFound },
    SameTest -> MatchQ,
    TestID   -> "ValidateMCPPrompt-InvalidName@@Tests/Prompts.wlt:244,1-250,2"
]

(* ::Section:: *)
(* normalizePromptData *)

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`normalizePromptData[ "WolframSearch" ],
    $DefaultMCPPrompts[ "WolframSearch" ],
    SameTest -> SameQ,
    TestID   -> "NormalizePromptData-StringLookup@@Tests/Prompts.wlt:255,1-260,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`normalizePromptData[ <| "Name" -> "Test", "Content" -> "Static text" |> ],
    <| "Name" -> "Test", "Content" -> "Static text", "Type" -> "Text" |>,
    SameTest -> SameQ,
    TestID   -> "NormalizePromptData-TextType@@Tests/Prompts.wlt:262,1-267,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`normalizePromptData[ <| "Name" -> "Test", "Content" -> Function[ x, x ] |> ],
    KeyValuePattern[ "Type" -> "Function" ],
    SameTest -> MatchQ,
    TestID   -> "NormalizePromptData-FunctionType@@Tests/Prompts.wlt:269,1-274,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`normalizePromptData[ "NonExistent" ],
    _Failure,
    { MCPServer::PromptNameNotFound },
    SameTest -> MatchQ,
    TestID   -> "NormalizePromptData-InvalidName@@Tests/Prompts.wlt:276,1-282,2"
]

(* ::Section:: *)
(* determinePromptType *)

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| "Type" -> "Function" |> ],
    "Function",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-ExplicitFunction@@Tests/Prompts.wlt:287,1-292,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| "Type" -> "Text" |> ],
    "Text",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-ExplicitText@@Tests/Prompts.wlt:294,1-299,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| "Content" -> "Some string" |> ],
    "Text",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-StringContent@@Tests/Prompts.wlt:301,1-306,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| "Content" -> Identity |> ],
    "Function",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-FunctionContent@@Tests/Prompts.wlt:308,1-313,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| |> ],
    "Text",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-EmptyDefault@@Tests/Prompts.wlt:315,1-320,2"
]

(* ::Section:: *)
(* MCPServerObject PromptData Property *)

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`getPromptData[
        <| "LLMEvaluator" -> <| "MCPPrompts" -> { "WolframSearch" } |> |>
    ],
    { $DefaultMCPPrompts[ "WolframSearch" ] },
    SameTest -> SameQ,
    TestID   -> "GetPromptData-WithMCPPrompts@@Tests/Prompts.wlt:325,1-332,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`getPromptData[
        <| "LLMEvaluator" -> <| |> |>
    ],
    { },
    SameTest -> SameQ,
    TestID   -> "GetPromptData-NoPrompts@@Tests/Prompts.wlt:334,1-341,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`getPromptData[
        <| "LLMEvaluator" -> <| "MCPPrompts" -> { "WolframSearch", "WolframLanguageSearch" } |> |>
    ],
    { $DefaultMCPPrompts[ "WolframSearch" ], $DefaultMCPPrompts[ "WolframLanguageSearch" ] },
    SameTest -> SameQ,
    TestID   -> "GetPromptData-MultiplePrompts@@Tests/Prompts.wlt:343,1-350,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`getPromptData[
        <| "LLMEvaluator" -> <| "MCPPrompts" -> { <| "Name" -> "Custom", "Content" -> "Test" |> } |> |>
    ],
    { <| "Name" -> "Custom", "Content" -> "Test", "Type" -> "Text" |> },
    SameTest -> SameQ,
    TestID   -> "GetPromptData-InlinePrompt@@Tests/Prompts.wlt:352,1-359,2"
]

(* ::Section:: *)
(* Deprecation Warning *)

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`getPromptData[
        <| "LLMEvaluator" -> <| "PromptData" -> { <| "Name" -> "Test" |> } |> |>
    ],
    _Failure,
    { MCPServer::DeprecatedPromptData },
    SameTest -> MatchQ,
    TestID   -> "GetPromptData-DeprecatedPromptDataFails@@Tests/Prompts.wlt:364,1-372,2"
]

(* ::Section:: *)
(* makePromptContent (Phase 3) *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        <| "Type" -> "Function", "Content" -> Function[ args, "Result: " <> args[ "query" ] ] |>,
        <| "query" -> "test" |>
    ],
    <| "type" -> "text", "text" -> "Result: test" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-FunctionType@@Tests/Prompts.wlt:377,1-385,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        <| "Type" -> "Text", "Content" -> "Static content" |>,
        <| |>
    ],
    <| "type" -> "text", "text" -> "Static content" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-TextType@@Tests/Prompts.wlt:387,1-395,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        <| "Content" -> "No explicit type" |>,
        <| |>
    ],
    <| "type" -> "text", "text" -> "No explicit type" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-NoExplicitType@@Tests/Prompts.wlt:397,1-405,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        <| "Content" -> StringTemplate[ "Hello, `name`!" ] |>,
        <| "name" -> "World" |>
    ],
    <| "type" -> "text", "text" -> "Hello, World!" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-StringTemplate@@Tests/Prompts.wlt:407,1-415,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        "Plain string",
        <| |>
    ],
    <| "type" -> "text", "text" -> "Plain string" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-PlainString@@Tests/Prompts.wlt:417,1-425,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        12345,
        <| |>
    ],
    <| "type" -> "text", "text" -> "12345" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-Fallback@@Tests/Prompts.wlt:427,1-435,2"
]

(* ::Section:: *)
(* makePromptData (Phase 3) *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptData[ {
        <| "Name" -> "Test", "Description" -> "A test prompt" |>
    } ],
    { <| "name" -> "Test", "description" -> "A test prompt" |> },
    SameTest -> SameQ,
    TestID   -> "MakePromptData-CapitalizedKeys@@Tests/Prompts.wlt:440,1-447,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptData[ {
        <| "name" -> "Test", "description" -> "A test prompt" |>
    } ],
    { <| "name" -> "Test", "description" -> "A test prompt" |> },
    SameTest -> SameQ,
    TestID   -> "MakePromptData-LowercaseKeys@@Tests/Prompts.wlt:449,1-456,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptData[ {
        <|
            "Name" -> "Test",
            "Description" -> "A test prompt",
            "Arguments" -> {
                <| "Name" -> "arg1", "Description" -> "First arg", "Required" -> True |>
            }
        |>
    } ],
    {
        <|
            "name" -> "Test",
            "description" -> "A test prompt",
            "arguments" -> {
                <| "name" -> "arg1", "description" -> "First arg", "required" -> True |>
            }
        |>
    },
    SameTest -> SameQ,
    TestID   -> "MakePromptData-WithArguments@@Tests/Prompts.wlt:458,1-479,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptData[ {
        <| "Name" -> "NoArgs" |>
    } ],
    { <| "name" -> "NoArgs", "description" -> "" |> },
    SameTest -> SameQ,
    TestID   -> "MakePromptData-NoArguments@@Tests/Prompts.wlt:481,1-488,2"
]

(* ::Section:: *)
(* normalizeArguments (Phase 3) *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArguments[ {
        <| "Name" -> "query", "Description" -> "The search query", "Required" -> True |>
    } ],
    { <| "name" -> "query", "description" -> "The search query", "required" -> True |> },
    SameTest -> SameQ,
    TestID   -> "NormalizeArguments-CapitalizedKeys@@Tests/Prompts.wlt:493,1-500,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArguments[ {
        <| "name" -> "query", "description" -> "The search query", "required" -> True |>
    } ],
    { <| "name" -> "query", "description" -> "The search query", "required" -> True |> },
    SameTest -> SameQ,
    TestID   -> "NormalizeArguments-LowercaseKeys@@Tests/Prompts.wlt:502,1-509,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArguments[ {
        <| "Name" -> "arg1" |>,
        <| "Name" -> "arg2", "Required" -> False |>
    } ],
    {
        <| "name" -> "arg1", "description" -> "", "required" -> False |>,
        <| "name" -> "arg2", "description" -> "", "required" -> False |>
    },
    SameTest -> SameQ,
    TestID   -> "NormalizeArguments-MultipleWithDefaults@@Tests/Prompts.wlt:511,1-522,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArguments[ { } ],
    { },
    SameTest -> SameQ,
    TestID   -> "NormalizeArguments-Empty@@Tests/Prompts.wlt:524,1-529,2"
]

(* ::Section:: *)
(* normalizeArgument (Phase 3) *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArgument[
        <| "Name" -> "query", "Description" -> "The query", "Required" -> True |>
    ],
    <| "name" -> "query", "description" -> "The query", "required" -> True |>,
    SameTest -> SameQ,
    TestID   -> "NormalizeArgument-AllFields@@Tests/Prompts.wlt:534,1-541,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArgument[
        <| "Name" -> "query" |>
    ],
    <| "name" -> "query", "description" -> "", "required" -> False |>,
    SameTest -> SameQ,
    TestID   -> "NormalizeArgument-DefaultValues@@Tests/Prompts.wlt:543,1-550,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArgument[
        <| "name" -> "query", "description" -> "Lowercase keys", "required" -> True |>
    ],
    <| "name" -> "query", "description" -> "Lowercase keys", "required" -> True |>,
    SameTest -> SameQ,
    TestID   -> "NormalizeArgument-LowercaseKeys@@Tests/Prompts.wlt:552,1-559,2"
]

(* ::Section:: *)
(* Server Configuration (Phase 4) *)

VerificationTest[
    $DefaultMCPServers[ "Wolfram" ][ "MCPPrompts" ],
    { "WolframSearch" },
    SameTest -> SameQ,
    TestID   -> "ServerConfig-WolframHasMCPPrompts@@Tests/Prompts.wlt:564,1-569,2"
]

VerificationTest[
    $DefaultMCPServers[ "WolframAlpha" ][ "MCPPrompts" ],
    { "WolframAlphaSearch" },
    SameTest -> SameQ,
    TestID   -> "ServerConfig-WolframAlphaHasMCPPrompts@@Tests/Prompts.wlt:571,1-576,2"
]

VerificationTest[
    $DefaultMCPServers[ "WolframLanguage" ][ "MCPPrompts" ],
    { "WolframLanguageSearch", "Notebook" },
    SameTest -> SameQ,
    TestID   -> "ServerConfig-WolframLanguageHasMCPPrompts@@Tests/Prompts.wlt:578,1-583,2"
]

VerificationTest[
    $DefaultMCPServers[ "WolframPacletDevelopment" ][ "MCPPrompts" ],
    { "WolframLanguageSearch", "Notebook" },
    SameTest -> SameQ,
    TestID   -> "ServerConfig-WolframPacletDevelopmentHasMCPPrompts@@Tests/Prompts.wlt:585,1-590,2"
]

(* ::Subsection:: *)
(* Server PromptData Property *)

VerificationTest[
    MCPServerObject[ "Wolfram" ][ "PromptData" ],
    { KeyValuePattern[ "Name" -> "Search" ] },
    SameTest -> MatchQ,
    TestID   -> "ServerPromptData-Wolfram@@Tests/Prompts.wlt:595,1-600,2"
]

VerificationTest[
    MCPServerObject[ "WolframAlpha" ][ "PromptData" ],
    { KeyValuePattern[ "Name" -> "Search" ] },
    SameTest -> MatchQ,
    TestID   -> "ServerPromptData-WolframAlpha@@Tests/Prompts.wlt:602,1-607,2"
]

VerificationTest[
    MCPServerObject[ "WolframLanguage" ][ "PromptData" ],
    { KeyValuePattern[ "Name" -> "Search" ], KeyValuePattern[ "Name" -> "Notebook" ] },
    SameTest -> MatchQ,
    TestID   -> "ServerPromptData-WolframLanguage@@Tests/Prompts.wlt:609,1-614,2"
]

VerificationTest[
    MCPServerObject[ "WolframPacletDevelopment" ][ "PromptData" ],
    { KeyValuePattern[ "Name" -> "Search" ], KeyValuePattern[ "Name" -> "Notebook" ] },
    SameTest -> MatchQ,
    TestID   -> "ServerPromptData-WolframPacletDevelopment@@Tests/Prompts.wlt:616,1-621,2"
]

(* ::Subsection:: *)
(* All Servers Have Correct Prompt Type *)

VerificationTest[
    AllTrue[
        { "Wolfram", "WolframAlpha", "WolframLanguage", "WolframPacletDevelopment" },
        Function[ name,
            MatchQ[
                MCPServerObject[ name ][ "PromptData" ],
                { KeyValuePattern[ "Type" -> "Function" ]... }
            ]
        ]
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "ServerPromptData-AllHaveFunctionType@@Tests/Prompts.wlt:626,1-639,2"
]

(* ::Subsection:: *)
(* Prompt Names Match Across Servers *)

VerificationTest[
    Union @ Flatten @ Map[
        Function[ name, #[ "Name" ] & /@ MCPServerObject[ name ][ "PromptData" ] ],
        { "Wolfram", "WolframAlpha", "WolframLanguage", "WolframPacletDevelopment" }
    ],
    { "Notebook", "Search" },
    SameTest -> SameQ,
    TestID   -> "ServerPromptData-PromptNames@@Tests/Prompts.wlt:644,1-652,2"
]

(* ::Section:: *)
(* Error Handling (Phase 5) *)

(* ::Subsection:: *)
(* catchPromptFunction *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`catchPromptFunction[
        Function[ args, "Success: " <> args[ "query" ] ],
        <| "query" -> "test" |>
    ],
    "Success: test",
    SameTest -> SameQ,
    TestID   -> "CatchPromptFunction-Success@@Tests/Prompts.wlt:660,1-668,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`catchPromptFunction[
        Function[ args, Failure[ "TestError", <| "MessageTemplate" -> "Something went wrong" |> ] ],
        <| "query" -> "test" |>
    ],
    "[Error] Something went wrong",
    SameTest -> SameQ,
    TestID   -> "CatchPromptFunction-ReturnsFailure@@Tests/Prompts.wlt:670,1-678,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`catchPromptFunction[
        Function[ args, Wolfram`MCPServer`Common`throwFailure[ "InvalidArguments", MCPServer, "test" ] ],
        <| "query" -> "test" |>
    ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "CatchPromptFunction-ThrowsFailure@@Tests/Prompts.wlt:680,1-688,2"
]

(* ::Subsection:: *)
(* formatPromptError *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`formatPromptError[
        Failure[ "TestError", <| "MessageTemplate" -> "Test message" |> ]
    ],
    "[Error] Test message",
    SameTest -> SameQ,
    TestID   -> "FormatPromptError-WithMessage@@Tests/Prompts.wlt:693,1-700,2"
]

VerificationTest[
    StringMatchQ[
        Wolfram`MCPServer`StartMCPServer`Private`formatPromptError[
            Failure[ "TestError", <| |> ]
        ],
        "[Error] " ~~ __
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatPromptError-NoMessage@@Tests/Prompts.wlt:702,1-712,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`formatPromptError[ "not a failure" ],
    "[Error] Failed to generate prompt content.",
    SameTest -> SameQ,
    TestID   -> "FormatPromptError-NonFailure@@Tests/Prompts.wlt:714,1-719,2"
]

(* ::Subsection:: *)
(* makePromptContent with Error Handling *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        <| "Type" -> "Function", "Content" -> Function[ args, Failure[ "TestError", <| "MessageTemplate" -> "Function failed" |> ] ] |>,
        <| "query" -> "test" |>
    ],
    <| "type" -> "text", "text" -> "[Error] Function failed" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-FunctionReturnsFailure@@Tests/Prompts.wlt:724,1-732,2"
]

VerificationTest[
    StringQ @ Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        <| "Type" -> "Function", "Content" -> Function[ args, Wolfram`MCPServer`Common`throwFailure[ "InvalidArguments", MCPServer, "test" ] ] |>,
        <| "query" -> "test" |>
    ][ "text" ],
    True,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-FunctionThrowsFailure@@Tests/Prompts.wlt:734,1-742,2"
]

(* ::Section:: *)
(* Prompt Format (Phase 6) *)

(* ::Subsection:: *)
(* formatSearchPrompt *)

VerificationTest[
    Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "test query", "some results" ],
    "<search-query>test query</search-query>\n<search-results>\nsome results\n</search-results>\nUse the above search results to answer the user's query below.\n<user-query>test query</user-query>",
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-BasicOutput@@Tests/Prompts.wlt:750,1-755,2"
]

VerificationTest[
    StringQ @ Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "query", "results" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ReturnsString@@Tests/Prompts.wlt:757,1-762,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "my query", "my results" ],
        "<search-query>my query</search-query>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ContainsSearchQueryTag@@Tests/Prompts.wlt:764,1-772,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "my query", "my results" ],
        "<search-results>\nmy results\n</search-results>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ContainsSearchResultsTag@@Tests/Prompts.wlt:774,1-782,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "my query", "my results" ],
        "<user-query>my query</user-query>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ContainsUserQueryTag@@Tests/Prompts.wlt:784,1-792,2"
]

VerificationTest[
    StringCount[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "duplicated", "results" ],
        "duplicated"
    ],
    2,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-QueryAppearsInBothTags@@Tests/Prompts.wlt:794,1-802,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "test", "test" ],
        "Use the above search results to answer the user's query below."
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ContainsInstructionalText@@Tests/Prompts.wlt:804,1-812,2"
]

(* ::Subsection:: *)
(* Format Used by Search Prompts *)

(* Skip these in GitHub Actions due to an issue with wolframscript hanging when checking the license server during
   tests that potentially spend a long time downloading files. *)
skipIfGitHubActions @ VerificationTest[
    StringContainsQ[
        $DefaultMCPPrompts[ "WolframSearch" ][ "Content" ][ <| "query" -> "test query" |> ],
        "<search-query>test query</search-query>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframSearch-UsesNewFormat@@Tests/Prompts.wlt:819,23-827,2"
]

skipIfGitHubActions @ VerificationTest[
    StringContainsQ[
        $DefaultMCPPrompts[ "WolframLanguageSearch" ][ "Content" ][ <| "query" -> "test query" |> ],
        "<search-query>test query</search-query>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageSearch-UsesNewFormat@@Tests/Prompts.wlt:829,23-837,2"
]

skipIfGitHubActions @ VerificationTest[
    StringContainsQ[
        $DefaultMCPPrompts[ "WolframAlphaSearch" ][ "Content" ][ <| "query" -> "test query" |> ],
        "<search-query>test query</search-query>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframAlphaSearch-UsesNewFormat@@Tests/Prompts.wlt:839,23-847,2"
]

(* ::Subsection:: *)
(* formatNotebookPrompt *)

VerificationTest[
    Wolfram`MCPServer`Prompts`Notebook`Private`formatNotebookPrompt[ "/path/to/file.nb", "# Heading\n\nContent" ],
    "<notebook-path>/path/to/file.nb</notebook-path>\n<notebook-content>\n# Heading\n\nContent\n</notebook-content>",
    SameTest -> SameQ,
    TestID   -> "FormatNotebookPrompt-BasicOutput@@Tests/Prompts.wlt:852,1-857,2"
]

VerificationTest[
    StringQ @ Wolfram`MCPServer`Prompts`Notebook`Private`formatNotebookPrompt[ "/path/to/file.nb", "content" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatNotebookPrompt-ReturnsString@@Tests/Prompts.wlt:859,1-864,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Notebook`Private`formatNotebookPrompt[ "/my/path.nb", "my content" ],
        "<notebook-path>/my/path.nb</notebook-path>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatNotebookPrompt-ContainsPathTag@@Tests/Prompts.wlt:866,1-874,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Notebook`Private`formatNotebookPrompt[ "/my/path.nb", "my content" ],
        "<notebook-content>\nmy content\n</notebook-content>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatNotebookPrompt-ContainsContentTag@@Tests/Prompts.wlt:876,1-884,2"
]

(* ::Subsection:: *)
(* Notebook Prompt Error Handling *)

VerificationTest[
    StringMatchQ[
        $DefaultMCPPrompts[ "Notebook" ][ "Content" ][ <| "path" -> "/nonexistent/path.nb" |> ],
        "[Error] File does not exist: /nonexistent/path.nb"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "NotebookPrompt-NonexistentFile@@Tests/Prompts.wlt:889,1-897,2"
]

VerificationTest[
    StringMatchQ[
        $DefaultMCPPrompts[ "Notebook" ][ "Content" ][ <| "path" -> "/path/to/file.txt" |> ],
        "[Error] File is not a notebook (.nb): /path/to/file.txt"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "NotebookPrompt-InvalidExtension@@Tests/Prompts.wlt:899,1-907,2"
]

(* :!CodeAnalysis::EndBlock:: *)
