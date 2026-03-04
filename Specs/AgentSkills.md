# Agent Skills — Design Specification

## Overview

Agent skills package Wolfram MCP tools as distributable skills following the open [Agent Skills](https://agentskills.io/) standard. Each skill bundles standalone Wolfram Language scripts (`.wls`) generated from `$DefaultMCPTools`, along with a hand-authored `SKILL.md` that instructs compatible agents how to use them. Skills work with any agent that supports the standard (Claude Code, Cursor, Gemini CLI, VS Code, and [many others](https://agentskills.io/home)).

When the Wolfram MCP server is available, skills instruct the agent to prefer the MCP tools. When it is not, the agent falls back to executing the bundled scripts via `wolframscript`.

For distribution via Claude Code specifically, all skills are packaged as a single plugin called **wolfram**.

---

## Goals

- Provide Wolfram Language, Wolfram|Alpha, and notebook capabilities to any compatible agent without requiring MCP server setup.
- Follow the open [Agent Skills specification](https://agentskills.io/specification) for maximum portability across agent products.
- Support dual-mode operation: prefer MCP tools when available, fall back to bundled scripts.
- Generate standalone `.wls` scripts automatically from existing `$DefaultMCPTools` definitions.
- Package skills as a single installable Claude Code plugin (other distribution methods can be added later).

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

Each skill has a hand-authored `SKILL.md` with YAML frontmatter and markdown instructions, following the [Agent Skills specification](https://agentskills.io/specification).

### Frontmatter

```yaml
---
name: wolfram-language
description: >
  Evaluates Wolfram Language code, searches documentation, inspects code,
  runs tests, and retrieves symbol definitions. Use when the user needs
  Wolfram Language computation or development assistance.
compatibility: Requires the Wolfram MCP server or wolframscript on PATH
metadata:
  author: Wolfram Research
  version: "<paclet-version>"
---
```

Required fields (per the [spec](https://agentskills.io/specification)):
- `name` — Lowercase letters, numbers, and hyphens only. Max 64 characters. Must not start/end with a hyphen or contain consecutive hyphens. Must match the parent directory name.
- `description` — What the skill does and when to use it. Max 1024 characters.

Optional fields:
- `compatibility` — Environment requirements (max 500 characters). Used to indicate `wolframscript` dependency.
- `license` — License name or reference to a bundled license file.
- `metadata` — Arbitrary key-value pairs (e.g., author, version).
- `allowed-tools` — Space-delimited list of pre-approved tools (experimental; support varies by agent).

### Content Structure

Each SKILL.md should follow this general structure:

```markdown
# <Skill Title>

## Prerequisites

These scripts require `wolframscript`. If it is not installed or not on
your PATH, read `references/GetWolframEngine.md` (relative to this
skill directory) for installation instructions.

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

Rather than duplicating installation instructions in every SKILL.md, a single source file at `AgentSkills/References/GetWolframEngine.md` contains full installation guidance for `wolframscript`. The build system copies this file into each skill's `references/` subdirectory so that every skill is self-contained. Each SKILL.md includes a brief prerequisites section that directs the agent to read that file if `wolframscript` is not available:

```markdown
## Prerequisites

These scripts require `wolframscript`. If it is not installed or not on
your PATH, read `references/GetWolframEngine.md` (relative to this
skill directory) for installation instructions.
```

The source `references/GetWolframEngine.md` file is hand-authored and contains platform-specific installation instructions (macOS via Homebrew, Linux/Windows downloads, etc.).

### Dual-Mode Detection

SKILL.md instructs the agent to check its available tool list:

```markdown
## Usage

If you have Wolfram MCP tools available in your tool list (e.g.,
`mcp__Wolfram__WolframLanguageEvaluator`), use those directly —
they provide better integration. The scripts below are for environments
where the MCP server is not configured.
```

The agent infers MCP availability from its tool list at runtime. No detection script is needed.

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

Here is the rough structure for the generated scripts:

```wl
#!/usr/bin/env wolframscript

(* Generated by BuildAgentSkills.wls — do not edit manually *)

(* Parse CLI arguments into an Association matching the tool's parameter schema *)
args = <argument-parsing-logic>;

(* If `--help` argument is present: issue usage message and `Exit[0]` *)
(* If arguments invalid: issue usage message and `Exit[1]` *)

PacletInstall["Wolfram/MCPServer"];
Get["Wolfram`MCPServer`"];

tool = $DefaultMCPTools["<ToolName>"];

(* Invoke the tool function with parsed arguments *)
result = tool[args];

(* Output result to stdout *)
WriteString["stdout", result];

(* Exit with code 1 if the tool failed, 0 otherwise *)
If[ FailureQ @ result, Exit[ 1 ], Exit[ 0 ] ];
```

This is just a basic outline. The actual script should have more robust error handling and validation.

**Key details:**

- The script loads the MCPServer paclet and delegates to the existing tool function.
- Argument parsing converts positional args and `--flag value` pairs into an `Association`.
- Output is written to stdout as markdown text (matching MCP tool output format).
- For tools that also return image content, we should replace the images with a simple text placeholder.
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

See [generating-scripts-from-tools](../Notes/generating-scripts-from-tools.md) for example code to get started extracting script arguments from tools.

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
4. **Distribute to skills** — For each skill in the manifest:
   - Copy the relevant generated scripts into `AgentSkills/Skills/<skill-name>/scripts/`.
   - Copy `AgentSkills/References/GetWolframEngine.md` into `AgentSkills/Skills/<skill-name>/references/`.
5. **Clean up** — Remove the temporary build directory.

### Outputs

Generated scripts are placed in each skill's `scripts/` directory, and the shared `GetWolframEngine.md` reference is copied into each skill's `references/` directory. SKILL.md files are **not** generated — they are hand-authored.

### What the Build Script Does NOT Do

- Does not generate or modify SKILL.md files.
- Does not create plugin packaging (marketplace.json, etc.) — that is a separate step.
- Does not install or publish skills.

---

## Plugin Packaging (Claude Code)

The skills themselves follow the open Agent Skills standard and are portable. For distribution via **Claude Code** specifically, all skills are combined into a single plugin named **wolfram**.

### Plugin Directory Structure

```
wolfram/
├── .claude-plugin/
│   └── marketplace.json
└── skills/
    ├── wolfram-language/
    │   ├── SKILL.md
    │   ├── references/
    │   │   └── GetWolframEngine.md
    │   └── scripts/
    │       ├── WolframLanguageContext.wls
    │       ├── WolframLanguageEvaluator.wls
    │       ├── SymbolDefinition.wls
    │       ├── TestReport.wls
    │       └── CodeInspector.wls
    ├── wolfram-alpha/
    │   ├── SKILL.md
    │   ├── references/
    │   │   └── GetWolframEngine.md
    │   └── scripts/
    │       ├── WolframAlphaContext.wls
    │       └── WolframAlpha.wls
    └── wolfram-notebooks/
        ├── SKILL.md
        ├── references/
        │   └── GetWolframEngine.md
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
├── references/
│   └── GetWolframEngine.md             # Single source (hand-authored)
├── Skills/
│   ├── Manifest.wl                       # Tool-to-skill mapping
│   ├── wolfram-language/
│   │   ├── SKILL.md                      # Hand-authored
│   │   ├── references/                   # Copied by build from AgentSkills/References/
│   │   │   └── GetWolframEngine.md
│   │   └── scripts/                      # Generated by build
│   │       ├── WolframLanguageContext.wls
│   │       ├── WolframLanguageEvaluator.wls
│   │       ├── SymbolDefinition.wls
│   │       ├── TestReport.wls
│   │       └── CodeInspector.wls
│   ├── wolfram-alpha/
│   │   ├── SKILL.md                      # Hand-authored
│   │   ├── references/                   # Copied by build
│   │   │   └── GetWolframEngine.md
│   │   └── scripts/                      # Generated by build
│   │       ├── WolframAlphaContext.wls
│   │       └── WolframAlpha.wls
│   └── wolfram-notebooks/
│       ├── SKILL.md                      # Hand-authored
│       ├── references/                   # Copied by build
│       │   └── GetWolframEngine.md
│       └── scripts/                      # Generated by build
│           ├── ReadNotebook.wls
│           └── WriteNotebook.wls
└── Scripts/                              # Reserved for shared build utilities
```

`Scripts/BuildAgentSkills.wls` lives in the top-level `Scripts/` directory alongside other build scripts.

---

## Future Considerations

- **wolfram-paclet-development skill** — A fourth skill bundling CreateSymbolDoc, EditSymbolDoc, and EditSymbolDocExamples alongside the wolfram-language tools. Deferred to a later phase.
- **Marketplace submission** — Submit the wolfram plugin to the official Claude Code marketplace once skills are stable.
- **Additional distribution channels** — Since skills follow the open standard, they can also be distributed as standalone skill directories for agents that don't use Claude Code plugins (e.g., Cursor, Gemini CLI, VS Code).
- **Versioning** — Plugin version should track `$pacletVersion` for consistency with the MCP server. The `metadata.version` field in each SKILL.md frontmatter should also track this.
- **Standalone mode** — Scripts currently require the MCPServer paclet to be loadable. A future enhancement could generate fully self-contained scripts that embed the tool logic directly, removing the paclet dependency.
- **Validation** — Use the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) reference library to validate skill directories (`skills-ref validate ./my-skill`).
