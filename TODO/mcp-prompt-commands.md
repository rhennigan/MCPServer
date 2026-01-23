# Support MCP prompt commands

Add support for MCP prompt commands (e.g., `/mcp__WolframLanguage__Search "query"`) that return contextual information to help the LLM answer questions.

## References

- [MCP specification for prompts](https://modelcontextprotocol.io/specification/2025-11-25/server/prompts.md)
- [Claude Code MCP prompts documentation](https://code.claude.com/docs/en/mcp#use-mcp-prompts-as-commands)

## Specification

See [Specs/MCPPromptCommands.md](../Specs/MCPPromptCommands.md) for the detailed specification.

## Tasks

- [x] Create detailed specifications for this feature in the `Specs/` directory

**Phase 1: Core infrastructure**
- [x] Add error messages to `Kernel/Messages.wl`
- [x] Create `Kernel/Prompts/Prompts.wl` with `$DefaultMCPPrompts`
- [x] Create `Kernel/Prompts/Search.wl` with search prompt definitions
- [x] Update `Kernel/Main.wl` to export `$DefaultMCPPrompts` and contexts
- [x] Update `PacletInfo.wl` to include new symbol
- [x] Write and run tests for `$DefaultMCPPrompts`
- [x] Fix code until all tests pass (Checkpoint A)

**Phase 2: Property access and validation**
- [x] Update `Kernel/MCPServerObject.wl` for validation and property access
- [x] Write tests for `MCPServerObject[...]["PromptData"]`, validation, and other new functionality
- [x] Run full test suite and fix code until all tests pass (Checkpoint B)

**Phase 3: Protocol handling**
- [x] Update `Kernel/StartMCPServer.wl` for Function-type prompt handling
- [x] Write tests for `makePromptContent` with Function/Text types and other new functionality
- [x] Run full test suite and fix code until all tests pass (Checkpoint C)

**Phase 4: Server configuration**
- [ ] Update `Kernel/DefaultServers.wl` with MCPPrompts configurations
- [ ] Write and run full integration tests
- [ ] Run full test suite and fix code until all tests pass (Checkpoint D)

**Phase 5: Developer documentation**
- [ ] Create `docs/mcp-prompts.md` (how prompts work, how to add new ones)
- [ ] Update `AGENTS.md` with links to new documentation