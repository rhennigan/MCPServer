# TODO

Consolidated list of TODO/FIXME items from the codebase.

## Server Features

- [ ] Support "Remote" type for server deployment (deploy as cloud API)
  - Source: `Kernel/CreateMCPServer.wl`
- [ ] Add `Initialization` option to `CreateMCPServer`
  - Source: `Kernel/CreateMCPServer.wl`
- [ ] Add `ProcessDirectory` option to `InstallMCPServer` ([See Issue #69](https://github.com/rhennigan/MCPServer/issues/69))
- [x] Include all required environment variables in `makeJSONConfiguration`
  - Source: `Kernel/MCPServerObject.wl`
  - Should match `defaultEnvironment` from `InstallMCPServer.wl`

## MCP Protocol Support

- [ ] Query client roots and set directory appropriately
  - Source: `Kernel/StartMCPServer.wl`
  - Spec: https://modelcontextprotocol.io/specification/2025-11-25/client/roots#protocol-messages
- [ ] Support logging capability
  - Source: `Kernel/StartMCPServer.wl`
- [ ] Support resources capability
  - Source: `Kernel/StartMCPServer.wl`

## Tools

### New Tools

- [ ] Implement `BuildPaclet` tool
  - Source: `Kernel/Tools/Tools.wl`
- [ ] Implement `ReloadPaclet` tool
  - Source: `Kernel/Tools/Tools.wl`
- [ ] Implement `RestartMCPServer` tool (if possible)
  - Source: `Kernel/Tools/Tools.wl`
- [ ] Tool to open notebooks for the user (e.g., `UsingFrontEnd[SystemOpen[notebookPath]]`)
  - Source: `Kernel/Tools/Tools.wl`
  - Might be redundant, since the same can be trivially done with a Bash tool or even the WL tool itself
  - Maybe just add something to the WL tool description that mentions this can be done?

### Tool Improvements

- [ ] Log tool calls (and generate a notebook)
  - Source: `Kernel/Tools/Tools.wl`
- [ ] Add optional "description" parameter to evaluator tool (maybe all tools?)
  - Source: `Kernel/Tools/Tools.wl`
- [ ] Group similar tools and have another tool to activate them when needed (to save on token usage)
  - Source: `Kernel/Tools/Tools.wl`
- [ ] Documentation editing tools should have examples evaluation be optional
  - Source: `Kernel/Tools/Tools.wl`
- [ ] Implement `ReadableForm` in this paclet for better code formatting
  - Source: `Kernel/Tools/TestReport.wl`
- [ ] Show relative paths in CodeInspector output when inspecting directories
  - Source: `Kernel/Tools/CodeInspector/Formatting.wl`

## Prompts

- [ ] Implement `Documentation` prompt
  - Attaches full WL documentation pages as markdown

## UI & Formatting

- [ ] Show installations in formatted boxes
  - Source: `Kernel/Formatting.wl`
- [ ] Move icon definition to assets
  - Source: `Kernel/Formatting.wl`

## Logging & Diagnostics

- [ ] Create MCP server output log file at `$UserBaseDirectory/Logs/MCPServer/Output/`
  - Source: `Kernel/StartMCPServer.wl`
  - Redirect `$Output` and `$Messages` to the log file
  - Catch and redirect explicit `Write`/`WriteString`/`BinaryWrite` calls to stdout/stderr
- [ ] Include information about the current MCP server in bug reports
  - Source: `Kernel/Common.wl`

## Connect to External MCP Servers (Major Feature)

This is effectively what the paclet currently does, but we'll run it in reverse. Instead of `LLMConfiguration[...]` -> MCP server, we'll have a way to connect to an external MCP server and give a valid `LLMConfiguration`.

- [ ] Support connecting to local MCP servers
- [ ] Support connecting to remote MCP servers

## Blocked / Dependencies

- [ ] Expose `$includeDefinitions` as an option in `WolframLanguageToolEvaluate`
  - Source: `Kernel/Tools/WolframLanguageEvaluator.wl`

- [ ] WolframAlpha multiple queries support
  - Blocked on: Next Chatbook paclet update
  - Source: `Kernel/Tools/WolframAlpha.wl`
  - Test to enable: `Tests/Tools.wlt`
