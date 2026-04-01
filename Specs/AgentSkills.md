# Agent Skills — Design Specification

## Overview

Agent skills package Wolfram MCP tools as distributable skills following the open [Agent Skills](https://agentskills.io/) standard. Each skill bundles standalone Wolfram Language scripts (`.wls`) generated from `$DefaultMCPTools`, along with a hand-authored `SKILL.md` that instructs compatible agents how to use them. Skills work with any agent that supports the standard (Claude Code, Cursor, Gemini CLI, VS Code, and [many others](https://agentskills.io/home)).

When the Wolfram MCP server is available, skills instruct the agent to prefer the MCP tools. When it is not, the agent falls back to executing the bundled scripts via `wolframscript`.

For distribution via Claude Code specifically, skills are packaged as two plugins (**wolfram-language-development** and **wolfram-alpha**) within a single marketplace called **wolfram-agent-skills**.

---

## Goals

- Provide Wolfram Language, Wolfram|Alpha, and notebook capabilities to any compatible agent without requiring MCP server setup.
- Follow the open [Agent Skills specification](https://agentskills.io/specification) for maximum portability across agent products.
- Support dual-mode operation: prefer MCP tools when available, fall back to bundled scripts.
- Generate standalone `.wls` scripts automatically from existing `$DefaultMCPTools` definitions.
- Package skills as installable Claude Code plugins (other distribution methods can be added later).

---

## Skills

Three skills are defined in `AgentSkills/Manifest.wl`:

### wolfram-language

Full Wolfram Language development environment.

| Script | Source Tool | Description |
| --- | --- | --- |
| `WolframLanguageContext.wls` | WolframLanguageContext | Semantic search for Wolfram Language documentation |
| `WolframLanguageEvaluator.wls` | WolframLanguageEvaluator | Evaluate Wolfram Language code |
| `SymbolDefinition.wls` | SymbolDefinition | Retrieve readable symbol definitions |
| `TestReport.wls` | TestReport | Run `.wlt` test files and return results |
| `CodeInspector.wls` | CodeInspector | Inspect code for issues |

### wolfram-alpha

Wolfram|Alpha queries and context retrieval.

| Script | Source Tool | Description |
| --- | --- | --- |
| `WolframAlphaContext.wls` | WolframAlphaContext | Semantic search using Wolfram\|Alpha |
| `WolframAlpha.wls` | WolframAlpha | Query Wolfram\|Alpha |

### wolfram-notebooks

Read and write Wolfram notebook (`.nb`) files.

| Script | Source Tool | Description |
| --- | --- | --- |
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

If you do not have Wolfram MCP tools but would like to set them up,
see `references/SetUpWolframMCPServer.md` for instructions.

### With Bundled Scripts

If no MCP tools are available, use the bundled scripts in the `scripts/`
directory. Pass `--usage` to any script to see its argument documentation.

## Available Tools

[Summary table: script name and when to use it]

For detailed usage, arguments, and invocation syntax for each script, see
`references/Scripts.md` (relative to this skill directory).

## Tips

[High-level guidance for using the tools effectively]
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

### MCP Server Setup Reference

A second shared reference file at `AgentSkills/References/SetUpWolframMCPServer.md` explains how to set up the Wolfram MCP server. This is relevant for the dual-mode detection described below — when MCP tools are not available, the agent can direct the user to set up the MCP server for a better experience.

The file covers two paths:

1. **Local server via `InstallMCPServer`** — If `wolframscript` is available, the user can install the Wolfram MCP server paclet and run `InstallMCPServer["<ClientName>", "<ServerName>"]` from a Wolfram Language session. This configures the MCP server for any supported client (Claude Code, Claude Desktop, Cursor, VS Code, Gemini CLI, etc.).
2. **Remote Wolfram MCP Service** — If no local Wolfram Engine is available, the user can subscribe to the [Wolfram MCP Service](https://www.wolfram.com/artificial-intelligence/mcp-service) and configure their client to connect to the remote server at `https://services.wolfram.com/api/mcp` using streamable HTTP transport with an API key.

The build system copies this file into each skill's `references/` subdirectory alongside `GetWolframEngine.md`. Each SKILL.md includes a note directing the agent to this file:

```markdown
For a richer experience, consider setting up the Wolfram MCP server.
See `references/SetUpWolframMCPServer.md` (relative to this skill
directory) for instructions.
```

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

(* If `--usage` argument is present: issue usage message and `Exit[0]` *)
(* If arguments invalid: issue usage message and `Exit[1]` *)

PacletInstall["Wolfram/AgentTools"];
Get["Wolfram`AgentTools`"];

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

- The script loads the AgentTools paclet and delegates to the existing tool function.
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

- `AgentSkills/Manifest.wl` — Maps skill names to their tool lists.
- `$DefaultMCPTools` — Registry of all MCP tool definitions (loaded from the paclet).

### Process

1. **Load paclet** — `PacletDirectoryLoad` + ``Get["Wolfram`AgentTools`"]``.
2. **Read manifest** — Parse `Manifest.wl` into an Association.
3. **Generate scripts** — For each tool name referenced across all skills:
   - Look up the tool in `$DefaultMCPTools`.
   - Extract parameter metadata (name, required, interpreter type, help text).
   - Generate a `.wls` script with CLI argument parsing and tool invocation.
   - Write to a temporary build directory.
4. **Distribute to skills** — For each skill in the manifest:
   - Copy the relevant generated scripts into `AgentSkills/Skills/<skill-name>/scripts/`.
   - Copy shared reference files from `AgentSkills/References/` into `AgentSkills/Skills/<skill-name>/references/`.
   - Generate a `Scripts.md` reference from the skill's tool metadata and write it to `AgentSkills/Skills/<skill-name>/references/Scripts.md`.
5. **Update marketplace version** — Update the `metadata.version` field in `.claude-plugin/marketplace.json` to match the current paclet version.
6. **Update skill versions** — Update the `version` field in each `SKILL.md` frontmatter to match the current paclet version.
7. **Clean up** — Remove the temporary build directory.

### Outputs

Generated scripts are placed in each skill's `scripts/` directory. The shared reference files (`GetWolframEngine.md`, `SetUpWolframMCPServer.md`) are copied into each skill's `references/` directory, and a `Scripts.md` reference is generated into each skill's `references/` directory from tool metadata. SKILL.md files are **not** generated — they are hand-authored. However, the build script does update the `version` field in each SKILL.md frontmatter and the `metadata.version` field in `.claude-plugin/marketplace.json` to match the current paclet version.

### What the Build Script Does NOT Do

- Does not generate or modify SKILL.md content — those are hand-authored. (It does update the `version` field in the frontmatter.)
- Does not create new plugins or restructure `marketplace.json` — it only updates the version field.
- Does not install or publish skills.

---

## Plugin Packaging (Claude Code)

The skills themselves follow the open Agent Skills standard and are portable. For distribution via **Claude Code** specifically, skills are packaged into two plugins within a single marketplace named **wolfram-agent-skills**:

- **wolfram-language-development** — Bundles the `wolfram-language` and `wolfram-notebooks` skills for a full Wolfram Language development environment.
- **wolfram-alpha** — Bundles the `wolfram-alpha` skill for Wolfram|Alpha queries and context retrieval.

The marketplace is defined by `.claude-plugin/marketplace.json` in the MCPServer repository root. Skills are referenced via relative paths from the `source` directory.

### marketplace.json

The marketplace file lives at `.claude-plugin/marketplace.json` in the repository root. Required fields at the root level are `name`, `owner`, and `plugins`. Each plugin entry requires `name` and `source`. Since these plugins don't have their own `plugin.json`, `strict` must be set to `false`.

```json
{
  "name": "wolfram-agent-skills",
  "owner": {
    "name": "Richard Hennigan",
    "email": "richardh@wolfram.com"
  },
  "metadata": {
    "description": "A collection of Wolfram agent skills",
    "version": "<paclet-version>"
  },
  "plugins": [
    {
      "name": "wolfram-language-development",
      "description": "A full Wolfram Language development environment with code evaluation, documentation search, symbol inspection, static analysis, and test execution.",
      "source": "./AgentSkills/Skills",
      "strict": false,
      "skills": [
        "./wolfram-language",
        "./wolfram-notebooks"
      ]
    },
    {
      "name": "wolfram-alpha",
      "description": "Wolfram|Alpha queries and context retrieval.",
      "source": "./AgentSkills/Skills",
      "strict": false,
      "skills": [
        "./wolfram-alpha"
      ]
    }
  ]
}
```

### Installation

Users first add the marketplace, then install individual plugins:

```
/plugin marketplace add <owner/repo>
/plugin install wolfram-language-development@wolfram-agent-skills
/plugin install wolfram-alpha@wolfram-agent-skills
```

Alternatively, a project can pre-configure the marketplace in `.claude/settings.json` using `extraKnownMarketplaces`, so team members are automatically prompted to install it.

---

## Source Directory Structure

Within the MCPServer repository:

```
AgentSkills/
├── Manifest.wl                           # Tool-to-skill mapping
├── References/
│   ├── GetWolframEngine.md               # Single source (hand-authored)
│   └── SetUpWolframMCPServer.md          # Single source (hand-authored)
├── Skills/
│   ├── wolfram-language/
│   │   ├── SKILL.md                      # Hand-authored
│   │   ├── references/                   # Copied/generated by build
│   │   │   ├── GetWolframEngine.md
│   │   │   ├── Scripts.md                # Generated by build
│   │   │   └── SetUpWolframMCPServer.md
│   │   └── scripts/                      # Generated by build
│   │       ├── WolframLanguageContext.wls
│   │       ├── WolframLanguageEvaluator.wls
│   │       ├── SymbolDefinition.wls
│   │       ├── TestReport.wls
│   │       └── CodeInspector.wls
│   ├── wolfram-alpha/
│   │   ├── SKILL.md                      # Hand-authored
│   │   ├── references/                   # Copied/generated by build
│   │   │   ├── GetWolframEngine.md
│   │   │   ├── Scripts.md                # Generated by build
│   │   │   └── SetUpWolframMCPServer.md
│   │   └── scripts/                      # Generated by build
│   │       ├── WolframAlphaContext.wls
│   │       └── WolframAlpha.wls
│   └── wolfram-notebooks/
│       ├── SKILL.md                      # Hand-authored
│       ├── references/                   # Copied/generated by build
│       │   ├── GetWolframEngine.md
│       │   ├── Scripts.md                # Generated by build
│       │   └── SetUpWolframMCPServer.md
│       └── scripts/                      # Generated by build
│           ├── ReadNotebook.wls
│           └── WriteNotebook.wls
└── Scripts/                              # Reserved for shared build utilities (future)
```

`Scripts/BuildAgentSkills.wls` lives in the top-level `Scripts/` directory alongside other build scripts.

---

## Evaluation

After implementation, create evals to verify that skills work correctly end-to-end. Evals should cover two layers:

Agent-level evals verify that an agent following the SKILL.md instructions can successfully use each skill. A test harness presents the skill to an agent and checks that it:

- **Detects MCP tools** — When MCP tools are available, the agent uses them instead of the bundled scripts.
- **Falls back to scripts** — When MCP tools are not available, the agent invokes the bundled scripts correctly via `wolframscript`.
- **Handles missing prerequisites** — When `wolframscript` is not on PATH, the agent directs the user to the `references/GetWolframEngine.md` instructions rather than failing silently.
- **Produces correct results** — For representative tasks (e.g., "evaluate `Solve[x^2 == 4, x]`", "search documentation for Plot options"), the agent returns accurate output.

Eval definitions live in `AgentSkills/Evals/` and can be run manually during development. The specific eval framework and file format will be determined during implementation, but evals should be repeatable and produce a clear pass/fail summary.

The [`skill-creator`](https://github.com/anthropics/skills/tree/main/skills/skill-creator) skill by Anthropic can be used as a good reference for how to write evals.

Script correctness (valid output, error handling, `--usage` flag) is covered by separate tests, not evals.

---

## Future Considerations

- **wolfram-paclet-development skill** — A fourth skill bundling CreateSymbolDoc, EditSymbolDoc, and EditSymbolDocExamples alongside the wolfram-language tools. Deferred to a later phase.
- **Marketplace submission** — Submit the wolfram plugin to the official Claude Code marketplace once skills are stable.
- **Additional distribution channels** — Since skills follow the open standard, they can also be distributed as standalone skill directories for agents that don't use Claude Code plugins (e.g., Cursor, Gemini CLI, VS Code).
- **Versioning** — Plugin version should track `$pacletVersion` for consistency with the MCP server. The `metadata.version` field in each SKILL.md frontmatter should also track this.
- **Standalone mode** — Scripts currently require the AgentTools paclet to be loadable. A future enhancement could generate fully self-contained scripts that embed the tool logic directly, removing the paclet dependency.
- **Validation** — Use the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) reference library to validate skill directories (`skills-ref validate ./my-skill`).
