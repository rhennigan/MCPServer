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
- [x] Update `Kernel/DefaultServers.wl` with MCPPrompts configurations
- [x] Write and run full integration tests
- [x] Run full test suite and fix code until all tests pass (Checkpoint D)

**Phase 5: Investigate MCP Error**
- [x] Investigate and fix "MCP error -32603: Internal error" that occurs when trying to use the prompt via MCP
    - Root cause: `relatedDocumentation`, `relatedWolframContext`, and `relatedWolframAlphaResults` were defined in private context and not accessible from `Prompts/Search.wl`
    - Fix: Added these symbols to `CommonSymbols.wl` so they're shared between packages
    - Also added error handling in `makePromptContent` to gracefully handle function failures
- [x] Write tests for the MCP error handling
- [x] Run full test suite and fix code until all tests pass (Checkpoint E)
- [x] Verify fix works (tested in Claude Desktop - works correctly; Claude Code has a client-side bug with argument parsing: https://github.com/anthropics/claude-code/issues/14210)

**Phase 6: Prompt Format Improvements**
- [x] Generated prompt should add explanatory text and indicate parts with xml-style tags
    Use the following format for the generated prompt:
    ```
    <search-query>{query}</search-query>
    <search-results>
    {results}
    </search-results>
    Use the above search results to answer the user's query below.
    <user-query>{query}</user-query>
    ```
    We repeat the query so the LLM can infer when something went wrong due to bugs like the Claude Code issue above.

- [x] Ensure the `MCPPromptCommands.md` specification is updated to reflect this change
- [x] Write tests for the new prompt format
- [x] Run full test suite and fix code until all tests pass (Checkpoint F)

**Phase 7: Developer documentation**
- [x] Create `docs/mcp-prompts.md` (how prompts work, how to add new ones)
- [x] Update `AGENTS.md` with links to new documentation