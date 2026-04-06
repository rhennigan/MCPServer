# Kiro MCP Client Research

## Overview

[Kiro](https://kiro.dev/) is an agentic IDE from AWS (with CLI and autonomous product surfaces). It supports MCP for extending the agent with tools. This document summarizes how Kiro stores MCP configuration, how that maps to AgentTools’ `InstallMCPServer` machinery, and what an implementation would need to touch.

Official reference: [Configuration – MCP – Kiro Docs](https://kiro.dev/docs/mcp/configuration/) (page updated January 15, 2026).

## Configuration Details

### Config file locations

Kiro supports **two scopes**. If both exist, configurations are **merged**, with **workspace settings overriding user** settings.

| Scope | Path | Notes |
|-------|------|--------|
| User (global) | `~/.kiro/settings/mcp.json` | Applies to all workspaces |
| Workspace (project) | `.kiro/settings/mcp.json` | Project-specific |

There is no separate macOS `Application Support` path in the public docs: the user-level file lives under the home directory in a `.kiro` tree, analogous to tools like OpenCode or Cursor.

### JSON format

Kiro uses **JSON** with a top-level **`mcpServers`** object—the same structural convention as Claude Desktop, Cursor, Windsurf, and Cline.

Example shape (abridged from the docs):

```json
{
  "mcpServers": {
    "local-server-name": {
      "command": "command-to-run-server",
      "args": ["arg1", "arg2"],
      "env": {
        "ENV_VAR1": "hard-coded-variable",
        "ENV_VAR2": "${EXPANDED_VARIABLE}"
      },
      "disabled": false,
      "autoApprove": ["tool_name1", "tool_name2"],
      "disabledTools": ["tool_name3"]
    }
  }
}
```

Remote servers use `url`, optional `headers`, and the same `disabled` / `autoApprove` / `disabledTools` fields where relevant.

### Local (stdio) server fields

| Property | Required | Role |
|----------|----------|------|
| `command` | Yes | Executable |
| `args` | Yes | Argument list |
| `env` | No | Environment variables (docs show `${VAR}` style expansion) |
| `disabled` | No | Default `false` |
| `autoApprove` | No | Tool names to auto-approve; `"*"` means all tools |
| `disabledTools` | No | Tools to hide from the agent |

### UX for opening config

From the docs, users can open these files via the command palette (**Kiro: Open workspace MCP config (JSON)** / **Kiro: Open user MCP config (JSON)**) or the Kiro panel (**Open MCP Config**). Saving the file reapplies configuration.

## Mapping to AgentTools

### Central definition

Supported clients are defined in `$supportedMCPClients` in [`Kernel/SupportedClients.wl`](../Kernel/SupportedClients.wl). Each entry supplies:

- `"DisplayName"`, `"Aliases"`, `"ConfigFormat"`, `"ConfigKey"`, `"URL"`
- `"InstallLocation"` (per OS or a single delayed path)
- Optional `"ProjectPath"` + implicit project support (see `clientMetadata` in the same file)
- Optional `"ServerConverter"` when the on-disk entry shape differs from the standard `command` / `args` / `env` association produced from `MCPServerObject`

### JSON merge and install path

For non-Codex JSON clients, [`Kernel/InstallMCPServer.wl`](../Kernel/InstallMCPServer.wl) reads the existing file, follows the client’s `"ConfigKey"` path, injects or updates one server entry, and writes JSON back. For Kiro, **`"ConfigKey" -> { "mcpServers" }`** matches the documented file layout.

### Server entry shape vs Cline

Kiro’s documented local entry is a **superset** of the usual Claude-style fields: it adds optional `disabled`, `autoApprove`, and `disabledTools`.

AgentTools already has **`convertToClineFormat`** in `SupportedClients.wl`, which adds `disabled -> False` and `autoApprove -> {}` so Cline’s UI expectations are met. Kiro’s docs treat those keys as optional with defaults, so **reusing the same converter** (or a tiny variant that also sets `"disabledTools" -> {}` for symmetry with the docs) is reasonable and avoids inventing a new merge strategy.

**Caveat:** `guessClientNameFromJSON` in `InstallMCPServer.wl` uses “has `disabled` and `autoApprove` on an entry” to infer **Cline**. A bare `mcp.json` that only contains `mcpServers` could therefore be classified as Cline even when it is intended for Kiro. In practice:

- **`InstallMCPServer["Kiro", ...]`** does not rely on JSON guessing; it uses **`installLocation`**.
- **`InstallMCPServer[File[".../mcp.json"], ..., "ApplicationName" -> Automatic]`** resolves the client via **`guessClientName`**, which first matches the file against each client’s **`installLocation`**. Adding Kiro makes **`~/.kiro/settings/mcp.json`** (and project paths) resolve correctly **before** JSON heuristics run.
- For ad hoc paths, users can pass **`"ApplicationName" -> "Kiro"`**.

### Proposed `$supportedMCPClients` entry (illustrative)

| Field | Suggested value |
|-------|------------------|
| Canonical name | `"Kiro"` |
| Display name | `"Kiro"` |
| Aliases | `{ }` or e.g. `{ "AmazonKiro" }` if product naming requires it |
| `ConfigFormat` | `"JSON"` |
| `ConfigKey` | `{ "mcpServers" }` |
| `URL` | `https://kiro.dev` (or the product’s canonical download/docs URL) |
| `InstallLocation` | `{ $HomeDirectory, ".kiro", "settings", "mcp.json" }` (same structure on macOS/Linux/Windows under `$HomeDirectory`) |
| `ProjectPath` | `{ ".kiro", "settings", "mcp.json" }` |
| `ServerConverter` | `convertToClineFormat` or a Kiro-specific copy that also sets `"disabledTools" -> {}` |

This mirrors clients that already support **project-level** MCP JSON (e.g. Claude Code, Zed): **`InstallMCPServer[{"Kiro", dir}, ...]`** would target `FileNameJoin[{dir, ".kiro", "settings", "mcp.json"}]`.

### Other code to update for a full implementation

1. **`guessClientName`** (`InstallMCPServer.wl`): extend the `Switch` on `FileNameSplit` for project files, e.g. tail `.../.kiro/settings/mcp.json` → `"Kiro"`.
2. **Tests** ([`Tests/InstallMCPServer.wlt`](../Tests/InstallMCPServer.wlt)): patterns used for Windsurf/Cline—`installLocation` per OS (if split), `toInstallName`, `installDisplayName`, `$SupportedMCPClients` keys/count and any metadata tests.
3. **User-facing docs** ([`docs/mcp-clients.md`](../docs/mcp-clients.md)): add a table row and a short “Kiro” section with paths and merge behavior.
4. **Optional:** Notebook reference pages under `Documentation/` if those are maintained alongside client lists (other clients are mentioned in tutorials).

No change to **`PacletInfo.wl` / `Main.wl`** is required for a new client name unless new symbols are exported (client support is internal metadata plus existing `InstallMCPServer`).

## Implementation Assessment

### Feasibility: **Fully feasible**

Reasons:

1. **Documented, file-based JSON** at stable relative paths under the user home and project root.
2. **Same top-level key** (`mcpServers`) and same core entry fields AgentTools already generates for stdio servers.
3. **Optional fields** align with existing converter patterns (Cline); no TOML or nested VS Code–style `mcp.servers` path.
4. **Project-level config** is explicitly supported by Kiro, matching AgentTools’ `{client, directory}` install form.

### Risks / verification

- **OS-specific home layout:** Confirm on Windows that `~/.kiro/settings/mcp.json` matches Kiro’s actual resolution (AgentTools typically uses `$HomeDirectory` segments; this matches other dot-directory clients).
- **Heuristic collisions:** Rely on path-based `guessClientName` for Kiro paths; document `ApplicationName` for unusual file locations.
- **`disabledTools` / `autoApprove`:** If Kiro’s runtime expects these keys to be present, extend the converter to emit empty lists; if they are truly optional, Cline’s converter may be enough.

## References

- [Kiro – MCP configuration](https://kiro.dev/docs/mcp/configuration/)
- [Kiro – MCP server directory](https://kiro.dev/docs/mcp/servers/)
- [Kiro – MCP usage / tools](https://kiro.dev/docs/mcp/usage/)
- AgentTools: [`docs/mcp-clients.md`](../docs/mcp-clients.md) (“Adding Support for New Clients”)
