# Augment Code MCP Client Research

## Overview

[Augment Code](https://www.augmentcode.com/) is an AI coding assistant. Its CLI, Auggie, natively integrates with MCP servers. This document details how MCP servers are configured in Augment Code and assesses the feasibility of implementing `InstallMCPServer` support.

## Configuration Details

### Config File Location

| Platform | Path |
|----------|------|
| macOS/Linux/Windows | `~/.augment/settings.json` |

A single cross-platform path is used — no OS-specific variants.

### JSON Format

Augment Code uses the standard `mcpServers` JSON structure, identical to Claude Desktop:

```json
{
  "mcpServers": {
    "ServerName": {
      "command": "...",
      "args": ["..."],
      "env": {
        "KEY": "value"
      }
    }
  }
}
```

### Supported Fields

**For stdio/command-based servers:**
- `command` (string): The executable to run
- `args` (array): Arguments passed to the command
- `env` (object): Environment variables

**For remote HTTP servers:**
- `type` (string): `"http"` or `"sse"`
- `url` (string): The HTTP endpoint
- `headers` (object): Custom HTTP headers

### Transport Types

Augment Code supports three transport types:
1. stdio (standard input/output)
2. HTTP
3. SSE (Server-Sent Events)

### Configuration Scope

- **Global only**: Configuration is at the user level only
- **No project-level support**: The documentation does not describe a per-project MCP configuration file; per-invocation overrides are available through the `--mcp-config` flag on the Auggie CLI, but these are transient and not written to disk.

### CLI Management

The Auggie CLI provides built-in commands for managing MCP server entries in `~/.augment/settings.json`:

- `auggie mcp add` - Add a server entry
- `auggie mcp list` - List configured servers
- `auggie mcp remove` - Remove a server entry

These write to the same `settings.json` that `InstallMCPServer` would edit, so the two mechanisms are interoperable.

## Implementation Assessment

### Feasibility: **Fully Feasible**

Augment Code's MCP configuration is straightforward to implement because:

1. **Standard Format**: Uses the same `mcpServers` JSON structure as Claude Desktop, Cursor, Windsurf, and other clients already supported
2. **Simple File Location**: Single cross-platform global config file
3. **No Special Conversion**: No format conversion needed (no `ServerConverter` required)

### Implementation Notes

1. Add a single-path `InstallLocation` (same on all OSes)
2. Add name aliases (`"Auggie"`, `"Augment"`)
3. Display name "Augment Code"
4. Uses standard format - no special handling in `installMCPServer` needed
5. No `ProjectPath` (project-level not supported)

### Proposed Configuration

| Field | Value |
|-------|-------|
| Canonical Name | `"AugmentCode"` |
| Aliases | `"Auggie"`, `"Augment"` |
| Config Format | JSON (standard `mcpServers`) |
| Project Support | No |

## References

- [Official Augment CLI Integrations Documentation](https://docs.augmentcode.com/cli/integrations)
- [Augment Code Website](https://www.augmentcode.com/)
