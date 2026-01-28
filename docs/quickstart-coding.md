# Quick Start: Wolfram MCP Server for AI Coding Tools

This guide walks you through setting up the Wolfram MCP Server with AI coding tools like Claude Code, Cursor, VS Code, and others. By the end, your AI coding assistant will be able to evaluate Wolfram Language code, search documentation, read and write notebooks, run tests, and inspect code.

## Recommended Server

For coding tools, use the **WolframLanguage** server. It gives the AI the ability to:

- **Search Wolfram resources** including documentation, function repository, data repository, and more
- **Execute code** to test implementations and verify behavior
- **Read and write notebooks** for working with `.nb` files as markdown
- **Look up symbol definitions** to understand existing code
- **Inspect code** for potential issues and style problems
- **Run tests** to validate changes against your test suite

## Installation

All installation methods use the `InstallMCPServer` function. Open a Wolfram Language session and run the appropriate command for your tool.

### Claude Code

**Global installation** (available in all projects):

```wl
InstallMCPServer["ClaudeCode", "WolframLanguage"]
```

**Project-level installation** (available only in a specific project):

```wl
InstallMCPServer[{"ClaudeCode", "/path/to/project"}, "WolframLanguage"]
```

Verify the installation from the command line:

```shell
claude mcp get WolframLanguage
```

The output should indicate that the server is connected.

### Cline

```wl
InstallMCPServer["Cline", "WolframLanguage"]
```

### Copilot CLI

```wl
InstallMCPServer["CopilotCLI", "WolframLanguage"]
```

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

### Google Antigravity

```wl
InstallMCPServer["Antigravity", "WolframLanguage"]
```

### OpenAI Codex

```wl
InstallMCPServer["Codex", "WolframLanguage"]
```

### OpenCode

**Global installation** (available in all projects):

```wl
InstallMCPServer["OpenCode", "WolframLanguage"]
```

**Project-level installation** (available only in a specific project):

```wl
InstallMCPServer[{"OpenCode", "/path/to/project"}, "WolframLanguage"]
```

### Visual Studio Code

**Global installation** (available in all projects):

```wl
InstallMCPServer["VisualStudioCode", "WolframLanguage"]
```

**Project-level installation** (available only in a specific project):

```wl
InstallMCPServer[{"VisualStudioCode", "/path/to/project"}, "WolframLanguage"]
```

This adds configuration to `.vscode/settings.json` in the project directory.

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

### Verifying the Installation

After installing, restart your coding tool and confirm the Wolfram tools are available. In most tools, you can ask:

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

## Troubleshooting

### Tools not appearing

- Fully restart your coding tool after installation (closing the window often just minimizes it to the system tray)
- Manually inspect the configuration file returned by `InstallMCPServer` to ensure the server is configured correctly
- Check your client's documentation for location of log files and check for errors

### Timeouts or slow responses

- The first tool call in a session starts a Wolfram kernel, which can be slow
- Subsequent calls reuse the kernel and are faster
- If timeouts persist, check that Wolfram Language starts correctly by running `wolframscript -code "Print[1+1]"` in your terminal

### WolframLanguageContext not working as expected

The `WolframLanguageContext` tool requires an [LLMKit subscription](https://www.wolfram.com/llmkit/) for best results. Without it, documentation search will be less accurate. Code execution (`WolframLanguageEvaluator`) and other tools work without LLMKit.

### Server is using the wrong version of Wolfram Language

The installed MCP server will use the same version of Wolfram Language as the session it was installed from. If you want to use a different version of Wolfram Language, you need to install the MCP server in a session of that version or manually edit the configuration file to point to a different Wolfram kernel.
