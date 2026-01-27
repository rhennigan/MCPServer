# Continue MCP Client Research

## Overview

[Continue](https://www.continue.dev/) is an open-source AI code assistant that runs as an extension for VS Code and JetBrains IDEs. It supports MCP natively, allowing users to extend its capabilities with custom tools. Continue is an MCP Host that orchestrates user-configured MCP servers.

**Important**: MCP can only be used in Continue's **agent mode**.

## Configuration Details

### Config File Locations

Continue supports two configuration approaches:

#### 1. Global Configuration (config.yaml)

| Platform | Path |
|----------|------|
| macOS/Linux | `~/.continue/config.yaml` |
| Windows | `%USERPROFILE%\.continue\config.yaml` |

**Note**: If both `config.yaml` and `config.json` exist, `config.yaml` takes precedence. Continue is migrating to YAML as the preferred format.

#### 2. Project-Level Configuration

Project-specific MCP servers can be configured by creating files in the `.continue/mcpServers/` directory at the workspace root.

| Scope | Location |
|-------|----------|
| Project | `.continue/mcpServers/*.yaml` or `.continue/mcpServers/*.json` |

### YAML Format (Preferred)

#### Global config.yaml

MCP servers are defined under the `mcpServers` key as an **array of objects**:

```yaml
mcpServers:
  - name: ServerName
    command: "..."
    args:
      - "arg1"
      - "arg2"
    env:
      KEY: "value"
```

**Required fields:**
- `name` (string): Display name for the server
- `command` (string): The executable to run (for stdio type)

**Optional fields:**
- `args` (array): Arguments passed to the command
- `env` (object): Environment variables
- `cwd` (string): Working directory
- `type` (string): Transport type (`stdio`, `sse`, `streamable-http`). Often inferred automatically.
- `url` (string): Server URL (for sse/streamable-http types)
- `connectionTimeout` (number): Initial connection timeout
- `requestOptions` (object): HTTP options for specific server types

#### Standalone Block Files (.continue/mcpServers/*.yaml)

When creating individual files in the `.continue/mcpServers/` directory, additional metadata is required:

```yaml
name: My MCP Server
version: 0.0.1
schema: v1
mcpServers:
  - name: ServerDisplayName
    command: npx
    args:
      - "@example/mcp-server"
```

**Required top-level fields for standalone files:**
- `name` (string): Configuration identifier
- `version` (string): Version number
- `schema` (string): Schema version (e.g., `v1`)

### JSON Format (Legacy/Compatibility)

Continue also supports JSON configuration files copied from other tools (Claude Desktop, Cursor, Cline):

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

JSON files can be placed directly in `.continue/mcpServers/` and Continue will automatically pick them up.

### Environment Variables and Secrets

Continue supports environment variables through:
- The `env` property in server configuration
- Hub secrets using syntax: `${{ secrets.SECRET_NAME }}`

### Transport Types

Continue supports three transport types:
1. **stdio** (standard input/output) - most common for local servers
2. **sse** (Server-Sent Events) - for real-time streaming
3. **streamable-http** - standard HTTP with streaming capabilities

### Configuration Scope

| Scope | Support |
|-------|---------|
| Global | Yes (`~/.continue/config.yaml`) |
| Project | Yes (`.continue/mcpServers/` directory) |

## Format Comparison with Standard Clients

| Feature | Continue (YAML) | Claude Desktop (JSON) |
|---------|-----------------|----------------------|
| mcpServers structure | **Array of objects** | Object with named keys |
| Server name location | Inside object (`name:`) | As object key |
| File format | YAML (preferred) or JSON | JSON only |
| Project support | Yes | No |

**Key difference**: Continue uses an array format where each server has a `name` property inside the object, rather than using the server name as an object key:

```yaml
# Continue format
mcpServers:
  - name: MyServer
    command: "..."

# vs Claude Desktop format
"mcpServers": {
  "MyServer": {
    "command": "..."
  }
}
```

## Implementation Assessment

### Feasibility: **Feasible with Format Conversion**

Implementing `InstallMCPServer["Continue", ...]` is feasible but requires careful handling of the different configuration format.

**Pros:**
1. **Well-documented**: Clear documentation on configuration format
2. **Project-level support**: Can support both global and per-project installation
3. **JSON compatibility**: Accepts Claude Desktop-style JSON files in `.continue/mcpServers/`

**Cons/Complications:**
1. **Different Structure**: Uses array-based `mcpServers` rather than keyed objects
2. **YAML Format**: Global config uses YAML, requiring either:
   - YAML parsing/generation support, or
   - Using JSON files in `.continue/mcpServers/` instead
3. **Multiple Config Methods**: Need to decide between modifying global `config.yaml` or creating project files
4. **Standalone File Metadata**: Files in `.continue/mcpServers/` require additional metadata fields

### Recommended Approach: **Use JSON Files in .continue/mcpServers/**

The simplest implementation approach:

1. **For global installation**: Create/modify a JSON file in `~/.continue/mcpServers/wolfram-mcp.json`
2. **For project installation**: Create/modify a JSON file in `.continue/mcpServers/wolfram-mcp.json`

This leverages Continue's JSON compatibility feature and avoids the need for YAML parsing.

**Standalone JSON file format:**
```json
{
  "mcpServers": {
    "WolframLanguage": {
      "command": "...",
      "args": ["..."],
      "env": { ... }
    }
  }
}
```

Note: Continue's documentation states that JSON config files from other tools can be copied directly into `.continue/mcpServers/` and will be automatically recognized.

### Implementation Notes

1. Install location should point to `.continue/mcpServers/` directory (with a specific filename like `wolfram.json`)
2. For global: `~/.continue/mcpServers/wolfram.json` (macOS/Linux) or `%USERPROFILE%\.continue\mcpServers\wolfram.json` (Windows)
3. For project: `.continue/mcpServers/wolfram.json` in project root
4. Create the `mcpServers` directory if it doesn't exist
5. Use standard Claude Desktop JSON format (keyed objects)
6. No special fields needed (unlike Cline's `disabled`/`autoApprove`)

### Proposed Configuration

| Field | Value |
|-------|-------|
| Canonical Name | `"Continue"` |
| Config Format | JSON (standard `mcpServers` keyed format) |
| Config Location | `.continue/mcpServers/wolfram.json` |
| Project Support | Yes |

## References

- [Continue MCP Documentation](https://docs.continue.dev/customize/deep-dives/mcp)
- [Continue config.yaml Reference](https://docs.continue.dev/reference)
- [Config Migration to YAML](https://docs.continue.dev/customize/yaml-migration)
- [Model Context Protocol x Continue (Blog)](https://blog.continue.dev/model-context-protocol/)
