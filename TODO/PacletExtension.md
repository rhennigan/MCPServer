# Paclet Extension — TODO

Tasks for implementing the [Paclet Extension specification](../Specs/PacletExtension.md).
Each item is a logical unit of work for one coding session.

---

- [x] **1. Add shared symbols, exports, and error messages**

  Declare new shared symbols in `CommonSymbols.wl`, add exports and subcontexts in `Main.wl`, update `PacletInfo.wl` symbols list, and add all new error messages to `Messages.wl`.

  **Files:** `Kernel/CommonSymbols.wl`, `Kernel/Main.wl`, `PacletInfo.wl`, `Kernel/Messages.wl`

---

- [x] **2. Implement core PacletExtension.wl — name parsing and paclet discovery**

  Create `Kernel/PacletExtension.wl` with `pacletQualifiedNameQ`, `parsePacletQualifiedName`, and `findMCPPaclets`. Write tests.

  **Files:** `Kernel/PacletExtension.wl`, `Tests/PacletExtension.wlt`

---

- [x] **3. Implement PacletExtension.wl — definition file loading and resolution**

  Extend `Kernel/PacletExtension.wl` with `loadPacletDefinitionFile`, `resolvePacletTool`, `resolvePacletServer`, `resolvePacletPrompt`, and session-level caching. Tests need a mock paclet directory structure with sample definition files.

  **Files:** `Kernel/PacletExtension.wl`, `Tests/PacletExtension.wlt`

---

- [x] **4. Update MCPServerObject.wl — paclet-backed server metadata and properties**

  Add `_PacletObject` as valid `"Location"` in `$$metadata`, add `"ToolNames"`/`"PromptNames"` to `$specialProperties`, add `_PacletObject` cases to `mcpServerExistsQ` and `deleteMCPServer`, extend `getMCPServerObjectByName` with paclet server resolution (installed + remote). Write tests.

  **Files:** `Kernel/MCPServerObject.wl`, `Tests/MCPServerObject.wlt`

---

- [x] **5. Update MCPServerObject.wl — paclet tool/prompt string resolution**

  Extend `convertStringTools0`, `normalizePromptData`, `validateMCPPrompt`, `validateTool`, and `getToolList` to handle `/`-containing paclet-qualified names. Write tests.

  **Files:** `Kernel/MCPServerObject.wl`, `Tests/MCPServerObject.wlt`

---

- [x] **6. Extend MCPServerObjects with paclet server listing and options**

  Add installed paclet servers to default listing. Add `"IncludeBuiltIn"`, `"IncludeRemotePaclets"`, and `UpdatePacletSites` options. Extend function signature to accept options alongside the pattern argument. Write tests.

  **Files:** `Kernel/MCPServerObject.wl`, `Tests/MCPServerObject.wlt`

---

- [x] **7. Update CreateMCPServer.wl — store paclet-qualified names as strings**

  Ensure `/`-containing tool name strings pass through validation and `convertStringTools` without resolution, and are preserved as-is in `Metadata.wxf`. Write tests.

  **Files:** `Kernel/CreateMCPServer.wl`, `Tests/CreateMCPServer.wlt`

---

- [x] **8. Update InstallMCPServer.wl — support paclet-qualified server names**

  Handle paclet-qualified server names: auto-install via `PacletInstall`, full validation at install time (load definitions, verify tools/prompts), surface errors immediately. Store names as strings in config. Write tests.

  **Files:** `Kernel/InstallMCPServer.wl`, `Tests/InstallMCPServer.wlt`

---

- [x] **9. Update StartMCPServer.wl — resolve paclet references and run tool initialization**

  Fully resolve all paclet references at start time. Behavioral change: run `"Initialization"` code for all tools at startup (not just at install time). Write tests.

  **Files:** `Kernel/StartMCPServer.wl`, `Tests/StartMCPServer.wlt`

---

- [x] **10. Implement MCP name collision disambiguation in StartMCPServer.wl**

  After loading all tools, detect duplicate MCP-exposed names and append numeric suffixes. Maintain mapping from disambiguated names back to original keys for `tools/call` routing. Write tests.

  **Files:** `Kernel/StartMCPServer.wl`, `Tests/StartMCPServer.wlt`

---

- [x] **11. Implement ValidateMCPPacletExtension.wl**

  Create `Kernel/ValidateMCPPacletExtension.wl` with all four validation check categories: extension structure, file existence, file contents, and cross-references. Return `Success`/`Failure` as specified. Write tests using mock paclets.

  **Files:** `Kernel/ValidateMCPPacletExtension.wl`, `Tests/ValidateMCPPacletExtension.wlt`
