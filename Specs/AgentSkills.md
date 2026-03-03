# Agent Skills — Design Specification

## Overview

Agent skills package Wolfram MCP tools as distributable [Claude Code skills](https://code.claude.com/docs/en/skills) that work with or without a running MCP server. Each skill bundles standalone Wolfram Language scripts (`.wls`) generated from `$DefaultMCPTools`, along with a hand-authored `SKILL.md` that instructs Claude how to use them.

When the Wolfram MCP server is available, skills instruct Claude to prefer the MCP tools. When it is not, Claude falls back to executing the bundled scripts via `wolframscript`.

All skills are packaged as a single Claude Code plugin called **wolfram**.

---

## Goals

- Provide Wolfram Language, Wolfram|Alpha, and notebook capabilities to Claude Code users without requiring MCP server setup.
- Support dual-mode operation: prefer MCP tools when available, fall back to bundled scripts.
- Generate standalone `.wls` scripts automatically from existing `$DefaultMCPTools` definitions.
- Package skills as a single installable Claude Code plugin.

---

## Skills

Three skills are defined in `AgentSkills/Skills/Manifest.wl`:

### wolfram-language

Full Wolfram Language development environment.

| Script | Source Tool | Description |
|--------|-----------|-------------|
| `WolframLanguageContext.wls` | WolframLanguageContext | Semantic search for Wolfram Language documentation |
| `WolframLanguageEvaluator.wls` | WolframLanguageEvaluator | Evaluate Wolfram Language code |
| `SymbolDefinition.wls` | SymbolDefinition | Retrieve readable symbol definitions |
| `TestReport.wls` | TestReport | Run `.wlt` test files and return results |
| `CodeInspector.wls` | CodeInspector | Inspect code for issues |

### wolfram-alpha

Wolfram|Alpha queries and context retrieval.

| Script | Source Tool | Description |
|--------|-----------|-------------|
| `WolframAlphaContext.wls` | WolframAlphaContext | Semantic search using Wolfram|Alpha |
| `WolframAlpha.wls` | WolframAlpha | Query Wolfram|Alpha |

### wolfram-notebooks

Read and write Wolfram notebook (`.nb`) files.

| Script | Source Tool | Description |
|--------|-----------|-------------|
| `ReadNotebook.wls` | ReadNotebook | Read a notebook file as markdown |
| `WriteNotebook.wls` | WriteNotebook | Convert markdown to a notebook file |

---

## SKILL.md Format

Each skill has a hand-authored `SKILL.md` with YAML frontmatter and markdown instructions.

### Frontmatter

```yaml
---
name: wolfram-language
description: >
  Evaluates Wolfram Language code, searches documentation, inspects code,
  runs tests, and retrieves symbol definitions. Use when the user needs
  Wolfram Language computation or development assistance.
---
```

Required fields:
- `name` — Lowercase, hyphenated, max 64 characters.
- `description` — What the skill does and when to use it. Max 1024 characters.

Optional fields to consider:
- `allowed-tools` — Restrict to `Bash` (for script execution) and `Read` (for inspecting output files).

### Content Structure

Each SKILL.md should follow this general structure:

```markdown
# <Skill Title>

## Prerequisites

[wolframscript installation guidance]

## Usage

### With MCP Server (preferred)

If you have Wolfram Language MCP tools available (check your tool list for
tools like `mcp__WolframLanguage__*`), use them directly. They provide
richer integration and better performance.

### With Bundled Scripts

If no MCP tools are available, use the bundled scripts:

[Script usage documentation with examples]

## Tool Reference

[Per-script documentation: purpose, arguments, options, example invocations]
```

### Prerequisites Section

Every SKILL.md must include installation guidance for `wolframscript`:

```markdown
## Prerequisites

These scripts require [wolframscript](https://www.wolfram.com/wolframscript/)
to be installed and available on your PATH.

- **macOS**: `brew install --cask wolfram-engine` or download from wolfram.com
- **Linux**: Download from https://www.wolfram.com/engine/
- **Windows**: Download from https://www.wolfram.com/engine/
```

### Dual-Mode Detection

SKILL.md instructs Claude to check its available tool list:

```markdown
## Usage

If you have Wolfram MCP tools available in your tool list (e.g.,
`mcp__WolframLanguage__WolframLanguageEvaluator`), use those directly —
they provide better integration. The scripts below are for environments
where the MCP server is not configured.
```

Claude infers MCP availability from its tool list at runtime. No detection script is needed.

---

## Script Generation

### CLI Interface

Each generated `.wls` script accepts command-line arguments:

- **Required parameters** are positional arguments in declaration order.
- **Optional parameters** are passed as `--flagName value` pairs.
- All parameter values are strings (matching MCP tool behavior — the tool function handles parsing).

**Example — TestReport.wls:**

```
wolframscript -f TestReport.wls <paths> [--timeConstraint N] [--memoryConstraint N] [--newKernel true|false]
```

Where `paths` is the sole required parameter (positional) and the rest are optional flags.

**Example — CodeInspector.wls:**

```
wolframscript -f CodeInspector.wls [--code "..."] [--file "..."] [--severityExclusions "..."] [--confidenceLevel N] [--limit N]
```

When a tool has no required parameters (all optional), all arguments are flags.

### Script Template

Each generated script follows this structure:

```wl
#!/usr/bin/env wolframscript

(* Generated by BuildAgentSkills.wls — do not edit manually *)

PacletDirectoryLoad["<paclet-path>"];
Get["Wolfram`MCPServer`"];

Module[{tool, args, result},
    tool = $DefaultMCPTools["<ToolName>"];

    (* Parse CLI arguments into an Association matching the tool's parameter schema *)
    args = <argument-parsing-logic>;

    (* Invoke the tool function with parsed arguments *)
    result = tool[args];

    (* Output result to stdout *)
    WriteString["stdout", result];
]
```

**Key details:**

- The script loads the MCPServer paclet and delegates to the existing tool function.
- Argument parsing converts positional args and `--flag value` pairs into an `Association`.
- Output is written to stdout as markdown text (matching MCP tool output format).
- Errors are caught and printed to stderr with a non-zero exit code.

### Argument Parsing

The build system generates argument parsing code from the tool's parameter metadata:

```wl
(* For a tool with required param "paths" and optional "timeConstraint", "newKernel" *)
params = <|"Parameters" -> <|
    "paths" -> <|"Required" -> True|>,
    "timeConstraint" -> <|"Required" -> False|>,
    "newKernel" -> <|"Required" -> False|>
|>|>;
```

The generated parser:
1. Collects positional arguments (in declaration order) for required parameters.
2. Scans for `--flagName value` pairs for optional parameters.
3. Returns an `Association` suitable for passing to the tool function.
4. Prints usage information and exits with code 1 if required arguments are missing.

---

## Build System

`Scripts/BuildAgentSkills.wls` orchestrates skill generation:

### Inputs

- `AgentSkills/Skills/Manifest.wl` — Maps skill names to their tool lists.
- `$DefaultMCPTools` — Registry of all MCP tool definitions (loaded from the paclet).

### Process

1. **Load paclet** — `PacletDirectoryLoad` + ``Get["Wolfram`MCPServer`"]``.
2. **Read manifest** — Parse `Manifest.wl` into an Association.
3. **Generate scripts** — For each tool name referenced across all skills:
   - Look up the tool in `$DefaultMCPTools`.
   - Extract parameter metadata (name, required, interpreter type, help text).
   - Generate a `.wls` script with CLI argument parsing and tool invocation.
   - Write to a temporary build directory.
4. **Distribute scripts** — For each skill in the manifest:
   - Copy the relevant generated scripts into `AgentSkills/Skills/<skill-name>/scripts/`.
5. **Clean up** — Remove the temporary build directory.

### Outputs

Generated scripts are placed in each skill's `scripts/` directory. SKILL.md files are **not** generated — they are hand-authored.

### What the Build Script Does NOT Do

- Does not generate or modify SKILL.md files.
- Does not create plugin packaging (marketplace.json, etc.) — that is a separate step.
- Does not install or publish skills.

---

## Plugin Packaging

All skills are combined into a single Claude Code plugin named **wolfram**.

### Plugin Directory Structure

```
wolfram/
├── .claude-plugin/
│   └── marketplace.json
└── skills/
    ├── wolfram-language/
    │   ├── SKILL.md
    │   └── scripts/
    │       ├── WolframLanguageContext.wls
    │       ├── WolframLanguageEvaluator.wls
    │       ├── SymbolDefinition.wls
    │       ├── TestReport.wls
    │       └── CodeInspector.wls
    ├── wolfram-alpha/
    │   ├── SKILL.md
    │   └── scripts/
    │       ├── WolframAlphaContext.wls
    │       └── WolframAlpha.wls
    └── wolfram-notebooks/
        ├── SKILL.md
        └── scripts/
            ├── ReadNotebook.wls
            └── WriteNotebook.wls
```

### marketplace.json

```json
{
  "plugins": [
    {
      "name": "wolfram",
      "description": "Wolfram Language computation, Wolfram|Alpha queries, and notebook tools for Claude Code.",
      "version": "<paclet-version>",
      "components": {
        "skills": [
          "skills/wolfram-language",
          "skills/wolfram-alpha",
          "skills/wolfram-notebooks"
        ]
      }
    }
  ]
}
```

### Installation

Users install via:

```
/plugin install wolfram
```

Or by adding the plugin repository as a marketplace source.

---

## Source Directory Structure

Within the MCPServer repository:

```
AgentSkills/
├── Skills/
│   ├── Manifest.wl                    # Tool-to-skill mapping
│   ├── wolfram-language/
│   │   ├── SKILL.md                   # Hand-authored
│   │   └── scripts/                   # Generated by build
│   │       ├── WolframLanguageContext.wls
│   │       ├── WolframLanguageEvaluator.wls
│   │       ├── SymbolDefinition.wls
│   │       ├── TestReport.wls
│   │       └── CodeInspector.wls
│   ├── wolfram-alpha/
│   │   ├── SKILL.md                   # Hand-authored
│   │   └── scripts/                   # Generated by build
│   │       ├── WolframAlphaContext.wls
│   │       └── WolframAlpha.wls
│   └── wolfram-notebooks/
│       ├── SKILL.md                   # Hand-authored
│       └── scripts/                   # Generated by build
│           ├── ReadNotebook.wls
│           └── WriteNotebook.wls
└── Scripts/                           # Reserved for shared build utilities
```

`Scripts/BuildAgentSkills.wls` lives in the top-level `Scripts/` directory alongside other build scripts.

---

## Future Considerations

- **wolfram-paclet-development skill** — A fourth skill bundling CreateSymbolDoc, EditSymbolDoc, and EditSymbolDocExamples alongside the wolfram-language tools. Deferred to a later phase.
- **Marketplace submission** — Submit the wolfram plugin to the official Claude Code marketplace once skills are stable.
- **Versioning** — Plugin version should track `$pacletVersion` for consistency with the MCP server.
- **Standalone mode** — Scripts currently require the MCPServer paclet to be loadable. A future enhancement could generate fully self-contained scripts that embed the tool logic directly, removing the paclet dependency.
- **Additional plugins** — The single-plugin approach can be split into separate plugins later if needed for modularity.
