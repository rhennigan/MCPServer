# Predefined MCP Servers

This document describes the predefined MCP servers available in MCPServer and helps you choose the right one for your needs.

## Overview

MCPServer provides four predefined server configurations, each tailored for different use cases. These are available via `$DefaultMCPServers` and can be installed into MCP clients using `InstallMCPServer`.

| Server | Primary Use Case |
|--------|------------------|
| `Wolfram` | General-purpose: Wolfram Language + Wolfram Alpha |
| `WolframAlpha` | Natural language queries via Wolfram Alpha |
| `WolframLanguage` | Wolfram Language development with notebook support |
| `WolframPacletDevelopment` | Paclet development with documentation tools |

## Choosing a Server

### Wolfram (Default)

**Best for:** General-purpose use combining computational power with natural language understanding.

```wl
InstallMCPServer["ClaudeDesktop", "Wolfram"]
```

This is the default server when no server name is specified. It provides:

| Component | Name | Description |
|-----------|------|-------------|
| Tool | `WolframContext` | Semantic search across Wolfram resources (documentation, Wolfram Alpha, repositories, and more) |
| Tool | `WolframLanguageEvaluator` | Execute Wolfram Language code |
| Tool | `WolframAlpha` | Natural language queries to Wolfram Alpha |
| Prompt | `Search` | Combined documentation and Wolfram Alpha search |

**Use this when:** You want a balanced mix of code execution, documentation lookup, and natural language computation.

### WolframAlpha

**Best for:** Natural language queries without code execution.

```wl
InstallMCPServer["ClaudeDesktop", "WolframAlpha"]
```

This server focuses on Wolfram Alpha's natural language capabilities:

| Component | Name | Description |
|-----------|------|-------------|
| Tool | `WolframAlphaContext` | Semantic search for Wolfram Alpha results |
| Tool | `WolframAlpha` | Natural language queries to Wolfram Alpha |
| Prompt | `Search` | Wolfram Alpha search |

**Use this when:** You need computational knowledge (math, science, data) without running Wolfram Language code.

### WolframLanguage

**Best for:** Wolfram Language development and learning.

```wl
InstallMCPServer["ClaudeCode", "WolframLanguage"]
```

This server provides comprehensive Wolfram Language development tools:

| Component | Name | Description |
|-----------|------|-------------|
| Tool | `WolframLanguageContext` | Semantic search across Wolfram Language resources (documentation, repositories, and more) |
| Tool | `WolframLanguageEvaluator` | Execute Wolfram Language code |
| Tool | `ReadNotebook` | Read Wolfram notebooks (.nb) as markdown |
| Tool | `WriteNotebook` | Convert markdown to Wolfram notebooks |
| Tool | `SymbolDefinition` | Look up symbol definitions |
| Tool | `CodeInspector` | Inspect Wolfram Language code for issues |
| Tool | `TestReport` | Run Wolfram Language test files (.wlt) |
| Prompt | `Search` | Wolfram Language documentation search |
| Prompt | `Notebook` | Attach notebook contents to context |

**Use this when:** You're developing Wolfram Language code, working with notebooks, or learning the language.

### WolframPacletDevelopment

**Best for:** Developing and maintaining Wolfram paclets.

```wl
InstallMCPServer[{"ClaudeCode", "/path/to/paclet"}, "WolframPacletDevelopment"]
```

This server extends `WolframLanguage` with paclet documentation tools:

| Component | Name | Description |
|-----------|------|-------------|
| Tool | `WolframLanguageContext` | Semantic search across Wolfram Language resources (documentation, repositories, and more) |
| Tool | `WolframLanguageEvaluator` | Execute Wolfram Language code |
| Tool | `ReadNotebook` | Read Wolfram notebooks (.nb) as markdown |
| Tool | `WriteNotebook` | Convert markdown to Wolfram notebooks |
| Tool | `SymbolDefinition` | Look up symbol definitions |
| Tool | `CodeInspector` | Inspect Wolfram Language code for issues |
| Tool | `TestReport` | Run Wolfram Language test files (.wlt) |
| Tool | `CreateSymbolDoc` | Create new symbol documentation pages |
| Tool | `EditSymbolDoc` | Edit existing symbol documentation |
| Tool | `EditSymbolDocExamples` | Edit example sections in documentation |
| Prompt | `Search` | Wolfram Language documentation search |
| Prompt | `Notebook` | Attach notebook contents to context |

**Use this when:** You're developing a Wolfram paclet and need to create or maintain documentation notebooks.

## Server Comparison

### Tools by Server

| Tool | Wolfram | WolframAlpha | WolframLanguage | WolframPacletDevelopment |
|------|:-------:|:------------:|:---------------:|:------------------------:|
| `WolframContext` | X | | | |
| `WolframAlphaContext` | | X | | |
| `WolframLanguageContext` | | | X | X |
| `WolframLanguageEvaluator` | X | | X | X |
| `WolframAlpha` | X | X | | |
| `ReadNotebook` | | | X | X |
| `WriteNotebook` | | | X | X |
| `SymbolDefinition` | | | X | X |
| `CodeInspector` | | | X | X |
| `TestReport` | | | X | X |
| `CreateSymbolDoc` | | | | X |
| `EditSymbolDoc` | | | | X |
| `EditSymbolDocExamples` | | | | X |

### Prompts by Server

| Prompt (MCP Name) | Wolfram | WolframAlpha | WolframLanguage | WolframPacletDevelopment |
|-------------------|:-------:|:------------:|:---------------:|:------------------------:|
| `Search` | X | X | X | X |
| `Notebook` | | | X | X |

Note: The `Search` prompt has different implementations depending on the server:
- **Wolfram**: Searches both documentation and Wolfram Alpha
- **WolframAlpha**: Searches Wolfram Alpha only
- **WolframLanguage/WolframPacletDevelopment**: Searches documentation only

## Using Predefined Servers

### Installation

Install a server into an MCP client:

```wl
(* Install default (Wolfram) server *)
InstallMCPServer["ClaudeDesktop"]

(* Install a specific server *)
InstallMCPServer["ClaudeCode", "WolframLanguage"]

(* Install to a project directory *)
InstallMCPServer[{"ClaudeCode", "/path/to/project"}, "WolframPacletDevelopment"]
```

See [mcp-clients.md](mcp-clients.md) for details on supported clients and installation options.

### Accessing Server Objects

Get a server object programmatically:

```wl
(* Get all predefined servers *)
$DefaultMCPServers
(* <|"Wolfram" -> MCPServerObject[...], ...|> *)

(* Get a specific server *)
MCPServerObject["WolframLanguage"]
```

### Server Properties

Query server properties:

```wl
server = MCPServerObject["WolframLanguage"];
server["Name"]           (* "WolframLanguage" *)
server["Tools"]          (* List of LLMTool objects *)
server["MCPPrompts"]     (* List of prompt definitions *)
server["JSONConfiguration"]  (* JSON config for manual setup *)
```

## Creating Custom Servers

If the predefined servers don't meet your needs, you can create custom servers with `CreateMCPServer`.

### Basic Custom Server

```wl
CreateMCPServer["MyServer", <|
    "Tools" -> {"WolframLanguageEvaluator", "WolframAlpha"}
|>]
```

### Mixing Predefined and Custom Tools

```wl
CreateMCPServer["MyServer", <|
    "Tools" -> {
        "WolframLanguageEvaluator",
        LLMTool @ <|
            "Name" -> "CustomTool",
            "Description" -> "My custom tool",
            "Function" -> myFunction,
            "Parameters" -> {"input" -> <|"Interpreter" -> "String"|>}
        |>
    }
|>]
```

### Adding Custom Prompts

```wl
CreateMCPServer["MyServer", <|
    "Tools" -> {"WolframLanguageEvaluator"},
    "MCPPrompts" -> {
        "WolframLanguageSearch",
        <|
            "Name" -> "Greet",
            "Description" -> "Generates a greeting",
            "Arguments" -> {<|"Name" -> "name", "Required" -> True|>},
            "Type" -> "Text",
            "Content" -> StringTemplate["Hello, `name`!"]
        |>
    }
|>]
```

See [tools.md](tools.md) and [mcp-prompts.md](mcp-prompts.md) for details on creating custom tools and prompts.

## LLMKit Requirements

Some tools require an [LLMKit subscription](https://www.wolfram.com/llmkit/) for full functionality:

| Tool | LLMKit Dependency |
|------|-------------------|
| `WolframContext` | Required |
| `WolframAlphaContext` | Required |
| `WolframLanguageContext` | Required |
| Other tools | Not required |

The context tools use semantic search powered by LLMKit. Without a subscription, these tools will not function. Code execution tools (`WolframLanguageEvaluator`, `WolframAlpha`) work without LLMKit.

## Related Documentation

- [tools.md](tools.md) - Detailed tool documentation and creating custom tools
- [mcp-prompts.md](mcp-prompts.md) - Prompt system and creating custom prompts
- [mcp-clients.md](mcp-clients.md) - Client installation and configuration
- [getting-started.md](getting-started.md) - Development setup
