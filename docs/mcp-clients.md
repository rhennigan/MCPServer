# MCP Client Support in MCPServer

This document explains how MCPServer supports different MCP client applications and how to install MCP servers into them.

## Overview

MCPServer works with **any MCP client that supports the stdio server transport**. The server communicates via standard input/output using JSON-RPC messages, which is the most common transport mechanism for local MCP servers.

For convenience, `InstallMCPServer` and `UninstallMCPServer` functions are provided to automatically configure several popular client applications. These functions handle the different configuration file formats and locations used by each client.

## Clients with InstallMCPServer Support

The following clients have built-in support for automatic configuration via `InstallMCPServer`:

| Client | Canonical Name | Aliases | Config Format | Project Support |
|--------|---------------|---------|---------------|-----------------|
| Claude Desktop | `"ClaudeDesktop"` | `"Claude"` | JSON | No |
| Claude Code | `"ClaudeCode"` | `"claude-code"` | JSON | Yes |
| Copilot CLI | `"CopilotCLI"` | `"Copilot"`, `"copilot-cli"`, `"GitHubCopilotCLI"` | JSON | No |
| Cursor | `"Cursor"` | — | JSON | No |
| Gemini CLI | `"GeminiCLI"` | `"Gemini"` | JSON | No |
| Antigravity | `"Antigravity"` | `"GoogleAntigravity"` | JSON | No |
| OpenAI Codex | `"Codex"` | `"codex"`, `"OpenAICodex"` | TOML | No |
| OpenCode | `"OpenCode"` | — | JSON | Yes |
| Visual Studio Code | `"VisualStudioCode"` | `"VSCode"`, `"Code"` | JSON | Yes |

## Usage

### Basic Installation

Install an MCP server into a client application:

```wl
InstallMCPServer["ClaudeDesktop"]
```

This installs the default MCP server into Claude Desktop's configuration file.

### Installing a Specific Server

```wl
InstallMCPServer["ClaudeCode", "WolframLanguage"]
```

### Project-Level Installation

For clients that support project-level configuration, use a `{name, directory}` specification:

```wl
InstallMCPServer[{"ClaudeCode", "/path/to/project"}]
```

This creates a `.mcp.json` file in the specified project directory.

### Installing to a Custom File

```wl
InstallMCPServer[File["/custom/path/config.json"]]
```

For TOML files (Codex), the format is auto-detected from the `.toml` extension.

### Uninstalling

```wl
UninstallMCPServer["ClaudeDesktop"]              (* Remove all servers *)
UninstallMCPServer["ClaudeDesktop", "Wolfram"]   (* Remove specific server *)
UninstallMCPServer[myServerObject]               (* Remove from all locations *)
```

## Client Configuration Details

### Claude Desktop

| OS | Config Location |
|----|----------------|
| macOS | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Windows | `%APPDATA%\Claude\claude_desktop_config.json` |

**Format:**
```json
{
    "mcpServers": {
        "ServerName": {
            "command": "...",
            "args": ["..."],
            "env": { ... }
        }
    }
}
```

### Claude Code

| Scope | Config Location |
|-------|----------------|
| Global | `~/.claude.json` |
| Project | `.mcp.json` (in project root) |

**Format:** Same as Claude Desktop (`mcpServers` key).

### Copilot CLI

| Scope | Config Location |
|-------|----------------|
| Global | `~/.copilot/mcp-config.json` |

**Format:**
```json
{
    "mcpServers": {
        "ServerName": {
            "command": "...",
            "args": ["..."],
            "env": { ... },
            "tools": ["*"]
        }
    }
}
```

Note: Copilot CLI requires the `tools` field to specify which tools to enable. `InstallMCPServer` automatically adds `"tools": ["*"]` to enable all tools.

### Cursor

| Scope | Config Location |
|-------|----------------|
| Global | `~/.cursor/mcp.json` |

**Format:** Same as Claude Desktop (`mcpServers` key).

### Gemini CLI

| Scope | Config Location |
|-------|----------------|
| Global | `~/.gemini/settings.json` |

**Format:** Same as Claude Desktop (`mcpServers` key).

### Antigravity

| Scope | Config Location |
|-------|----------------|
| Global | `~/.gemini/antigravity/mcp_config.json` |

**Format:** Same as Claude Desktop (`mcpServers` key).

### OpenAI Codex

| Scope | Config Location |
|-------|----------------|
| Global | `~/.codex/config.toml` |

**Format (TOML):**
```toml
[mcp_servers.ServerName]
command = "..."
args = ["..."]
enabled = true

[mcp_servers.ServerName.env]
KEY = "value"
```

### OpenCode

| Scope | Config Location |
|-------|----------------|
| Global | `~/.config/opencode/opencode.json` |
| Project | `opencode.json` (in project root) |

**Format:**
```json
{
    "mcp": {
        "ServerName": {
            "type": "local",
            "command": ["...", "arg1", "arg2"],
            "enabled": true,
            "environment": { ... }
        }
    }
}
```

Note: OpenCode uses a different format where the command and args are combined into a single `command` array.

### Visual Studio Code

| OS | Config Location |
|----|----------------|
| macOS | `~/Library/Application Support/Code/User/settings.json` |
| Windows | `%APPDATA%\Code\User\settings.json` |
| Linux | `~/.config/Code/User/settings.json` |
| Project | `.vscode/settings.json` |

**Format:**
```json
{
    "mcp": {
        "servers": {
            "ServerName": {
                "command": "...",
                "args": ["..."],
                "env": { ... }
            }
        }
    }
}
```

Note: VS Code nests servers under `mcp.servers` rather than `mcpServers`.

## Using Other MCP Clients

MCPServer can be used with any MCP client that supports the stdio transport. If your client is not listed above, you can manually configure it using the server's command, arguments, and environment variables.

### Server Configuration

The basic configuration requires:

| Field | Value |
|-------|-------|
| Command | `/full/path/to/wolfram` (or `wolfram.exe` on Windows) |
| Arguments | ``-run PacletSymbol["Wolfram/MCPServer","StartMCPServer"][] -noinit -noprompt`` |

### Environment Variables

Include these environment variables for proper operation:

| Variable | Description |
|----------|-------------|
| `MCP_SERVER_NAME` | Name of the MCP server to run (e.g. `"WolframLanguage"`, optional) |
| `WOLFRAM_BASE` | Path to Wolfram base directory (`$BaseDirectory`) |
| `WOLFRAM_USERBASE` | Path to user's Wolfram files (`$UserBaseDirectory`) |
| `APPDATA` | (Windows only) Path to application data (typically `ParentDirectory[$UserBaseDirectory]`) |

### Getting the Configuration

You can generate the JSON configuration for manual use:

```wl
MCPServerObject["Wolfram"]["JSONConfiguration"]
```

This returns a JSON string with the complete server configuration that you can adapt to your client's format.

### Setup Instructions

For clients not listed here, consult the [MCP documentation](https://modelcontextprotocol.io/) or your client's documentation for instructions on configuring stdio-based MCP servers.

## Options

### DevelopmentMode

Controls how the MCP server is started:

| Value | Behavior |
|-------|----------|
| `False` (default) | Uses the installed paclet via `PacletSymbol` |
| `True` | Uses `Scripts/StartMCPServer.wls` from the current paclet location |
| `"path/to/directory"` | Uses `Scripts/StartMCPServer.wls` from the specified directory |

This is useful for testing local changes without reinstalling the paclet:

```wl
InstallMCPServer["ClaudeCode", "DevelopmentMode" -> True]
```

### ProcessEnvironment

Specifies additional environment variables to include in the configuration:

```wl
InstallMCPServer["ClaudeCode", ProcessEnvironment -> <|"MY_VAR" -> "value"|>]
```

By default, `InstallMCPServer` includes:
- `MCP_SERVER_NAME`
- `WOLFRAM_BASE`
- `WOLFRAM_USERBASE`
- `APPDATA` (Windows only)

### VerifyLLMKit

Controls whether to check LLMKit subscription requirements:

| Value | Behavior |
|-------|----------|
| `True` (default) | Warns or errors if tools require LLMKit subscription |
| `False` | Skips the LLMKit check |

## Adding Support for New Clients

To add support for a new MCP client application:

1. **Add install location** in `Kernel/InstallMCPServer.wl`:
   ```wl
   installLocation["NewClient", "MacOSX"] :=
       fileNameJoin[$HomeDirectory, ".newclient", "config.json"];
   ```

2. **Add name aliases** (optional):
   ```wl
   toInstallName["newclient"] := "NewClient";
   ```

3. **Add display name**:
   ```wl
   installDisplayName["NewClient"] := "New Client";
   ```

4. **Handle format differences** (if needed):
   - If the client uses a non-standard JSON structure, add handling in `installMCPServer` and `uninstallMCPServer`
   - If the client uses a different file format (like TOML), add appropriate conversion functions

5. **Add project-level support** (if applicable):
   ```wl
   projectInstallLocation["NewClient", dir_] :=
       fileNameJoin[dir, ".newclient.json"];
   ```

## Related Files

- `Kernel/InstallMCPServer.wl` - Installation and uninstallation implementation
- `Kernel/CreateMCPServer.wl` - Server creation and JSON configuration generation
- `Kernel/MCPServerObject.wl` - Server object structure
