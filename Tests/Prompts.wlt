(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* ::Section:: *)
(* Initialization *)

VerificationTest[
    If[ ! TrueQ @ Wolfram`MCPServerTests`$TestDefinitionsLoaded,
        Get @ FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" }
    ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions@@Tests/Prompts.wlt:7,1-14,2"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext@@Tests/Prompts.wlt:16,1-21,2"
]

(* ::Section:: *)
(* $DefaultMCPPrompts *)

VerificationTest[
    $DefaultMCPPrompts,
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "DefaultMCPPrompts-IsAssociation@@Tests/Prompts.wlt:26,1-31,2"
]

VerificationTest[
    Sort @ Keys @ $DefaultMCPPrompts,
    { "Notebook", "WolframAlphaSearch", "WolframLanguageSearch", "WolframSearch" },
    SameTest -> SameQ,
    TestID   -> "DefaultMCPPrompts-Keys@@Tests/Prompts.wlt:33,1-38,2"
]

VerificationTest[
    AllTrue[ Values @ $DefaultMCPPrompts, AssociationQ ],
    True,
    SameTest -> SameQ,
    TestID   -> "DefaultMCPPrompts-AllAssociations@@Tests/Prompts.wlt:40,1-45,2"
]

(* ::Section:: *)
(* Prompt Properties *)

VerificationTest[
    AllTrue[ $DefaultMCPPrompts, StringQ @ #[ "Name" ] & ],
    True,
    SameTest -> SameQ,
    TestID   -> "PromptProperties-AllHaveNames@@Tests/Prompts.wlt:50,1-55,2"
]

VerificationTest[
    AllTrue[ $DefaultMCPPrompts, StringQ @ #[ "Description" ] & ],
    True,
    SameTest -> SameQ,
    TestID   -> "PromptProperties-AllHaveDescriptions@@Tests/Prompts.wlt:57,1-62,2"
]

VerificationTest[
    AllTrue[ $DefaultMCPPrompts, MemberQ[ { "Function", "Text" }, #[ "Type" ] ] & ],
    True,
    SameTest -> SameQ,
    TestID   -> "PromptProperties-AllHaveValidType@@Tests/Prompts.wlt:64,1-69,2"
]

VerificationTest[
    AllTrue[ $DefaultMCPPrompts, MatchQ[ #[ "Arguments" ], { ___Association } ] & ],
    True,
    SameTest -> SameQ,
    TestID   -> "PromptProperties-AllHaveArguments@@Tests/Prompts.wlt:71,1-76,2"
]

VerificationTest[
    AllTrue[ $DefaultMCPPrompts, MatchQ[ #[ "Content" ], _Symbol | _Function ] & ],
    True,
    SameTest -> MatchQ,
    TestID   -> "PromptProperties-AllHaveContent@@Tests/Prompts.wlt:78,1-83,2"
]

(* ::Section:: *)
(* MCP Name Mapping *)

VerificationTest[
    Union @ Map[ #[ "Name" ] &, Values @ $DefaultMCPPrompts ],
    { "Notebook", "Search" },
    SameTest -> SameQ,
    TestID   -> "MCPNameMapping-PromptNames@@Tests/Prompts.wlt:88,1-93,2"
]

(* ::Section:: *)
(* Individual Prompt Definitions *)

VerificationTest[
    $DefaultMCPPrompts[ "WolframSearch" ][ "Name" ],
    "Search",
    SameTest -> SameQ,
    TestID   -> "WolframSearch-HasCorrectName@@Tests/Prompts.wlt:98,1-103,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframSearch" ][ "Type" ],
    "Function",
    SameTest -> SameQ,
    TestID   -> "WolframSearch-HasCorrectType@@Tests/Prompts.wlt:105,1-110,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframLanguageSearch" ][ "Name" ],
    "Search",
    SameTest -> SameQ,
    TestID   -> "WolframLanguageSearch-HasCorrectName@@Tests/Prompts.wlt:112,1-117,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframLanguageSearch" ][ "Type" ],
    "Function",
    SameTest -> SameQ,
    TestID   -> "WolframLanguageSearch-HasCorrectType@@Tests/Prompts.wlt:119,1-124,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframAlphaSearch" ][ "Name" ],
    "Search",
    SameTest -> SameQ,
    TestID   -> "WolframAlphaSearch-HasCorrectName@@Tests/Prompts.wlt:126,1-131,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframAlphaSearch" ][ "Type" ],
    "Function",
    SameTest -> SameQ,
    TestID   -> "WolframAlphaSearch-HasCorrectType@@Tests/Prompts.wlt:133,1-138,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "Notebook" ][ "Name" ],
    "Notebook",
    SameTest -> SameQ,
    TestID   -> "Notebook-HasCorrectName@@Tests/Prompts.wlt:140,1-145,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "Notebook" ][ "Type" ],
    "Function",
    SameTest -> SameQ,
    TestID   -> "Notebook-HasCorrectType@@Tests/Prompts.wlt:147,1-152,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "Notebook" ][ "Arguments" ],
    { KeyValuePattern @ { "Name" -> "path", "Required" -> True } },
    SameTest -> MatchQ,
    TestID   -> "Notebook-HasPathArgument@@Tests/Prompts.wlt:154,1-159,2"
]

(* ::Section:: *)
(* Argument Specifications *)

VerificationTest[
    $DefaultMCPPrompts[ "WolframSearch" ][ "Arguments" ],
    { KeyValuePattern @ { "Name" -> "query", "Required" -> True } },
    SameTest -> MatchQ,
    TestID   -> "WolframSearch-HasQueryArgument@@Tests/Prompts.wlt:164,1-169,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframLanguageSearch" ][ "Arguments" ],
    { KeyValuePattern @ { "Name" -> "query", "Required" -> True } },
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageSearch-HasQueryArgument@@Tests/Prompts.wlt:171,1-176,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframAlphaSearch" ][ "Arguments" ],
    { KeyValuePattern @ { "Name" -> "query", "Required" -> True } },
    SameTest -> MatchQ,
    TestID   -> "WolframAlphaSearch-HasQueryArgument@@Tests/Prompts.wlt:178,1-183,2"
]

(* ::Section:: *)
(* Validation Functions *)

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ "WolframSearch" ],
    { "WolframSearch" },
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompts-SingleString@@Tests/Prompts.wlt:188,1-193,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ { "WolframSearch", "WolframLanguageSearch" } ],
    { "WolframSearch", "WolframLanguageSearch" },
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompts-ListOfStrings@@Tests/Prompts.wlt:195,1-200,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ { <| "Name" -> "Custom" |> } ],
    { <| "Name" -> "Custom" |> },
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompts-InlineAssociation@@Tests/Prompts.wlt:202,1-207,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ { "WolframSearch", <| "Name" -> "Custom" |> } ],
    { "WolframSearch", <| "Name" -> "Custom" |> },
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompts-MixedList@@Tests/Prompts.wlt:209,1-214,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ "NonExistentPrompt" ],
    _Failure,
    { MCPServer::PromptNameNotFound, MCPServer::InvalidMCPPromptsSpecification },
    SameTest -> MatchQ,
    TestID   -> "ValidateMCPPrompts-InvalidName@@Tests/Prompts.wlt:216,1-222,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ 123 ],
    _Failure,
    { MCPServer::InvalidMCPPromptsSpecification },
    SameTest -> MatchQ,
    TestID   -> "ValidateMCPPrompts-InvalidType@@Tests/Prompts.wlt:224,1-230,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompt[ "WolframSearch" ],
    "WolframSearch",
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompt-ValidString@@Tests/Prompts.wlt:232,1-237,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompt[ <| "Name" -> "Custom" |> ],
    <| "Name" -> "Custom" |>,
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompt-Association@@Tests/Prompts.wlt:239,1-244,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompt[ "NonExistent" ],
    _Failure,
    { MCPServer::PromptNameNotFound },
    SameTest -> MatchQ,
    TestID   -> "ValidateMCPPrompt-InvalidName@@Tests/Prompts.wlt:246,1-252,2"
]

(* ::Section:: *)
(* normalizePromptData *)

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`normalizePromptData[ "WolframSearch" ],
    $DefaultMCPPrompts[ "WolframSearch" ],
    SameTest -> SameQ,
    TestID   -> "NormalizePromptData-StringLookup@@Tests/Prompts.wlt:257,1-262,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`normalizePromptData[ <| "Name" -> "Test", "Content" -> "Static text" |> ],
    <| "Name" -> "Test", "Content" -> "Static text", "Type" -> "Text" |>,
    SameTest -> SameQ,
    TestID   -> "NormalizePromptData-TextType@@Tests/Prompts.wlt:264,1-269,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`normalizePromptData[ <| "Name" -> "Test", "Content" -> Function[ x, x ] |> ],
    KeyValuePattern[ "Type" -> "Function" ],
    SameTest -> MatchQ,
    TestID   -> "NormalizePromptData-FunctionType@@Tests/Prompts.wlt:271,1-276,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`normalizePromptData[ "NonExistent" ],
    _Failure,
    { MCPServer::PromptNameNotFound },
    SameTest -> MatchQ,
    TestID   -> "NormalizePromptData-InvalidName@@Tests/Prompts.wlt:278,1-284,2"
]

(* ::Section:: *)
(* determinePromptType *)

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| "Type" -> "Function" |> ],
    "Function",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-ExplicitFunction@@Tests/Prompts.wlt:289,1-294,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| "Type" -> "Text" |> ],
    "Text",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-ExplicitText@@Tests/Prompts.wlt:296,1-301,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| "Content" -> "Some string" |> ],
    "Text",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-StringContent@@Tests/Prompts.wlt:303,1-308,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| "Content" -> Identity |> ],
    "Function",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-FunctionContent@@Tests/Prompts.wlt:310,1-315,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| |> ],
    "Text",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-EmptyDefault@@Tests/Prompts.wlt:317,1-322,2"
]

(* ::Section:: *)
(* MCPServerObject PromptData Property *)

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`getPromptData[
        <| "LLMEvaluator" -> <| "MCPPrompts" -> { "WolframSearch" } |> |>
    ],
    { $DefaultMCPPrompts[ "WolframSearch" ] },
    SameTest -> SameQ,
    TestID   -> "GetPromptData-WithMCPPrompts@@Tests/Prompts.wlt:327,1-334,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`getPromptData[
        <| "LLMEvaluator" -> <| |> |>
    ],
    { },
    SameTest -> SameQ,
    TestID   -> "GetPromptData-NoPrompts@@Tests/Prompts.wlt:336,1-343,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`getPromptData[
        <| "LLMEvaluator" -> <| "MCPPrompts" -> { "WolframSearch", "WolframLanguageSearch" } |> |>
    ],
    { $DefaultMCPPrompts[ "WolframSearch" ], $DefaultMCPPrompts[ "WolframLanguageSearch" ] },
    SameTest -> SameQ,
    TestID   -> "GetPromptData-MultiplePrompts@@Tests/Prompts.wlt:345,1-352,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`getPromptData[
        <| "LLMEvaluator" -> <| "MCPPrompts" -> { <| "Name" -> "Custom", "Content" -> "Test" |> } |> |>
    ],
    { <| "Name" -> "Custom", "Content" -> "Test", "Type" -> "Text" |> },
    SameTest -> SameQ,
    TestID   -> "GetPromptData-InlinePrompt@@Tests/Prompts.wlt:354,1-361,2"
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
    TestID   -> "GetPromptData-DeprecatedPromptDataFails@@Tests/Prompts.wlt:366,1-374,2"
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
    TestID   -> "MakePromptContent-FunctionType@@Tests/Prompts.wlt:379,1-387,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        <| "Type" -> "Text", "Content" -> "Static content" |>,
        <| |>
    ],
    <| "type" -> "text", "text" -> "Static content" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-TextType@@Tests/Prompts.wlt:389,1-397,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        <| "Content" -> "No explicit type" |>,
        <| |>
    ],
    <| "type" -> "text", "text" -> "No explicit type" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-NoExplicitType@@Tests/Prompts.wlt:399,1-407,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        <| "Content" -> StringTemplate[ "Hello, `name`!" ] |>,
        <| "name" -> "World" |>
    ],
    <| "type" -> "text", "text" -> "Hello, World!" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-StringTemplate@@Tests/Prompts.wlt:409,1-417,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        "Plain string",
        <| |>
    ],
    <| "type" -> "text", "text" -> "Plain string" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-PlainString@@Tests/Prompts.wlt:419,1-427,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        12345,
        <| |>
    ],
    <| "type" -> "text", "text" -> "12345" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-Fallback@@Tests/Prompts.wlt:429,1-437,2"
]

(* ::Section:: *)
(* makePromptData (Phase 3) *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptData[ {
        <| "Name" -> "Test", "Description" -> "A test prompt" |>
    } ],
    { <| "name" -> "Test", "description" -> "A test prompt" |> },
    SameTest -> SameQ,
    TestID   -> "MakePromptData-CapitalizedKeys@@Tests/Prompts.wlt:442,1-449,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptData[ {
        <| "name" -> "Test", "description" -> "A test prompt" |>
    } ],
    { <| "name" -> "Test", "description" -> "A test prompt" |> },
    SameTest -> SameQ,
    TestID   -> "MakePromptData-LowercaseKeys@@Tests/Prompts.wlt:451,1-458,2"
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
    TestID   -> "MakePromptData-WithArguments@@Tests/Prompts.wlt:460,1-481,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptData[ {
        <| "Name" -> "NoArgs" |>
    } ],
    { <| "name" -> "NoArgs", "description" -> "" |> },
    SameTest -> SameQ,
    TestID   -> "MakePromptData-NoArguments@@Tests/Prompts.wlt:483,1-490,2"
]

(* ::Section:: *)
(* normalizeArguments (Phase 3) *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArguments[ {
        <| "Name" -> "query", "Description" -> "The search query", "Required" -> True |>
    } ],
    { <| "name" -> "query", "description" -> "The search query", "required" -> True |> },
    SameTest -> SameQ,
    TestID   -> "NormalizeArguments-CapitalizedKeys@@Tests/Prompts.wlt:495,1-502,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArguments[ {
        <| "name" -> "query", "description" -> "The search query", "required" -> True |>
    } ],
    { <| "name" -> "query", "description" -> "The search query", "required" -> True |> },
    SameTest -> SameQ,
    TestID   -> "NormalizeArguments-LowercaseKeys@@Tests/Prompts.wlt:504,1-511,2"
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
    TestID   -> "NormalizeArguments-MultipleWithDefaults@@Tests/Prompts.wlt:513,1-524,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArguments[ { } ],
    { },
    SameTest -> SameQ,
    TestID   -> "NormalizeArguments-Empty@@Tests/Prompts.wlt:526,1-531,2"
]

(* ::Section:: *)
(* normalizeArgument (Phase 3) *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArgument[
        <| "Name" -> "query", "Description" -> "The query", "Required" -> True |>
    ],
    <| "name" -> "query", "description" -> "The query", "required" -> True |>,
    SameTest -> SameQ,
    TestID   -> "NormalizeArgument-AllFields@@Tests/Prompts.wlt:536,1-543,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArgument[
        <| "Name" -> "query" |>
    ],
    <| "name" -> "query", "description" -> "", "required" -> False |>,
    SameTest -> SameQ,
    TestID   -> "NormalizeArgument-DefaultValues@@Tests/Prompts.wlt:545,1-552,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArgument[
        <| "name" -> "query", "description" -> "Lowercase keys", "required" -> True |>
    ],
    <| "name" -> "query", "description" -> "Lowercase keys", "required" -> True |>,
    SameTest -> SameQ,
    TestID   -> "NormalizeArgument-LowercaseKeys@@Tests/Prompts.wlt:554,1-561,2"
]

(* ::Section:: *)
(* Server Configuration (Phase 4) *)

VerificationTest[
    $DefaultMCPServers[ "Wolfram" ][ "MCPPrompts" ],
    { "WolframSearch" },
    SameTest -> SameQ,
    TestID   -> "ServerConfig-WolframHasMCPPrompts@@Tests/Prompts.wlt:566,1-571,2"
]

VerificationTest[
    $DefaultMCPServers[ "WolframAlpha" ][ "MCPPrompts" ],
    { "WolframAlphaSearch" },
    SameTest -> SameQ,
    TestID   -> "ServerConfig-WolframAlphaHasMCPPrompts@@Tests/Prompts.wlt:573,1-578,2"
]

VerificationTest[
    $DefaultMCPServers[ "WolframLanguage" ][ "MCPPrompts" ],
    { "WolframLanguageSearch", "Notebook" },
    SameTest -> SameQ,
    TestID   -> "ServerConfig-WolframLanguageHasMCPPrompts@@Tests/Prompts.wlt:580,1-585,2"
]

VerificationTest[
    $DefaultMCPServers[ "WolframPacletDevelopment" ][ "MCPPrompts" ],
    { "WolframLanguageSearch", "Notebook" },
    SameTest -> SameQ,
    TestID   -> "ServerConfig-WolframPacletDevelopmentHasMCPPrompts@@Tests/Prompts.wlt:587,1-592,2"
]

(* ::Subsection:: *)
(* Server PromptData Property *)

VerificationTest[
    MCPServerObject[ "Wolfram" ][ "PromptData" ],
    { KeyValuePattern[ "Name" -> "Search" ] },
    SameTest -> MatchQ,
    TestID   -> "ServerPromptData-Wolfram@@Tests/Prompts.wlt:597,1-602,2"
]

VerificationTest[
    MCPServerObject[ "WolframAlpha" ][ "PromptData" ],
    { KeyValuePattern[ "Name" -> "Search" ] },
    SameTest -> MatchQ,
    TestID   -> "ServerPromptData-WolframAlpha@@Tests/Prompts.wlt:604,1-609,2"
]

VerificationTest[
    MCPServerObject[ "WolframLanguage" ][ "PromptData" ],
    { KeyValuePattern[ "Name" -> "Search" ], KeyValuePattern[ "Name" -> "Notebook" ] },
    SameTest -> MatchQ,
    TestID   -> "ServerPromptData-WolframLanguage@@Tests/Prompts.wlt:611,1-616,2"
]

VerificationTest[
    MCPServerObject[ "WolframPacletDevelopment" ][ "PromptData" ],
    { KeyValuePattern[ "Name" -> "Search" ], KeyValuePattern[ "Name" -> "Notebook" ] },
    SameTest -> MatchQ,
    TestID   -> "ServerPromptData-WolframPacletDevelopment@@Tests/Prompts.wlt:618,1-623,2"
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
    TestID   -> "ServerPromptData-AllHaveFunctionType@@Tests/Prompts.wlt:628,1-641,2"
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
    TestID   -> "ServerPromptData-PromptNames@@Tests/Prompts.wlt:646,1-654,2"
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
    TestID   -> "CatchPromptFunction-Success@@Tests/Prompts.wlt:662,1-670,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`catchPromptFunction[
        Function[ args, Failure[ "TestError", <| "MessageTemplate" -> "Something went wrong" |> ] ],
        <| "query" -> "test" |>
    ],
    "[Error] Something went wrong",
    SameTest -> SameQ,
    TestID   -> "CatchPromptFunction-ReturnsFailure@@Tests/Prompts.wlt:672,1-680,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`catchPromptFunction[
        Function[ args, Wolfram`MCPServer`Common`throwFailure[ "InvalidArguments", MCPServer, "test" ] ],
        <| "query" -> "test" |>
    ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "CatchPromptFunction-ThrowsFailure@@Tests/Prompts.wlt:682,1-690,2"
]

(* ::Subsection:: *)
(* formatPromptError *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`formatPromptError[
        Failure[ "TestError", <| "MessageTemplate" -> "Test message" |> ]
    ],
    "[Error] Test message",
    SameTest -> SameQ,
    TestID   -> "FormatPromptError-WithMessage@@Tests/Prompts.wlt:695,1-702,2"
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
    TestID   -> "FormatPromptError-NoMessage@@Tests/Prompts.wlt:704,1-714,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`formatPromptError[ "not a failure" ],
    "[Error] Failed to generate prompt content.",
    SameTest -> SameQ,
    TestID   -> "FormatPromptError-NonFailure@@Tests/Prompts.wlt:716,1-721,2"
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
    TestID   -> "MakePromptContent-FunctionReturnsFailure@@Tests/Prompts.wlt:726,1-734,2"
]

VerificationTest[
    StringQ @ Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        <| "Type" -> "Function", "Content" -> Function[ args, Wolfram`MCPServer`Common`throwFailure[ "InvalidArguments", MCPServer, "test" ] ] |>,
        <| "query" -> "test" |>
    ][ "text" ],
    True,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-FunctionThrowsFailure@@Tests/Prompts.wlt:736,1-744,2"
]

(* ::Section:: *)
(* Prompt Format (Phase 6) *)

(* ::Subsection:: *)
(* formatSearchPrompt *)

VerificationTest[
    Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "test query", "some results" ],
    "<search-query>test query</search-query>\n<search-results>\nsome results\n</search-results>\nUse the above search results to answer the user's query below.\n<user-query>test query</user-query>",
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-BasicOutput@@Tests/Prompts.wlt:752,1-757,2"
]

VerificationTest[
    StringQ @ Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "query", "results" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ReturnsString@@Tests/Prompts.wlt:759,1-764,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "my query", "my results" ],
        "<search-query>my query</search-query>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ContainsSearchQueryTag@@Tests/Prompts.wlt:766,1-774,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "my query", "my results" ],
        "<search-results>\nmy results\n</search-results>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ContainsSearchResultsTag@@Tests/Prompts.wlt:776,1-784,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "my query", "my results" ],
        "<user-query>my query</user-query>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ContainsUserQueryTag@@Tests/Prompts.wlt:786,1-794,2"
]

VerificationTest[
    StringCount[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "duplicated", "results" ],
        "duplicated"
    ],
    2,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-QueryAppearsInBothTags@@Tests/Prompts.wlt:796,1-804,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "test", "test" ],
        "Use the above search results to answer the user's query below."
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ContainsInstructionalText@@Tests/Prompts.wlt:806,1-814,2"
]

(* ::Subsection:: *)
(* Format Used by Search Prompts *)

(* Skip these in GitHub Actions due to an issue with wolframscript hanging when checking the license server during
   tests that potentially spend a long time downloading files. *)
skipIfGitHub // Attributes = { HoldFirst };
skipIfGitHub[ test_ ] := If[ StringQ @ Environment[ "GITHUB_ACTIONS" ], Null, test ];


skipIfGitHub @ VerificationTest[
    StringContainsQ[
        $DefaultMCPPrompts[ "WolframSearch" ][ "Content" ][ <| "query" -> "test query" |> ],
        "<search-query>test query</search-query>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframSearch-UsesNewFormat@@Tests/Prompts.wlt:825,16-833,2"
]

skipIfGitHub @ VerificationTest[
    StringContainsQ[
        $DefaultMCPPrompts[ "WolframLanguageSearch" ][ "Content" ][ <| "query" -> "test query" |> ],
        "<search-query>test query</search-query>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageSearch-UsesNewFormat@@Tests/Prompts.wlt:835,16-843,2"
]

skipIfGitHub @ VerificationTest[
    StringContainsQ[
        $DefaultMCPPrompts[ "WolframAlphaSearch" ][ "Content" ][ <| "query" -> "test query" |> ],
        "<search-query>test query</search-query>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframAlphaSearch-UsesNewFormat@@Tests/Prompts.wlt:845,16-853,2"
]

(* ::Subsection:: *)
(* formatNotebookPrompt *)

VerificationTest[
    Wolfram`MCPServer`Prompts`Notebook`Private`formatNotebookPrompt[ "/path/to/file.nb", "# Heading\n\nContent" ],
    "<notebook-path>/path/to/file.nb</notebook-path>\n<notebook-content>\n# Heading\n\nContent\n</notebook-content>",
    SameTest -> SameQ,
    TestID   -> "FormatNotebookPrompt-BasicOutput@@Tests/Prompts.wlt:858,1-863,2"
]

VerificationTest[
    StringQ @ Wolfram`MCPServer`Prompts`Notebook`Private`formatNotebookPrompt[ "/path/to/file.nb", "content" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatNotebookPrompt-ReturnsString@@Tests/Prompts.wlt:865,1-870,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Notebook`Private`formatNotebookPrompt[ "/my/path.nb", "my content" ],
        "<notebook-path>/my/path.nb</notebook-path>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatNotebookPrompt-ContainsPathTag@@Tests/Prompts.wlt:872,1-880,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Notebook`Private`formatNotebookPrompt[ "/my/path.nb", "my content" ],
        "<notebook-content>\nmy content\n</notebook-content>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatNotebookPrompt-ContainsContentTag@@Tests/Prompts.wlt:882,1-890,2"
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
    TestID   -> "NotebookPrompt-NonexistentFile@@Tests/Prompts.wlt:895,1-903,2"
]

VerificationTest[
    StringMatchQ[
        $DefaultMCPPrompts[ "Notebook" ][ "Content" ][ <| "path" -> "/path/to/file.txt" |> ],
        "[Error] File is not a notebook (.nb): /path/to/file.txt"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "NotebookPrompt-InvalidExtension@@Tests/Prompts.wlt:905,1-913,2"
]

(* :!CodeAnalysis::EndBlock:: *)
