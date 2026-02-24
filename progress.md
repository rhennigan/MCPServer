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

## Session 4

Completed resource handlers (Phase 1.3 from spec):

- Updated `handleMethod["resources/list", ...]` in `StartMCPServer.wl` to call `listUIResources[]` instead of returning empty list
- Added `handleMethod["resources/read", ...]` that delegates to new `handleResourceRead` function
- Added `handleResourceRead` function that wraps `readUIResource` in `catchAlways` and converts failures to MCP error responses with code `-32602` (Invalid params)
- Added `resourceReadErrorMessage` helper to extract the URI from the request and format the error message
- Fixed bug in `readUIResource` (`UIResources.wl`): changed `If[..., throwFailure[...]]; <| ... |>` to `If[..., throwFailure[...], <| ... |>]` so that the failure is properly returned instead of being discarded by `CompoundExpression`
- Wrote 13 new unit tests covering:
  - `readUIResource`: valid URI returns content, HTML content accessible, unknown URI returns Failure, invalid URI type returns Failure
  - `handleResourceRead`: valid URI returns result with `"result"` key, unknown URI returns error with code -32602 and URI in message, invalid params returns error
  - `handleMethod` integration: `resources/list` returns UI resources for UI clients and empty for non-UI clients, `resources/read` returns content for valid URI and error for unknown URI

Key learnings:
- `throwFailure` only throws (via `Throw`) when `$catching` is `True` (inside `catchAlways`/`catchMine`). Otherwise it returns a `Failure` without throwing. Code after `If[..., throwFailure[...]]; ...` will continue executing when `$catching` is False — use `If/Else` pattern instead of `If; continue`
- Tests that invoke error paths emitting messages need `Quiet` wrapper to avoid `MessagesFailure` outcomes

## Session 5

Completed tool metadata (Phase 1.4 from spec):

- Fixed `toolUIMetadata` in `UIResources.wl`: replaced `/; TrueQ @ $clientSupportsUI` conditional definition + catch-all `_String` fallback with a single definition using `If[TrueQ @ $clientSupportsUI, ..., {}]` to avoid the `endDefinition` reordering bug
- Added `withToolUIMetadata` function in `UIResources.wl`: takes a list of tool associations and adds `_meta.ui` to each tool that has a UI resource association in `$toolUIAssociations`
- Declared `withToolUIMetadata` in `CommonSymbols.wl`
- Modified `handleMethod["tools/list", ...]` in `StartMCPServer.wl` to call `withToolUIMetadata @ $toolList` instead of returning `$toolList` directly — this is needed because `$toolList` is pre-computed at startup before `$clientSupportsUI` is set during the `initialize` handshake
- Wrote 16 new unit tests covering:
  - `toolUIMetadata`: known tools return `_meta` with correct resourceUri and visibility, evaluator tool mapping, empty for unknown tools, empty when UI not supported, empty when UI unset
  - `withToolUIMetadata`: adds `_meta` to known tools, no `_meta` for unknown tools, correct meta content, no changes when UI not supported, preserves existing fields
  - `handleMethod["tools/list"]` integration: `_meta` present for UI-linked tools, absent for unlinked tools, absent when UI not supported

Key design note:
- `$toolList` is pre-computed during `startMCPServer` init (before `$clientSupportsUI` is known), so UI metadata must be added dynamically at request time via `withToolUIMetadata`, not during the initial `Map` over tools

## Session 6

Completed full review and verification of phase 1 code:

- Reviewed all phase 1 implementation files: `UIResources.wl`, `StartMCPServer.wl`, `CommonSymbols.wl`, `Messages.wl`, `PacletInfo.wl`, `Assets/Apps/`, `Tests/MCPApps.wlt`
- **Fixed cross-context symbol bug:** `writeError` and `debugPrint` used in `UIResources.wl` resolved to `Wolfram`MCPServer`UIResources`Private`` instead of `Wolfram`MCPServer`Common`` where the definitions live (defined in `StartMCPServer.wl`). The logging calls were effectively no-ops. Fixed by adding both symbols to `CommonSymbols.wl` as shared symbols.
- Verified correct behavior with `SymbolDefinition` and raw `DownValues` inspection: `initializeUIResources` now correctly references `Wolfram`MCPServer`Common`writeError` and `Wolfram`MCPServer`Common`debugPrint`
- All 60 MCP Apps tests pass; all other tests pass (6 pre-existing SymbolDefinition.wlt failures unrelated)
- CodeInspector reports no issues on UIResources.wl
- Confirmed all spec requirements for Phase 1 are met:
  - Extension negotiation: `$clientSupportsUI` flag + `initResponse` extensions ✓
  - UI resource registry: HTML + JSON loaded from paclet assets ✓
  - Resource handlers: `resources/list` + `resources/read` ✓
  - Tool metadata: `_meta.ui` attached dynamically via `withToolUIMetadata` ✓
  - Graceful degradation: non-UI clients get empty resources, no metadata ✓
