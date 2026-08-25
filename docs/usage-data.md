# Usage Data

This document describes the anonymous usage data collected by the local MCP servers, how users control it, and how it is stored and submitted.

## Overview

To learn which AI environments (MCP clients) people use with the Wolfram tools and which tools and prompts get used, the built-in local MCP servers (`Wolfram`, `WolframAlpha`, `WolframLanguage`, and `WolframPacletDevelopment`) record basic usage data for each server session and submit it to Wolfram. The data is anonymous and never contains content: no tool arguments, prompt arguments, results, code, or queries.

Cloud-deployed servers (see [cloud-deployment.md](cloud-deployment.md)) do not collect usage data.

## What Is Recorded

For each local server session (one server process, from start to exit):

| Field | Description |
|-------|-------------|
| `MCPSessionID` | A random UUID assigned when the server starts (`$mcpSessionID`) |
| `ServerName` | The name of the MCP server, e.g. `"WolframLanguage"` |
| `ClientInformation` | The `params` of the client's `initialize` request: `clientInfo` (name and version of the MCP client), `protocolVersion`, and `capabilities`. `null` until `initialize` has been received |
| `Events` | One event per `tools/call` and `prompts/get` request (see below) |
| `PacletVersion` | The version of Wolfram/AgentTools |
| `WolframVersion` | `$Version` |
| `SystemID` | `$SystemID` |
| `LastUpdated` | `AbsoluteTime[TimeZone -> 0]` of the last change |

Each event has:

| Field | Description |
|-------|-------------|
| `Type` | `"ToolCall"` or `"PromptGet"` |
| `Name` | The name of the tool or prompt, or `null` if the request named a tool or prompt the server does not have (so arbitrary text can never end up in the data) |
| `Success` | Whether the request succeeded: `false` for tool errors (`isError`), JSON-RPC errors, and internal failures |
| `Timestamp` | `AbsoluteTime[TimeZone -> 0]` of the request |

Everything else in a request — in particular the `arguments` — is never looked at.

## When It Is Recorded

Whether a session is tracked is decided once, when the server starts (`initializeUsageData` in `Kernel/Server/UsageData.wl`):

1. If the `SUBMIT_USAGE_DATA` environment variable holds a boolean (`true`/`false`, case-insensitive; `yes`/`no`, `on`/`off`, and `1`/`0` are accepted too), that value wins.
2. Otherwise the session is tracked only if the server's `"EnableUsageData"` property is exactly `True`. The built-in servers set it (see `Kernel/DefaultServers.wl`); servers created with `CreateMCPServer` or defined by paclets do not have the property, so they are not tracked unless the environment variable says otherwise.

```wl
MCPServerObject["WolframLanguage"]["EnableUsageData"]  (* True *)
```

### Opting Out (or In)

`InstallMCPServer` — and therefore `DeployAgentTools`, which forwards all `InstallMCPServer` options — has a `"SubmitUsageData"` option:

| Value | Behavior |
|-------|----------|
| `Automatic` (default) | Nothing is added to the client configuration; the server's `"EnableUsageData"` property decides |
| `False` | Sets `SUBMIT_USAGE_DATA=false` in the server's environment: no usage data is recorded or submitted by that installation |
| `True` | Sets `SUBMIT_USAGE_DATA=true`: usage data is recorded even for a custom server |

```wl
InstallMCPServer["ClaudeCode", "WolframLanguage", "SubmitUsageData" -> False]
```

Any other value is rejected with `InstallMCPServer::InvalidSubmitUsageData`.

The system preferences panel built by `CreatePreferencesContent` (see [preferences-content.md](preferences-content.md)) has a checkbox, *Share anonymous usage data with Wolfram to help improve these tools*, which is checked by default. Unchecking it re-deploys the currently configured toolsets with `"SubmitUsageData" -> False` (keeping their other options) and applies to toolsets configured from the panel afterward; checking it again re-deploys them without the option.

Servers started by the test suite never track anything: `GetMCPEnvironment` in `Tests/MCPServerTestUtilities.wl` sets `SUBMIT_USAGE_DATA=false` for every test server.

## How It Is Stored

The session's data is written to `$rootPath/UsageData/<MCPSessionID>.wxf`, i.e. under `$UserBaseDirectory/ApplicationData/Wolfram/AgentTools/UsageData/`. The file is rewritten in full whenever the client information arrives or an event is added, so it always holds the complete session. At most 10,000 events are recorded per session.

A server session cannot know that it is over, and an MCP client may leave a server idle for a long time, so the file's modification time is kept current on purpose: a scheduled task in the server kernel (`SessionSubmit@ScheduledTask[...]`) touches the file once an hour. A session counts as finished once its file has not been modified for 24 hours.

## How It Is Submitted

Submission happens in later sessions. Ten seconds after any tracked server starts, a scheduled task submits every session file that has not been modified for 24 hours by POSTing the file's contents as JSON (`Content-Type: application/json`) to

```
https://www.wolframcloud.com/obj/wolframai-content/api/1.0/usage
```

and deletes the file once the endpoint has accepted it with a 2xx status. The JSON has exactly the fields listed above.

Only one process submits at a time: the scan runs under `WithLock` on `UsageData/Submit.lock`. A server that finds the lock taken skips its turn (it waits at most one second), and a lock left behind by a crashed process expires after ten minutes.

Failures are handled conservatively:

- A failed submission (for example, no network) keeps the file and stops the batch for this session; the remaining files are tried again by a later session.
- Files that could not be submitted for 30 days, and files that cannot be read, are deleted.
- Sessions that are not tracked (opted out, or a server without the property) never submit, delete, or create files.

Usage tracking must never interfere with the server: every hook is wrapped in `usageDataQuietly`, which logs a failure to the server log (`Log.wl`) and otherwise ignores it.

## Implementation

| File | Role |
|------|------|
| `Kernel/Server/UsageData.wl` | Session state, enabling logic, recording, the session file, the keep-alive task, and locked submission |
| `Kernel/Server/Local.wl` | Calls `initializeUsageData` when the server starts and `recordUsageData` after each handled request |
| `Kernel/Server/Server.wl` | Declares the session symbols and hooks shared with the local transport |
| `Kernel/DefaultServers.wl` | `"EnableUsageData" -> True` for the built-in servers |
| `Kernel/InstallMCPServer.wl` | The `"SubmitUsageData"` option and the `SUBMIT_USAGE_DATA` environment variable |
| `Kernel/PreferencesContent.wl` | The opt-out checkbox and re-deployment of configured toolsets |
| `Tests/UsageData.wlt` | Unit tests and server integration tests |

Session state lives in the `` Wolfram`AgentTools`Server` `` context: `$mcpSessionID`, `$mcpClientInformation`, `$usageEvents` (an `` Internal`Bag ``), and `$usageDataEnabled`. Tunable settings (endpoint, timeouts, intervals, limits) are file-scoped variables at the top of `Kernel/Server/UsageData.wl`.

## See Also

- [mcp-clients.md](mcp-clients.md) — The `"SubmitUsageData"` option and the `SUBMIT_USAGE_DATA` environment variable
- [servers.md](servers.md) — The built-in servers and their `"EnableUsageData"` property
- [preferences-content.md](preferences-content.md) — The opt-out checkbox in the preferences panel
- [Specs/UsageData.md](../Specs/UsageData.md) — Design specification
