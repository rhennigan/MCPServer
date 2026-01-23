# MCP Prompt Commands - Detailed Specification

## Overview

This specification defines support for MCP prompt commands in the Wolfram MCP Server. Prompts allow clients to invoke `/mcp__{serverName}__{promptName}` commands that return pre-formatted context or instructions to the LLM.

## Goals

- Support MCP prompt commands following the [MCP prompts specification](https://modelcontextprotocol.io/specification/2025-11-25/server/prompts.md)
- Create a prompts system parallel to the existing tools system (`$DefaultMCPPrompts` analogous to `$DefaultMCPTools`)
- Implement a "Search" prompt that provides relevant documentation/Wolfram Alpha context
- Use `"MCPPrompts"` as the LLMEvaluator property (deprecating `"PromptData"`)
- Support function-based prompts that can dynamically generate content

---

## MCP Prompts Specification Summary

The MCP protocol defines prompts with this structure:

```json
{
  "name": "string",              // Unique identifier for the prompt
  "description": "string",       // Human-readable description (optional)
  "arguments": [                 // Optional list of arguments
    {
      "name": "string",          // Argument identifier
      "description": "string",   // Argument description (optional)
      "required": true           // Whether argument is required (optional)
    }
  ]
}
```

**Protocol Methods:**
- `prompts/list` - Returns list of available prompts
- `prompts/get` - Returns prompt content for given name and arguments

---

## Wolfram Language Prompt Definition Format

### Structure

```wl
<|
    "Name"        -> "string",           (* MCP prompt name *)
    "Description" -> "string",           (* Human-readable description *)
    "Arguments"   -> { ... },            (* List of argument specifications *)
    "Type"        -> "Function" | "Text" | Automatic,  (* Content type *)
    "Content"     -> content             (* Function, String, or StringTemplate *)
|>
```

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `"Name"` | String | Yes | The MCP prompt name (e.g., `"Search"`). This is what appears in `/mcp__Server__Name` commands. |
| `"Description"` | String | No | Human-readable description of what the prompt does. |
| `"Arguments"` | List | No | List of argument specifications (see below). |
| `"Type"` | String | No | Content type: `"Function"`, `"Text"`, or `Automatic`. Default: `Automatic`. |
| `"Content"` | Any | Yes | The prompt content. Can be a function (for `"Type" -> "Function"`), a `String`, or a `StringTemplate` (for `"Type" -> "Text"`). |

### Argument Specification

```wl
<|
    "Name"        -> "string",     (* Argument identifier *)
    "Description" -> "string",     (* Human-readable description *)
    "Required"    -> True | False  (* Whether the argument is required *)
|>
```

Note: Keys can also be lowercase (`"name"`, `"description"`, `"required"`) for compatibility with MCP format. The system normalizes to capitalized keys internally.

### Type Determination Heuristics

When `"Type"` is `Automatic` (or omitted), the type is inferred from `"Content"`:

1. If `"Content"` is `_String` -> `"Text"`
2. If `"Content"` is `_TemplateObject` -> `"Text"`
3. If `"Content"` is anything else (assumed callable) -> `"Function"`
4. Default (no `"Content"`) -> `"Text"`

---

## $DefaultMCPPrompts

### Purpose

`$DefaultMCPPrompts` is a public symbol containing an Association of predefined prompt definitions, analogous to `$DefaultMCPTools`.

### Structure

```wl
$DefaultMCPPrompts = <|
    "WolframSearch"         -> <| ... |>,
    "WolframLanguageSearch" -> <| ... |>,
    "WolframAlphaSearch"    -> <| ... |>
|>
```

### Naming Convention

- **WL Name**: The key in `$DefaultMCPPrompts` (e.g., `"WolframSearch"`)
- **MCP Name**: The `"Name"` property inside the prompt definition (e.g., `"Search"`)

Multiple WL prompts can share the same MCP name. Each server includes the appropriate WL prompt for its purpose, but users see the same command name.

| WL Name | MCP Name | Server | Description |
|---------|----------|--------|-------------|
| `"WolframSearch"` | `"Search"` | Wolfram | Combined documentation + Wolfram Alpha |
| `"WolframLanguageSearch"` | `"Search"` | WolframLanguage | Documentation only |
| `"WolframAlphaSearch"` | `"Search"` | WolframAlpha | Wolfram Alpha only |

---

## Search Prompt Definitions

### WolframSearch

For the "Wolfram" server. Combines documentation and Wolfram Alpha results.

```wl
$defaultMCPPrompts[ "WolframSearch" ] := <|
    "Name"        -> "Search",
    "Description" -> "Searches for relevant Wolfram information to help answer a query.",
    "Arguments"   -> {
        <|
            "Name"        -> "query",
            "Description" -> "The search query",
            "Required"    -> True
        |>
    },
    "Type"    -> "Function",
    "Content" -> generateWolframSearchPrompt
|>
```

**Implementation:** Calls `relatedWolframContext` from `Wolfram`MCPServer`Tools`Context`` (which combines `cb`RelatedDocumentation` and `cb`RelatedWolframAlphaResults`).

### WolframLanguageSearch

For the "WolframLanguage" and "WolframPacletDevelopment" servers. Documentation only.

```wl
$defaultMCPPrompts[ "WolframLanguageSearch" ] := <|
    "Name"        -> "Search",
    "Description" -> "Searches Wolfram Language documentation for relevant information.",
    "Arguments"   -> {
        <|
            "Name"        -> "query",
            "Description" -> "The search query for Wolfram Language documentation",
            "Required"    -> True
        |>
    },
    "Type"    -> "Function",
    "Content" -> generateWLSearchPrompt
|>
```

**Implementation:** Calls `relatedDocumentation` from `Wolfram`MCPServer`Tools`Context``.

### WolframAlphaSearch

For the "WolframAlpha" server. Wolfram Alpha results only.

```wl
$defaultMCPPrompts[ "WolframAlphaSearch" ] := <|
    "Name"        -> "Search",
    "Description" -> "Searches Wolfram Alpha knowledge base for relevant information.",
    "Arguments"   -> {
        <|
            "Name"        -> "query",
            "Description" -> "The search query for Wolfram Alpha",
            "Required"    -> True
        |>
    },
    "Type"    -> "Function",
    "Content" -> generateWASearchPrompt
|>
```

**Implementation:** Calls `relatedWolframAlphaResults` from `Wolfram`MCPServer`Tools`Context``.

---

## LLMEvaluator Configuration

### Property Name

The property for specifying prompts in LLMEvaluator is `"MCPPrompts"` (not `"PromptData"`).

### Format

Prompts can be specified as:
1. **String names**: Reference prompts from `$DefaultMCPPrompts`
2. **Association definitions**: Inline prompt definitions

```wl
<|
    "Tools" -> { "WolframLanguageContext", "WolframLanguageEvaluator", ... },
    "MCPPrompts" -> { "WolframLanguageSearch" }  (* String reference *)
|>
```

```wl
<|
    "Tools" -> { ... },
    "MCPPrompts" -> {
        <|
            "Name"        -> "CustomPrompt",
            "Description" -> "A custom prompt",
            "Type"        -> "Text",
            "Content"     -> "This is static content."
        |>
    }
|>
```

### Default Server Configurations

| Server | MCPPrompts |
|--------|------------|
| `"Wolfram"` | `{"WolframSearch"}` |
| `"WolframAlpha"` | `{"WolframAlphaSearch"}` |
| `"WolframLanguage"` | `{"WolframLanguageSearch"}` |
| `"WolframPacletDevelopment"` | `{"WolframLanguageSearch"}` |

---

## Deprecation of "PromptData"

The `"PromptData"` property is deprecated. Using it should:

1. Issue a warning message: `MCPServer::DeprecatedPromptData`
2. Return a `Failure` object directing users to use `"MCPPrompts"` instead

```wl
MCPServer::DeprecatedPromptData =
    "The \"PromptData\" property is deprecated. Use \"MCPPrompts\" instead.";
```

---

## Protocol Implementation

### prompts/list Response

The server already handles `prompts/list` requests. The response format:

```json
{
    "prompts": [
        {
            "name": "Search",
            "description": "Searches for relevant information...",
            "arguments": [
                {
                    "name": "query",
                    "description": "The search query",
                    "required": true
                }
            ]
        }
    ]
}
```

**Implementation Notes:**
- Keys must be lowercase for MCP protocol
- The `makePromptData` function transforms WL-style capitalized keys to lowercase

### prompts/get Response

The server already handles `prompts/get` requests. The response format:

```json
{
    "messages": [
        {
            "role": "user",
            "content": {
                "type": "text",
                "text": "... generated prompt content ..."
            }
        }
    ]
}
```

**Implementation Notes:**
- For `"Type" -> "Function"` prompts, the function is called with an Association of arguments
- For `"Type" -> "Text"` prompts with `StringTemplate`, `TemplateApply` is used
- For `"Type" -> "Text"` prompts with plain strings, the content is returned as-is

---

## File Structure

### New Files

```
Kernel/Prompts/
├── Prompts.wl    (* Main entry point, $DefaultMCPPrompts, subcontext loading *)
└── Search.wl     (* WolframSearch, WolframLanguageSearch, WolframAlphaSearch *)

Tests/
└── Prompts.wlt   (* Unit tests for prompt functionality *)
```

### Modified Files

| File | Changes |
|------|---------|
| `Kernel/Main.wl` | Export `$DefaultMCPPrompts`, add context to `$MCPServerContexts` |
| `PacletInfo.wl` | Add `$DefaultMCPPrompts` to Symbols list |
| `Kernel/Messages.wl` | Add error messages for prompts |
| `Kernel/MCPServerObject.wl` | Add validation, update `getPromptData` to use `"MCPPrompts"` |
| `Kernel/StartMCPServer.wl` | Update `makePromptContent` to handle Function type |
| `Kernel/DefaultServers.wl` | Add `"MCPPrompts"` to each server configuration |

---

## Kernel/Prompts/Prompts.wl

### Package Structure

```wl
BeginPackage["Wolfram`MCPServer`Prompts`"];

`$defaultMCPPrompts;  (* Internal association *)

Begin["`Private`"];

Needs["Wolfram`MCPServer`"];
Needs["Wolfram`MCPServer`Common`"];

(* ::Section:: *)
(* $DefaultMCPPrompts *)

$DefaultMCPPrompts := WithCleanup[
    Unprotect @ $DefaultMCPPrompts,
    $DefaultMCPPrompts = AssociationMap[Apply @ Rule, $defaultMCPPrompts],
    Protect @ $DefaultMCPPrompts
];

$defaultMCPPrompts = <| |>;

(* ::Section:: *)
(* Load Subcontexts *)

$subcontexts = {
    "Wolfram`MCPServer`Prompts`Search`"
};

Scan[Needs[# -> None] &, $subcontexts];

$MCPServerContexts = Union[$MCPServerContexts, $subcontexts];

(* ::Section:: *)
(* Package Footer *)

addToMXInitialization[$DefaultMCPPrompts];

End[];
EndPackage[];
```

---

## Kernel/Prompts/Search.wl

### Package Structure

```wl
BeginPackage["Wolfram`MCPServer`Prompts`Search`"];
Begin["`Private`"];

Needs["Wolfram`MCPServer`"];
Needs["Wolfram`MCPServer`Common`"];
Needs["Wolfram`MCPServer`Prompts`"];
Needs["Wolfram`MCPServer`Tools`Context`"];

(* ::Section:: *)
(* Prompt Descriptions *)

$searchDescription =
    "Searches for relevant Wolfram information to help answer a query.";

$wlSearchDescription =
    "Searches Wolfram Language documentation for relevant information.";

$waSearchDescription =
    "Searches Wolfram Alpha knowledge base for relevant information.";

$searchArguments = {
    <|
        "Name"        -> "query",
        "Description" -> "The search query",
        "Required"    -> True
    |>
};

(* ::Section:: *)
(* Prompt Definitions *)

$defaultMCPPrompts[ "WolframSearch" ] := <|
    "Name"        -> "Search",
    "Description" -> $searchDescription,
    "Arguments"   -> $searchArguments,
    "Type"        -> "Function",
    "Content"     -> generateWolframSearchPrompt
|>;

$defaultMCPPrompts[ "WolframLanguageSearch" ] := <|
    "Name"        -> "Search",
    "Description" -> $wlSearchDescription,
    "Arguments"   -> $searchArguments,
    "Type"        -> "Function",
    "Content"     -> generateWLSearchPrompt
|>;

$defaultMCPPrompts[ "WolframAlphaSearch" ] := <|
    "Name"        -> "Search",
    "Description" -> $waSearchDescription,
    "Arguments"   -> $searchArguments,
    "Type"        -> "Function",
    "Content"     -> generateWASearchPrompt
|>;

(* ::Section:: *)
(* Definitions *)

(* ::Subsection:: *)
(* generateWolframSearchPrompt *)

generateWolframSearchPrompt // beginDefinition;

generateWolframSearchPrompt[KeyValuePattern["query" -> query_String]] :=
    generateWolframSearchPrompt @ query;

generateWolframSearchPrompt[query_String] := Enclose[
    Module[{result},
        (* relatedWolframContext is from Tools`Context` *)
        result = ConfirmBy[
            relatedWolframContext[<|"context" -> query|>],
            StringQ,
            "Result"
        ];
        StringJoin[result, "\n\n", query]
    ],
    throwInternalFailure
];

generateWolframSearchPrompt // endDefinition;

(* ::Subsection:: *)
(* generateWLSearchPrompt *)

generateWLSearchPrompt // beginDefinition;

generateWLSearchPrompt[KeyValuePattern["query" -> query_String]] :=
    generateWLSearchPrompt @ query;

generateWLSearchPrompt[query_String] := Enclose[
    Module[{result},
        (* relatedDocumentation is from Tools`Context` *)
        result = ConfirmBy[
            relatedDocumentation[<|"context" -> query|>],
            StringQ,
            "Result"
        ];
        StringJoin[result, "\n\n", query]
    ],
    throwInternalFailure
];

generateWLSearchPrompt // endDefinition;

(* ::Subsection:: *)
(* generateWASearchPrompt *)

generateWASearchPrompt // beginDefinition;

generateWASearchPrompt[KeyValuePattern["query" -> query_String]] :=
    generateWASearchPrompt @ query;

generateWASearchPrompt[query_String] := Enclose[
    Module[{result},
        (* relatedWolframAlphaResults is from Tools`Context` *)
        result = ConfirmBy[
            relatedWolframAlphaResults[<|"context" -> query|>],
            StringQ,
            "Result"
        ];
        StringJoin[result, "\n\n", query]
    ],
    throwInternalFailure
];

generateWASearchPrompt // endDefinition;

(* ::Section:: *)
(* Package Footer *)

End[];
EndPackage[];
```

---

## Error Messages

Add to `Kernel/Messages.wl`:

```wl
MCPServer::InvalidMCPPromptSpecification =
    "Invalid MCP prompt specification: `1`.";

MCPServer::InvalidMCPPromptsSpecification =
    "Invalid MCP prompts specification: `1`.";

MCPServer::PromptNameNotFound =
    "No prompt named \"`1`\" found in $DefaultMCPPrompts.";

MCPServer::DeprecatedPromptData =
    "The \"PromptData\" property is deprecated. Use \"MCPPrompts\" instead.";
```

---

## MCPServerObject.wl Changes

### Validation

Add to `validateLLMEvaluator0`:

```wl
validateLLMEvaluator0["MCPPrompts", prompts_] := validateMCPPrompts @ prompts;
```

New validation functions:

```wl
validateMCPPrompts // beginDefinition;
validateMCPPrompts[prompt_String] := validateMCPPrompts @ {prompt};
validateMCPPrompts[prompts_List] :=
    With[{v = validateMCPPrompt /@ Flatten @ {prompts}},
        Flatten @ {prompts} /; MatchQ[v, {(_Association | _String)...}]
    ];
validateMCPPrompts[prompts_] :=
    throwFailure["InvalidMCPPromptsSpecification", prompts];
validateMCPPrompts // endDefinition;

validateMCPPrompt // beginDefinition;
validateMCPPrompt[prompt_Association] := prompt;
validateMCPPrompt[name_String] /; KeyExistsQ[$DefaultMCPPrompts, name] := name;
validateMCPPrompt[name_String] := throwFailure["PromptNameNotFound", name];
validateMCPPrompt[other_] := throwFailure["InvalidMCPPromptSpecification", other];
validateMCPPrompt // endDefinition;
```

### getPromptData Update

```wl
getPromptData // beginDefinition;

(* Check for new property first *)
getPromptData[as_Association] :=
    getPromptData[as, as["LLMEvaluator", "MCPPrompts"], as["LLMEvaluator", "PromptData"]];

(* MCPPrompts takes precedence *)
getPromptData[as_, prompts: {(_String | _Association)...}, _] :=
    normalizePromptData /@ prompts;

(* No MCPPrompts, check for deprecated PromptData *)
getPromptData[as_, _, prompts: {___Association}] := (
    (* Issue deprecation warning *)
    Message[MCPServer::DeprecatedPromptData];
    throwFailure["DeprecatedPromptData"]
);

(* Neither property exists - return empty *)
getPromptData[as_, _, _] := {};

getPromptData // endDefinition;
```

### normalizePromptData

```wl
normalizePromptData // beginDefinition;

normalizePromptData[name_String] /; KeyExistsQ[$DefaultMCPPrompts, name] :=
    $DefaultMCPPrompts[name];

normalizePromptData[name_String] :=
    throwFailure["PromptNameNotFound", name];

normalizePromptData[as_Association] := Enclose[
    Module[{type},
        type = ConfirmBy[determinePromptType @ as, StringQ, "Type"];
        <| as, "Type" -> type |>
    ],
    throwInternalFailure
];

normalizePromptData // endDefinition;
```

### determinePromptType

```wl
determinePromptType // beginDefinition;
determinePromptType[KeyValuePattern["Type" -> "Function"]] := "Function";
determinePromptType[KeyValuePattern["Type" -> "Text"]] := "Text";
determinePromptType[KeyValuePattern["Type" -> Automatic]] := determinePromptType @ <||>;
determinePromptType[KeyValuePattern["Content" -> _String]] := "Text";
determinePromptType[KeyValuePattern["Content" -> _TemplateObject]] := "Text";
determinePromptType[KeyValuePattern["Content" -> _]] := "Function";
determinePromptType[_] := "Text";
determinePromptType // endDefinition;
```

---

## StartMCPServer.wl Changes

### makePromptContent Update

Add handler for Function type:

```wl
makePromptContent // beginDefinition;

(* Handle Function type - call the function with arguments *)
makePromptContent[KeyValuePattern[{"Type" -> "Function", "Content" -> func_}], arguments_] :=
    makePromptContent[func @ arguments, arguments];

(* Handle Text type with Content *)
makePromptContent[KeyValuePattern["Content" -> content_], arguments_] :=
    makePromptContent[content, arguments];

(* Handle string content *)
makePromptContent[content_String, arguments_] :=
    <|"type" -> "text", "text" -> content|>;

(* Handle template content *)
makePromptContent[template_TemplateObject, arguments_Association] :=
    makePromptContent[TemplateApply[template, arguments], arguments];

(* Fallback - convert to string *)
makePromptContent[content_, arguments_] :=
    <|"type" -> "text", "text" -> ToString @ content|>;

makePromptContent // endDefinition;
```

### makePromptData Update

Normalize keys and handle both capitalized and lowercase:

```wl
makePromptData // beginDefinition;
makePromptData[prompts: {___Association}] := makePromptData0 /@ prompts;
makePromptData // endDefinition;

makePromptData0 // beginDefinition;
makePromptData0[prompt_Association] := Enclose[
    Module[{name, description, arguments},
        name = ConfirmBy[
            prompt["Name"] /. _Missing :> prompt["name"],
            StringQ,
            "Name"
        ];
        description = Replace[
            prompt["Description"] /. _Missing :> prompt["description"],
            Except[_String] :> ""
        ];
        arguments = Replace[
            prompt["Arguments"] /. _Missing :> prompt["arguments"],
            {
                args: {___Association} :> normalizeArguments @ args,
                _ :> {}
            }
        ];
        <|
            "name"        -> name,
            "description" -> description,
            If[Length @ arguments > 0, "arguments" -> arguments, Nothing]
        |>
    ],
    throwInternalFailure
];
makePromptData0 // endDefinition;
```

### normalizeArguments

```wl
normalizeArguments // beginDefinition;
normalizeArguments[args: {___Association}] := normalizeArgument /@ args;
normalizeArguments // endDefinition;

normalizeArgument // beginDefinition;
normalizeArgument[arg_Association] := <|
    "name"        -> (arg["Name"] /. _Missing :> arg["name"]),
    "description" -> (arg["Description"] /. _Missing :> arg["description"]) /. _Missing :> "",
    "required"    -> (arg["Required"] /. _Missing :> arg["required"]) /. _Missing :> False
|>;
normalizeArgument // endDefinition;
```

---

## Testing

### Test File: Tests/Prompts.wlt

```wl
(* ::Section:: *)
(* Initialization *)

VerificationTest[
    If[! TrueQ @ Wolfram`MCPServerTests`$TestDefinitionsLoaded,
        Get @ FileNameJoin @ {DirectoryName[$TestFileName], "Common.wl"}
    ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions"
]

VerificationTest[
    Needs["Wolfram`MCPServer`"],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext"
]

(* ::Section:: *)
(* $DefaultMCPPrompts *)

VerificationTest[
    $DefaultMCPPrompts,
    _Association? AssociationQ,
    SameTest -> MatchQ,
    TestID   -> "DefaultMCPPrompts-IsAssociation"
]

VerificationTest[
    Sort @ Keys @ $DefaultMCPPrompts,
    {"WolframAlphaSearch", "WolframLanguageSearch", "WolframSearch"},
    SameTest -> SameQ,
    TestID   -> "DefaultMCPPrompts-Keys"
]

VerificationTest[
    AllTrue[Values @ $DefaultMCPPrompts, AssociationQ],
    True,
    SameTest -> SameQ,
    TestID   -> "DefaultMCPPrompts-AllAssociations"
]

(* ::Section:: *)
(* Prompt Properties *)

VerificationTest[
    AllTrue[$DefaultMCPPrompts, StringQ @ #["Name"] &],
    True,
    SameTest -> SameQ,
    TestID   -> "PromptProperties-AllHaveNames"
]

VerificationTest[
    AllTrue[$DefaultMCPPrompts, StringQ @ #["Description"] &],
    True,
    SameTest -> SameQ,
    TestID   -> "PromptProperties-AllHaveDescriptions"
]

VerificationTest[
    AllTrue[$DefaultMCPPrompts, MemberQ[{"Function", "Text"}, #["Type"]] &],
    True,
    SameTest -> SameQ,
    TestID   -> "PromptProperties-AllHaveValidType"
]

VerificationTest[
    AllTrue[$DefaultMCPPrompts, MatchQ[#["Arguments"], {___Association}] &],
    True,
    SameTest -> SameQ,
    TestID   -> "PromptProperties-AllHaveArguments"
]

(* ::Section:: *)
(* MCP Name Mapping *)

VerificationTest[
    Union @ Map[#["Name"] &, Values @ $DefaultMCPPrompts],
    {"Search"},
    SameTest -> SameQ,
    TestID   -> "MCPNameMapping-AllSearchPromptsShareName"
]

(* ::Section:: *)
(* Server Integration *)

VerificationTest[
    MCPServerObject["Wolfram"]["PromptData"],
    {_Association..},
    SameTest -> MatchQ,
    TestID   -> "ServerIntegration-WolframHasPrompts"
]

VerificationTest[
    MCPServerObject["WolframLanguage"]["PromptData"],
    {_Association..},
    SameTest -> MatchQ,
    TestID   -> "ServerIntegration-WolframLanguageHasPrompts"
]

VerificationTest[
    MCPServerObject["WolframAlpha"]["PromptData"],
    {_Association..},
    SameTest -> MatchQ,
    TestID   -> "ServerIntegration-WolframAlphaHasPrompts"
]

(* ::Section:: *)
(* Deprecation Warning *)

VerificationTest[
    (* Using PromptData directly should fail *)
    CreateMCPServer["TestServer", <|"PromptData" -> {<|"Name" -> "Test"|>}|>],
    _Failure,
    {MCPServer::DeprecatedPromptData},
    SameTest -> MatchQ,
    TestID   -> "Deprecation-PromptDataFails"
]
```

---

## Usage Examples

### Client Usage (Claude Code)

```text
/mcp__WolframLanguage__Search "How can I find the 123456789th prime number?"
```

This invokes the "Search" prompt on the WolframLanguage server, which:
1. Calls `generateWLSearchPrompt` with `<|"query" -> "How can I find..."|>`
2. Retrieves relevant documentation via `relatedDocumentation`
3. Returns the documentation context plus the original query

### Creating Custom Prompts

```wl
CreateMCPServer["MyServer", <|
    "MCPPrompts" -> {
        <|
            "Name"        -> "Greet",
            "Description" -> "Generates a greeting message",
            "Arguments"   -> {
                <| "Name" -> "name", "Description" -> "Name to greet", "Required" -> True |>
            },
            "Type"    -> "Text",
            "Content" -> StringTemplate["Hello, `name`! Welcome to the Wolfram Language."]
        |>
    }
|>]
```

### Using Function-Based Custom Prompts

```wl
generateCustomPrompt[args_Association] := Module[{name},
    name = args["name"];
    "Custom content for " <> name
];

CreateMCPServer["MyServer", <|
    "MCPPrompts" -> {
        <|
            "Name"        -> "Custom",
            "Description" -> "A custom prompt",
            "Arguments"   -> {
                <| "Name" -> "name", "Required" -> True |>
            },
            "Type"    -> "Function",
            "Content" -> generateCustomPrompt
        |>
    }
|>]
```

---

## Implementation Order

1. Add error messages to `Kernel/Messages.wl`
2. Create `Kernel/Prompts/Prompts.wl`
3. Create `Kernel/Prompts/Search.wl`
4. Update `Kernel/Main.wl` (exports and contexts)
5. Update `PacletInfo.wl` (symbols list)
6. Update `Kernel/MCPServerObject.wl` (validation and getPromptData)
7. Update `Kernel/StartMCPServer.wl` (makePromptContent and makePromptData)
8. Update `Kernel/DefaultServers.wl` (add MCPPrompts to each server)
9. Create `Tests/Prompts.wlt`
10. Run full test suite

---

## Future Expansion

Additional prompts that could be added:

- **Explain**: Explains a Wolfram Language expression or concept
- **Debug**: Provides debugging context for code issues
- **Optimize**: Suggests optimizations for given code
- **Document**: Generates documentation for a function

These would follow the same pattern, with appropriate functions calling relevant Chatbook or other backend services.
