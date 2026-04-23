# Augment Code MCP Client Research

## Overview

[Augment Code](https://www.augmentcode.com/) is an AI coding assistant available in two forms: the **Auggie CLI** and the **VS Code extension**. Each stores its MCP server configuration independently in a different file with a different JSON structure, so they are supported as two distinct clients in this paclet: `"AugmentCode"` (CLI) and `"AugmentCodeIDE"` (VS Code).

This document covers both.

## Auggie CLI (`"AugmentCode"`)

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
4. No `ProjectPath` (project-level not supported)
5. **Windows-specific quirk**: Augment Code shell-invokes the configured `command` on Windows, which breaks when the path contains spaces (e.g. `C:\Program Files\...`). cmd.exe splits the unquoted path on the first space and reports `'C:\Program' is not recognized as an internal or external command, operable program or batch file`. A `ServerConverter` is used to coerce the `command` to its 8.3 short-path form on Windows (e.g. `C:\PROGRA~1\WOLFRA~1\Wolfram\15.0\wolfram.exe`) so shell invocation resolves correctly. Other clients (Claude Desktop, Cursor, etc.) don't need this because they spawn the process directly rather than via a shell.

### Proposed Configuration

| Field | Value |
|-------|-------|
| Canonical Name | `"AugmentCode"` |
| Aliases | `"Auggie"`, `"Augment"` |
| Config Format | JSON (standard `mcpServers`) |
| Project Support | No |

## VS Code Extension (`"AugmentCodeIDE"`)

The Augment Code VS Code extension (`augment.vscode-augment`) stores its MCP server list in a **separate file** from the CLI, with a **different JSON shape**.

### Config File Location

The file lives under VS Code's user `globalStorage` directory:

| Platform | Path |
|----------|------|
| macOS | `~/Library/Application Support/Code/User/globalStorage/augment.vscode-augment/augment-global-state/mcpServers.json` |
| Windows | `%APPDATA%\Code\User\globalStorage\augment.vscode-augment\augment-global-state\mcpServers.json` |
| Linux | `~/.config/Code/User/globalStorage/augment.vscode-augment/augment-global-state/mcpServers.json` |

### JSON Format

The file's root is a **JSON array** (not an object with an `mcpServers` key). Each entry has its own `name` field that identifies the server within the array:

```json
[
    {
        "type": "stdio",
        "name": "Wolfram",
        "command": "...",
        "args": ["..."],
        "env": { "KEY": "value" }
    }
]
```

The extension's zod schema (reverse-engineered from `extension.js`) is `.passthrough()` and marks most fields optional: `{ name?, title?, type?: "stdio"|"http"|"sse", command?, args?, env?, url?, headers? }`. The minimum required for stdio is `type: "stdio"`, `name`, and `command`.

### Discovery via UI

The extension also accepts three object-formatted inputs through the **"Import from JSON"** button in the Augment Settings panel — `{ "mcpServers": { ... } }`, `{ "servers": { ... } }`, or the array form directly. Pasting the output of `MCPServerObject["..."]["JSONConfiguration"]` therefore also works as a manual workaround.

### Implementation Assessment

**Feasibility: Fully Feasible**, but the format is unique among all supported clients in that the root is an array, not an object. This required:

1. An empty `ConfigKey -> { }` in `$supportedMCPClients` to signal "no keyed root"
2. A dedicated `installMCPServer[...] /; $installClientName === "AugmentCodeIDE"` overload that upserts entries by matching the `name` field
3. A dedicated `uninstallMCPServer` overload that filters the array by `name`
4. A dedicated `readExistingAugmentCodeIDEConfig` helper that returns a `List` (vs. `readExistingMCPConfig`, which returns an `Association`)
5. Path-based client detection for `.../augment.vscode-augment/augment-global-state/mcpServers.json`
6. The same Windows 8.3 short-path coercion as `"AugmentCode"` — the extension also shell-invokes stdio servers on Windows

### Notes

- VS Code may need a window reload (`Ctrl+Shift+P` → "Reload Window") after `InstallMCPServer` writes the file, so the extension re-reads its state.
- No project-level MCP configuration is supported — only the single global file.
- The `id` and `disabled` fields sometimes seen on entries appear to be generated by the extension at runtime and are not required in the written file.

## References

- [Official Augment CLI Integrations Documentation](https://docs.augmentcode.com/cli/integrations)
- [Augment Code MCP Setup Docs](https://docs.augmentcode.com/setup-augment/mcp)
- [Augment Code Website](https://www.augmentcode.com/)
- [Augment Code VS Code extension marketplace page](https://marketplace.visualstudio.com/items?itemName=augment.vscode-augment)
