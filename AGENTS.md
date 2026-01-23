# AGENTS.md

This file provides guidance to AI agents (Claude Code, GitHub Copilot, etc.) when working with code in this repository.

## Overview

MCPServer is a Wolfram Language package that implements a Model Context Protocol (MCP) server. This enables Wolfram Language to function as a backend for large language models (LLMs) by providing a standardized interface for models to access Wolfram Language computation capabilities.

> **Human developers:** For a quick-start guide, see [docs/getting-started.md](docs/getting-started.md).

## Development

Always use the WolframLanguageContext tool when working with Wolfram Language code to ensure that you are aware of the latest documentation and other Wolfram resources.

In order to test changes to paclet code, you must first evaluate the following as a separate call to the WolframLanguageEvaluator tool:
```wl
PacletDirectoryLoad["path/to/MCPServer"];
Get["Wolfram`MCPServer`"]
```

Now you can make additional tool calls to run paclet code.

If you've previously built an MX file for the paclet, you should delete it before testing your changes. You can find it in `Kernel/64Bit/MCPServer.mx`.

If you are only testing changes to test files, you do not need to reload the paclet, since the TestReport tool handles this for you.

When reloading the paclet, do not `Clear`, `ClearAll`, or `Remove` symbols. Reloading the paclet does this automatically in `Kernel/MCPServerLoader.wl` and doing so manually may lead to unexpected behavior.

The kernel used by the WolframLanguageEvaluator tool cannot be restarted via code like `Quit[]` since it's also running the MCP server. If it gets into a bad state, and you can't fix it, you should stop and inform the user that the kernel needs to be restarted.

## Writing Tests

Write tests in the following format:
```wl
VerificationTest[
    input,
    expected,
    SameTest -> MatchQ,
    TestID   -> "AnAppropriateTestID"
]
```

You can optionally include a third argument to specify any expected messages that occur during the evaluation of the input, for example:

```wl
{ MCPServer::Tag, ... }
```

Existing test IDs will also have a suffix appended to them (everything after the last `@@`) to indicate where the test is located in the codebase. You do not need to include this suffix in your new test IDs, since they are automatically generated on commit.

### Unit Tests

You can write unit tests for private symbols, but you should suppress linting errors for private symbols by wrapping the file in:
```
(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)
...
(* :!CodeAnalysis::EndBlock:: *)
```

### Running Tests

You can run test files using the TestReport MCP tool on the "Tests" directory.

Use the WolframLanguageContext tool if tests fail to help find a solution.

## Building the Paclet

```bash
wolframscript -f Scripts/BuildPaclet.wls
```

This script builds the paclet and performs necessary checks. Options:
- `-c` or `--check`: Run code checks (default: True)
- `-i` or `--install`: Install the paclet after building (default: False)
- `-m` or `--mx`: Build MX files (default: True)

## Code Architecture

### Project Structure

- `Kernel/`: Contains the core implementation files
  - `MCPServer.wl`: Main entry point which loads an MX file if available, otherwise proceeds to `Main.wl`
  - `Main.wl`: Entry point for loading other package files; exported symbols must be declared here
  - `Common.wl`: Common utilities and error handling
  - `CommonSymbols.wl`: Any symbols shared between paclet files must be declared here
  - `CreateMCPServer.wl`: Implementation for creating MCP servers
  - `DefaultServers.wl`: Defines several predefined named MCP servers
  - `Files.wl`: Helper functions for file operations
  - `Formatting.wl`: Definitions for formatting in notebooks
  - `InstallMCPServer.wl`: Implementation for installing MCP servers for use in some common MCP client applications
  - `MCPServerObject.wl`: Defines the MCP server object format
  - `Messages.wl`: Definitions for error messages
  - `StartMCPServer.wl`: Implementation for starting MCP servers
  - `Tools/`: Contains several files defining predefined MCP tools used by default servers

- `Scripts/`: Contains utility scripts for building, testing, and running the paclet
  - `Common.wl`: Common utilities for scripts
  - `BuildMX.wls`: Script to build the MX file
  - `BuildPaclet.wls`: Script to build the paclet

- `Documentation/`: Contains documentation notebooks
  - `English/`: English documentation
    - `ReferencePages/Symbols/`: Reference pages for exported symbols
    - Use the ReadNotebook tool to read documentation notebooks as markdown text

- `Tests/`: Contains test files (.wlt)
  - Every test should have a `TestID` specification
  - Do not manually write the trailing `@@path/to/file.wlt:l,c` part of the `TestID` specification; it will be added automatically on commit

### Key Components

1. **MCPServerObject**: The main data structure representing an MCP server.

2. **CreateMCPServer**: Function to create a new server with the specified name and LLM evaluator.

3. **StartMCPServer**: Function that starts a server and processes client requests.

4. **Common Error Handling Framework**: The package uses a sophisticated error handling system with functions like `catchMine`, `throwFailure`, and `throwInternalFailure`.

### Protocol Implementation

The server implements the Model Context Protocol, which provides:

1. **Tool Listing**: Endpoints to list available tools
2. **Tool Execution**: Ability to execute tools from the LLM
3. **Prompt Management**: Support for managing prompts

## Code Style Guidelines

- Use `beginDefinition` and `endDefinition` wrappers for function definitions
- Follow error handling patterns using `Enclose`, `Confirm`, and `ConfirmBy`
- Use `catchMine` around the body of exported functions
- Use `throwFailure["tag", args...]` to issue a message and return a `Failure[...]` to top level
- Any tag used in `throwFailure` must be defined in `Messages.wl`

## Key Development Patterns

### Error Handling

Error handling is managed using the following helpers:
- `catchTop` - Catches anything thrown by `throwFailure` or `throwInternalFailure`. Only the outermost `catchTop` is used.
- `throwFailure` - Throws a handled handled error with a message ID and arguments.
- `throwInternalFailure` - Throws an unhandled internal failure error.

The functions `catchMine` and `catchTopAs` are variations of `catchTop` that specify the symbol that should be used for error messages. These should only be used for public functions.

Define any error messages using the `MCPServer` symbol in `Kernel/Messages.wl`. For example:
```wl
MCPServer::InvalidProperty = "Invalid property specification: `1`.";
```

Then, you can use something like the following to throw an error to the top level:
```wl
throwFailure[ "InvalidProperty", badValue ]
```

The message will automatically be issued from the symbol that's using the outermost `catchMine` or `catchTopAs` block.

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

The `Enclose` wrapper is only necessary if you are using any `Confirm`, `ConfirmBy`, `ConfirmMatch`, etc. functions in the body, and it will trigger a throw of an internal failure error if any of them fail.

### Other Development Guidelines

- Avoid using `Return` since the return point can sometimes be ambiguous. Instead, use `Catch` and `Throw` to control the flow of execution.
- Whenever you modify source code, you should also write and run tests for the changes you made.

## Special Considerations

While working on this paclet, you are also working on the code that's running the MCP server providing your Wolfram tools. Sometimes you might run into issues related to this and you'll need to carefully consider how current changes might be affecting the MCP server.