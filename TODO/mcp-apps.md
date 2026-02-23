# MCP Apps Task List

## Phase 1: Infrastructure

### 1.1 Extension Negotiation

- [ ] Declare `$clientSupportsUI` in `Kernel/CommonSymbols.wl`
- [ ] Implement `clientSupportsUIQ[msg]` — check `msg[["params","capabilities","extensions","io.modelcontextprotocol/ui"]]`
- [ ] Implement `clientSupportsUIQ[_]` fallback returning `False`
- [ ] Refactor `handleMethod["initialize", ...]` — replace pre-computed `$initResult` with dynamic `initResult[msg]` call
- [ ] Set `$clientSupportsUI` in `handleMethod["initialize", ...]` before calling `initResult`
- [ ] Update `initResponse` signature to accept `clientMsg` as a new argument
- [ ] Add `extensions` key to `initResponse` output — echo `io.modelcontextprotocol/ui` with `mimeTypes` when `clientSupportsUIQ[clientMsg]` is true
- [ ] Ensure `extensions` key is omitted entirely (via `Nothing`) when client does not advertise UI support
- [ ] Remove `$initResult` variable from `startMCPServer` `Block` scope (no longer pre-computed)

### 1.2 UI Resource Registry

- [ ] Declare `$uiResourceRegistry` in `Kernel/CommonSymbols.wl`
- [ ] Declare `$toolUIAssociations` in `Kernel/CommonSymbols.wl`
- [ ] Create `Kernel/UIResources.wl` with `beginDefinition`/`endDefinition` pattern
- [ ] Implement `initializeUIResources[]` — find HTML files in `PacletObject["Wolfram/MCPServer"]["AssetLocation","Apps"]`
- [ ] Graceful fallback in `initializeUIResources` — if assets directory missing, log error via `writeError` and set `$uiResourceRegistry = <||>`
- [ ] Implement `loadUIResource[htmlFile]` — read HTML file, derive `ui://wolfram/<baseName>` URI
- [ ] In `loadUIResource`, read optional sidecar JSON (`<baseName>.json`) for CSP metadata
- [ ] Handle missing/malformed JSON sidecar — default to `<||>` metadata
- [ ] Populate `$uiResourceRegistry` as `<| uri -> <| "uri", "name", "mimeType", "html", "meta" |>, ... |>`
- [ ] Call `initializeUIResources[]` in `startMCPServer` after `$clientSupportsUI` is set
- [ ] Add ``Get["Wolfram`MCPServer`UIResources`"]`` to the appropriate loader (e.g., `Tools/Tools.wl` or `Main.wl`)

### 1.3 Resources Handlers

- [ ] Update `handleMethod["resources/list", ...]` to return `listUIResources[]` result
- [ ] Implement `listUIResources[]` (UI client) — map `$uiResourceRegistry` to list of `<| "uri", "name", "description", "mimeType" |>`
- [ ] Implement `listUIResources[]` (non-UI client) — return `{}`
- [ ] Add `handleMethod["resources/read", msg, req]` — delegate to `readUIResource[msg, req]`
- [ ] Implement `readUIResource[msg, req]` — extract `params.uri`, look up in `$uiResourceRegistry`
- [ ] Return `<| "contents" -> { <| "uri", "mimeType", "text" (HTML), "_meta" |> } |>` for valid URI
- [ ] Return MCP error (code `-32602`) for unknown URI via `throwFailure["UIResourceNotFound", uri]`

### 1.4 Tool Metadata

- [ ] Define `$toolUIAssociations` mapping (e.g., `"WolframAlpha" -> "ui://wolfram/wolframalpha-viewer"`)
- [ ] Implement `toolUIMetadata[toolName]` — look up tool name in `$toolUIAssociations`
- [ ] `toolUIMetadata` returns `{"_meta" -> <| "ui" -> <| "resourceUri" -> ..., "visibility" -> {"model","app"} |> |>}` when association exists and `$clientSupportsUI` is true
- [ ] `toolUIMetadata` returns `{}` when no association exists or client does not support UI
- [ ] Update tool list construction in `startMCPServer` — splice `toolUIMetadata[#["Name"]]` into each tool definition
- [ ] Verify that existing tools without UI associations are unaffected (no `_meta` key added)

### 1.5 Graceful Degradation

- [ ] Verify: non-UI client `initialize` response has no `extensions` key
- [ ] Verify: non-UI client `resources/list` returns `{"resources": []}`
- [ ] Verify: non-UI client `resources/read` returns error (no resources registered)
- [ ] Verify: non-UI client `tools/list` has no `_meta` on any tool
- [ ] Verify: `tools/call` results are unchanged for both UI and non-UI clients (text + base64 PNG)
- [ ] Verify: app-only tools (visibility `["app"]`) excluded from `tools/list` when `$clientSupportsUI` is false

### 1.6 Directory Structure

- [ ] Create `Assets/Apps/` directory
- [ ] Create placeholder files to validate asset loading (can be minimal HTML for testing)

### 1.7 Error Messages

- [ ] Add `MCPServer::UIResourceNotFound = "UI resource not found: \`1\`."` to `Kernel/Messages.wl`
- [ ] Add `MCPServer::UIResourceLoadFailed = "Failed to load UI resource from \`1\`."` to `Kernel/Messages.wl`
- [ ] Add `MCPServer::UIAppAssetsMissing = "UI app assets directory not found. MCP Apps will be disabled."` to `Kernel/Messages.wl`

### 1.8 PacletInfo.wl

- [ ] Register `{"Apps", "Assets/Apps"}` in the `"Assets"` section of `PacletInfo.wl`

### 1.9 Testing

- [ ] Create `Tests/MCPApps.wlt` test file
- [ ] Test `clientSupportsUIQ` with UI-capable client message — returns `True`
- [ ] Test `clientSupportsUIQ` with non-UI client message — returns `False`
- [ ] Test `clientSupportsUIQ` with malformed/missing capabilities — returns `False`
- [ ] Test `initResponse` with UI client — response contains `extensions` key with `io.modelcontextprotocol/ui`
- [ ] Test `initResponse` without UI client — response has no `extensions` key
- [ ] Test `loadUIResource` — loads HTML and sidecar JSON correctly
- [ ] Test `loadUIResource` — handles missing JSON sidecar gracefully
- [ ] Test `initializeUIResources` — populates `$uiResourceRegistry` from assets directory
- [ ] Test `initializeUIResources` — graceful fallback when assets directory is missing
- [ ] Test `listUIResources` with `$clientSupportsUI = True` — returns resource list
- [ ] Test `listUIResources` with `$clientSupportsUI = False` — returns `{}`
- [ ] Test `readUIResource` with valid URI — returns HTML content and metadata
- [ ] Test `readUIResource` with unknown URI — returns error
- [ ] Test `toolUIMetadata` with associated tool and UI support — returns `_meta.ui` structure
- [ ] Test `toolUIMetadata` with associated tool but no UI support — returns `{}`
- [ ] Test `toolUIMetadata` with unassociated tool — returns `{}`
- [ ] Integration test: full `initialize` handshake with UI extension
- [ ] Integration test: `initialize` -> `resources/list` -> `resources/read` round-trip
- [ ] Integration test: `initialize` -> `tools/list` verifies `_meta` present on UI-linked tools
- [ ] Integration test: `initialize` without extensions — verify identical behavior to current

## Phase 2: WolframAlpha Interactive Viewer

### 2.1 App Scaffolding & Lifecycle

- [ ] Create `Assets/Apps/wolframalpha-viewer.html` with basic HTML structure (doctype, head, body)
- [ ] Implement `postMessage` JSON-RPC 2.0 communication layer (send/receive with host)
- [ ] Handle `ui/initialize` — store host context, theme CSS variables, container dimensions
- [ ] Handle `ui/notifications/tool-input` — display "Querying: ..." loading state with the query text
- [ ] Handle `ui/notifications/tool-result` — parse content items from the tool result
- [ ] Handle `ui/resource-teardown` — clean up state and event listeners

### 2.2 Content Parsing & Rendering

- [ ] Parse text content items — extract pod structure, section titles, plain text results
- [ ] Parse image content items — extract base64 PNG data for display
- [ ] Render pod layout — vertical list of pods with titled, collapsible sections
- [ ] Render base64 PNG images inside pods with proper sizing and alt text
- [ ] Render plain text results alongside images (formatted text blocks)
- [ ] Display loading indicator while waiting for tool results
- [ ] Display error state for failed queries

### 2.3 Interactive Features

- [ ] Image zoom — click-to-zoom or scroll-zoom on pod images
- [ ] Collapsible pod sections — click pod title to expand/collapse
- [ ] Query bar — display current query at top, allow editing
- [ ] Follow-up queries — submit modified query via `tools/call("WolframAlpha", ...)` through host
- [ ] Loading state during follow-up tool calls (spinner/skeleton)
- [ ] Update display with new results after follow-up query completes

### 2.4 Theming & Layout

- [ ] Read host CSS variables (`--color-background`, `--color-text`, etc.) and apply to app styling
- [ ] Responsive layout — adapt to inline display mode dimensions
- [ ] Fullscreen toggle — request `ui/request-display-mode` for expanded view
- [ ] Ensure app looks reasonable with no theme variables (sensible defaults)

### 2.5 Metadata & Configuration

- [ ] Create `Assets/Apps/wolframalpha-viewer.json` with CSP metadata (empty domain lists)
- [ ] Set `prefersBorder: true`
- [ ] Register tool-UI association: `"WolframAlpha" -> "ui://wolfram/wolframalpha-viewer"` in `$toolUIAssociations`

### 2.6 Testing

- [ ] Manual test: initialize handshake with UI extension, verify WA viewer in `resources/list`
- [ ] Manual test: `resources/read` for `ui://wolfram/wolframalpha-viewer` returns valid HTML
- [ ] Manual test: WA tool result renders pods and images in the viewer
- [ ] Manual test: follow-up query works end-to-end
- [ ] Manual test: non-UI client does not see WA viewer resources or `_meta.ui`
- [ ] Add unit tests for WA viewer resource loading in `Tests/MCPApps.wlt`

---

## Phase 3: WL Evaluator Interactive Viewer

### 3.1 App Scaffolding & Lifecycle

- [ ] Create `Assets/Apps/evaluator-viewer.html` with basic HTML structure
- [ ] Implement `postMessage` JSON-RPC 2.0 communication layer (reuse pattern from Phase 2)
- [ ] Handle `ui/initialize` — store host context, theme, dimensions
- [ ] Handle `ui/notifications/tool-input` — display the code being evaluated
- [ ] Handle `ui/notifications/tool-result` — parse and route content items by type
- [ ] Handle `ui/resource-teardown` — clean up iframes, event listeners, state

### 3.2 Content Type Detection & Routing

- [ ] Detect image content items (`type == "image"`) — route to image renderer
- [ ] Detect cloud URLs in text items (`![Image](https://www.wolframcloud.com/...)`) — route to iframe renderer
- [ ] Detect local image URLs in text items (`![Image](local://...)`) — display URL or linked image
- [ ] Detect plain text content items — route to text/code renderer
- [ ] Handle mixed content — display multiple content types in correct order

### 3.3 Code Display

- [ ] Show the evaluated code in a styled code block
- [ ] Implement basic WL syntax highlighting (keywords, strings, comments, brackets)
- [ ] Copy-to-clipboard button for code blocks

### 3.4 Result Rendering

- [ ] Render base64 PNG images with zoom (click-to-zoom / scroll-zoom)
- [ ] Render CloudDeploy results in iframe (`sandbox="allow-scripts allow-same-origin"`)
- [ ] Iframe loading indicator while cloud content loads
- [ ] Render plain text results with monospace formatting
- [ ] Render markdown-formatted text results (basic markdown support)
- [ ] Console output section — collapsible area for `Print` statements and messages (collapsed by default)

### 3.5 Interactive Features

- [ ] Re-evaluate button — open code editor input area with pre-filled code
- [ ] Submit re-evaluation via `tools/call("WolframLanguageEvaluator", ...)` through host
- [ ] Loading state during re-evaluation
- [ ] Update display with new results after re-evaluation completes
- [ ] Fullscreen toggle via `ui/request-display-mode`

### 3.6 Theming & Layout

- [ ] Read host CSS variables and apply to app styling
- [ ] Responsive layout for inline display mode
- [ ] Auto-switch output panel between text, image, and iframe based on content type
- [ ] Sensible default styling when host CSS variables are absent

### 3.7 Metadata & Configuration

- [ ] Create `Assets/Apps/evaluator-viewer.json` with CSP metadata
- [ ] Set `frameDomains: ["https://www.wolframcloud.com", "https://wolfr.am"]`
- [ ] Set `prefersBorder: true`
- [ ] Register tool-UI association: `"WolframLanguageEvaluator" -> "ui://wolfram/evaluator-viewer"` in `$toolUIAssociations`

### 3.8 Testing

- [ ] Manual test: initialize handshake, verify evaluator viewer in `resources/list`
- [ ] Manual test: `resources/read` for `ui://wolfram/evaluator-viewer` returns valid HTML
- [ ] Manual test: text-only evaluation result renders correctly
- [ ] Manual test: image (base64 PNG) result renders with zoom
- [ ] Manual test: CloudDeploy URL result embeds in iframe
- [ ] Manual test: re-evaluation works end-to-end
- [ ] Manual test: console output (Print/messages) appears in collapsible section
- [ ] Manual test: non-UI client behavior is unchanged
- [ ] Add unit tests for evaluator viewer resource loading in `Tests/MCPApps.wlt`