# Amazon Q Developer MCP Client Research

## Overview

[Amazon Q Developer](https://aws.amazon.com/q/developer/) is AWS's AI coding assistant available as both a CLI and IDE plugin (VS Code, JetBrains IDEs, Visual Studio). It supports MCP for extending the agent with tools. This document summarizes how Amazon Q stores MCP configuration, how that maps to AgentTools' `InstallMCPServer` machinery, and what an implementation touches.

Official references:

- [Using MCP with Q Developer (AWS docs)](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/qdev-mcp.html)
- [Amazon Q CLI agent format — `mcpServers` field](https://github.com/aws/amazon-q-developer-cli/blob/main/docs/agent-format.md#mcpservers-field)

## Configuration Details

### Config file locations

Amazon Q supports **two scopes**. Workspace configuration takes precedence over global for project-specific overrides.

| Scope | Path | Notes |
|-------|------|-------|
| Global (user) | `~/.aws/amazonq/mcp.json` | On Windows: `%USERPROFILE%\.aws\amazonq\mcp.json` |
| Workspace (project) | `.amazonq/mcp.json` | Placed in project root |

The path is uniform across macOS, Linux, and Windows (same `~/.aws/amazonq/` location under the user home directory). AWS also maintains a newer "agent" format (`~/.aws/amazonq/agents/default.json`) that bundles `mcpServers` with agent metadata — the legacy `mcp.json` remains supported via the `useLegacyMcpJson` agent flag and is the simplest surface for third-party installers to target.

### JSON format

Amazon Q uses **JSON** with a top-level **`mcpServers`** object — the same structural convention as Claude Desktop, Cursor, Windsurf.

Example:

```json
{
  "mcpServers": {
    "wolfram": {
      "command": "wolframscript",
      "args": ["-file", "/path/to/server.wls"],
      "env": {
        "WOLFRAM_LICENSE": "..."
      },
      "timeout": 120000
    }
  }
}
```

### Local (stdio) server fields

| Property | Required | Type | Default | Role |
|----------|----------|------|---------|------|
| `command` | Yes | string | — | Executable |
| `args` | No | array | `[]` | Argument list |
| `env` | No | object | — | Environment variables |
| `timeout` | No | number (ms) | `120000` | Per-request timeout |

**Runtime-only fields (NOT in `mcp.json`):** `disabled` and `autoApprove` are managed through the Amazon Q IDE UI at runtime, not persisted in `mcp.json`. This distinguishes Amazon Q from Cline/Kiro, which encode those keys in the config file.

## Mapping to AgentTools

### Central definition

Supported clients are defined in `$supportedMCPClients` in [`Kernel/SupportedClients.wl`](../Kernel/SupportedClients.wl). Amazon Q's entry uses the standard keys — no `ServerConverter` is required because the on-disk entry shape is exactly what `MCPServerObject` produces.

### `$supportedMCPClients` entry (as implemented)

| Field | Value |
|-------|-------|
| Canonical name | `"AmazonQ"` |
| Display name | `"Amazon Q Developer"` |
| Aliases | `{ "AmazonQDeveloper", "Q", "QDeveloper" }` |
| `ConfigFormat` | `"JSON"` |
| `ConfigKey` | `{ "mcpServers" }` |
| `URL` | `https://aws.amazon.com/q/developer/` |
| `InstallLocation` | `{ $HomeDirectory, ".aws", "amazonq", "mcp.json" }` |
| `ProjectPath` | `{ ".amazonq", "mcp.json" }` |
| `ServerConverter` | (none — standard `command`/`args`/`env` is correct) |

### Detection

`guessClientName` in [`Kernel/InstallMCPServer.wl`](../Kernel/InstallMCPServer.wl) is extended to match:

- `{ __, ".amazonq", "mcp.json" }` → `"AmazonQ"` (project scope)
- `{ __, ".aws", "amazonq", "mcp.json" }` → `"AmazonQ"` (any user-dir variant)

The canonical global path is already matched by the earlier `installLocation` check; these `Switch` arms cover project installs and absolute paths outside the literal `$HomeDirectory`.

### `timeout` field

The paclet does not emit `timeout`. Amazon Q applies its own 120000 ms default when the key is absent, matching the behavior of every other client integration.

## Implementation Assessment

### Feasibility: **Fully feasible — minimal change set**

Reasons:

1. **Documented, file-based JSON** at stable relative paths under the user home and project root.
2. **Same top-level key** (`mcpServers`) and identical core entry fields AgentTools already generates for stdio servers.
3. **No converter needed** — unlike Cline/Kiro/OpenCode/CopilotCLI, Amazon Q's on-disk entry matches the default shape.
4. **Project-level config** is explicitly supported, matching AgentTools' `{client, directory}` install form.

### Risks / verification

- **Legacy vs agent format:** AWS's newer agent files (`~/.aws/amazonq/agents/default.json`) bundle more than just MCP. Sticking with `mcp.json` is the safe choice; users who adopt the new agent format set `useLegacyMcpJson: true` to continue picking up `mcp.json`.
- **Windows home resolution:** `$HomeDirectory` on Windows maps to `%USERPROFILE%`, which is where AWS CLI tools expect `.aws/` to live. Verified by inspection of Codex and Cursor entries that use the same pattern.
- **Alias collisions:** `"Q"`, `"QDeveloper"`, `"AmazonQDeveloper"` are unique across current supported clients.

## References

- [Using MCP with Q Developer (AWS docs)](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/qdev-mcp.html)
- [Amazon Q CLI agent format spec](https://github.com/aws/amazon-q-developer-cli/blob/main/docs/agent-format.md)
- AgentTools: [`docs/mcp-clients.md`](../docs/mcp-clients.md) ("Adding Support for New Clients")
