# Support MCP prompt commands

- [MCP documentation for prompts](https://modelcontextprotocol.io/specification/2025-11-25/server/prompts.md)
- [Relevant Claude Code documentation](https://code.claude.com/docs/en/mcp#use-mcp-prompts-as-commands)

## Basic Idea

We want to support something like this in Claude Code inputs:
```text
/mcp__{serverName}__Search "{query}"
```

The prompt we would return would be something like:
```wl
generateSearchPrompt[ query_String ] := Wolfram`Chatbook`RelatedDocumentation[ query, "Prompt" ] <> "\n\n" <> query;
```

Example input in Claude Code:
```text
/mcp__WolframLanguage__Search "How can I find the 123456789th prime number?"
```

## MCP Spec for Prompts

```json
{
  name: string;              // Unique identifier for the prompt
  description?: string;      // Human-readable description
  arguments?: [              // Optional list of arguments
    {
      name: string;          // Argument identifier
      description?: string;  // Argument description
      required?: boolean;    // Whether argument is required
    }
  ]
}
```

Issue: `LLMConfiguration[...]` does not have an analogous property that fits this. It accepts a "Prompts" property, but the values are expected to be strings, or templates that evaluate to strings. This does not leave room for name, description, or arguments.

`LLMConfiguration` will let you add arbitrary properties to the configuration, so we implemented an initial prototype using the "PromptData" property:

```wl
CreateMCPServer[ "MyServer", LLMConfiguration[ <|
    "PromptData" -> {
        <|
            "Name" -> "Test Prompt",
            "Description" -> "This prompt is for testing arguments",
            "Arguments" -> {
                <|
                    "name"        -> "first",
                    "description" -> "This is the first argument",
                    "required"    -> True
                |>,
                <|
                    "name"        -> "second",
                    "description" -> "This is an optional second argument",
                    "required"    -> False
                |>
            },
            "Content" -> StringTemplate[
                "Test prompt, please ignore.\nFirst argument: `first`\nSecond argument: `second`"
            ]
        |>,
        ...
    }
|> ] ]
```

This approach works, but "PromptData" is not a very good name. We need to come up with a better name.

## Initial Thoughts

- In `Kernel/StartMCPServer.wl`:
    - Would need to be advertised properly in response to a `prompts/list` request
    - Would need to be generated properly in response to a `prompts/get` request

- We probably want to create a new file `Kernel/Prompts.wl` where these are defined
    - Would be similar to how tools are organized

- "name", "description", and "arguments" should be capitalized on the WL side (not yet implemented)

- "Content" works for strings and templates, but we also want a way to pass a function. Should we add a different property for this? Maybe "Function"? Alternatively, use "Content" and add a "Type" property that can be "Function", "Text", or `Automatic` (default). Use sensible heuristics to determine the type based on the content.

- The actual search prompt name and function should be specific to the MCP server name, similar to how the Wolfram*Context tools are:
    - WolframLanguage: Gives `RelatedDocumentation` (like the "WolframLanguageContext" tool)
    - WolframAlpha: Gives `RelatedWolframAlphaResults` (like the "WolframAlphaContext" tool)
    - Wolfram: Gives a combination of `RelatedDocumentation` and `RelatedWolframAlphaResults` (like the "WolframContext" tool)

- Possible names for the different types:
    - "Documentation" -> `/mcp__WolframLanguage__Documentation "{query}"`
    - "WolframAlpha" -> `/mcp__WolframAlpha__WolframAlpha "{query}"` (this seems awkward)
    - "Search" -> `/mcp__Wolfram__Search "{query}"` (this is nice)

- Could we use the same name for all three and still have it do different things depending on the server name? We could use the same name in the "Name" property of the MCP prompt, but we could define them differently in source code.

- We should define a `$DefaultMCPPrompts` similar to how we define `$DefaultMCPTools` for tools.

- What other prompts should we define by default? We can add these later as needed.

## Specification

See [Specs/MCPPromptCommands.md](../Specs/MCPPromptCommands.md) for the detailed specification.

## Plan

Implementation order (see specification for details):

1. Add error messages to `Kernel/Messages.wl`
2. Create `Kernel/Prompts/Prompts.wl`
3. Create `Kernel/Prompts/Search.wl`
4. Update `Kernel/Main.wl` (exports and contexts)
5. Update `PacletInfo.wl` (symbols list)
6. Update `Kernel/MCPServerObject.wl` (validation and getPromptData)
7. Update `Kernel/StartMCPServer.wl` (makePromptContent and makePromptData)
8. Update `Kernel/DefaultServers.wl` (add MCPPrompts to each server)
9. Create `Tests/Prompts.wlt`
10. Run full test suite

## Tasks

- [x] Create detailed specifications for this feature in the `Specs/` directory
- [ ] Add error messages to `Kernel/Messages.wl`
- [ ] Create `Kernel/Prompts/Prompts.wl` with `$DefaultMCPPrompts`
- [ ] Create `Kernel/Prompts/Search.wl` with search prompt definitions
- [ ] Update `Kernel/Main.wl` to export `$DefaultMCPPrompts`
- [ ] Update `PacletInfo.wl` to include new symbol
- [ ] Update `Kernel/MCPServerObject.wl` for validation and property access
- [ ] Update `Kernel/StartMCPServer.wl` for Function-type prompt handling
- [ ] Update `Kernel/DefaultServers.wl` with MCPPrompts configurations
- [ ] Create `Tests/Prompts.wlt` with unit tests
- [ ] Run full test suite and verify no regressions