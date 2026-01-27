# Cline MCP Client Research

## Overview

[Cline](https://cline.bot/) (formerly known as Claude Dev and Roo Code) is an autonomous coding agent VS Code extension that supports MCP natively. It allows users to configure MCP servers to extend its capabilities with custom tools.

## Configuration Details

### Config File Location

Cline stores its MCP configuration in the VS Code extension's global storage directory. The path varies by operating system and VS Code variant:

| Platform | Path |
|----------|------|
| macOS | `~/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json` |
| Windows | `%APPDATA%\Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json` |
| Linux | `~/.config/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json` |

**Note**: If using a VS Code variant (Cursor, Windsurf, etc.), replace `Code` with the appropriate application name in the path.

### JSON Format

Cline uses the standard `mcpServers` JSON structure:

```json
{
  "mcpServers": {
    "ServerName": {
      "command": "...",
      "args": ["..."],
      "env": {
        "KEY": "value"
      },
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

### Supported Fields

**For stdio/command-based servers:**
- `command` (string): The executable to run
- `args` (array): Arguments passed to the command
- `env` (object): Environment variables

**For SSE/remote servers:**
- `url` (string): The HTTPS endpoint for the remote server
- `headers` (object): HTTP headers for authentication

**Cline-specific fields:**
- `disabled` (boolean): Set to `true` to disable the server without removing it (default: `false`)
- `autoApprove` (array): List of tool names to approve automatically without user confirmation
- `alwaysAllow` (array): Alternative name for `autoApprove` - list of tools to auto-approve

### Transport Types

Cline supports two transport types:
1. **stdio** (standard input/output) - for local servers
2. **SSE** (Server-Sent Events) - for remote/centralized servers

### Configuration Scope

- **Global only**: Configuration is stored at the VS Code extension level, shared across all workspaces
- **No project-level support**: There is no per-workspace MCP configuration currently. There's an [open feature request](https://github.com/cline/cline/discussions/2355) to support workspace-level configuration via `.vscode/settings.json`, but it has not been implemented.

### Configuration Access

Users can access the MCP settings through the Cline extension UI:
1. Click the "MCP Servers" icon in the top navigation bar of the Cline extension
2. Select the "Configure" tab
3. Click "Advanced MCP Settings" to edit the JSON file directly

## Implementation Assessment

### Feasibility: **Partially Feasible with Caveats**

Implementing `InstallMCPServer["Cline", ...]` is feasible but has some complications:

**Pros:**
1. **Standard Format**: Uses the same `mcpServers` JSON structure as Claude Desktop and other clients
2. **Simple JSON Structure**: No complex format conversion needed

**Cons/Complications:**
1. **Extension Storage Location**: The config file is stored in VS Code's extension global storage (`globalStorage/saoudrizwan.claude-dev/`), which is:
   - Not in a predictable user-managed location
   - Tied to the VS Code extension ID, which could change
   - May not exist until Cline is installed and configured
2. **VS Code Variant Detection**: Users may use Cline with different VS Code variants (Code, Cursor, Windsurf), each with different base paths. We would need to detect or ask which variant is being used.
3. **No Project Support**: Cannot support project-level installation as Cline only has global configuration
4. **Settings Subdirectory**: The file is in a `settings` subdirectory within the extension storage, which must be created if it doesn't exist

### Recommendation: **Implement with VS Code variant as parameter**

Despite the complications, implementation is recommended because:
1. Cline is a popular and widely-used MCP client
2. The JSON format is standard and compatible with our existing infrastructure
3. We can default to standard VS Code paths and document the variant differences

### Implementation Notes

1. Add install location definitions for all three platforms
2. The path should use `$ApplicationDirectory` pattern to support VS Code variants
3. Create the `settings` subdirectory if it doesn't exist
4. Add Cline-specific default fields: `"disabled": false, "autoApprove": []`
5. No project-level support needed (not supported by Cline)
6. Add name aliases

### Proposed Configuration

| Field | Value |
|-------|-------|
| Canonical Name | `"Cline"` |
| Config Format | JSON (standard `mcpServers` with additional fields) |
| Project Support | No |

### Additional Fields for Cline

When installing to Cline, add these default fields to the server configuration:
```json
{
  "disabled": false,
  "autoApprove": []
}
```

## References

- [Cline Documentation - Configuring MCP Servers](https://docs.cline.bot/mcp/configuring-mcp-servers)
- [Cline Documentation - MCP Marketplace](https://docs.cline.bot/mcp/mcp-marketplace)
- [GitHub Discussion - Move MCP settings to VS Code settings](https://github.com/cline/cline/discussions/2355)
- [Cline VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=saoudrizwan.claude-dev)
- [MCP Config Manager (reference implementation)](https://github.com/easytocloud/mcp-config-manager)
