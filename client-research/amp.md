# Amp MCP Client Research

## Overview

[Amp](https://ampcode.com/) is Sourcegraph's AI coding agent, available as a
CLI and as a VS Code extension. Amp supports MCP servers for extending the
agent with external tools (Playwright, Linear, Lighthouse, etc.). This document
summarizes how Amp stores MCP configuration, how that maps to AgentTools'
`InstallMCPServer` machinery, and what would be needed to add
`InstallMCPServer["Amp", ...]` support.

Primary references:

- [Amp Owner's Manual](https://ampcode.com/manual)
- [Amp MCP Setup Guide](https://github.com/sourcegraph/amp-examples-and-guides/blob/main/guides/mcp/amp-mcp-setup-guide.md)
  (`sourcegraph/amp-examples-and-guides`)
- [Workspace Settings](https://ampcode.com/news/cli-workspace-settings)
- [Shared Settings](https://ampcode.com/news/shared-settings)

## Configuration Details

### Config file locations

Amp supports **two scopes** for its own settings file, plus the VS Code
extension UI which is backed by VS Code's native settings. If both CLI scopes
exist, workspace settings layer on top of user settings.

| Scope | Path | Notes |
|-------|------|--------|
| User (global) | `~/.config/amp/settings.json` (macOS/Linux) | Used by both the Amp CLI and the VS Code extension when reading CLI-style settings. |
| User (global) | `%APPDATA%\amp\settings.json` (Windows) | Per the Amp MCP setup guide. |
| Workspace (project) | `.amp/settings.json` | Introduced with Amp CLI workspace settings; picked up by both the CLI and the editor. Workspace MCP servers require explicit approval before they can run. |

Notes:

- The VS Code **extension UI** (Settings → Extensions → Amp → MCP Servers)
  lets users add MCP servers through a GUI. The Amp docs do not explicitly
  say whether that UI writes to Amp's `~/.config/amp/settings.json`, to
  VS Code's own `settings.json`, or both. For `InstallMCPServer` purposes it
  is safest to target Amp's own `settings.json` files, since that is the
  documented file-based configuration surface that the CLI and SDK both read.
- There is an additional Amp "Shared Settings" concept for teams/enterprise,
  but the underlying file format is the same `amp.mcpServers` JSON key.

### JSON format

Amp uses **JSON** with a top-level **`amp.mcpServers`** key. Unlike most other
clients, this is a **single literal key whose name contains a dot** (VS Code
settings convention), not a nested `{"amp": {"mcpServers": ...}}` object.

Example from the official setup guide:

```json
{
  "amp.mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest"
      ]
    },
    "Lighthouse": {
      "command": "lighthouse-mcp",
      "env": {}
    },
    "linear": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://mcp.linear.app/sse"
      ],
      "disabled": false
    },
    "jira": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://mcp.jira.com/sse"
      ],
      "disabled": false
    }
  }
}
```

The Amp manual also documents `${VAR_NAME}` syntax for environment variable
expansion in setting values.

### Local (stdio) server fields

| Property | Required | Role |
|----------|----------|------|
| `command` | Yes | Executable |
| `args` | No | Argument list (array of strings) |
| `env` | No | Environment variables (supports `${VAR}` expansion) |
| `disabled` | No | Boolean, default `false` |

Remote servers use `url` and optional `headers`. AgentTools only generates
stdio configurations, so the remote shape is not relevant for install.

### UX for opening config

- CLI users edit `~/.config/amp/settings.json` (or the Windows `%APPDATA%`
  variant) directly, or run `amp mcp add --workspace` to write entries into
  `.amp/settings.json` in the current project.
- VS Code users can open **Settings → Extensions → Amp → MCP Servers** and
  use "Add MCP Server" to configure servers through a graphical list.

## Mapping to AgentTools

### Central definition

Supported clients are defined in `$supportedMCPClients` in
[`Kernel/SupportedClients.wl`](../Kernel/SupportedClients.wl). Each entry
supplies:

- `"DisplayName"`, `"Aliases"`, `"ConfigFormat"`, `"ConfigKey"`, `"URL"`
- `"InstallLocation"` (per OS or a single delayed path)
- Optional `"ProjectPath"` + implicit project support (see `clientMetadata`
  in the same file)
- Optional `"ServerConverter"` when the on-disk entry shape differs from the
  standard `command` / `args` / `env` association produced from
  `MCPServerObject`

### JSON merge and install path

For non-Codex JSON clients, [`Kernel/InstallMCPServer.wl`](../Kernel/InstallMCPServer.wl)
reads the existing file, walks the client's `"ConfigKey"` path, injects or
updates one server entry, and writes JSON back.

For Amp the correct config key is a single-element list containing the literal
dotted string: **`"ConfigKey" -> { "amp.mcpServers" }`**. Because
`ensureNestedKey`, `configKeyPath`, and the `existing[keys, configName] = server`
pattern in `installMCPServer` already operate on a list of key strings (each
used as a literal Association key), a single-element list with the dotted
literal works correctly — AgentTools will create/merge
`<| "amp.mcpServers" -> <| configName -> server |> |>` in the existing JSON
without any changes to the traversal helpers.

### Server entry shape

Amp's documented local server entry uses the same core fields that AgentTools
already emits (`command`, `args`, `env`). `disabled` is documented as
optional with a default of `false`, so **no `ServerConverter` is required**
for a minimal installation — `InstallMCPServer["Amp"]` can reuse the default
identity converter that JSON clients like Cursor and Claude Desktop use.

If we want parity with how `convertToClineFormat` emits explicit defaults,
we could add a very small `convertToAmpFormat` that sets `"disabled" -> False`.
The Amp docs do not require it.

### Risks around client-detection heuristics

Two helpers in `Kernel/InstallMCPServer.wl` need attention when adding a new
client whose config file name is `settings.json`:

1. **`guessClientName`** first tries to match a given file against each
   registered client's `installLocation`. Once Amp is registered,
   `~/.config/amp/settings.json` (and `.amp/settings.json` via `ProjectPath`
   for project installs) will resolve to `"Amp"` automatically when the user
   passes a `File[...]` target that already lives at the standard path.
2. For ad hoc paths (e.g. a shared `settings.json` in an unusual location),
   `guessClientName` falls through to a file-split `Switch`. We should add
   a clause like:

   ```wl
   { __, ".amp", "settings.json" | "settings.jsonc" }, Throw[ "Amp" ],
   { __, ".config", "amp", "settings.json" | "settings.jsonc" }, Throw[ "Amp" ],
   ```

   This keeps Amp paths from being misclassified as a generic VS Code/Cursor
   file when the user supplies an explicit `File[]` path.
3. **`guessClientNameFromJSON`** currently inspects top-level keys and
   per-server traits of `mcpServers` entries. Since Amp uses the distinctive
   literal key `"amp.mcpServers"`, we can add a Tier 1 rule:

   ```wl
   If[ KeyExistsQ[ json, "amp.mcpServers" ], Throw[ "Amp" ] ];
   ```

   This rule is safe because no other supported client uses that dotted key,
   and it fires before the generic `mcpServers` heuristics.

### Proposed `$supportedMCPClients` entry (illustrative)

| Field | Suggested value |
|-------|------------------|
| Canonical name | `"Amp"` |
| Display name | `"Amp"` |
| Aliases | `{ "AmpCode", "SourcegraphAmp" }` (exact set TBD) |
| `ConfigFormat` | `"JSON"` |
| `ConfigKey` | `{ "amp.mcpServers" }` |
| `URL` | `https://ampcode.com` |
| `InstallLocation` | macOS/Linux: `{ $HomeDirectory, ".config", "amp", "settings.json" }`; Windows: `{ $HomeDirectory, "AppData", "Roaming", "amp", "settings.json" }` |
| `ProjectPath` | `{ ".amp", "settings.json" }` |
| `ServerConverter` | none (default identity) — optionally `convertToAmpFormat` that sets `"disabled" -> False` |

This mirrors clients that already support **project-level** MCP JSON
(Claude Code, Kiro, OpenCode, Zed, VS Code):
`InstallMCPServer[{"Amp", dir}, ...]` would target
`FileNameJoin[{dir, ".amp", "settings.json"}]`.

### Other code to update for a full implementation

1. **`guessClientName`** (`InstallMCPServer.wl`): add path-based rules for
   `~/.config/amp/settings.json` and `.amp/settings.json` (see above).
2. **`guessClientNameFromJSON`** (`InstallMCPServer.wl`): add the
   `"amp.mcpServers"` key check in Tier 1 so bare JSON files are correctly
   detected as Amp.
3. **Tests** ([`Tests/InstallMCPServer.wlt`](../Tests/InstallMCPServer.wlt)):
   follow the patterns used for Windsurf/Kiro/Cline — `installLocation` per
   OS (both POSIX and Windows branches), `toInstallName`, `installDisplayName`,
   `$SupportedMCPClients` keys/count, a round-trip install/uninstall test
   that verifies the resulting JSON uses the `"amp.mcpServers"` top-level key
   and preserves unrelated keys in the same `settings.json`.
4. **User-facing docs** ([`docs/mcp-clients.md`](../docs/mcp-clients.md)):
   add a table row and a short "Amp" section with paths, merge behavior, and
   the dotted-key caveat.
5. **Optional:** Notebook reference pages under `Documentation/` if those are
   maintained alongside client lists.

No change to **`PacletInfo.wl` / `Main.wl`** is required for a new client name
unless new symbols are exported (client support is internal metadata plus
existing `InstallMCPServer`).

## Implementation Assessment

### Feasibility: **Fully feasible**

Reasons:

1. **Documented, file-based JSON** at stable relative paths under the user
   home and project root, for both global and workspace scopes.
2. **Same core entry fields** (`command`, `args`, `env`) AgentTools already
   generates for stdio servers. `disabled` is optional and defaults sensibly.
3. **Single-element `ConfigKey`** (`{ "amp.mcpServers" }`) fits the existing
   traversal code with no refactor — each element of `ConfigKey` is already
   treated as a literal Association key, and a dotted literal string is
   just another literal key.
4. **Project-level config** (`.amp/settings.json`) maps directly to
   AgentTools' `{client, directory}` install form.
5. **Clean heuristic signature** (`"amp.mcpServers"`) avoids collisions with
   existing JSON client detection rules.

### Risks / verification

- **Windows path:** The setup guide gives `%APPDATA%\amp\settings.json`,
  i.e. `$HomeDirectory\AppData\Roaming\amp\settings.json`. Worth verifying
  against a real Amp install before shipping, since other search snippets
  have (incorrectly) suggested `%USERPROFILE%\.config\amp\settings.json`.
- **VS Code extension UI storage:** If the Amp VS Code extension stores its
  MCP servers in VS Code's own `settings.json` instead of (or in addition to)
  `~/.config/amp/settings.json`, users who manage MCP through the extension
  UI may not see servers added via `InstallMCPServer["Amp"]`. Worth spot
  checking in a real extension install; in the worst case we document the
  behavior and recommend restarting VS Code / Amp CLI after running
  `InstallMCPServer`.
- **Dotted key survival through JSON round-trip:** Confirm that
  `readRawJSONFile` / `writeRawJSONFile` preserve `"amp.mcpServers"` as a
  literal key (they should — these go through Wolfram's raw JSON which
  treats keys as opaque strings — but a round-trip test is warranted).
- **Workspace approval flow:** Amp requires explicit approval the first time
  an MCP server from `.amp/settings.json` runs. This is a runtime UX concern
  rather than an install concern, but it is worth mentioning in the user
  docs so people are not surprised when the server does not auto-start on
  first use.
- **Comment-friendly JSON (`settings.jsonc`):** The workspace-settings
  announcement mentions `.amp/settings.jsonc` as an accepted alternative.
  AgentTools currently writes strict JSON. We should either (a) only target
  `settings.json`, leaving any existing `settings.jsonc` untouched, or
  (b) explicitly detect and refuse to rewrite a `.jsonc` file to avoid
  clobbering user comments. Option (a) matches how VS Code support works.

## References

- [Amp Owner's Manual](https://ampcode.com/manual)
- [Amp MCP Setup Guide](https://github.com/sourcegraph/amp-examples-and-guides/blob/main/guides/mcp/amp-mcp-setup-guide.md)
- [Amp CLI Workspace Settings](https://ampcode.com/news/cli-workspace-settings)
- [Amp Shared Settings](https://ampcode.com/news/shared-settings)
- AgentTools: [`docs/mcp-clients.md`](../docs/mcp-clients.md) ("Adding Support for New Clients")
- AgentTools: [`Kernel/SupportedClients.wl`](../Kernel/SupportedClients.wl)
- AgentTools: [`Kernel/InstallMCPServer.wl`](../Kernel/InstallMCPServer.wl)
