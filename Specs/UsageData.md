# Usage Data — Design Specification

## Overview

Basic, anonymous usage tracking for the built-in local MCP servers, so that we can learn which MCP clients people use (to prioritize client support) and which tools and prompts get used (to understand feature usage). Nothing about the *content* of a session is ever recorded.

User-facing documentation: [docs/usage-data.md](../docs/usage-data.md).

## Goals

- Record, per local server session, the client information from `initialize` and one event per `tools/call` and `prompts/get` request (name, success, timestamp).
- Never record tool or prompt arguments, results, or any other content.
- Enabled by default for the built-in servers; easy to opt out, both programmatically and from the preferences UI.
- Submit each session's data once, after the session is over, without hitting the endpoint on every request.
- Never interfere with the server: tracking failures are invisible to the client.
- No tracking for cloud-deployed servers (stateless per request) and none from the test suite.

## What Gets Tracked

Client information: the `params` of the `initialize` request (`clientInfo`, `protocolVersion`, `capabilities`).

Events, for `tools/call` and `prompts/get` only:

```wl
<| "Type" -> "ToolCall" | "PromptGet", "Name" -> name | Null, "Success" -> True | False, "Timestamp" -> AbsoluteTime[ TimeZone -> 0 ] |>
```

- `Name` is the requested name only if the server actually has a tool/prompt of that name; otherwise `Null`. A hallucinated name is arbitrary model-generated text and must not be recorded.
- `Success` is `False` for a tool result with `"isError" -> True`, a JSON-RPC error response, or an internal failure.

## When to Track

- `InstallMCPServer` gets a `"SubmitUsageData"` option (default `Automatic`). `True`/`False` write `SUBMIT_USAGE_DATA=true|false` into the server's environment in the MCP configuration; `Automatic` writes nothing. Other values fail with `InvalidSubmitUsageData`. `DeployAgentTools` forwards the option like every other `InstallMCPServer` option and records it with the deployment.
- The built-in servers get `"EnableUsageData" -> True` in their metadata.
- At server start: if `SUBMIT_USAGE_DATA` holds a boolean, it wins (an explicit `True` also tracks custom servers, an explicit `False` opts a built-in server out); otherwise the server's `"EnableUsageData"` property must be exactly `True`.
- `CreatePreferencesContent` shows a checkbox (checked by default) whose state is stored in `CurrentValue[$FrontEnd, {PrivateFrontEndOptions, "InterfaceSettings", "ServicesForAIs", "SubmitUsageData"}]`. Checked adds nothing to deployments (`Automatic`); unchecked adds `"SubmitUsageData" -> False`. Toggling re-deploys every existing deployment of a built-in toolset, preserving its other options, so the change takes effect without re-configuring each client; the re-deployment runs as a session task rather than in the checkbox's preemptive evaluation.
- Development-mode servers are tracked like any other built-in server. Test servers are not: `GetMCPEnvironment` sets `SUBMIT_USAGE_DATA=false`.

## How It Is Tracked

Session state (`` Wolfram`AgentTools`Server` `` context, defined in `Kernel/Server/UsageData.wl`):

| Symbol | Value |
|--------|-------|
| `$mcpSessionID` | A UUID assigned by `initializeUsageData` when the local server starts; persists for the kernel session |
| `$mcpClientInformation` | `Null` until `initialize` is received, then `msg["params"]` |
| `$usageEvents` | An `` Internal`Bag `` of events |
| `$usageDataEnabled` | Whether this session is tracked |

The session file is `$rootPath/UsageData/<$mcpSessionID>.wxf`, holding

```wl
<|
    "MCPSessionID"      -> $mcpSessionID,
    "ServerName"        -> name,
    "ClientInformation" -> $mcpClientInformation,
    "Events"            -> Internal`BagPart[ $usageEvents, All ],
    "PacletVersion"     -> $pacletVersion,
    "WolframVersion"    -> $Version,
    "SystemID"          -> $SystemID,
    "LastUpdated"       -> AbsoluteTime[ TimeZone -> 0 ]
|>
```

The file is overwritten whenever the client information is set or an event is added. Events are capped at 10,000 per session.

Hooks in the local transport (`Kernel/Server/Local.wl`): `initializeUsageData @ $currentMCPServer` once the server state is built, and `recordUsageData[ method, message, response ]` in `processRequest` after each request has been handled. Both are no-ops when tracking is disabled, and both are wrapped in `usageDataQuietly` (`Quiet @ catchAlways`, logging failures to `Log.wl`) so that nothing can propagate to the read loop.

## Where and When It Is Sent

Endpoint: `https://www.wolframcloud.com/obj/wolframai-content/api/1.0/usage`, POST with the session data as a JSON body (`Content-Type: application/json`). A 2xx status means accepted. (The endpoint currently only checks that the body is JSON.)

We cannot know when a session's last message has arrived, so sessions are submitted by later sessions:

- The session file's modification time doubles as the liveness signal. Because a client can be idle for a long time, a `SessionSubmit@ScheduledTask` in the server kernel touches the file (`SetFileDate`) every hour. Scheduled tasks do fire while the kernel is blocked in `InputString[""]` on stdin (verified for both the `wolfram -run` and the `wolframscript -f` launch styles).
- A file that has not been modified for 24 hours belongs to a finished session. Ten seconds after a tracked server starts, a one-shot task submits all such files (oldest first) and deletes each one the endpoint accepts.
- `WithLock[ File[ "UsageData/Submit.lock" ], ..., TimeConstraint -> 1, PersistenceTime -> 600 ]` ensures only one process submits/deletes at a time; a process that cannot get the lock within a second skips its turn, and a stale lock from a dead process is broken after ten minutes.
- A failed submission keeps the file and stops the batch (the failure is most likely connectivity, which would affect the remaining files too). Files older than 30 days and unreadable files are discarded without submission, so that a permanently offline machine does not accumulate files forever.
- Untracked sessions never submit, delete, or create files.

## Files

| File | Change |
|------|--------|
| `Kernel/Server/UsageData.wl` | New: configuration, session state, `usageDataEnabledQ`, `initializeUsageData`, `recordUsageData`, session file, keep-alive task, locked submission |
| `Kernel/Server/Server.wl` | Declare the shared session symbols and hooks; load the new subcontext |
| `Kernel/Server/Local.wl` | Call the hooks |
| `Kernel/DefaultServers.wl` | `"EnableUsageData" -> True` on the four built-in servers |
| `Kernel/InstallMCPServer.wl` | `"SubmitUsageData"` option, validation, `SUBMIT_USAGE_DATA` in `addEnvironmentVariables` |
| `Kernel/Messages.wl` | `InvalidSubmitUsageData` |
| `Kernel/PreferencesContent.wl` | Checkbox, setting helpers, re-deployment; deployments from the panel pass the opt-out |
| `FrontEnd/Assets/AgentTools.wl` | `prefsSubmitUsageData` and `prefsSubmitUsageDataDescription` strings (English only until localized) |
| `Tests/UsageData.wlt` | Unit tests (enabling logic, recording, payload/JSON, keep-alive, staleness, locked submission with a stubbed HTTP call) and server integration tests |
| `Tests/InstallMCPServer.wlt`, `Tests/MCPServerObject.wlt`, `Tests/PreferencesContent.wlt` | Option, property, and panel tests |
| `Tests/MCPServerTestUtilities.wl` | `SUBMIT_USAGE_DATA=false` for test servers; `"Environment"` option of `StartMCPTestServer` |
| `docs/usage-data.md` and related docs | Documentation |

## Testing

- `usageDataEnabledQ`: property vs. environment precedence, non-boolean values ignored.
- `initializeUsageData`: session ID always assigned; tasks only when enabled; never fails startup.
- `recordUsageData`: client information, tool/prompt events, success/failure cases, unknown names recorded as `Null`, no arguments or results in the file, other methods ignored, disabled sessions record nothing, event cap, failure isolation.
- Payload JSON round trip.
- Keep-alive touch, stale-file detection (current session excluded).
- Submission with a stubbed `submitUsagePayload`: finished sessions submitted oldest first and deleted; fresh session kept; expired and unreadable files discarded; failure stops the batch; held lock skips; nonexistent directory.
- HTTP: unreachable endpoint returns `False`; the development endpoint accepts a JSON body (skipped on GitHub Actions).
- Integration (skipped when running as a script, like `StartMCPServer.wlt`): a real dev-mode server with `SUBMIT_USAGE_DATA=true` writes the expected file; one with the default test environment writes nothing.
