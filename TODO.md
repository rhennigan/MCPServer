# TODO

Consolidated list of TODO/FIXME items from the codebase.

## Installation

- [x] Rename `$installName` to `$installClientName`
  - Source: `Kernel/InstallMCPServer.wl`
- [x] Use `"ConfigKey"` property in `$supportedMCPClients` to determine config structure in `installMCPServer`, `readExistingMCPConfig`, and `uninstallMCPServer`
  - Source: `Kernel/InstallMCPServer.wl`
- [x] Implement `guessClientNameFromJSON` to guess client name based on JSON structure
  - Source: `Kernel/InstallMCPServer.wl`
- [x] Fix `UninstallMCPServer[All, obj]`: `mcpServerInstallations` now returns a list of associations
  - Source: `Kernel/InstallMCPServer.wl`
- [x] Determine if `UninstallMCPServer[target_File, obj]` should use `guessClientName` instead of checking `.toml` extension
  - Source: `Kernel/InstallMCPServer.wl`
- [x] Fix ambiguity in `UninstallMCPServer[targets_List, obj]`: a list could also refer to a project-level installation
  - Source: `Kernel/InstallMCPServer.wl`
  - Removed. It was never documented, so it's not a breaking change.
- [x] `serverConverter` should be a property of the client rather than a hardcoded function
  - Source: `Kernel/InstallMCPServer.wl`
- [x] Add `"ApplicationName"` option to `InstallMCPServer` and `UninstallMCPServer` to let users specify `$installClientName` (default `Automatic` uses `guessClientName`)
  - Source: `Kernel/InstallMCPServer.wl`

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
- [x] Investigate MCP apps
  - Spec: https://modelcontextprotocol.io/extensions/apps/overview.md
  - Can we use this to display Wolfram Alpha tool call results in an iframe?
  - How about results of the WL evaluator that produces CloudObjects (e.g. CloudDeploy)?
  - Result: Implementation specification created at `Specs/MCPApps.md`
- [ ] Implement MCP Apps extension (see `Specs/MCPApps.md`)
  - Phase 1: Infrastructure (extension negotiation, UI resource registry, resource handlers, tool metadata)
  - Phase 2: WolframAlpha Interactive Viewer
  - Phase 3: WL Evaluator Interactive Viewer
  - Phase 4: App-Only Tools (optional)

## Tools

### New Tools

- [ ] Implement `CreateResourceFunction` tool
  - Should create a new resource function definition notebook
- [ ] Implement `EditResourceFunction` tool
  - Should edit an existing resource function definition notebook
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

- [ ] Tool options set via environment variables
  - Example: we already have `WOLFRAM_LANGUAGE_EVALUATOR_METHOD`. We could make a nice interface for this in InstallMCPServer.
  - We could also have a single environment variable that points to a file containing all the options for tools

- [ ] Support file inputs in the evaluator tool
  - Could use the existing "code" parameter or add a new "file" parameter (only one can be used at a time)
    - If using the "code" parameter, disambiguate between a file path and a code string by using the syntax `"file://path/to/file.wl"`
    - If using the "file" parameter, it should just be something like `"path/to/file.wl"`
  - Should effectively just call `Get["path/to/file.wl"]` in the evaluator tool
  - Update tool description to suggest this for large code inputs
  - Could also allow other URI schemes, such as `"http://..."`, `"https://..."`, `"ftp://..."`, etc.

- [ ] Support for `ResourceFunction["..."]` in the SymbolDefinition tool
  - May want a special compact syntax to represent these, e.g. `rf:NameOfFunction`
  - These can be cleanly generated from the original source code in the definition notebook:
    ```wl
    nb = Import[ ResourceFunction[ "BettiNumbers", "DefinitionNotebookObject" ], "NB" ];
    definitionCells = DeleteCases[ DefinitionNotebookClient`ScrapeSection[ nb, "Function" ], CellLabel -> _, Infinity ];
    ResourceFunction[ "ExportMarkdownString" ][ Notebook @ definitionCells ]
    ```

- [ ] Bug: Messages are not included in SymbolDefinition tool output
  ```wl
  In[1]:= MyFunction::test = "Test message, please ignore";
  In[2]:= MyFunction[x_] := x + 1;
  In[3]:= $DefaultMCPTools["SymbolDefinition"][<|"symbols" -> "MyFunction"|>]

  Out[3]= "# MyFunction

  ## Definition

  ```wl
  MyFunction[ x_ ] := x + 1
  ```"
  ```
  Use `Messages[MyFunction]` to get the list of messages

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

- [ ] New CodeInspector rules
  - [ ] Rule for `ReadString` with `CharacterEncoding` option
    - Bad:
    ```wl
    ReadString[file, CharacterEncoding -> "enc"]
    ```
    - Recommendation:
    ```wl
    ByteArrayToString[ReadByteArray[file], "enc"]
    ```
  - [ ] Rule for `Nothing` in associations
    - Nothing does not get dropped from the association:
      ```wl
      In[9]:= <|"a" -> 1, "b" -> Nothing|>

      Out[9]= <|"a" -> 1, "b" -> Nothing|>
      ```
  - [ ] Rule for `KeyExistsQ` with nested key paths
    - Valid, but likely a mistake (this does not represent a nested key path):
      ```wl
      KeyExistsQ[assoc, {"k1", "k2", ...}]
      ```
    - Recommendation:
      ```wl
      ! MissingQ @ assoc["k1", "k2", ...]
      ```

## Prompts

- [ ] Implement `Documentation` prompt
  - Attaches full WL documentation pages as markdown

## UI & Formatting

- [ ] Show installations in formatted boxes
  - Source: `Kernel/Formatting.wl`
- [ ] Move icon definition to assets
  - Source: `Kernel/Formatting.wl`

## Logging & Diagnostics

- [x] Create MCP server output log file at `$UserBaseDirectory/Logs/MCPServer/Output/`
  - Source: `Kernel/StartMCPServer.wl`
  - Redirect `$Output` and `$Messages` to the log file
  - Note: Intercepting explicit `Write`/`WriteString`/`BinaryWrite` calls deferred to future work
- [ ] Include information about the current MCP server in bug reports
  - Source: `Kernel/Common.wl`

## Connect to External MCP Servers (Major Feature)

This is effectively what the paclet currently does, but we'll run it in reverse. Instead of `LLMConfiguration[...]` -> MCP server, we'll have a way to connect to an external MCP server and give a valid `LLMConfiguration`.

- [ ] Support connecting to local MCP servers
- [ ] Support connecting to remote MCP servers

## Agent Skills

Create distributable agent skills that use functionality from this paclet.

- [ ] Testing
  - Instructions:
    - writing tests
    - running tests
    - inspecting code
  - Scripts:
    - `TestReport.wls [path/to/Tests/]`
    - `CodeInspect.wls [path/to/Code/]`

- [ ] Paclet Building
  - Instructions:
    - checking the paclet
    - building the paclet
    - submitting the paclet
  - Scripts:
    - `CheckPaclet.wls [path/to/Paclet/]`
    - `BuildPaclet.wls [path/to/Paclet/]`
    - `SubmitPaclet.wls [path/to/Paclet/]`

- [ ] Paclet Optimization
  - Instructions:
    - MX builds
    - compiled functions

- [ ] Creating New Paclets
  - Instructions:
    - layout guidelines
    - naming conventions
    - documentation guidelines
  - Scripts:
    - `NewPaclet.wls [path/to/NewPaclet/]`

- [ ] Documentation
  - Instructions:
    - writing paclet documentation
    - building paclet documentation
  - Scripts:
    - `CreateDocumentation.wls [path/to/Documentation/]`
    - `BuildDocumentation.wls [path/to/Documentation/]`

## Blocked / Dependencies

- [ ] Expose `$includeDefinitions` as an option in `WolframLanguageToolEvaluate`
  - Source: `Kernel/Tools/WolframLanguageEvaluator.wl`

- [ ] WolframAlpha multiple queries support
  - Blocked on: Next Chatbook paclet update
  - Source: `Kernel/Tools/WolframAlpha.wl`
  - Test to enable: `Tests/Tools.wlt`
