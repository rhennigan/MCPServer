# Writing and Running Tests

This guide covers how to write and run tests for MCPServer.

## Test File Format

Tests use `VerificationTest` with the following format:

```wl
VerificationTest[
    input,
    expected,
    SameTest -> MatchQ,
    TestID   -> "AnAppropriateTestID"
]
```

You can optionally include expected messages (see [Error Handling](error-handling.md) for how messages are defined and thrown):

```wl
VerificationTest[
    input,
    expected,
    { MCPServer::Tag, ... },
    SameTest -> MatchQ,
    TestID   -> "AnAppropriateTestID"
]
```

### Creating New Test Files

Always start new test files with the following boilerplate:

```wl
(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Initialization*)
VerificationTest[
    Needs[ "Wolfram`MCPServerTests`", FileNameJoin @ { DirectoryName @ $TestFileName, "Common.wl" } ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "GetDefinitions"
]

VerificationTest[
    Needs[ "Wolfram`MCPServer`" ],
    Null,
    SameTest -> MatchQ,
    TestID   -> "LoadContext"
]

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Name of First Section*)
```

The first test defines some helper functions and ensures that the paclet is loaded from the correct directory. The second test puts the main context into scope.

## TestID Conventions

- Every test should have a `TestID` specification
- If the test corresponds to a GitHub issue, you should include the issue number in the test ID, e.g. `"AnAppropriateTestID-GH#123"`
- Do not manually write the trailing `@@path/to/file.wlt:l,c` suffix
- This location suffix is automatically generated on commit by `Scripts/FormatFiles.wls`

To enable automatic TestID annotation, configure the git hook:

```bash
git config --local core.hooksPath Scripts/.githooks
```

## Running Tests with the TestReport MCP Tool

If you're using an AI coding agent with the WolframPacletDevelopment MCP server, you can run tests using the `TestReport` tool on the `Tests/` directory.

## Running Tests with `wolframscript`

> Note: Only use `wolframscript` for running tests if the TestReport MCP tool is not available.

Run all tests:

```bash
wolframscript -f Scripts/TestPaclet.wls
```

Run a specific test file:

```bash
wolframscript -f Scripts/TestPaclet.wls Tests/CreateMCPServer.wlt
```

Run multiple test files:

```bash
wolframscript -f Scripts/TestPaclet.wls Tests/CreateMCPServer.wlt Tests/StartMCPServer.wlt
```

**Path resolution**: The script accepts both absolute paths and paths relative to the paclet root directory. For example, `Tests/Foo.wlt` is equivalent to the full path `H:\Documents\MCPServer\Tests\Foo.wlt`.

## Unit Tests for Private Symbols

You can write unit tests for private symbols. Suppress linting errors by wrapping the test file content:

```wl
(* :!CodeAnalysis::BeginBlock:: *)
(* :!CodeAnalysis::Disable::PrivateContextSymbol:: *)

(* Your tests here *)

(* :!CodeAnalysis::EndBlock:: *)
```

## Troubleshooting

If tests fail, consider:

1. **Check for MX file conflicts**: If you've modified source files but an MX file exists, delete `Kernel/64Bit/MCPServer.mx` and reload the paclet
2. **Reload the paclet**: Changes to source files require reloading with ``PacletDirectoryLoad["path/to/MCPServer"]; Get["Wolfram`MCPServer`"]``
3. **Review test output**: The test report will show which tests failed and why

## See Also

- [Getting Started](getting-started.md) - Development environment setup
- [Building](building.md) - Building the paclet
- [Error Handling](error-handling.md) - Error handling architecture and patterns
- [AGENTS.md](../AGENTS.md) - Detailed development guidelines
