# More MCP Clients

For each MCP client, we need to properly research how MCP servers are added to the client and then decide if we can implement support for `InstallMCPServer` or if we need to reject it. If it's not feasible to implement a client, add text to the relevant section below to explain why.

## Research Instructions

1. For each MCP client, research how MCP servers are added to the client and write a detailed report in `MCPServer/client-research/client-name.md`.

2. Commit research results with an appropriate commit message and wait for user input to continue.

## Implementation Instructions

1. Implement support for `InstallMCPServer` for the client in `MCPServer/Kernel/InstallMCPServer.wl`.

2. Do not add any new aliases to `toInstallName` unless specifically requested.

3. When you've finished implementation, write appropriate unit tests and run them to ensure they pass.

4. When you've finished the tests, commit your changes with an appropriate commit message.

5. Update this file to mark the task as complete and wait for user input to continue.

## Clients

### [Windsurf](https://windsurf.com/)

- [x] Research how MCP servers are added to Windsurf and write a detailed report in `MCPServer/client-research/windsurf.md`
- [x] Implement support for `InstallMCPServer["Windsurf", ...]`

### [Cline](https://cline.bot/)

- [x] Research how MCP servers are added to Cline and write a detailed report in `MCPServer/client-research/cline.md`
- [x] Implement support for `InstallMCPServer["Cline", ...]`

### [Zed](https://zed.dev/)

- [x] Research how MCP servers are added to Zed and write a detailed report in `MCPServer/client-research/zed.md`
- [x] Implement support for `InstallMCPServer["Zed", ...]`

### [Goose](https://github.com/block/goose)

- [x] Research how MCP servers are added to Goose and write a detailed report in `MCPServer/client-research/goose.md`
- [ ] Do one of the following:
    - Implement support for `InstallMCPServer["Goose", ...]`
    - Reject support for `InstallMCPServer["Goose", ...]` if not feasible

### [Cherry Studio](https://github.com/CherryHQ/cherry-studio)

- [ ] Research how MCP servers are added to Cherry Studio and write a detailed report in `MCPServer/client-research/cherry-studio.md`
- [ ] Do one of the following:
    - Implement support for `InstallMCPServer["CherryStudio", ...]`
    - Reject support for `InstallMCPServer["CherryStudio", ...]` if not feasible

## On Hold

### [Continue](https://www.continue.dev/)

Requires a more complicated implementation due to the use of YAML files.

- [x] Research how MCP servers are added to Continue and write a detailed report in `MCPServer/client-research/continue.md`