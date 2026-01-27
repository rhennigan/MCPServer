# More MCP Clients

For each MCP client, we need to properly research how MCP servers are added to the client and then decide if we can implement support for `InstallMCPServer` or if we need to reject it. When implementing support, it should be done on a branch dedicated to that particular MCP client, e.g. `feature/windsurf-client-support`. If it's not feasible to implement, add text to the relevant section below to explain why.

## [Windsurf](https://windsurf.com/)

- [ ] Research how MCP servers are added to Windsurf and write a detailed report in client-research/windsurf.md
- [ ] Do one of the following:
    - Implement support for `InstallMCPServer["Windsurf", ...]`
    - Reject support for `InstallMCPServer["Windsurf", ...]` if not feasible

## [Cline](https://cline.bot/)

- [ ] Research how MCP servers are added to Cline and write a detailed report in client-research/cline.md
- [ ] Do one of the following:
    - Implement support for `InstallMCPServer["Cline", ...]`
    - Reject support for `InstallMCPServer["Cline", ...]` if not feasible

## [Continue](https://www.continue.dev/)

- [ ] Research how MCP servers are added to Continue and write a detailed report in client-research/continue.md
- [ ] Do one of the following:
    - Implement support for `InstallMCPServer["Continue", ...]`
    - Reject support for `InstallMCPServer["Continue", ...]` if not feasible

## [Zed](https://zed.dev/)

- [ ] Research how MCP servers are added to Zed and write a detailed report in client-research/zed.md
- [ ] Do one of the following:
    - Implement support for `InstallMCPServer["Zed", ...]`
    - Reject support for `InstallMCPServer["Zed", ...]` if not feasible

## [Goose](https://github.com/block/goose)

- [ ] Research how MCP servers are added to Goose and write a detailed report in client-research/goose.md
- [ ] Do one of the following:
    - Implement support for `InstallMCPServer["Goose", ...]`
    - Reject support for `InstallMCPServer["Goose", ...]` if not feasible

## [Cherry Studio](https://github.com/CherryHQ/cherry-studio)

- [ ] Research how MCP servers are added to Cherry Studio and write a detailed report in client-research/cherry-studio.md
- [ ] Do one of the following:
    - Implement support for `InstallMCPServer["Cherry Studio", ...]`
    - Reject support for `InstallMCPServer["Cherry Studio", ...]` if not feasible