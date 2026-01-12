# AGENTS.md

This file provides guidance to AI agents (Claude Code, GitHub Copilot, etc.) when working with code in this repository.

## Overview

MCPServer is a Wolfram Language package that implements a Model Context Protocol (MCP) server. This enables Wolfram Language to function as a backend for large language models (LLMs) by providing a standardized interface for models to access Wolfram Language computation capabilities.

## Development

Always use the WolframLanguageContext tool when working with Wolfram Language code to ensure that you are aware of the latest documentation and other Wolfram resources.

In order to test changes to paclet code, you must first evaluate the following as a separate call to the WolframLanguageEvaluator tool:
```wl
PacletDirectoryLoad["path/to/MCPServer"];
Get["Wolfram`MCPServer`"]
```

Now you can make additional tool calls to run paclet code.

If you've previously built an MX file for the paclet, you should delete it before testing your changes. You can find it in `Kernel/64Bit/MCPServer.mx`.

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

You can run test files individually using:

```wl
report = TestReport["path/to/test/file.wlt"];
report["TestsFailed"]
```

Use the WolframLanguageContext tool if tests fail to help find a solution.

### Building the Paclet

```bash
wolframscript -f Scripts/BuildPaclet.wls
```

This script builds the paclet and performs necessary checks. Options:
- `-c` or `--check`: Run code checks (default: True)
- `-i` or `--install`: Install the paclet after building (default: False)
- `-m` or `--mx`: Build MX files (default: True)

### Testing the Paclet

```bash
wolframscript -f Scripts/TestPaclet.wls
```

This runs the paclet tests and generates a test report. An exit code of 0 means all tests passed.

If you've made any changes to source code, be sure to rebuild the paclet before testing.

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

- `Scripts/`: Contains utility scripts for building, testing, and running the paclet
  - `Common.wl`: Common utilities for scripts
  - `BuildPaclet.wls`: Script to build the paclet
  - `TestPaclet.wls`: Script to test the paclet
  - `StartMCPServer.wls`: Script to start an MCP server (should only be called by an MCP client)

- `Documentation/`: Contains documentation notebooks
  - `English/`: English documentation
    - `ReferencePages/Symbols/`: Reference pages for exported symbols
    - Use the ReadNotebook tool to read documentation notebooks as markdown text

- `Tests/`: Contains test files
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

1. **Symbol Definition Pattern**:
    ```wolfram
    functionName // beginDefinition;
    functionName[ args___ ] := ...
    functionName // endDefinition;
    ```

    ```wolfram
    ExportedFunctionName // beginDefinition;
    ExportedFunctionName[ args___ ] := ...
    ExportedFunctionName // endExportedDefinition;
    ```

2. **Error Handling Pattern**:
    ```wolfram
    Enclose[
        Module[ { ... },
            result = ConfirmBy[ operation, check, "Tag" ];
            ...
        ],
        throwInternalFailure
    ];
    ```

3. **MX Initialization**:
    ```wolfram
    addToMXInitialization[
        code to initialize during MX load
    ];
    ```