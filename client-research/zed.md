# Zed MCP Client Research

## Overview

[Zed](https://zed.dev/) is a high-performance code editor built in Rust that supports MCP servers through its Agent Panel. Zed calls MCP servers "context servers" and provides both extension-based and custom configuration options. This document details how MCP servers are configured in Zed and assesses the feasibility of implementing `InstallMCPServer` support.

## Configuration Details

### Config File Location

| Platform | Path |
|----------|------|
| macOS | `~/.config/zed/settings.json` |
| Linux | `~/.config/zed/settings.json` (or `$XDG_CONFIG_HOME/zed/settings.json`) |
| Windows | `%APPDATA%\Zed\settings.json` |
| Project | `.zed/settings.json` |

### JSON Format

Zed uses a `context_servers` key (not `mcpServers` like Claude Desktop):

```json
{
  "context_servers": {
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
- `url` (string): The HTTP endpoint
- `headers` (object): Custom HTTP headers including authentication

### Configuration Scope

- **Global**: User-level `settings.json` file
- **Project-level**: `.zed/settings.json` in project root (settings are merged with global)

### MCP Server Extensions

Zed also supports installing MCP servers as extensions through:
1. The extension marketplace (filtered by "context-servers")
2. The Agent Panel's "Add Custom Server" button
3. Manual configuration in `settings.json`

## Implementation Assessment

### Feasibility: **Fully Feasible**

Zed's MCP configuration is straightforward to implement because:

1. **Similar Format**: Uses the same inner structure as Claude Desktop (`command`, `args`, `env`)
2. **Different Top-Level Key**: Uses `context_servers` instead of `mcpServers`
3. **Standard JSON**: No special format conversion needed
4. **Project Support**: Has `.zed/settings.json` for project-level configuration

### Implementation Notes

1. Add install location definitions for macOS, Linux, and Windows
2. Add canonical name "Zed"
3. Add display name "Zed"
4. **Special handling needed**: Use `context_servers` key instead of `mcpServers`
5. Add project-level support at `.zed/settings.json`

### Proposed Configuration

| Field | Value |
|-------|-------|
| Canonical Name | `"Zed"` |
| Config Format | JSON (`context_servers` key) |
| Project Support | Yes |

### Key Differences from Other Clients

| Aspect | Zed | Claude Desktop |
|--------|-----|----------------|
| Top-level key | `context_servers` | `mcpServers` |
| Server entry format | Same | Same |
| Settings file | Shared settings.json | Dedicated config file |

## References

- [Model Context Protocol Documentation](https://zed.dev/docs/ai/mcp)
- [MCP Server Extensions](https://zed.dev/docs/extensions/mcp-extensions)
- [Configuring Zed](https://zed.dev/docs/configuring-zed)
- [GitHub Discussion on MCP](https://github.com/zed-industries/zed/discussions/21455)
