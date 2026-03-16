# Paclet Extension — TODO

Tasks for implementing the [Paclet Extension specification](../Specs/PacletExtension.md).
Each item is a logical unit of work for one coding session.

---

- [x] **1. Add shared symbols, exports, and error messages**

  Foundation task that all other work depends on. Declare the new shared symbols
  in `CommonSymbols.wl` (`resolvePacletTool`, `resolvePacletServer`,
  `resolvePacletPrompt`, `pacletQualifiedNameQ`, `parsePacletQualifiedName`,
  `findMCPPaclets`, `loadPacletDefinitionFile`). Add `ValidateMCPPacletExtension`
  to the exports in `Main.wl` and the Symbols list in `PacletInfo.wl`. Register
  new subcontexts `` Wolfram`MCPServer`PacletExtension` `` and
  `` Wolfram`MCPServer`ValidateMCPPacletExtension` `` in `$MCPServerContexts` in
  `Main.wl`. Add all 9 new error messages to `Messages.wl`:
  `PacletNotInstalled`, `PacletExtensionNotFound`, `PacletToolNotFound`,
  `PacletServerNotFound`, `PacletPromptNotFound`, `InvalidPacletToolDefinition`,
  `InvalidPacletServerDefinition`, `PacletDependencyMissing`,
  `InvalidMCPPacletExtension`, `DeletePacletMCPServer`. Use the exact message
  templates from the spec.

  **Files:** `Kernel/CommonSymbols.wl`, `Kernel/Main.wl`, `PacletInfo.wl`, `Kernel/Messages.wl`

---

- [ ] **2. Implement core PacletExtension.wl — name parsing and paclet discovery**

  Create `Kernel/PacletExtension.wl` with the foundational utilities. Implement:

  - `pacletQualifiedNameQ[name]` — returns `True` if `name` contains `/`
    (reserved for paclet-defined items).
  - `parsePacletQualifiedName[name]` — parses `"PacletName/ItemName"` or
    `"PublisherID/PacletShortName/ItemName"` into an association with keys
    `"PacletName"` and `"ItemName"`. Two-segment names have
    `"PacletName" -> "PacletName"`, three-segment names have
    `"PacletName" -> "PublisherID/PacletShortName"`.
  - `findMCPPaclets[]` — calls `Needs["PacletTools`"]` then uses
    `PacletTools`PacletExtensions` to discover all paclets declaring an `"MCP"`
    extension. Returns a list of `PacletObject`s.

  Write and run tests covering: name parsing for 2- and 3-segment names, invalid
  inputs, `pacletQualifiedNameQ` for names with and without `/`, and basic
  `findMCPPaclets` behavior (returns a list).

  **Files:** `Kernel/PacletExtension.wl`, `Tests/PacletExtension.wlt`

---

- [ ] **3. Implement PacletExtension.wl — definition file loading and resolution**

  Extend `Kernel/PacletExtension.wl` with definition file loading and resolution
  logic:

  - `loadPacletDefinitionFile[pacletObj, type, itemName]` — resolves and loads a
    definition file for an item. Uses `PacletTools`PacletExtensionDirectory` to
    find the root, then follows the resolution order: per-item file first
    (`<root>/<Type>/<ItemName>.(mx|wxf|wl)`), then combined file
    (`<root>/<Type>.(mx|wxf|wl)`) with key lookup. File format priority:
    `.mx` > `.wxf` > `.wl`. Returns the loaded association or throws a failure.
  - `resolvePacletTool[qualifiedName]` — parses the name, loads the tool
    definition file, constructs and returns an `LLMTool`.
  - `resolvePacletServer[qualifiedName]` — parses the name, loads the server
    definition file, applies intra-paclet name pre-qualification (rewriting short
    tool/prompt names in `"LLMEvaluator"` to fully qualified
    `"PacletName/ItemName"` form), returns the server metadata association.
  - `resolvePacletPrompt[qualifiedName]` — parses the name, loads the prompt
    definition file, returns the prompt data association.
  - Session-level caching for loaded definitions (with invalidation consideration).

  Write and run tests for file resolution order, per-item vs. combined file
  loading, intra-paclet name pre-qualification, and error cases (missing files,
  malformed definitions). Tests will need a mock paclet directory structure with
  sample definition files.

  **Files:** `Kernel/PacletExtension.wl`, `Tests/PacletExtension.wlt`

---

- [ ] **4. Update MCPServerObject.wl — paclet-backed server metadata and properties**

  Modify `MCPServerObject.wl` to recognize and construct paclet-backed servers:

  - **`$$metadata` pattern** (~line 24): Add `_PacletObject` as a valid
    `"Location"` value alongside `_File? fileQ | "BuiltIn"`.
  - **`$specialProperties`** (~line 331): Add `"ToolNames"` and `"PromptNames"`.
    Implement their accessor logic — for installed paclets, derive from the
    server definition's `"LLMEvaluator"` lists; for uninstalled paclets, return
    `Failure["PacletNotInstalled", ...]`.
  - **`mcpServerExistsQ`** (~line 584): Add a `_PacletObject` case that checks
    via `PacletFind[paclet["Name"]]`.
  - **`deleteMCPServer`** (~line 531): Add a `_PacletObject` case that refuses
    deletion with `throwFailure["DeletePacletMCPServer", name]`, analogous to
    the existing `"BuiltIn"` case.
  - **`getMCPServerObjectByName`** (~line 179): Add paclet server resolution
    after built-in server lookup. For installed paclets, load the server
    definition file and construct full metadata. For uninstalled remote paclets
    (via `PacletFindRemote`), construct partial metadata from PacletInfo only.
    `"Location"` is `PacletObject[...]`.

  Write and run tests for: paclet server metadata construction, `"ToolNames"`
  and `"PromptNames"` properties, `mcpServerExistsQ` for paclet servers,
  `deleteMCPServer` refusal for paclet servers, and
  `getMCPServerObjectByName` resolution chain.

  **Files:** `Kernel/MCPServerObject.wl`, `Tests/MCPServerObject.wlt`

---

- [ ] **5. Update MCPServerObject.wl — paclet tool/prompt string resolution**

  Modify the tool and prompt resolution pipeline in `MCPServerObject.wl` to
  handle paclet-qualified names (strings containing `/`):

  - **`convertStringTools0`** (~line 498): Add a clause for
    `pacletQualifiedNameQ[name]` that routes to `resolvePacletTool[name]`.
    Built-in tools still take precedence for short names.
  - **`normalizePromptData`** (~line 378): Add `/`-containing name support that
    routes to `resolvePacletPrompt[name]`.
  - **`validateMCPPrompt`** (~line 164): Accept `/`-containing names without
    rejecting (currently rejects names not in `$DefaultMCPPrompts`).
  - **`validateTool`** (~line 141): Pass through `/`-containing strings without
    attempting immediate resolution.
  - **`getToolList`** (~line 412): Handle mixed lists of `LLMTool` objects and
    unresolved paclet-qualified strings, resolving strings at access time.

  Write and run tests for: `/`-containing name passthrough in validation,
  deferred resolution of paclet tool strings, mixed tool list handling, and
  prompt resolution for paclet-qualified names.

  **Files:** `Kernel/MCPServerObject.wl`, `Tests/MCPServerObject.wlt`

---

- [ ] **6. Extend MCPServerObjects with paclet server listing and options**

  Extend `MCPServerObjects` (~line 593) to include paclet servers and accept new
  options:

  - Change the default behavior to return file-based + installed paclet servers
    (use `findMCPPaclets` to discover installed paclet servers).
  - Add option `"IncludeBuiltIn" -> False` to also include built-in servers from
    `$DefaultMCPServers`.
  - Add option `"IncludeRemotePaclets" -> False` to include uninstalled paclet
    servers discovered via `PacletFindRemote`.
  - Add option `UpdatePacletSites -> False` passed through to `PacletFindRemote`.
  - Extend the function signature to accept options:
    `MCPServerObjects[pattern: All | _String? StringQ : All, opts: OptionsPattern[]]`.

  Write and run tests for: default listing includes installed paclet servers,
  `"IncludeBuiltIn"` option, `"IncludeRemotePaclets"` option, and pattern
  filtering.

  **Files:** `Kernel/MCPServerObject.wl`, `Tests/MCPServerObject.wlt`

---

- [ ] **7. Update CreateMCPServer.wl — store paclet-qualified names as strings**

  Modify `CreateMCPServer` so paclet-qualified tool name strings (containing `/`)
  are stored as-is in `Metadata.wxf` without resolution:

  - The current flow `validateMCPServerObjectData` → `validateTools` →
    `convertStringTools` attempts resolution at creation time. Ensure
    `/`-containing strings pass through `convertStringTools` without triggering
    `convertStringTools0` resolution.
  - Verify that the validation pipeline accepts paclet-qualified strings without
    error.
  - Confirm that `Metadata.wxf` written by `createMCPServerData` (~line 151)
    preserves paclet-qualified strings.

  Write and run tests for: creating a server with paclet-qualified tool names,
  reading back the metadata to verify strings are preserved, and mixed tool lists
  (built-in resolved + paclet strings stored).

  **Files:** `Kernel/CreateMCPServer.wl`, `Tests/CreateMCPServer.wlt`

---

- [ ] **8. Update InstallMCPServer.wl — support paclet-qualified server names**

  Extend `InstallMCPServer` to handle paclet-qualified server names:

  - When a paclet-qualified server name is passed, automatically install the
    referenced paclet via `PacletInstall` if not already present.
  - Perform full validation at install time: load definition files for all
    paclet-qualified tool and prompt strings, verify each produces a valid
    `LLMTool` / prompt association, validate tool options.
  - Surface errors immediately (this is the user's interactive entry point).
  - The server configuration still stores paclet-qualified names as plain strings
    (not resolved objects), so paclet updates are picked up on next start.

  Write and run tests for: installing a server with paclet-qualified name,
  auto-install of referenced paclet, validation error surfacing, and config
  storage format.

  **Files:** `Kernel/InstallMCPServer.wl`, `Tests/InstallMCPServer.wlt`

---

- [ ] **9. Update StartMCPServer.wl — resolve paclet references and run tool initialization**

  Extend `StartMCPServer` to fully resolve paclet references at start time:

  - Install any referenced paclets that are not yet locally available (via
    `PacletInstall`).
  - Load definition files for all paclet-qualified tool and prompt strings.
  - Construct `LLMTool` objects and prompt data from loaded definitions.
  - **Behavioral change:** Run `"Initialization"` code for ALL tools at server
    startup (currently only done at install time by `InstallMCPServer` via
    `initializeTools`). This ensures initialization runs even when a server is
    started without a preceding `InstallMCPServer` call. Retain install-time
    initialization as-is for early validation.

  Write and run tests for: paclet tool resolution at start time, tool
  initialization execution at start time, handling of missing/failed paclet
  installs (`PacletDependencyMissing` error), and the start-time initialization
  behavioral change.

  **Files:** `Kernel/StartMCPServer.wl`, `Tests/StartMCPServer.wlt`

---

- [ ] **10. Implement MCP name collision disambiguation in StartMCPServer.wl**

  Add disambiguation logic to `StartMCPServer.wl` for MCP-exposed name
  collisions:

  - After all tool definitions are loaded into `LLMTool` objects, group tools by
    their MCP-exposed name (the `"Name"` field).
  - For any group with more than one tool, rename each to `name <> ToString[i]`
    where `i` is a sequential index starting at 1, ordered by position in the
    server's tool list.
  - Non-conflicting tools keep their original name.
  - Maintain a mapping from disambiguated MCP names back to original qualified
    tool keys so `tools/call` routes correctly.
  - This is a thin renaming layer — it modifies only the names sent over the MCP
    wire, not the underlying `LLMTool` objects.
  - Applies to all tools (built-in + paclet), not just paclet-defined ones.

  Write and run tests for: no-op when names are unique, numeric suffix
  disambiguation for duplicate names, correct routing of `tools/call` after
  renaming, and mixed built-in/paclet tool name collisions.

  **Files:** `Kernel/StartMCPServer.wl`, `Tests/StartMCPServer.wlt`

---

- [ ] **11. Implement ValidateMCPPacletExtension.wl**

  Create `Kernel/ValidateMCPPacletExtension.wl` with the exported
  `ValidateMCPPacletExtension` function:

  - **Extension structure validation:** PacletInfo contains `"MCP"` extension,
    uses valid keys (`"Root"`, `"Servers"`, `"Tools"`, `"Prompts"`), each item
    uses a valid declaration form (name-only, name+description, association).
  - **File existence:** Root directory exists, each declared item has a
    corresponding definition file (per-item or combined), warn on duplicate
    definition files for the same item.
  - **File contents** (installed paclets): Each definition file evaluates without
    error, server definitions produce valid associations with required keys, tool
    definitions can construct `LLMTool` objects, prompt definitions have required
    keys.
  - **Cross-references:** Tool/prompt names referenced by servers are declared in
    the same paclet or are valid fully qualified names.
  - Return `Success["ValidMCPPacletExtension", <|...|>]` on success or
    `Failure["InvalidMCPPacletExtension", <|"Errors" -> {...}|>]` on failure
    (with `throwFailure` for the message).

  Write and run tests using a mock paclet with valid/invalid extensions covering:
  structure validation, missing files, malformed definitions, cross-reference
  errors, and successful validation.

  **Files:** `Kernel/ValidateMCPPacletExtension.wl`, `Tests/ValidateMCPPacletExtension.wlt`
