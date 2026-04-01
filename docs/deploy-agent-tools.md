# Deploy Agent Tools

This document describes the deployment management system for deploying Wolfram tools to AI agent clients.

## Overview

`DeployAgentTools` provides a higher-level alternative to `InstallMCPServer` that tracks deployments as managed, reversible operations. Each deployment is represented as an `AgentToolsDeployment` object that can be inspected, listed, and deleted.

Three symbols are provided, all in the `System` context:

| Symbol | Description |
|--------|-------------|
| `DeployAgentTools[target]` | Create a tracked deployment |
| `AgentToolsDeployment[...]` | Object representing a deployment |
| `DeployedAgentTools[]` | List and query existing deployments |

In the current phase, `DeployAgentTools` wraps `InstallMCPServer` to deploy MCP server configurations. Future phases will extend it to install agent skills, hooks, and other components as part of a single deployment.

## DeployAgentTools

### Signatures

```wl
DeployAgentTools[target]
DeployAgentTools[target, server]
DeployAgentTools[target, server, opts]
```

### Arguments

| Argument | Type | Description |
|----------|------|-------------|
| `target` | `String`, `File[...]`, or `{String, dir}` | The client to deploy to (same target formats as `InstallMCPServer`) |
| `server` | `MCPServerObject`, `String`, or `Automatic` | The MCP server to deploy (defaults to `Automatic`, which resolves to the default `"Wolfram"` server) |

### Options

| Option | Default | Description |
|--------|---------|-------------|
| `OverwriteTarget` | `False` | If `True`, replace any existing deployment for the same target |

`DeployAgentTools` also accepts all `InstallMCPServer` options, which are passed through:

- `"ApplicationName"`, `"DevelopmentMode"`, `"EnableMCPApps"`, `"MCPServerName"`, `"ProcessEnvironment"`, `"ToolOptions"`, `"VerifyLLMKit"`

### Examples

```wl
(* Deploy to Claude Desktop with default server *)
dep = DeployAgentTools["ClaudeDesktop"]

(* Deploy a specific server to Cursor *)
dep = DeployAgentTools["Cursor", "WolframLanguage"]

(* Replace an existing deployment *)
dep = DeployAgentTools["ClaudeDesktop", OverwriteTarget -> True]

(* Project-level deployment *)
dep = DeployAgentTools[{"ClaudeCode", "/path/to/project"}]

(* Deploy with tool options *)
dep = DeployAgentTools["ClaudeCode",
    "ToolOptions" -> <|"WolframLanguageEvaluator" -> <|"Method" -> "Local"|>|>
]
```

### Behavior

1. Validates the target specification; issues `AgentTools::InvalidDeployTarget` for unrecognized forms
2. Resolves the target to a concrete config file path (same resolution as `InstallMCPServer`)
3. For `{name, dir}` targets, the directory is expanded to an absolute `File[...]` path in the stored deployment record
4. Checks for an existing deployment matching the config file; errors if one exists (unless `OverwriteTarget -> True`)
5. Calls `InstallMCPServer` with the resolved target and filtered options
6. Creates a persistent deployment record on disk
7. Returns an `AgentToolsDeployment` object

## AgentToolsDeployment

An `AgentToolsDeployment` wraps an association containing the deployment record.

### Properties

```wl
dep["PropertyName"]
dep["MCP", "Options"]
```

| Property | Returns |
|----------|---------|
| `"UUID"` | UUID string uniquely identifying the deployment |
| `"ClientName"` | Canonical client name (e.g. `"ClaudeDesktop"`) |
| `"Target"` | Original target specification |
| `"Server"` | Server name string (e.g. `"WolframLanguage"`) |
| `"ConfigFile"` | `File[...]` pointing to the client's config file |
| `"Timestamp"` | `DateObject` when the deployment was created |
| `"PacletVersion"` | Paclet version at deployment time |
| `"MCPServerObject"` | The `MCPServerObject` for the deployed server |
| `"Scope"` | Deployment scope: `"Global"` for named clients, or `File[...]` directory for project-level deployments |
| `"Tools"` | List of tools provided by the deployed server |
| `"LLMConfiguration"` | The `LLMConfiguration` for the deployed server |
| `"Data"` | Full internal data association |
| `"Location"` | `File[...]` deployment directory |
| `"Properties"` | List of all property names |

### Deleting Deployments

Use `DeleteObject` to remove a deployment:

```wl
DeleteObject[dep]
```

This:
1. Calls `UninstallMCPServer` to remove the server configuration from the client
2. Deletes the deployment record from disk

## DeployedAgentTools

### Signatures

```wl
DeployedAgentTools[]           (* all deployments *)
DeployedAgentTools["Client"]   (* filter by client name *)
```

### Examples

```wl
(* List all deployments *)
DeployedAgentTools[]
(* {AgentToolsDeployment[...], AgentToolsDeployment[...]} *)

(* Filter by client *)
DeployedAgentTools["ClaudeDesktop"]
(* {AgentToolsDeployment[...]} *)

(* Aliases are resolved *)
DeployedAgentTools["Claude"]  (* same as "ClaudeDesktop" *)
```

## Storage

Deployment records are stored as WXF files under:

```
$UserBaseDirectory/ApplicationData/Wolfram/AgentTools/Deployments/<ClientName>/<UUID>/Deployment.wxf
```

Deployments are grouped by canonical client name. There is no master index file — `DeployedAgentTools` scans the directory structure directly.

## Related Files

- `Kernel/DeployAgentTools.wl` - Implementation of `DeployAgentTools`, `AgentToolsDeployment`, and `DeployedAgentTools`
- `Kernel/InstallMCPServer.wl` - Underlying installation mechanism
- `Kernel/Formatting.wl` - Summary box formatting for `AgentToolsDeployment`
- `Kernel/Files.wl` - `$deploymentsPath` definition
- `Kernel/Messages.wl` - Error messages for deployment operations
- `Tests/DeployAgentTools.wlt` - Tests for the deployment system
- `Specs/DeployAgentTools.md` - Design specification

## Related Documentation

- [mcp-clients.md](mcp-clients.md) - Client installation and the `"MCPServerName"` option
- [servers.md](servers.md) - Predefined servers and the shared config key
- [tools.md](tools.md) - Available MCP tools
