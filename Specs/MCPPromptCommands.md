# MCP Prompt Commands - Specification

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

| Property | Value |
|----------|-------|
| MCP Name | `"Search"` |
| Description | Searches for relevant Wolfram information to help answer a query. |
| Arguments | `query` (required) - The search query |
| Type | Function |
| Behavior | Retrieves both Wolfram Language documentation and Wolfram Alpha results |

### WolframLanguageSearch

For the "WolframLanguage" and "WolframPacletDevelopment" servers. Documentation only.

| Property | Value |
|----------|-------|
| MCP Name | `"Search"` |
| Description | Searches Wolfram Language documentation for relevant information. |
| Arguments | `query` (required) - The search query for Wolfram Language documentation |
| Type | Function |
| Behavior | Retrieves relevant Wolfram Language documentation |

### WolframAlphaSearch

For the "WolframAlpha" server. Wolfram Alpha results only.

| Property | Value |
|----------|-------|
| MCP Name | `"Search"` |
| Description | Searches Wolfram Alpha knowledge base for relevant information. |
| Arguments | `query` (required) - The search query for Wolfram Alpha |
| Type | Function |
| Behavior | Retrieves relevant Wolfram Alpha computation results |

---

## Prompt Output Format

All search prompts use a consistent XML-style format to structure their output:

```
<search-query>{query}</search-query>
<search-results>
{results}
</search-results>
Use the above search results to answer the user's query below.
<user-query>{query}</user-query>
```

### Format Elements

| Element | Description |
|---------|-------------|
| `<search-query>` | Contains the original query passed to the search function |
| `<search-results>` | Contains the search results from the underlying context function |
| `<user-query>` | Repeats the original query at the end |

### Rationale

The query is intentionally repeated in both `<search-query>` and `<user-query>` tags. This allows LLMs to:

1. **Detect argument parsing issues**: If a client incorrectly truncates arguments (e.g., Claude Code issue #14210), the LLM can see the original query in context and potentially infer the intended request.
2. **Maintain context**: The repeated query provides clear boundaries for what the search was about.
3. **Support debugging**: The structured format makes it easier to identify issues in the search pipeline.

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

---

## Error Messages

The following error messages should be defined:

| Message Tag | Description |
|-------------|-------------|
| `InvalidMCPPromptSpecification` | Invalid MCP prompt specification: \`1\`. |
| `InvalidMCPPromptsSpecification` | Invalid MCP prompts specification: \`1\`. |
| `PromptNameNotFound` | No prompt named "\`1\`" found in $DefaultMCPPrompts. |
| `DeprecatedPromptData` | The "PromptData" property is deprecated. Use "MCPPrompts" instead. |

---

## Protocol Implementation

### prompts/list Response

The response format for `prompts/list`:

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

**Notes:**
- Keys must be lowercase for MCP protocol compliance
- WL-style capitalized keys are transformed to lowercase when generating the response

### prompts/get Response

The response format for `prompts/get`:

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

**Content Generation:**
- For `"Type" -> "Function"` prompts, the function is called with an Association of arguments
- For `"Type" -> "Text"` prompts with `StringTemplate`, `TemplateApply` is used
- For `"Type" -> "Text"` prompts with plain strings, the content is returned as-is

---

## Usage Examples

### Client Usage (Claude Code)

```text
/mcp__WolframLanguage__Search "How can I find the 123456789th prime number?"
```

This invokes the "Search" prompt on the WolframLanguage server, which:
1. Receives the query argument
2. Retrieves relevant documentation
3. Returns the documentation context formatted with the original query

### Creating Custom Prompts

**Text-based prompt with template:**

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

**Function-based prompt:**

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
