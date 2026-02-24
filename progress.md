# Progress

Append concise notes about your progress to this file (don't remove existing notes). Include the following types of information:

- What was achieved during this session
- Anything you learned that would be helpful to others resuming your work

Use the following format incrementing the session number from the latest entry:

## Session 1

Completed scaffolding for MCP Apps (Phase 1.6/1.7/1.8 from spec):

- Created `Assets/Apps/` directory with placeholder HTML and JSON files for both viewers
- Created `Kernel/UIResources.wl` with full package skeleton containing:
  - `$toolUIAssociations` config mapping tool names to UI resource URIs
  - `clientSupportsUIQ` to check client capabilities
  - `initializeUIResources` to load HTML apps from paclet assets at startup
  - `loadUIResource` to read individual HTML + JSON metadata files
  - `listUIResources` to return resource list (empty for non-UI clients)
  - `readUIResource` to serve HTML content for `resources/read` requests
  - `toolUIMetadata` to attach `_meta.ui` to tools for UI-capable clients
- Added 9 new shared symbols to `CommonSymbols.wl`
- Added 3 new error messages to `Messages.wl`
- Registered `Apps` asset location in `PacletInfo.wl`
- Added `UIResources` context to `Main.wl`
- Created `Tests/MCPApps.wlt` with initial boilerplate

Key design notes:
- All new functions live in `Kernel/UIResources.wl` (context ``Wolfram`MCPServer`UIResources` ``)
- Symbols are declared in `CommonSymbols.wl` so `StartMCPServer.wl` can reference them
- The next tasks (extension negotiation, resource handlers, tool metadata) will modify `StartMCPServer.wl` to call these functions

## Session 2

Completed extension negotiation (Phase 1.1 from spec):

- Modified `handleMethod["initialize", ...]` in `StartMCPServer.wl` to:
  - Set `$clientSupportsUI` flag via `clientSupportsUIQ` when processing client initialize message
  - Compute init response dynamically via `initResponse[$currentMCPServer, msg]` instead of pre-computed `$initResult`
- Refactored `startMCPServer` to remove pre-computed `$initResult` from Block scope
- Added `initializeUIResources[]` call at startup (before main loop)
- Added new `initResponse` overloads:
  - `initResponse[obj, clientMsg]` - dispatches with client message
  - `initResponse[name, version, tools, prompts, clientMsg]` - includes `extensions` in capabilities when `$clientSupportsUI` is True
  - Old 4-arg form preserved for backward compatibility
- Fixed `clientSupportsUIQ` to use `! MissingQ @ msg["params", "capabilities", "extensions", "io.modelcontextprotocol/ui"]` instead of `KeyExistsQ` with nested key paths (which doesn't work in WL)
- Wrote unit tests covering `clientSupportsUIQ`, `initResponse` extensions, and integration

## Session 3

Completed UI resource registry (Phase 1.2 from spec):

- Fixed `loadUIResource` in `UIResources.wl`: replaced `ReadString[file, CharacterEncoding -> "UTF-8"]` with `ByteArrayToString @ ReadByteArray @ file` to avoid `OptionValue::nodef` errors (`ReadString` doesn't support the `CharacterEncoding` option)
- Fixed `listUIResources` in `UIResources.wl`: replaced `/;` condition + separate unconditional definition with a single definition using `If[TrueQ @ $clientSupportsUI, ..., {}]`. The two-definition approach failed because WL's DownValues ordering placed the unconditional `listUIResources[] := {}` before the conditional definition, causing it to always return `{}`
- Wrote 16 new unit tests covering:
  - `loadUIResource`: HTML-only files, HTML+JSON metadata, URI derivation from filename, empty meta when no JSON
  - `initializeUIResources`: populates registry from paclet assets, loads both apps, HTML is string, MIME type correct, JSON metadata loaded, evaluator frame domains, graceful fallback when assets missing
  - `listUIResources`: returns resources when UI supported, returns 2 resources, empty when no UI, empty when unset, correct URIs

Key learnings:
- `ReadString` does NOT accept `CharacterEncoding` as an option; use `ByteArrayToString @ ReadByteArray @ file` instead
- When two DownValues have identical LHS patterns (one with `/;` condition, one without), `endDefinition` can cause the unconditional definition to be ordered first, shadowing the conditional one. Use `If` inside a single definition to avoid this
