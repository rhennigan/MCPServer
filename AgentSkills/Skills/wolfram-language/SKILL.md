---
name: wolfram-language
description: >
  Evaluates Wolfram Language code, searches documentation, inspects code,
  runs tests, and retrieves symbol definitions. Use this skill when the user
  needs Wolfram Language computation or development assistance, including
  symbolic math, data analysis, visualization, or working with .wl/.wls/.wlt
  files.
compatibility: Requires the Wolfram MCP server or wolframscript on PATH
metadata:
  author: Wolfram Research
  version: "1.7.21"
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

## Tool Reference

### WolframLanguageContext.wls

Search Wolfram Language documentation using semantic search. Use this before
writing Wolfram Language code to find relevant functions, options, and usage
patterns. Write the query in natural language with as much detail as possible.

**Usage:**

```
wolframscript -f scripts/WolframLanguageContext.wls <context>
```

**Arguments:**

| Argument | Required | Description |
| --- | --- | --- |
| `context` | Yes | A detailed natural language summary of what the user is trying to achieve or learn about |

**Example:**

```
wolframscript -f scripts/WolframLanguageContext.wls "how to solve a system of differential equations with initial conditions"
```

---

### WolframLanguageEvaluator.wls

Evaluate Wolfram Language code and return the result. The user does not
automatically see the result, so you must include it in your response.

Use `\[FreeformPrompt]["query"]` (written as the Unicode character U+F351) to
parse natural language into Wolfram Language expressions. This is useful for
obtaining `Quantity`, `DateObject`, `Entity`, and similar expressions.

**Usage:**

```
wolframscript -f scripts/WolframLanguageEvaluator.wls <code> [--timeConstraint N]
```

**Arguments:**

| Argument | Required | Description |
| --- | --- | --- |
| `code` | Yes | Wolfram Language code to evaluate |
| `--timeConstraint` | No | Time limit in seconds for the evaluation |

**Examples:**

```
wolframscript -f scripts/WolframLanguageEvaluator.wls "Solve[x^2 - 4 == 0, x]"
```

```
wolframscript -f scripts/WolframLanguageEvaluator.wls "Plot[Sin[x], {x, 0, 2 Pi}]" --timeConstraint 30
```

---

### SymbolDefinition.wls

Retrieve readable definitions of Wolfram Language symbols. Returns formatted
definition strings with context path management to minimize fully qualified
names. Use this to inspect how symbols are defined.

**Usage:**

```
wolframscript -f scripts/SymbolDefinition.wls <symbols> [--includeContextDetails value] [--maxLength N]
```

**Arguments:**

| Argument | Required | Description |
| --- | --- | --- |
| `symbols` | Yes | Symbol name or comma-separated list of names. Use fully qualified names if the context is known (e.g., `System`Plus`) |
| `--includeContextDetails` | No | Whether to include a JSON map of symbol-to-context mappings (default: false) |
| `--maxLength` | No | Maximum character length for output before truncation (default: 10000) |

**Examples:**

```
wolframscript -f scripts/SymbolDefinition.wls "Plus"
```

```
wolframscript -f scripts/SymbolDefinition.wls "Map,Apply" --includeContextDetails true
```

---

### TestReport.wls

Run Wolfram Language test files (`.wlt`) and return a formatted report of the
results. Supports individual test files and directories of test files.

**Usage:**

```
wolframscript -f scripts/TestReport.wls <paths> [--timeConstraint N] [--memoryConstraint N] [--newKernel value]
```

**Arguments:**

| Argument | Required | Description |
| --- | --- | --- |
| `paths` | Yes | Comma-separated list of paths to `.wlt` test files or directories |
| `--timeConstraint` | No | Time limit in seconds for each test file |
| `--memoryConstraint` | No | Memory limit in bytes for each test file |
| `--newKernel` | No | Whether to use a fresh kernel for running tests (default: true) |

**Example:**

```
wolframscript -f scripts/TestReport.wls "Tests/MyTests.wlt" --timeConstraint 60
```

---

### CodeInspector.wls

Inspect Wolfram Language code for issues and return a formatted report.
Supports inspecting code strings, individual files, or entire directories
of `.wl`, `.m`, and `.wls` files.

**Usage:**

```
wolframscript -f scripts/CodeInspector.wls [--code "..."] [--file "..."] [--severityExclusions "..."] [--confidenceLevel N] [--limit N] [--tagExclusions "..."]
```

**Arguments:**

| Argument | Required | Description |
| --- | --- | --- |
| `--code` | No | Wolfram Language code string to inspect |
| `--file` | No | File or directory path to inspect (directories are searched recursively) |
| `--severityExclusions` | No | Comma-separated severities to exclude (default: "Formatting,Remark,Scoping"). Available: Fatal, Error, Warning, Scoping, Remark, Formatting |
| `--confidenceLevel` | No | Minimum confidence level 0.0 to 1.0 (default: 0.75) |
| `--limit` | No | Maximum number of issues to display (default: 100) |
| `--tagExclusions` | No | Comma-separated tags to exclude (e.g., "UnusedVariable,SuspiciousSessionSymbol") |

Provide either `--code` or `--file` (or both).

**Examples:**

```
wolframscript -f scripts/CodeInspector.wls --code "x=1;x+1"
```

```
wolframscript -f scripts/CodeInspector.wls --file "src/MyPackage.wl" --severityExclusions "Formatting,Remark"
```
