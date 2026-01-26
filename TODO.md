# TODO

Consolidated list of TODO/FIXME items from the codebase.

## Server Features

- [ ] Support "Remote" type for server deployment (deploy as cloud API)
  - Source: `Kernel/CreateMCPServer.wl`
- [ ] Add `Initialization` option to `CreateMCPServer`
  - Source: `Kernel/CreateMCPServer.wl`
- [ ] Add `ProcessDirectory` option to `InstallMCPServer` ([See Issue #69](https://github.com/rhennigan/MCPServer/issues/69))

## MCP Protocol Support

- [ ] Query client roots and set directory appropriately
  - Source: `Kernel/StartMCPServer.wl`
  - Spec: https://modelcontextprotocol.io/specification/2025-11-25/client/roots#protocol-messages
- [ ] Support logging capability
  - Source: `Kernel/StartMCPServer.wl`
- [ ] Support resources capability
  - Source: `Kernel/StartMCPServer.wl`
- [ ] Support image outputs from tools according to MCP spec
  - Source: `Kernel/Tools/Tools.wl`

## Tools

### New Tools

- [ ] Implement `CodeInspector` tool
  - Source: `Kernel/Tools/Tools.wl`
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
- [ ] Return multimodal content in tool results when appropriate
  - Source: `Kernel/StartMCPServer.wl`
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

- [ ] Add message handler to log messages to a file
  - Source: `Kernel/StartMCPServer.wl`
- [ ] Include information about the current MCP server in bug reports
  - Source: `Kernel/Common.wl`
- [ ] Remove empty "Settings" section from bug reports (this paclet has no settings)
  - Source: `Kernel/Common.wl`

## Blocked / Dependencies

- [ ] Expose `$includeDefinitions` as an option in `WolframLanguageToolEvaluate`
  - Source: `Kernel/Tools/WolframLanguageEvaluator.wl`

- [ ] WolframAlpha multiple queries support
  - Blocked on: Next Chatbook paclet update
  - Source: `Kernel/Tools/WolframAlpha.wl`
  - Test to enable: `Tests/Tools.wlt`
