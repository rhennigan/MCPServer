# Support MCP prompt commands

Add support for MCP prompt commands (e.g., `/mcp__WolframLanguage__Search "query"`) that return contextual information to help the LLM answer questions.

## References

- [MCP specification for prompts](https://modelcontextprotocol.io/specification/2025-11-25/server/prompts.md)
- [Claude Code MCP prompts documentation](https://code.claude.com/docs/en/mcp#use-mcp-prompts-as-commands)

## Specification

See [Specs/MCPPromptCommands.md](../Specs/MCPPromptCommands.md) for the detailed specification.

## Plan

Implementation order (see specification for details):

**Phase 1: Core infrastructure**

1. Add error messages to `Kernel/Messages.wl`
2. Create `Kernel/Prompts/Prompts.wl`
3. Create `Kernel/Prompts/Search.wl`
4. Update `Kernel/Main.wl` (exports and contexts)
5. Update `PacletInfo.wl` (symbols list)

**Checkpoint A: Test $DefaultMCPPrompts**

6. Write tests for `$DefaultMCPPrompts` structure and prompt properties
7. Run tests to verify prompt definitions load correctly

**Phase 2: Property access and validation**

8. Update `Kernel/MCPServerObject.wl` (validation and getPromptData)

**Checkpoint B: Test MCPServerObject integration**

9. Write tests for `MCPServerObject[...]["PromptData"]` and validation
10. Run tests to verify property access works

**Phase 3: Protocol handling**

11. Update `Kernel/StartMCPServer.wl` (makePromptContent and makePromptData)

**Checkpoint C: Test prompt content generation**

12. Write tests for `makePromptContent` with Function/Text types
13. Run tests to verify content generation works

**Phase 4: Server configuration**

14. Update `Kernel/DefaultServers.wl` (add MCPPrompts to each server)

**Checkpoint D: Full integration tests**

15. Write tests for full server integration (prompts in default servers)
16. Run full test suite and verify no regressions

## Tasks

- [x] Create detailed specifications for this feature in the `Specs/` directory

**Phase 1: Core infrastructure**
- [ ] Add error messages to `Kernel/Messages.wl`
- [ ] Create `Kernel/Prompts/Prompts.wl` with `$DefaultMCPPrompts`
- [ ] Create `Kernel/Prompts/Search.wl` with search prompt definitions
- [ ] Update `Kernel/Main.wl` to export `$DefaultMCPPrompts`
- [ ] Update `PacletInfo.wl` to include new symbol
- [ ] Write and run tests for `$DefaultMCPPrompts` (Checkpoint A)

**Phase 2: Property access and validation**
- [ ] Update `Kernel/MCPServerObject.wl` for validation and property access
- [ ] Write and run tests for MCPServerObject integration (Checkpoint B)

**Phase 3: Protocol handling**
- [ ] Update `Kernel/StartMCPServer.wl` for Function-type prompt handling
- [ ] Write and run tests for prompt content generation (Checkpoint C)

**Phase 4: Server configuration**
- [ ] Update `Kernel/DefaultServers.wl` with MCPPrompts configurations
- [ ] Write and run full integration tests (Checkpoint D)