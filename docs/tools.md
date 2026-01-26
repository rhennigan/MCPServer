# MCP Tools in MCPServer

This document explains how MCP tools work in MCPServer and how to add new tools.

## Overview

MCP tools allow servers to expose callable functions to language models. Clients can discover available tools, view their parameter specifications, and invoke them with arguments. This follows the [MCP tools specification](https://modelcontextprotocol.io/specification/2025-11-25/server/tools.md).

Tools are designed to be model-controlled, meaning the LLM decides when and how to use them based on the conversation context and user requests.

The tools system provides:
- `$DefaultMCPTools` - An association of predefined tool definitions
- Tools are specified via the `"Tools"` LLMEvaluator property
- Tools can be referenced by name (string) or defined inline (association)

## How Tools Work

### Protocol Flow

1. **Client requests tool list** (`tools/list`): Server returns available tools with names, descriptions, and JSON schemas for parameters
2. **Client invokes tool** (`tools/call`): Server executes the tool function with provided arguments
3. **Result returned**: The generated content is returned as a string to the LLM

### Tool Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `"Name"` | String | Yes | Unique identifier for the tool |
| `"DisplayName"` | String | No | Human-readable display name |
| `"Description"` | String | Yes | Detailed description of what the tool does |
| `"Function"` | Symbol | Yes | The Wolfram Language function to call |
| `"Parameters"` | List | Yes | Parameter specifications (see below) |
| `"Options"` | List | No | Tool options |
| `"LLMKit"` | String | No | Dependency: `"Suggested"`, `"Required"`, or `Automatic` |
| `"Initialization"` | Delayed | No | Optional initialization code run before first use |

## $DefaultMCPTools

The paclet provides `$DefaultMCPTools`, an association of predefined tool definitions:

```wl
$DefaultMCPTools = <|
    "WolframLanguageEvaluator" -> LLMTool[ ... ],
    "WolframContext"           -> LLMTool[ ... ],
    "WolframAlpha"             -> LLMTool[ ... ],
    ...
|>
```

### Available Tools

#### Context Tools

| Tool | Description | Server |
|------|-------------|--------|
| `WolframContext` | Semantic search for combined Wolfram documentation and Wolfram Alpha results | Wolfram |
| `WolframAlphaContext` | Semantic search for Wolfram Alpha results | WolframAlpha |
| `WolframLanguageContext` | Semantic search for Wolfram Language documentation | WolframLanguage, WolframPacletDevelopment |

#### Code Execution Tools

| Tool | Description | Server |
|------|-------------|--------|
| `WolframLanguageEvaluator` | Evaluates Wolfram Language code with time constraints | Wolfram, WolframLanguage, WolframPacletDevelopment |
| `WolframAlpha` | Natural language queries to Wolfram Alpha | Wolfram, WolframAlpha |
| `SymbolDefinition` | Retrieves symbol definitions in readable markdown format | WolframLanguage, WolframPacletDevelopment |

#### Notebook Tools

| Tool | Description | Server |
|------|-------------|--------|
| `ReadNotebook` | Reads Wolfram notebooks (.nb) as markdown text | WolframLanguage, WolframPacletDevelopment |
| `WriteNotebook` | Converts markdown to Wolfram notebooks | WolframLanguage, WolframPacletDevelopment |

#### Testing Tools

| Tool | Description | Server |
|------|-------------|--------|
| `TestReport` | Runs Wolfram Language test files (.wlt) and returns a report | WolframLanguage, WolframPacletDevelopment |

#### Code Analysis Tools

| Tool | Description | Server |
|------|-------------|--------|
| `CodeInspector` | Inspects Wolfram Language code and returns a formatted report of issues | WolframLanguage, WolframPacletDevelopment |

#### Documentation Tools

| Tool | Description | Server |
|------|-------------|--------|
| `CreateSymbolDoc` | Creates new symbol documentation pages for paclets | WolframPacletDevelopment |
| `EditSymbolDoc` | Edits existing symbol documentation pages | WolframPacletDevelopment |
| `EditSymbolDocExamples` | Edits example sections of symbol documentation | WolframPacletDevelopment |

## Tool Definition Format

### Structure

```wl
$defaultMCPTools[ "ToolName" ] := LLMTool @ <|
    "Name"           -> "ToolName",
    "DisplayName"    -> "Human Readable Name",
    "Description"    -> "Detailed tool description...",
    "Function"       -> toolFunction,
    "Options"        -> { },
    "Parameters"     -> { ... },
    "LLMKit"         -> "Suggested",           (* Optional *)
    "Initialization" :> initFunction[ ]        (* Optional *)
|>
```

### Parameter Specification

Parameters are specified as a list of rules, where each parameter is defined as:

```wl
"paramName" -> <|
    "Interpreter" -> "String" | "Integer" | "Boolean",
    "Help"        -> "Parameter description",
    "Required"    -> True | False
|>
```

**Example from WolframLanguageEvaluator:**

```wl
"Parameters" -> {
    "code" -> <|
        "Interpreter" -> "String",
        "Help"        -> "The Wolfram Language code to evaluate.",
        "Required"    -> True
    |>,
    "timeConstraint" -> <|
        "Interpreter" -> "Integer",
        "Help"        -> "The time constraint for the evaluation (default is 60 seconds).",
        "Required"    -> False
    |>
}
```

## Adding a New Tool

### Step 1: Create the Tool Definition File

Create a new file in `Kernel/Tools/` following this pattern:

```wl
(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`Tools`YourTool`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];
Needs[ "Wolfram`MCPServer`Tools`"  ];

(* ::Section::Closed:: *)
(*Prompts*)
$yourToolDescription = "\
Description of what your tool does.
Include usage guidance for the LLM.";

(* ::Section::Closed:: *)
(*Tool Definition*)
$defaultMCPTools[ "YourTool" ] := LLMTool @ <|
    "Name"        -> "YourTool",
    "DisplayName" -> "Your Tool Name",
    "Description" -> $yourToolDescription,
    "Function"    -> yourToolFunction,
    "Options"     -> { },
    "Parameters"  -> {
        "param1" -> <|
            "Interpreter" -> "String",
            "Help"        -> "Description of parameter",
            "Required"    -> True
        |>
    }
|>;

(* ::Section::Closed:: *)
(*Definitions*)
yourToolFunction // beginDefinition;

yourToolFunction[ KeyValuePattern[ "param1" -> value_ ] ] :=
    yourToolFunction @ value;

yourToolFunction[ value_String ] := Enclose[
    Module[ { result },
        result = ConfirmBy[ yourComputation @ value, StringQ, "Result" ];
        (* Tools must return a string *)
        result
    ],
    throwInternalFailure
];

yourToolFunction // endDefinition;

(* ::Section::Closed:: *)
(*Package Footer*)
End[ ];
EndPackage[ ];
```

### Step 2: Register the Subcontext

Add your new subcontext to `Kernel/Tools/Tools.wl`:

```wl
$subcontexts = {
    "Wolfram`MCPServer`Tools`Context`",
    "Wolfram`MCPServer`Tools`Notebooks`",
    (* ... existing subcontexts ... *)
    "Wolfram`MCPServer`Tools`YourTool`"  (* Add your new subcontext *)
};
```

### Step 3: Add to Server Configuration (Optional)

If you want the tool to be included in default servers, update `Kernel/DefaultServers.wl`:

```wl
$defaultMCPServers[ "ServerName" ] := <|
    "Name"          -> "ServerName",
    "Location"      -> "BuiltIn",
    "Transport"     -> "StandardInputOutput",
    "ServerVersion" -> $pacletVersion,
    "ObjectVersion" -> $objectVersion,
    "LLMEvaluator"  -> <|
        "Tools" -> {
            (* ... existing tools ... *)
            "YourTool"  (* Add your tool *)
        },
        "MCPPrompts" -> { ... }
    |>
|>
```

### Step 4: Write Tests

Add tests to `Tests/Tools.wlt`:

```wl
VerificationTest[
    $DefaultMCPTools[ "YourTool" ][ "Name" ],
    "YourTool",
    TestID -> "YourTool-Name"
]

VerificationTest[
    StringQ @ $DefaultMCPTools[ "YourTool" ][ "Description" ],
    True,
    TestID -> "YourTool-Description"
]
```

## Using Tools in Custom Servers

### Reference by Name

```wl
CreateMCPServer[ "MyServer", <|
    "Tools" -> { "WolframLanguageEvaluator", "WolframAlpha" }
|> ]
```

### Inline Definition

```wl
CreateMCPServer[ "MyServer", <|
    "Tools" -> {
        LLMTool @ <|
            "Name"        -> "CustomTool",
            "Description" -> "Does something custom",
            "Function"    -> myFunction,
            "Parameters"  -> {
                "input" -> <| "Interpreter" -> "String", "Required" -> True |>
            }
        |>
    }
|> ]
```

## Tool Implementation Patterns

### KeyValuePattern Entry Point

Tools receive parameters as an association. Use `KeyValuePattern` to extract values:

```wl
toolFunction[ KeyValuePattern @ {
    "param1" -> value1_,
    "param2" -> value2_
} ] := toolFunction[ value1, value2 ];
```

### Handling Optional Parameters

Optional parameters may have value `Missing["NoInput"]`:

```wl
toolFunction[ KeyValuePattern @ {
    "required" -> value_,
    "optional" -> optional_
} ] := Module[ { opt },
    opt = Replace[ optional, Except[ _Integer ] -> 60 ];  (* Default value *)
    (* ... *)
];
```

### Using the Evaluator Kernel

For tools that need to access definitions from the evaluator kernel (when using external evaluation):

```wl
toolFunction[ args_ ] := useEvaluatorKernel @ toolFunction0 @ args;
```

### Initialization

Use the `"Initialization"` property for lazy setup (e.g., loading vector databases):

```wl
$defaultMCPTools[ "MyTool" ] := LLMTool @ <|
    (* ... *)
    "Initialization" :> initializeResources[ ]
|>
```

## Tool Output Format

Tools must return strings. For structured output, use consistent formats:

### Markdown Output

```wl
"# Result\n\n## Section\n\n```wl\ncode\n```"
```

### Error Messages

Return error information as part of the string:

```wl
"Error: Invalid input \"" <> input <> "\""
```

### Image Output

Images can be exported to cloud and returned as markdown links:

```wl
"![Image](" <> cloudURL <> ")"
```

## Error Handling

Tools should handle errors gracefully using the standard error handling pattern:

```wl
toolFunction[ args_ ] := Enclose[
    Module[ { result },
        result = ConfirmBy[ computation[ args ], StringQ, "Result" ];
        result
    ],
    throwInternalFailure
];
```

The server wraps tool calls with error handling that converts failures to error messages rather than MCP protocol errors.

## LLMKit Dependency

Tools can specify their LLMKit dependency:

| Value | Meaning |
|-------|---------|
| `"Required"` | Tool will fail without LLMKit subscription |
| `"Suggested"` | Tool works better with LLMKit but has fallback |
| `Automatic` | No special dependency |

Example:

```wl
$defaultMCPTools[ "WolframAlphaContext" ] := LLMTool @ <|
    (* ... *)
    "LLMKit" -> "Required"
|>
```

## Related Files

- `Kernel/Tools/Tools.wl` - Main tools module, defines `$DefaultMCPTools`
- `Kernel/Tools/Context.wl` - Context tools (WolframContext, WolframAlphaContext, WolframLanguageContext)
- `Kernel/Tools/WolframLanguageEvaluator.wl` - Code evaluation tool
- `Kernel/Tools/WolframAlpha.wl` - Wolfram Alpha query tool
- `Kernel/Tools/SymbolDefinition.wl` - Symbol definition lookup tool
- `Kernel/Tools/Notebooks.wl` - ReadNotebook and WriteNotebook tools
- `Kernel/Tools/TestReport.wl` - Test runner tool
- `Kernel/Tools/CodeInspector/` - Code inspection tool
- `Kernel/Tools/PacletDocumentation/` - Documentation editing tools
- `Kernel/MCPServerObject.wl` - Tool validation and normalization
- `Kernel/StartMCPServer.wl` - Protocol handling for `tools/list` and `tools/call`
- `Kernel/DefaultServers.wl` - Server configurations with `"Tools"` settings
- `Tests/Tools.wlt` - Tests for tool functionality
