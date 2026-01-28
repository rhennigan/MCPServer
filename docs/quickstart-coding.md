# Quick Start for AI Coding Applications

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

**Example:** To see a real-world `AGENTS.md` file, view the one used during development of this paclet:
```wl
Import[PacletObject["Wolfram/MCPServer"]["AssetLocation", "AGENTS.md"], "Text"]
```

### Keeping AGENTS.md Up to Date

Your `AGENTS.md` is a living document that should evolve with your project. Update it when you:
- Add new files, directories, or architectural components
- Establish new coding patterns or conventions
- Discover edge cases or gotchas the AI should know about
- Change testing strategies or workflows

A few minutes spent updating `AGENTS.md` after significant changes saves time in future sessions by preventing the AI from making outdated assumptions.

> **Tip:** AI coding assistants can help you write and update your `AGENTS.md` file—just ask! However, always review AI-suggested changes carefully to ensure they accurately reflect your project's conventions and requirements.

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

AI coding tools have finite context windows. For implementing large or complex features, context accumulation can degrade performance. Many applications have features to mitigate this, such as context compression, subagents, or task management features. However, these strategies also often involve using AI to make decisions about what information in the context is important. Mistakes in these decisions continuously compound, leading to worse and worse performance over time. For best results, you may want to consider taking a more manual approach to context management. Here we'll cover one such approach.

Here's the basic strategy:

- Create a detailed specifications document for the feature you're implementing
- Break down the specification into a list of tasks that need to be completed to implement the feature
- Maintain a running log that summarizes the progress of the feature implementation
- Iteratively use these three items as initial context asking the AI to take on *one* task at a time

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
CSVImportValidated[file, schema] (* returns {<|...|>, ...} or Failure *)
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

AI assistants can help you draft this spec—ask them to propose an API design or identify edge cases you might have missed. However, iterate on the document until every detail is correct. This spec becomes the source of truth for all implementation work that follows, so inaccuracies here will propagate into the code. Time spent getting the spec right pays dividends during implementation.

#### Generate a Task List

In a new session, ask the AI to generate a task list in another file based on the spec. For example:

> "Analyze @Specs/CSVImportValidated.md and determine how to break it down into tasks. Create a file called TODO/CSVImportValidated.md with a list of these tasks with checkboxes for completion."

The goal is to have a file that looks something like this:

````markdown
# TODO: CSVImportValidated

- [ ] Implement CSVImportValidated with basic parsing
- [ ] Add schema validation for String, Integer, Real types
- [ ] Write 12 tests, all passing
- [ ] Add support for DateObject columns
- [ ] Handle quoted strings with commas
- [ ] Add Options for delimiter and header row
- [ ] Verify all tests pass
- [ ] Update documentation
- [ ] Perform final review
````

#### Write Progress Reports

At the end of each session, ask the AI to append a progress report to a running log. For example:

> Append a progress report to Progress/CSVImportValidated.md as a new '## Session N' section, concisely summarizing what we accomplished along with anything you've learned that might be useful for others resuming this task.

As you iterate, the file will be filled out with information about the current state of the feature implementation. This is important to minimize the amount of work the AI needs to do to resume the task from where it left off.
For example, after the first session, the file might look like this:

````markdown
# Progress: CSVImportValidated

## Session 1

Task: Implement CSVImportValidated with basic parsing
Status: Completed

Work completed:

- Created Kernel/CSVImportValidated.wl with basic parsing implementation
- CSVImportValidated currently returns a list of associations with no validation yet
...

Things learned:

- `FileFormatQ["path/to/file.csv", "CSV"]` can check if a file is a valid CSV file without fully importing it
...

````

#### Iteratively Implement Tasks

Now you can use the same prompt to iterate over the tasks in the task list. For example, interactively perform one iteration of the task list using Claude Code:

```shell
claude "## Task List

@TODO/CSVImportValidated.md

## Full Specification

@Specs/CSVImportValidated.md

## Progress

@Progress/CSVImportValidated.md

## Your Current Task

- Choose the next task from the task list that is not yet complete
- Carefully study the specification to understand the requirements for the current task
- Implement the task
- Append a progress report to Progress/CSVImportValidated.md as a new '## Session N' section, concisely summarizing what we accomplished along with anything you've learned that might be useful for others resuming this task
- If the task is complete, update the task list in TODO/CSVImportValidated.md to mark it as complete and commit your changes with an appropriate commit message
- Wait for user input to continue

IMPORTANT: Only complete *one* task at a time. Do not attempt to complete multiple tasks at once."
```

**Note:** In Claude Code, the `@path/to/file` syntax is a way to insert the contents of the file at the specified location in the prompt. Other AI coding applications typically use a similar syntax. If they don't have this feature, you can always just ask the AI to read the files as part of the prompt.

After the AI completes the task, rather than continuing the same conversation and accumulating context, you start a new session using the same prompt to resume work on the next task.

For best results, you should be monitoring changes to the progress report as well as any source files that are modified. When necessary, you should step in and manually edit the progress file to ensure that it contains good context for the next session.

This approach ensures that the AI is only working with high-quality context that is relevant to the current task whenever it resumes.

You can even automate this as a loop if you write some code that checks if the task list is complete and stops the loop when it is.

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
