---
name: wolfram-language
description: Evaluates Wolfram Language code, searches documentation, inspects code, runs tests, and retrieves symbol definitions. Use this skill when the user needs Wolfram Language computation or development assistance, including symbolic math, data analysis, visualization, or working with .wl/.wls/.wlt files.
compatibility: Requires the Wolfram MCP server or wolframscript on PATH
metadata:
  author: Wolfram Research
  version: 1.7.21
---

# Wolfram Language

A full Wolfram Language development environment with code evaluation,
documentation search, symbol inspection, static analysis, and test execution.

## Prerequisites

These scripts require `wolframscript`. If it is not installed or not on
your PATH, read `references/GetWolframEngine.md` (relative to this
skill directory) for installation instructions.

## Usage

### With MCP Server (preferred)

If you have Wolfram Language MCP tools available in your tool list (e.g.,
`mcp__WolframLanguage__WolframLanguageEvaluator`), use those directly. They
provide richer integration, stateful evaluation, and better performance than
the bundled scripts.

For a richer experience, consider setting up the Wolfram MCP server.
See `references/SetUpWolframMCPServer.md` (relative to this skill
directory) for instructions.

### With Bundled Scripts

If no MCP tools are available, use the bundled scripts in the `scripts/`
directory (relative to this skill directory). Run them with:

```
wolframscript -f scripts/<ScriptName>.wls <arguments>
```

Pass `--usage` to any script to see its argument documentation:

```
wolframscript -f scripts/<ScriptName>.wls --usage
```

## Available Tools

| Script | When to use |
| --- | --- |
| `WolframLanguageContext.wls` | Search documentation before writing Wolfram Language code to find relevant functions, options, and usage patterns |
| `WolframLanguageEvaluator.wls` | Evaluate Wolfram Language code and return results to the user |
| `SymbolDefinition.wls` | Inspect how symbols are defined (use instead of `Definition` or `DownValues`) |
| `TestReport.wls` | Run `.wlt` test files and directories to verify correctness |
| `CodeInspector.wls` | Check Wolfram Language code or files for issues and style problems |

For detailed usage, arguments, and invocation syntax for each script, see
`references/Scripts.md` (relative to this skill directory).

## Tips

- Always search documentation with `WolframLanguageContext.wls` before writing
  Wolfram Language code to find the right functions and patterns.
- The user does not automatically see evaluation results from
  `WolframLanguageEvaluator.wls` — always include the output in your response.
- Use `\[FreeformPrompt]["query"]` (Unicode character U+F351) to parse natural
  language into Wolfram Language expressions like `Quantity`, `DateObject`, and
  `Entity`.
- Use `SymbolDefinition.wls` instead of evaluating `Definition` or `DownValues`
  to inspect symbol definitions.
- Provide either `--code` or `--file` (or both) to `CodeInspector.wls`.
