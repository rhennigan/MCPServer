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
    { "WolframAlphaSearch", "WolframLanguageSearch", "WolframSearch" },
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
    { "Search" },
    SameTest -> SameQ,
    TestID   -> "MCPNameMapping-AllSearchPromptsShareName@@Tests/Prompts.wlt:88,1-93,2"
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

(* ::Section:: *)
(* Argument Specifications *)

VerificationTest[
    $DefaultMCPPrompts[ "WolframSearch" ][ "Arguments" ],
    { KeyValuePattern @ { "Name" -> "query", "Required" -> True } },
    SameTest -> MatchQ,
    TestID   -> "WolframSearch-HasQueryArgument@@Tests/Prompts.wlt:143,1-148,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframLanguageSearch" ][ "Arguments" ],
    { KeyValuePattern @ { "Name" -> "query", "Required" -> True } },
    SameTest -> MatchQ,
    TestID   -> "WolframLanguageSearch-HasQueryArgument@@Tests/Prompts.wlt:150,1-155,2"
]

VerificationTest[
    $DefaultMCPPrompts[ "WolframAlphaSearch" ][ "Arguments" ],
    { KeyValuePattern @ { "Name" -> "query", "Required" -> True } },
    SameTest -> MatchQ,
    TestID   -> "WolframAlphaSearch-HasQueryArgument@@Tests/Prompts.wlt:157,1-162,2"
]

(* ::Section:: *)
(* Validation Functions *)

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ "WolframSearch" ],
    { "WolframSearch" },
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompts-SingleString@@Tests/Prompts.wlt:167,1-172,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ { "WolframSearch", "WolframLanguageSearch" } ],
    { "WolframSearch", "WolframLanguageSearch" },
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompts-ListOfStrings@@Tests/Prompts.wlt:174,1-179,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ { <| "Name" -> "Custom" |> } ],
    { <| "Name" -> "Custom" |> },
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompts-InlineAssociation@@Tests/Prompts.wlt:181,1-186,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ { "WolframSearch", <| "Name" -> "Custom" |> } ],
    { "WolframSearch", <| "Name" -> "Custom" |> },
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompts-MixedList@@Tests/Prompts.wlt:188,1-193,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ "NonExistentPrompt" ],
    _Failure,
    { MCPServer::PromptNameNotFound, MCPServer::InvalidMCPPromptsSpecification },
    SameTest -> MatchQ,
    TestID   -> "ValidateMCPPrompts-InvalidName@@Tests/Prompts.wlt:195,1-201,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompts[ 123 ],
    _Failure,
    { MCPServer::InvalidMCPPromptsSpecification },
    SameTest -> MatchQ,
    TestID   -> "ValidateMCPPrompts-InvalidType@@Tests/Prompts.wlt:203,1-209,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompt[ "WolframSearch" ],
    "WolframSearch",
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompt-ValidString@@Tests/Prompts.wlt:211,1-216,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompt[ <| "Name" -> "Custom" |> ],
    <| "Name" -> "Custom" |>,
    SameTest -> SameQ,
    TestID   -> "ValidateMCPPrompt-Association@@Tests/Prompts.wlt:218,1-223,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`validateMCPPrompt[ "NonExistent" ],
    _Failure,
    { MCPServer::PromptNameNotFound },
    SameTest -> MatchQ,
    TestID   -> "ValidateMCPPrompt-InvalidName@@Tests/Prompts.wlt:225,1-231,2"
]

(* ::Section:: *)
(* normalizePromptData *)

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`normalizePromptData[ "WolframSearch" ],
    $DefaultMCPPrompts[ "WolframSearch" ],
    SameTest -> SameQ,
    TestID   -> "NormalizePromptData-StringLookup@@Tests/Prompts.wlt:236,1-241,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`normalizePromptData[ <| "Name" -> "Test", "Content" -> "Static text" |> ],
    <| "Name" -> "Test", "Content" -> "Static text", "Type" -> "Text" |>,
    SameTest -> SameQ,
    TestID   -> "NormalizePromptData-TextType@@Tests/Prompts.wlt:243,1-248,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`normalizePromptData[ <| "Name" -> "Test", "Content" -> Function[ x, x ] |> ],
    KeyValuePattern[ "Type" -> "Function" ],
    SameTest -> MatchQ,
    TestID   -> "NormalizePromptData-FunctionType@@Tests/Prompts.wlt:250,1-255,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`normalizePromptData[ "NonExistent" ],
    _Failure,
    { MCPServer::PromptNameNotFound },
    SameTest -> MatchQ,
    TestID   -> "NormalizePromptData-InvalidName@@Tests/Prompts.wlt:257,1-263,2"
]

(* ::Section:: *)
(* determinePromptType *)

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| "Type" -> "Function" |> ],
    "Function",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-ExplicitFunction@@Tests/Prompts.wlt:268,1-273,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| "Type" -> "Text" |> ],
    "Text",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-ExplicitText@@Tests/Prompts.wlt:275,1-280,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| "Content" -> "Some string" |> ],
    "Text",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-StringContent@@Tests/Prompts.wlt:282,1-287,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| "Content" -> Identity |> ],
    "Function",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-FunctionContent@@Tests/Prompts.wlt:289,1-294,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`determinePromptType[ <| |> ],
    "Text",
    SameTest -> SameQ,
    TestID   -> "DeterminePromptType-EmptyDefault@@Tests/Prompts.wlt:296,1-301,2"
]

(* ::Section:: *)
(* MCPServerObject PromptData Property *)

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`getPromptData[
        <| "LLMEvaluator" -> <| "MCPPrompts" -> { "WolframSearch" } |> |>
    ],
    { $DefaultMCPPrompts[ "WolframSearch" ] },
    SameTest -> SameQ,
    TestID   -> "GetPromptData-WithMCPPrompts@@Tests/Prompts.wlt:306,1-313,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`getPromptData[
        <| "LLMEvaluator" -> <| |> |>
    ],
    { },
    SameTest -> SameQ,
    TestID   -> "GetPromptData-NoPrompts@@Tests/Prompts.wlt:315,1-322,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`getPromptData[
        <| "LLMEvaluator" -> <| "MCPPrompts" -> { "WolframSearch", "WolframLanguageSearch" } |> |>
    ],
    { $DefaultMCPPrompts[ "WolframSearch" ], $DefaultMCPPrompts[ "WolframLanguageSearch" ] },
    SameTest -> SameQ,
    TestID   -> "GetPromptData-MultiplePrompts@@Tests/Prompts.wlt:324,1-331,2"
]

VerificationTest[
    Wolfram`MCPServer`MCPServerObject`Private`getPromptData[
        <| "LLMEvaluator" -> <| "MCPPrompts" -> { <| "Name" -> "Custom", "Content" -> "Test" |> } |> |>
    ],
    { <| "Name" -> "Custom", "Content" -> "Test", "Type" -> "Text" |> },
    SameTest -> SameQ,
    TestID   -> "GetPromptData-InlinePrompt@@Tests/Prompts.wlt:333,1-340,2"
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
    TestID   -> "GetPromptData-DeprecatedPromptDataFails@@Tests/Prompts.wlt:345,1-353,2"
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
    TestID   -> "MakePromptContent-FunctionType@@Tests/Prompts.wlt:358,1-366,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        <| "Type" -> "Text", "Content" -> "Static content" |>,
        <| |>
    ],
    <| "type" -> "text", "text" -> "Static content" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-TextType@@Tests/Prompts.wlt:368,1-376,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        <| "Content" -> "No explicit type" |>,
        <| |>
    ],
    <| "type" -> "text", "text" -> "No explicit type" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-NoExplicitType@@Tests/Prompts.wlt:378,1-386,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        <| "Content" -> StringTemplate[ "Hello, `name`!" ] |>,
        <| "name" -> "World" |>
    ],
    <| "type" -> "text", "text" -> "Hello, World!" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-StringTemplate@@Tests/Prompts.wlt:388,1-396,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        "Plain string",
        <| |>
    ],
    <| "type" -> "text", "text" -> "Plain string" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-PlainString@@Tests/Prompts.wlt:398,1-406,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        12345,
        <| |>
    ],
    <| "type" -> "text", "text" -> "12345" |>,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-Fallback@@Tests/Prompts.wlt:408,1-416,2"
]

(* ::Section:: *)
(* makePromptData (Phase 3) *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptData[ {
        <| "Name" -> "Test", "Description" -> "A test prompt" |>
    } ],
    { <| "name" -> "Test", "description" -> "A test prompt" |> },
    SameTest -> SameQ,
    TestID   -> "MakePromptData-CapitalizedKeys@@Tests/Prompts.wlt:421,1-428,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptData[ {
        <| "name" -> "Test", "description" -> "A test prompt" |>
    } ],
    { <| "name" -> "Test", "description" -> "A test prompt" |> },
    SameTest -> SameQ,
    TestID   -> "MakePromptData-LowercaseKeys@@Tests/Prompts.wlt:430,1-437,2"
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
    TestID   -> "MakePromptData-WithArguments@@Tests/Prompts.wlt:439,1-460,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`makePromptData[ {
        <| "Name" -> "NoArgs" |>
    } ],
    { <| "name" -> "NoArgs", "description" -> "" |> },
    SameTest -> SameQ,
    TestID   -> "MakePromptData-NoArguments@@Tests/Prompts.wlt:462,1-469,2"
]

(* ::Section:: *)
(* normalizeArguments (Phase 3) *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArguments[ {
        <| "Name" -> "query", "Description" -> "The search query", "Required" -> True |>
    } ],
    { <| "name" -> "query", "description" -> "The search query", "required" -> True |> },
    SameTest -> SameQ,
    TestID   -> "NormalizeArguments-CapitalizedKeys@@Tests/Prompts.wlt:474,1-481,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArguments[ {
        <| "name" -> "query", "description" -> "The search query", "required" -> True |>
    } ],
    { <| "name" -> "query", "description" -> "The search query", "required" -> True |> },
    SameTest -> SameQ,
    TestID   -> "NormalizeArguments-LowercaseKeys@@Tests/Prompts.wlt:483,1-490,2"
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
    TestID   -> "NormalizeArguments-MultipleWithDefaults@@Tests/Prompts.wlt:492,1-503,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArguments[ { } ],
    { },
    SameTest -> SameQ,
    TestID   -> "NormalizeArguments-Empty@@Tests/Prompts.wlt:505,1-510,2"
]

(* ::Section:: *)
(* normalizeArgument (Phase 3) *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArgument[
        <| "Name" -> "query", "Description" -> "The query", "Required" -> True |>
    ],
    <| "name" -> "query", "description" -> "The query", "required" -> True |>,
    SameTest -> SameQ,
    TestID   -> "NormalizeArgument-AllFields@@Tests/Prompts.wlt:515,1-522,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArgument[
        <| "Name" -> "query" |>
    ],
    <| "name" -> "query", "description" -> "", "required" -> False |>,
    SameTest -> SameQ,
    TestID   -> "NormalizeArgument-DefaultValues@@Tests/Prompts.wlt:524,1-531,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`normalizeArgument[
        <| "name" -> "query", "description" -> "Lowercase keys", "required" -> True |>
    ],
    <| "name" -> "query", "description" -> "Lowercase keys", "required" -> True |>,
    SameTest -> SameQ,
    TestID   -> "NormalizeArgument-LowercaseKeys@@Tests/Prompts.wlt:533,1-540,2"
]

(* ::Section:: *)
(* Server Configuration (Phase 4) *)

VerificationTest[
    $DefaultMCPServers[ "Wolfram" ][ "MCPPrompts" ],
    { "WolframSearch" },
    SameTest -> SameQ,
    TestID   -> "ServerConfig-WolframHasMCPPrompts@@Tests/Prompts.wlt:545,1-550,2"
]

VerificationTest[
    $DefaultMCPServers[ "WolframAlpha" ][ "MCPPrompts" ],
    { "WolframAlphaSearch" },
    SameTest -> SameQ,
    TestID   -> "ServerConfig-WolframAlphaHasMCPPrompts@@Tests/Prompts.wlt:552,1-557,2"
]

VerificationTest[
    $DefaultMCPServers[ "WolframLanguage" ][ "MCPPrompts" ],
    { "WolframLanguageSearch" },
    SameTest -> SameQ,
    TestID   -> "ServerConfig-WolframLanguageHasMCPPrompts@@Tests/Prompts.wlt:559,1-564,2"
]

VerificationTest[
    $DefaultMCPServers[ "WolframPacletDevelopment" ][ "MCPPrompts" ],
    { "WolframLanguageSearch" },
    SameTest -> SameQ,
    TestID   -> "ServerConfig-WolframPacletDevelopmentHasMCPPrompts@@Tests/Prompts.wlt:566,1-571,2"
]

(* ::Subsection:: *)
(* Server PromptData Property *)

VerificationTest[
    MCPServerObject[ "Wolfram" ][ "PromptData" ],
    { KeyValuePattern[ "Name" -> "Search" ] },
    SameTest -> MatchQ,
    TestID   -> "ServerPromptData-Wolfram@@Tests/Prompts.wlt:576,1-581,2"
]

VerificationTest[
    MCPServerObject[ "WolframAlpha" ][ "PromptData" ],
    { KeyValuePattern[ "Name" -> "Search" ] },
    SameTest -> MatchQ,
    TestID   -> "ServerPromptData-WolframAlpha@@Tests/Prompts.wlt:583,1-588,2"
]

VerificationTest[
    MCPServerObject[ "WolframLanguage" ][ "PromptData" ],
    { KeyValuePattern[ "Name" -> "Search" ] },
    SameTest -> MatchQ,
    TestID   -> "ServerPromptData-WolframLanguage@@Tests/Prompts.wlt:590,1-595,2"
]

VerificationTest[
    MCPServerObject[ "WolframPacletDevelopment" ][ "PromptData" ],
    { KeyValuePattern[ "Name" -> "Search" ] },
    SameTest -> MatchQ,
    TestID   -> "ServerPromptData-WolframPacletDevelopment@@Tests/Prompts.wlt:597,1-602,2"
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
    TestID   -> "ServerPromptData-AllHaveFunctionType@@Tests/Prompts.wlt:607,1-620,2"
]

(* ::Subsection:: *)
(* Prompt Names Match Across Servers *)

VerificationTest[
    Union @ Flatten @ Map[
        Function[ name, #[ "Name" ] & /@ MCPServerObject[ name ][ "PromptData" ] ],
        { "Wolfram", "WolframAlpha", "WolframLanguage", "WolframPacletDevelopment" }
    ],
    { "Search" },
    SameTest -> SameQ,
    TestID   -> "ServerPromptData-AllUseSearchName@@Tests/Prompts.wlt:625,1-633,2"
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
    TestID   -> "CatchPromptFunction-Success@@Tests/Prompts.wlt:641,1-649,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`catchPromptFunction[
        Function[ args, Failure[ "TestError", <| "MessageTemplate" -> "Something went wrong" |> ] ],
        <| "query" -> "test" |>
    ],
    "[Error] Something went wrong",
    SameTest -> SameQ,
    TestID   -> "CatchPromptFunction-ReturnsFailure@@Tests/Prompts.wlt:651,1-659,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`catchPromptFunction[
        Function[ args, Wolfram`MCPServer`Common`throwFailure[ "InvalidArguments", MCPServer, "test" ] ],
        <| "query" -> "test" |>
    ],
    _String,
    SameTest -> MatchQ,
    TestID   -> "CatchPromptFunction-ThrowsFailure@@Tests/Prompts.wlt:661,1-669,2"
]

(* ::Subsection:: *)
(* formatPromptError *)

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`formatPromptError[
        Failure[ "TestError", <| "MessageTemplate" -> "Test message" |> ]
    ],
    "[Error] Test message",
    SameTest -> SameQ,
    TestID   -> "FormatPromptError-WithMessage@@Tests/Prompts.wlt:674,1-681,2"
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
    TestID   -> "FormatPromptError-NoMessage@@Tests/Prompts.wlt:683,1-693,2"
]

VerificationTest[
    Wolfram`MCPServer`StartMCPServer`Private`formatPromptError[ "not a failure" ],
    "[Error] Failed to generate prompt content.",
    SameTest -> SameQ,
    TestID   -> "FormatPromptError-NonFailure@@Tests/Prompts.wlt:695,1-700,2"
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
    TestID   -> "MakePromptContent-FunctionReturnsFailure@@Tests/Prompts.wlt:705,1-713,2"
]

VerificationTest[
    StringQ @ Wolfram`MCPServer`StartMCPServer`Private`makePromptContent[
        <| "Type" -> "Function", "Content" -> Function[ args, Wolfram`MCPServer`Common`throwFailure[ "InvalidArguments", MCPServer, "test" ] ] |>,
        <| "query" -> "test" |>
    ][ "text" ],
    True,
    SameTest -> SameQ,
    TestID   -> "MakePromptContent-FunctionThrowsFailure@@Tests/Prompts.wlt:715,1-723,2"
]

(* ::Section:: *)
(* Prompt Format (Phase 6) *)

(* ::Subsection:: *)
(* formatSearchPrompt *)

VerificationTest[
    Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "test query", "some results" ],
    "<search-query>test query</search-query>\n<search-results>\nsome results\n</search-results>\nUse the above search results to answer the user's query below.\n<user-query>test query</user-query>",
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-BasicOutput@@Tests/Prompts.wlt:731,1-736,2"
]

VerificationTest[
    StringQ @ Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "query", "results" ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ReturnsString@@Tests/Prompts.wlt:738,1-743,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "my query", "my results" ],
        "<search-query>my query</search-query>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ContainsSearchQueryTag@@Tests/Prompts.wlt:745,1-753,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "my query", "my results" ],
        "<search-results>\nmy results\n</search-results>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ContainsSearchResultsTag@@Tests/Prompts.wlt:755,1-763,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "my query", "my results" ],
        "<user-query>my query</user-query>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ContainsUserQueryTag@@Tests/Prompts.wlt:765,1-773,2"
]

VerificationTest[
    StringCount[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "duplicated", "results" ],
        "duplicated"
    ],
    2,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-QueryAppearsInBothTags@@Tests/Prompts.wlt:775,1-783,2"
]

VerificationTest[
    StringContainsQ[
        Wolfram`MCPServer`Prompts`Search`Private`formatSearchPrompt[ "test", "test" ],
        "Use the above search results to answer the user's query below."
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "FormatSearchPrompt-ContainsInstructionalText@@Tests/Prompts.wlt:785,1-793,2"
]

(* ::Subsection:: *)
(* Format Used by Search Prompts *)

VerificationTest[
    StringContainsQ[
        $DefaultMCPPrompts[ "WolframSearch" ][ "Content" ][ <| "query" -> "test query" |> ],
        "<search-query>test query</search-query>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframSearch-UsesNewFormat@@Tests/Prompts.wlt:798,1-806,2"
]

VerificationTest[
    StringContainsQ[
        $DefaultMCPPrompts[ "WolframLanguageSearch" ][ "Content" ][ <| "query" -> "test query" |> ],
        "<search-query>test query</search-query>"
    ],
    True,
    SameTest -> SameQ,
    TestID   -> "WolframLanguageSearch-UsesNewFormat@@Tests/Prompts.wlt:808,1-816,2"
]

(* We don't have the necessary API keys stored in the CI/CD pipeline to test this *)
If[ StringQ @ Environment[ "GITHUB_ACTIONS" ],
    Null,
    VerificationTest[
        StringContainsQ[
            $DefaultMCPPrompts[ "WolframAlphaSearch" ][ "Content" ][ <| "query" -> "test query" |> ],
            "<search-query>test query</search-query>"
        ],
        True,
        SameTest -> SameQ,
        TestID   -> "WolframAlphaSearch-UsesNewFormat@@Tests/Prompts.wlt:821,5-829,6"
    ]
]

(* :!CodeAnalysis::EndBlock:: *)
