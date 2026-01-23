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

You can optionally include expected messages:

```wl
VerificationTest[
    input,
    expected,
    { MCPServer::Tag, ... },
    SameTest -> MatchQ,
    TestID   -> "AnAppropriateTestID"
]
```

## TestID Conventions

- Every test should have a `TestID` specification
- Do not manually write the trailing `@@path/to/file.wlt:l,c` suffix
- This location suffix is automatically generated on commit by `Scripts/FormatFiles.wls`

To enable automatic TestID annotation, configure the git hook:

```bash
git config --local core.hooksPath Scripts/.githooks
```

## Running Tests with wolframscript

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

## Using the TestReport MCP Tool

If you're using an AI coding agent with the WolframPacletDevelopment MCP server, you can run tests using the `TestReport` tool on the `Tests/` directory.

## Troubleshooting

If tests fail, consider:

1. **Check for MX file conflicts**: If you've modified source files but an MX file exists, delete `Kernel/64Bit/MCPServer.mx` and reload the paclet
2. **Reload the paclet**: Changes to source files require reloading with ``Get["Wolfram`MCPServer`"]``
3. **Review test output**: The test report will show which tests failed and why

## See Also

- [Getting Started](getting-started.md) - Development environment setup
- [Building](building.md) - Building the paclet
- [AGENTS.md](../AGENTS.md) - Detailed development guidelines
