# AGENTS.md

This file provides guidance to AI agents (Claude Code, GitHub Copilot, etc.) when working with code in this repository.

## Overview

MCPServer is a Wolfram Language package that implements a Model Context Protocol (MCP) server. This enables Wolfram Language to function as a backend for large language models (LLMs) by providing a standardized interface for models to access Wolfram Language computation capabilities.

## Development

Always use the WolframLanguageContext tool when working with Wolfram Language code to ensure that you are aware of the latest documentation and other Wolfram resources.

When you make changes to paclet source code, you should also write and run tests for the changes you made using the TestReport tool and check the updated files with the CodeInspector tool.

If you need to debug code in the WolframLanguageEvaluator tool, you'll first need to evaluate:
```wl
PacletDirectoryLoad[ "path/to/MCPServer" ];
Get[ "Wolfram`MCPServer`" ]
```

Note: This is not necessary for the TestReport tool, since the tests load the paclet automatically.

You should use the SymbolDefinition tool to investigate symbols rather than use things like `DownValues`, `Definition`, etc. It runs in the same kernel as the WolframLanguageEvaluator tool, so it will have access to the same definitions.

## Writing and Running Tests

Use the TestReport MCP tool to run tests.

Always review [testing.md](docs/testing.md) for detailed instructions before modifying or adding tests.

## Building the Paclet

See [building.md](docs/building.md) for detailed instructions.

## Code Architecture

### Project Structure

- `Kernel/`: Contains the core implementation files
  - `MCPServer.wl`: Main entry point which loads an MX file if available, otherwise proceeds to `Main.wl`
  - `Main.wl`: Entry point for loading other package files; exported symbols must be declared here
  - `Common.wl`: Common utilities and [error handling](docs/error-handling.md)
  - `CommonSymbols.wl`: Any symbols shared between paclet files must be declared here
  - `CreateMCPServer.wl`: Implementation for creating MCP servers
  - `DefaultServers.wl`: Defines several predefined named MCP servers
  - `Files.wl`: Helper functions for file operations
  - `Formatting.wl`: Definitions for formatting in notebooks
  - `InstallMCPServer.wl`: Implementation for installing MCP servers for use in some common MCP client applications
  - `MCPServerObject.wl`: Defines the MCP server object format
  - `Messages.wl`: Definitions for error messages
  - `StartMCPServer.wl`: Implementation for starting MCP servers
  - `UIResources.wl`: [MCP Apps](docs/mcp-apps.md) UI resource registry and client capability detection
  - `Tools/`: Contains several files defining predefined MCP tools used by default servers
  - `Prompts/`: Contains files defining predefined [MCP prompts](docs/mcp-prompts.md) used by default servers

- `Assets/`: Static assets bundled with the paclet
  - `Apps/`: HTML and JSON files for [MCP Apps](docs/mcp-apps.md) UI resources

- `Scripts/`: Contains utility scripts for building, testing, and running the paclet

- `Documentation/`: Contains documentation notebooks
  - `English/`: English documentation
    - `ReferencePages/Symbols/`: Reference pages for exported symbols
    - Use the ReadNotebook tool to read documentation notebooks as markdown text

- `Tests/`: Contains test files (.wlt)

- `docs/`: Developer documentation
  - `testing.md`: Writing and running tests
  - `building.md`: Building the paclet for distribution
  - `error-handling.md`: Error handling architecture and patterns
  - `servers.md`: Predefined MCP servers and choosing the right one
  - `tools.md`: MCP tools system and how to add new tools
  - `mcp-prompts.md`: MCP prompts system and how to add new prompts
  - `mcp-clients.md`: MCP client support and installation
  - `mcp-apps.md`: MCP Apps system for interactive UI resources

### MCP Documentation

Use the official MCP documentation when working on the server implementation (`Kernel/StartMCPServer.wl`).

- [Overview](https://modelcontextprotocol.io/specification/2025-11-25/basic/index.md)
- [Lifecycle](https://modelcontextprotocol.io/specification/2025-11-25/basic/lifecycle.md)
- [Tools](https://modelcontextprotocol.io/specification/2025-11-25/server/tools.md)
- [Prompts](https://modelcontextprotocol.io/specification/2025-11-25/server/prompts.md)
- [List of all documentation pages](https://modelcontextprotocol.io/llms.txt)

## Key Development Patterns

### Error Handling

- Use `beginDefinition` and `endDefinition` wrappers for function definitions
- Follow error handling patterns using `Enclose`, `Confirm`, and `ConfirmBy`
- Use `catchMine` around the body of exported functions
- Use `throwFailure["tag", args...]` to issue a message and return a `Failure[...]` to top level
- Any tag used in `throwFailure` must be defined in `Messages.wl`

For comprehensive documentation on error handling, see [error-handling.md](docs/error-handling.md).

### Exported Functions

Exported functions in the main context must be declared in both the PacletInfo.wl and Kernel/Main.wl files. Define them using the following format:
```wl
NameOfFunction // beginDefinition;
NameOfFunction[ ... ] := catchMine @ internalFunction[ ... ];
NameOfFunction // endExportedDefinition;
```

The name of the internal function is often the same as the exported function, but beginning with a lowercase letter.

### Internal Functions

Define internal helper functions using the following format:

```wl
nameOfFunction // beginDefinition;

nameOfFunction[ ... ] := Enclose[
    body,
    throwInternalFailure
];

nameOfFunction // endDefinition;
```

The `Enclose` wrapper is only necessary if you are using any `Confirm`, `ConfirmBy`, `ConfirmMatch`, etc. functions in the body, and it will trigger a throw of an internal failure error if any of them fail. See [error-handling.md](docs/error-handling.md) for details on how these are optimized.

### Naming Conventions

- Use `UpperCamelCase` for exported function names.
- Use `lowerCamelCase` for internal function names.
- Use `$UpperCamelCase` for exported variables and constants.
- Use `$lowerCamelCase` for package or file-scoped variables and constants.
- Use `$$patternName` for reusable patterns to improve readability, e.g.
  ```wl
  $$strings = _String | { ___String };
  ```
  which can improve readability:
  ```wl
  toCommaSeparated[ names: $$strings ] := StringRiffle[ Flatten @ { names }, "," ];
  ```

### Other Development Guidelines

- Whenever you modify source code, you should also write and run tests for the changes you made.
- If you are using a package-scoped symbol defined in a different file, ensure that it is declared in a context that's reachable (e.g. `CommonSymbols.wl`).

## Special Considerations

While working on this paclet, you are also working on the code that's running the MCP server providing your Wolfram tools. Sometimes you might run into issues related to this and you'll need to carefully consider how current changes might be affecting the MCP server.