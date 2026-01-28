# Quick Start: Wolfram MCP Server for AI Coding Applications

This guide walks you through setting up the Wolfram MCP Server with AI coding applications like Claude Code, Cursor, Visual Studio Code, and others. By the end, your AI coding assistant will be able to evaluate Wolfram Language code, search documentation, read and write notebooks, run tests, and inspect code.

## Recommended Server

For Wolfram Language development, it's recommended to use the **WolframLanguage** server. It gives the AI the ability to:

- **Search Wolfram resources** including documentation, function repository, data repository, and more
- **Execute code** to test implementations and verify behavior
- **Read and write notebooks** for working with `.nb` files as markdown
- **Look up symbol definitions** to understand existing code
- **Inspect code** for potential issues and style problems
- **Run tests** to validate changes against your test suite

## Installation

All installation methods use the `InstallMCPServer` function. Open a Wolfram Language session and run the appropriate command for your application.

### Claude Code

Choose whether to install the server globally or project-level. Global installation is available in all projects, while project-level installation is available only in a specific project directory.

Global installation:

```wl
InstallMCPServer["ClaudeCode", "WolframLanguage"]
```

Project-level installation:

```wl
InstallMCPServer[{"ClaudeCode", "/path/to/project"}, "WolframLanguage"]
```

Verify the installation from the command line:

```shell
claude mcp get WolframLanguage
```

The output should indicate that the "WolframLanguage" server is connected.

### Cline

```wl
InstallMCPServer["Cline", "WolframLanguage"]
```

### Copilot CLI

```wl
InstallMCPServer["CopilotCLI", "WolframLanguage"]
```

To verify the installation from the command line:

```shell
copilot -i "/mcp show"
```

The output should indicate that the "WolframLanguage" server is configured.

### Cursor

```wl
InstallMCPServer["Cursor", "WolframLanguage"]
```

To verify the installation:

- Navigate to Cursor settings
- Select the "Tools & MCP" tab
- Verify that "WolframLanguage" is listed under "Installed MCP Servers"

### Gemini CLI

```wl
InstallMCPServer["GeminiCLI", "WolframLanguage"]
```

To verify the installation from the command line:

```shell
gemini -i "/mcp"
```

The output should indicate that the "WolframLanguage" server is configured.

### Google Antigravity

```wl
InstallMCPServer["Antigravity", "WolframLanguage"]
```

To verify the installation:

- In the editor view, click the "..." menu at the top right of the "Agent" panel
- Select "MCP Servers"
- Click "Manage MCP Servers" at the top right of the panel
- Verify that "WolframLanguage" is listed under "Installed MCP Servers"

### OpenAI Codex

```wl
InstallMCPServer["Codex", "WolframLanguage"]
```

To verify the installation from the command line:

```shell
codex mcp get WolframLanguage
```

The output should indicate that the "WolframLanguage" server is enabled.

### OpenCode

Choose whether to install the server globally or project-level. Global installation is available in all projects, while project-level installation is available only in a specific project directory.

Global installation:

```wl
InstallMCPServer["OpenCode", "WolframLanguage"]
```

Project-level installation:

```wl
InstallMCPServer[{"OpenCode", "/path/to/project"}, "WolframLanguage"]
```

To verify the installation from the command line:

```shell
opencode mcp list
```

The output should indicate that the "WolframLanguage" server is connected.

### Visual Studio Code

Choose whether to install the server globally or project-level. Global installation is available in all projects, while project-level installation is available only in a specific project directory.

Global installation:

```wl
InstallMCPServer["VisualStudioCode", "WolframLanguage"]
```

Project-level installation:

```wl
InstallMCPServer[{"VisualStudioCode", "/path/to/project"}, "WolframLanguage"]
```

### Windsurf

```wl
InstallMCPServer["Windsurf", "WolframLanguage"]
```

### Zed

```wl
InstallMCPServer["Zed", "WolframLanguage"]
```

### Other Clients

For other MCP-compatible clients, you can generate the raw JSON configuration and adapt it manually:

```wl
MCPServerObject["WolframLanguage"]["JSONConfiguration"]
```

See [mcp-clients.md](mcp-clients.md) for a full list of supported clients, configuration file locations, and format details.

#### Verifying the Installation

After installing, restart your coding tool and confirm the Wolfram tools are available. Most applications have a way to list configured MCP servers and their status. If you're unsure, you can always just ask the AI:

> "What Wolfram Language tools do you have access to?"

The AI should list tools like `WolframLanguageEvaluator`, `WolframLanguageContext`, `TestReport`, etc.

## Configuring AI Guidance with AGENTS.md

AI coding tools start each session with no memory of previous conversations. An `AGENTS.md` file (or similar project-level instructions file) at the root of your project gives the AI essential context about your codebase, conventions, and how to use the Wolfram Language tools effectively.

### Why AGENTS.md Matters

Without guidance, the AI will:
- Not know when to use `WolframLanguageContext` to look up documentation
- Miss your project's coding conventions and patterns
- Write code in unfamiliar styles or use deprecated patterns
- Skip testing and code inspection

With a well-written `AGENTS.md`, the AI will follow your conventions from the start.

### What to Include

1. **Tool guidance** - When and how to use each Wolfram Language tool
2. **Project layout** - Directory structure, key files, entry points
3. **Code style** - Naming conventions, patterns, error handling approach
4. **Testing** - How to run tests, where test files live, test format

### Available Tools

The WolframLanguage server provides these tools that you can reference in your AGENTS.md:

| Tool | Description |
|------|-------------|
| `WolframLanguageContext` | Semantic search across Wolfram resources (documentation, function repository, data repository, neural net repository, and more) |
| `WolframLanguageEvaluator` | Execute Wolfram Language code |
| `ReadNotebook` | Read Wolfram notebooks (.nb) as markdown |
| `WriteNotebook` | Convert markdown to Wolfram notebooks |
| `SymbolDefinition` | Look up symbol definitions in readable format |
| `CodeInspector` | Inspect code for issues and return a formatted report |
| `TestReport` | Run Wolfram Language test files (.wlt) |

### AGENTS.md Template

Below is a template you can adapt for your Wolfram Language project:

````markdown
# AGENTS.md

## Overview

Brief description of what your project does.

## Development

Always use the WolframLanguageContext tool when working with Wolfram Language code
to look up documentation and find relevant functions before writing code.

When you make changes to source code, write and run tests using the TestReport tool
and check your work with the CodeInspector tool.

## Project Structure

- `Kernel/` - Main source files
  - `MyPaclet.wl` - Entry point
  - `Utilities.wl` - Helper functions
- `Tests/` - Test files (.wlt)
- `Documentation/` - Notebooks and docs

## Code Style

- Use `UpperCamelCase` for public function names
- Use `lowerCamelCase` for internal function names
- Use `Enclose`/`Confirm` for error handling:
  ```wl
  myFunction[arg_] := Enclose[
      Module[{result},
          result = ConfirmBy[computation[arg], StringQ];
          result
      ]
  ];
  ```

## Writing Tests

Write tests in this format:

```wl
VerificationTest[
    input,
    expected,
    TestID -> "DescriptiveTestID"
]
```

Test files go in the `Tests/` directory with a `.wlt` extension.

## Key Patterns

Describe any project-specific patterns, conventions, or architectural decisions
that the AI should follow.
````

Adjust the template to match your actual project structure, conventions, and requirements.

## Best Practices for AI-Assisted Development

### Test-Driven Development

AI coding tools work well with a test-driven workflow:

1. **Write tests first** describing the expected behavior
2. **Ask the AI to implement** the function to pass the tests
3. **Run tests with TestReport** to verify
4. **Iterate** until all tests pass

This gives the AI a concrete specification to work against and provides automatic verification.

### Use Planning Mode

For non-trivial tasks, ask the AI to plan before implementing:

> "I need to add a function that parses CSV files into Associations. Plan the implementation before writing code."

This lets the AI explore the codebase, understand existing patterns, and propose an approach for your review before making changes.

### Avoiding "Context Rot" in Large Tasks

AI coding tools have finite context windows. For tasks spanning multiple sessions or involving many files, context can degrade. Use these strategies to maintain coherence:

#### Create a Specifications Document

Before starting a large task, write a detailed spec:

````markdown
# Feature: CSV Import with Schema Validation

## Requirements
- Parse CSV files into lists of Associations
- Support custom column type specifications
- Validate data against provided schema
- Return Failure objects for invalid data

## API Design
```wl
CSVImport[file, schema] (* returns {<|...|>, ...} or Failure *)
```

## Schema Format
```wl
<|"Name" -> "String", "Age" -> "Integer", "Score" -> "Real"|>
```

## Edge Cases
- Empty files return {}
- Missing columns return Failure["MissingColumn", ...]
- Type mismatches return Failure["TypeError", ...]
````

Reference this file when starting work:

> "Read the spec in docs/csv-import-spec.md and implement the CSVImport function."

#### Write Progress Reports

At the end of each session, ask the AI to write a progress report:

> "Write a progress report summarizing what we accomplished, what's left to do, and any decisions made. Save it to docs/progress/csv-import.md."

This produces a file like:

````markdown
# Progress: CSV Import

## Completed
- Implemented CSVImport with basic parsing
- Added schema validation for String, Integer, Real types
- Wrote 12 tests, all passing

## Remaining
- Add support for DateObject columns
- Handle quoted strings with commas
- Add Options for delimiter and header row

## Decisions
- Using ReadList for parsing (faster than Import for large files)
- Schema is required, no auto-detection
````

#### Resume with Context

At the start of the next session, load both documents:

> "Read docs/csv-import-spec.md and docs/progress/csv-import.md, then continue implementing the CSV import feature."

This gives the AI the full specification and current state without relying on conversation history.

## Security Considerations

The **WolframLanguageEvaluator** and **TestReport** tools execute arbitrary Wolfram Language code. This means they can perform any action that a Wolfram kernel can perform, including:

- Reading, writing, and deleting files
- Making network requests
- Running system commands
- Accessing environment variables

Most AI coding applications support **approval-based permissions** that prompt you before the AI executes potentially dangerous tools. You should configure your application to require approval for these tools:

| Tool | Risk | Recommendation |
|------|------|----------------|
| `WolframLanguageEvaluator` | Executes arbitrary code | Require approval |
| `TestReport` | Runs test files (which execute code) | Require approval |
| `WriteNotebook` | Writes notebook files | Require approval |
| `CodeInspector` | Read-only, but reads file contents | Auto-approve or require approval* |
| `ReadNotebook` | Read-only, but reads file contents | Auto-approve or require approval* |
| `WolframLanguageContext` | Read-only documentation search | Auto-approve is safe |
| `SymbolDefinition` | Read-only symbol lookup | Auto-approve is safe |

*`CodeInspector` and `ReadNotebook` read file contents that are sent to your LLM provider. If your project contains sensitive information you wouldn't want included in LLM context, consider requiring approval for these tools as well. Note that these tools are designed for Wolfram Language files and notebooks respectively, so they will likely fail on other file types.

### Prompt Injection Considerations

If your AI coding application has access to tools that fetch content from the web or other untrusted sources, be aware of prompt injection risks. Malicious content could instruct the AI to use other tools in unintended ways.

For example, `SymbolDefinition` is generally safe, but if the AI previously used `WolframLanguageEvaluator` to connect to a service (storing API keys in memory), a prompt injection attack could potentially instruct the AI to use `SymbolDefinition` to extract those values.

As a general rule: if you auto-approve any tools that read untrusted external content, consider requiring approval for all other tools that could expose sensitive information.

Consult your AI coding application's documentation for how to configure tool permissions.

## Troubleshooting

### Server not connecting

- Fully restart your coding application after installation (closing the window often just minimizes it to the system tray)
- Manually inspect the configuration file returned by `InstallMCPServer` to ensure the server is configured correctly
- Check your client's documentation for location of log files or other diagnostic information to check for errors

### WolframLanguageContext not working as expected

The `WolframLanguageContext` tool requires an [LLM Kit subscription](https://www.wolfram.com/notebook-assistant-llm-kit/) for best results. Without it, documentation search will be less accurate. Code execution (`WolframLanguageEvaluator`) and other tools work without LLM Kit.

### Server is using the wrong version of Wolfram Language

The installed MCP server will use the same version of Wolfram Language as the session it was installed from. If you want to use a different version of Wolfram Language, you need to install the MCP server in a session of that version or manually edit the configuration file to point to a different Wolfram kernel.
