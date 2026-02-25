# MCP Apps - Implementation Specification

## Overview

This specification defines the implementation plan for integrating [MCP Apps](https://modelcontextprotocol.io/docs/extensions/apps) into the MCPServer paclet. MCP Apps is the first official MCP extension (`io.modelcontextprotocol/ui`), enabling servers to deliver interactive HTML user interfaces that render inside MCP hosts (Claude Desktop, VS Code, etc.) in sandboxed iframes.

This enables three key use cases for the Wolfram MCP server:

1. **Interactive WolframAlpha results** -- full WA experience embedded in an iframe
2. **CloudDeploy results in iframes** -- live Wolfram Cloud deployments embedded in conversation
3. **Rich WL evaluator output** -- interactive graphics, formatted expressions, Manipulate-like controls

## Goals

- Implement MCP Apps extension negotiation so UI-capable clients get interactive experiences
- Serve HTML apps via `resources/read` for `ui://` resources
- Add `_meta.ui` metadata to tools that support interactive display
- Maintain full backward compatibility for clients that do not support MCP Apps
- Store HTML app templates as paclet assets, loaded at runtime
- Support graceful degradation: non-UI clients continue to receive text + base64 PNG as today

---

## Background: MCP Apps Protocol

### Extension Identity

- **Extension ID:** `io.modelcontextprotocol/ui`
- **Spec version:** `2026-01-26`
- **MIME type:** `text/html;profile=mcp-app`
- **Resource URI scheme:** `ui://`

### Capability Negotiation

MCP Apps support is negotiated during `initialize`. The client advertises the extension in `capabilities.extensions`:

```json
{
  "method": "initialize",
  "params": {
    "protocolVersion": "2024-11-05",
    "capabilities": {
      "extensions": {
        "io.modelcontextprotocol/ui": {
          "mimeTypes": ["text/html;profile=mcp-app"]
        }
      }
    },
    "clientInfo": { "name": "claude-desktop", "version": "1.0.0" }
  }
}
```

The server echoes the extension in its response if it supports it:

```json
{
  "result": {
    "protocolVersion": "2024-11-05",
    "capabilities": {
      "tools": { "listChanged": true },
      "prompts": {},
      "extensions": {
        "io.modelcontextprotocol/ui": {
          "mimeTypes": ["text/html;profile=mcp-app"]
        }
      }
    },
    "serverInfo": { "name": "WolframLanguage", "version": "1.5.0" }
  }
}
```

### Tool-UI Linkage

Tools declare an associated UI resource via `_meta.ui`:

```json
{
  "name": "WolframAlpha",
  "description": "...",
  "inputSchema": { ... },
  "_meta": {
    "ui": {
      "resourceUri": "ui://wolfram/wolframalpha-viewer",
      "visibility": ["model", "app"]
    }
  }
}
```

### Resource Serving

The host fetches UI resources via `resources/read`:

```json
{
  "method": "resources/read",
  "params": { "uri": "ui://wolfram/wolframalpha-viewer" }
}
```

Response:

```json
{
  "result": {
    "contents": [{
      "uri": "ui://wolfram/wolframalpha-viewer",
      "mimeType": "text/html;profile=mcp-app",
      "text": "<!DOCTYPE html><html>...</html>",
      "_meta": {
        "ui": {
          "csp": {
            "connectDomains": [],
            "resourceDomains": [],
            "frameDomains": []
          },
          "prefersBorder": true
        }
      }
    }]
  }
}
```

### Responsibility Model

MCP Apps involve three parties with distinct responsibilities:

| Party | Responsibilities |
|-------|-----------------|
| **MCP Server** (our code) | Extension negotiation, serving UI resources via `resources/read`, attaching `_meta.ui` to tools, executing tool calls |
| **MCP Host** (Claude Desktop, VS Code, etc.) | Rendering iframes, enforcing CSP/sandbox, proxying `postMessage` between app and server, filtering tool visibility for LLM |
| **MCP App** (HTML in iframe) | Implementing `ui/initialize`, handling `ui/notifications/*`, rendering interactive UI, calling `tools/call` via host |

The `ui/*` messages (e.g., `ui/initialize`, `ui/notifications/tool-input`) are part of the **host-app protocol** over `postMessage`. The server does NOT handle these messages directly. The server only handles standard MCP messages (`initialize`, `resources/list`, `resources/read`, `tools/list`, `tools/call`).

### App Lifecycle

1. **Preload**: Host reads `_meta.ui.resourceUri` from tool definition, fetches HTML via `resources/read` (server handles this)
2. **Render**: Host renders HTML in a sandboxed iframe (host responsibility)
3. **Initialize**: App sends `ui/initialize` to host via `postMessage` (host-app protocol)
4. **Tool Input**: Host forwards tool arguments via `ui/notifications/tool-input` (host-app protocol)
5. **Tool Result**: Host forwards tool result via `ui/notifications/tool-result` (host-app protocol)
6. **Interactive**: App can call `tools/call` back through host, which forwards to server (server handles the `tools/call`)
7. **Teardown**: Host sends `ui/resource-teardown`, iframe is removed (host-app protocol)

### Tool Visibility

- `["model", "app"]` (default): Tool visible to LLM and callable by app
- `["model"]`: Tool visible to LLM only; app cannot call it
- `["app"]`: Hidden from LLM; only callable by app (useful for pagination, re-evaluation)

### Security Model

- Apps run in sandboxed iframes with `allow-scripts allow-same-origin`
- CSP is constructed from declared `csp` domains; default is highly restrictive
- All communication via `postMessage` JSON-RPC 2.0
- Hosts control which tools apps can call

---

## Implementation Phases

### Phase 1: Infrastructure

Core protocol changes to support MCP Apps negotiation, resource serving, and tool metadata.

#### 1.1 Extension Negotiation

**File:** `Kernel/StartMCPServer.wl`

During `initialize`, inspect the client's `capabilities.extensions` for `io.modelcontextprotocol/ui`. Store the result so downstream code can branch on it.

**New symbols** (declare in `Kernel/CommonSymbols.wl`):

```wl
`$clientSupportsUI;
`$uiResourceRegistry;
```

**Changes to `handleMethod["initialize", ...]`:**

```wl
handleMethod[ "initialize", msg_, req_ ] := (
    $clientName = Replace[ msg[[ "params", "clientInfo", "name" ]], Except[ _String ] :> None ];
    $clientSupportsUI = clientSupportsUIQ @ msg;
    If[ ! stderrEnabledQ[ ], $Messages = { } ];
    <| req, "result" -> initResult[ msg ] |>
);
```

The key change: `$initResult` (currently a pre-computed value) becomes a function call `initResult[msg]` that examines the client message and returns the appropriate response. The existing `initResponse` function gains an additional argument for the client message. When the client advertises `io.modelcontextprotocol/ui`, the server echoes it back in `capabilities.extensions`.

**Note:** `$clientSupportsUI` must be set *before* `initResult` is called, because `initResult` (and subsequently `initResponse`) reads it to decide whether to include extensions. The `$initResult` variable in the `Block` scope of `startMCPServer` should be removed; instead, `handleMethod["initialize", ...]` computes the response dynamically. Other methods that reference `$initResult` do not exist (only `handleMethod["initialize", ...]` uses it), so the change is safe.

**New function `clientSupportsUIQ`:**

```wl
clientSupportsUIQ // beginDefinition;

clientSupportsUIQ[ msg_Association ] :=
    KeyExistsQ[ msg, { "params", "capabilities", "extensions", "io.modelcontextprotocol/ui" } ];

clientSupportsUIQ[ _ ] := False;

clientSupportsUIQ // endDefinition;
```

**Changes to `initResponse`:**

```wl
initResponse[ name_String, version_String, tools0: { ___LLMTool }, prompts_, clientMsg_ ] := Enclose[
    Module[ { tools, instructions, extensions },
        tools = If[ Length @ tools0 > 0, <| "listChanged" -> True |>, <| |> ];
        instructions = ConfirmMatch[ makeInstructions @ prompts, _Missing | _String, "Instructions" ];

        (* Only include extensions if client supports UI *)
        extensions = If[ clientSupportsUIQ @ clientMsg,
            <| "io.modelcontextprotocol/ui" -> <| "mimeTypes" -> { "text/html;profile=mcp-app" } |> |>,
            Nothing
        ];

        DeleteMissing @ <|
            "protocolVersion" -> $protocolVersion,
            "instructions"    -> instructions,
            "capabilities" -> DeleteMissing @ <|
                "prompts"    -> <| |>,
                "tools"      -> tools,
                "extensions" -> extensions
            |>,
            "serverInfo" -> <| "name" -> name, "version" -> version |>
        |>
    ],
    throwInternalFailure
];
```

#### 1.2 UI Resource Registry

**File:** `Kernel/StartMCPServer.wl` (or new file `Kernel/UIResources.wl`)

A registry mapping `ui://` URIs to HTML content and metadata. Populated at server startup from paclet assets.

**Data structure:**

```wl
$uiResourceRegistry = <|
    "ui://wolfram/wolframalpha-viewer" -> <|
        "uri"      -> "ui://wolfram/wolframalpha-viewer",
        "name"     -> "WolframAlpha Interactive Viewer",
        "mimeType" -> "text/html;profile=mcp-app",
        "html"     -> "<!DOCTYPE html>...",  (* loaded from Assets/Apps/ *)
        "meta"     -> <|
            "ui" -> <|
                "csp" -> <| "connectDomains" -> {}, "resourceDomains" -> {} |>,
                "prefersBorder" -> True
            |>
        |>
    |>,
    ...
|>;
```

**New function `initializeUIResources`:**

Called during `startMCPServer`, after `$clientSupportsUI` is set but before the main loop. Insert the call in `startMCPServer` after the `init` computation:

```wl
(* In startMCPServer, after init = ConfirmBy[ initResponse @ obj, ... ] *)
initializeUIResources[ ];
```

```wl
initializeUIResources // beginDefinition;

initializeUIResources[ ] := Enclose[
    Module[ { assetsDir, htmlFiles },
        assetsDir = ConfirmBy[
            PacletObject[ "Wolfram/MCPServer" ][ "AssetLocation", "Apps" ],
            DirectoryQ,
            "AssetsDir"
        ];
        htmlFiles = FileNames[ "*.html", assetsDir ];
        $uiResourceRegistry = Association[
            loadUIResource /@ htmlFiles
        ];
        debugPrint[ "Loaded " <> ToString[ Length @ htmlFiles ] <> " UI resources" ];
    ],
    (
        (* Graceful fallback: no UI resources. Log the error but do not fail startup. *)
        writeError[ "Failed to load UI app assets. MCP Apps will be disabled." ];
        $uiResourceRegistry = <| |>
    ) &
];

initializeUIResources // endDefinition;
```

**Note:** `initializeUIResources` runs once at startup. HTML files are read from disk and cached in memory. To update an app during development, restart the server. Hot-reload is not supported (see Future Considerations).

**New function `loadUIResource`:**

```wl
loadUIResource // beginDefinition;

loadUIResource[ htmlFile_String ] := Enclose[
    Module[ { baseName, uri, html, metaFile, meta },
        baseName = FileBaseName @ htmlFile;
        uri = "ui://wolfram/" <> baseName;
        html = ConfirmBy[ ReadString[ htmlFile, CharacterEncoding -> "UTF-8" ], StringQ, "HTML" ];
        metaFile = FileNameJoin[ { DirectoryName @ htmlFile, baseName <> ".json" } ];
        meta = If[ FileExistsQ @ metaFile,
            Quiet @ Developer`ReadRawJSONString @ ReadString[ metaFile, CharacterEncoding -> "UTF-8" ],
            <| |>
        ];
        uri -> <|
            "uri"      -> uri,
            "name"     -> baseName,
            "mimeType" -> "text/html;profile=mcp-app",
            "html"     -> html,
            "meta"     -> Replace[ meta, Except[ _Association ] :> <| |> ]
        |>
    ],
    throwInternalFailure
];

loadUIResource // endDefinition;
```

#### 1.3 Resources Handler

**File:** `Kernel/StartMCPServer.wl`

Update the `resources/list` and add `resources/read` handler.

**Changes to `handleMethod`:**

```wl
(* Return UI resources when client supports UI, empty otherwise *)
handleMethod[ "resources/list", msg_, req_ ] :=
    <| req, "result" -> <| "resources" -> listUIResources[ ] |> |>;

(* New: resources/read handler *)
handleMethod[ "resources/read", msg_, req_ ] :=
    <| req, "result" -> readUIResource[ msg, req ] |>;
```

**New function `listUIResources`:**

```wl
listUIResources // beginDefinition;

listUIResources[ ] /; TrueQ @ $clientSupportsUI :=
    KeyValueMap[
        Function[ { uri, data },
            <|
                "uri"         -> uri,
                "name"        -> data[ "name" ],
                "description" -> Lookup[ data, "description", "" ],
                "mimeType"    -> data[ "mimeType" ]
            |>
        ],
        $uiResourceRegistry
    ];

listUIResources[ ] := { };

listUIResources // endDefinition;
```

**New function `readUIResource`:**

```wl
readUIResource // beginDefinition;

readUIResource[ msg_Association, req_ ] := Enclose[
    Module[ { uri, resource },
        uri = ConfirmBy[ msg[[ "params", "uri" ]], StringQ, "URI" ];
        resource = Lookup[ $uiResourceRegistry, uri, Missing[ "NotFound" ] ];
        If[ MissingQ @ resource,
            throwFailure[ "UIResourceNotFound", uri ]
        ];
        <| "contents" -> {
            <|
                "uri"      -> resource[ "uri" ],
                "mimeType" -> resource[ "mimeType" ],
                "text"     -> resource[ "html" ],
                "_meta"    -> resource[ "meta" ]
            |>
        } |>
    ],
    throwInternalFailure
];

readUIResource // endDefinition;
```

#### 1.4 Tool Metadata

**File:** `Kernel/StartMCPServer.wl`

When building the tool list for `tools/list`, attach `_meta.ui` to tools that have a registered UI resource, but only when the client supports UI.

**Changes to `startMCPServer` (tool list construction):**

```wl
toolList = Map[
    <|
        "name"        -> safeString @ #[ "Name"        ],
        "description" -> safeString @ #[ "Description" ],
        "inputSchema" -> #[ "JSONSchema" ],
        (* Add _meta.ui when client supports UI and tool has a UI resource *)
        Sequence @@ toolUIMetadata[ #[ "Name" ] ]
    |> &,
    Values @ llmTools
];
```

**New function `toolUIMetadata`:**

```wl
toolUIMetadata // beginDefinition;

toolUIMetadata[ toolName_String ] /; TrueQ @ $clientSupportsUI :=
    toolUIMetadata[ toolName, Lookup[ $toolUIAssociations, toolName, None ] ];

toolUIMetadata[ toolName_, uri_String ] :=
    { "_meta" -> <| "ui" -> <| "resourceUri" -> uri, "visibility" -> { "model", "app" } |> |> };

toolUIMetadata[ toolName_, None ] := { };
toolUIMetadata[ _ ] := { };

toolUIMetadata // endDefinition;
```

**New symbol `$toolUIAssociations`** (mapping tool names to UI resource URIs):

```wl
$toolUIAssociations = <|
    "WolframAlpha"            -> "ui://wolfram/wolframalpha-viewer",
    "WolframLanguageEvaluator" -> "ui://wolfram/evaluator-viewer"
|>;
```

#### 1.5 Graceful Degradation

The design ensures backward compatibility. `$clientSupportsUI` affects **both** tool metadata and tool count:

| Aspect | UI-capable client | Non-UI client |
|--------|-------------------|---------------|
| `initialize` response | Includes `capabilities.extensions` | No `extensions` field |
| `resources/list` | Returns UI resources | Returns empty `{ "resources": [] }` |
| `resources/read` | Returns HTML content | Returns error (no resources registered) |
| `tools/list` tool count | All tools including app-only | Standard tools only (app-only tools excluded) |
| `tools/list` metadata | Includes `_meta.ui` on UI-linked tools | No `_meta` field on any tools |
| `tools/call` WolframAlpha results | JSON metadata (notebookUrl) + text + base64 PNG | Text + base64 PNG (unchanged) |
| `tools/call` other tool results | Unchanged (text + base64 PNG) | Unchanged (text + base64 PNG) |

**Detailed rules:**

- **Extension negotiation is opt-in.** If the client does not advertise `io.modelcontextprotocol/ui` in its `capabilities.extensions` (or does not send `capabilities` at all), the server responds exactly as it does today.
- **App-only tools are excluded for non-UI clients.** Tools with visibility `["app"]` are not included in `tools/list` or `$llmTools` when `$clientSupportsUI` is `False`. This prevents non-UI clients from seeing tools they cannot use.
- **Tool results are mostly unchanged.** The `evaluateTool` function continues to return text + base64 PNG content items for all tools. The one exception is `WolframAlpha`: when `$clientSupportsUI` is `True`, the WolframAlpha tool prepends a JSON metadata content item containing the cloud notebook URL (`{"notebookUrl": "https://..."}`) before the standard text + image items. The UI app finds this URL and embeds the notebook using WolframNotebookEmbedder. If the notebook deployment fails, the tool falls back to the standard format. The text + image items are always included regardless, so the LLM always receives usable text.
- **`resources/read` for unknown URIs** returns a standard MCP error response:

```json
{
    "jsonrpc": "2.0",
    "id": 2,
    "error": { "code": -32602, "message": "UI resource not found: ui://wolfram/unknown" }
}
```

#### 1.6 Directory Structure

```
Assets/
    Apps/
        wolframalpha-viewer.html     -- WolframAlpha interactive viewer
        wolframalpha-viewer.json     -- CSP and metadata for WA viewer
        evaluator-viewer.html        -- WL Evaluator interactive viewer
        evaluator-viewer.json        -- CSP and metadata for evaluator viewer
Kernel/
    UIResources.wl                   -- UI resource registry and loading (new file)
    StartMCPServer.wl                -- Modified: extension negotiation, resource handlers
    CommonSymbols.wl                 -- Modified: new shared symbols
    Messages.wl                      -- Modified: new error messages
```

#### 1.7 Error Messages

Add to `Kernel/Messages.wl`:

```wl
MCPServer::UIResourceNotFound    = "UI resource not found: `1`.";
MCPServer::UIResourceLoadFailed  = "Failed to load UI resource from `1`.";
MCPServer::UIAppAssetsMissing    = "UI app assets directory not found. MCP Apps will be disabled.";
```

#### 1.8 PacletInfo.wl Changes

Register the `Apps` asset location:

```wl
"Assets" -> {
    {"Apps", "Assets/Apps"}
}
```

---

### Phase 2: WolframAlpha Interactive Viewer

An HTML app that displays WolframAlpha results as an interactive cloud notebook, using the same WolframNotebookEmbedder approach as the NotebookViewer tool.

**Background:** WolframAlpha does not allow iframe embedding (`X-Frame-Options: SAMEORIGIN`), so the original plan of embedding `wolframalpha.com` directly is not viable. Instead, the server formats WA results into a Wolfram Notebook, CloudDeploys it, and the app embeds the cloud notebook using WolframNotebookEmbedder.

#### 2.1 Design Goals

- Format WolframAlpha results as an interactive Wolfram Cloud notebook using Chatbook's `FormatWolframAlphaPods`
- CloudDeploy the formatted notebook and embed it via WolframNotebookEmbedder (same approach as NotebookViewer)
- Maintain the text + base64 PNG tool result for the LLM's consumption (unchanged)
- Include a JSON metadata content item with the cloud notebook URL so the app can extract and embed it
- Allow the user to submit follow-up queries from within the app (each follow-up deploys a new notebook)
- Use host CSS variables for theming the query bar chrome
- Graceful fallback: when `$clientSupportsUI` is `False` or CloudDeploy fails, the tool keeps current behavior (text + base64 PNG only)

#### 2.2 Data Flow

```
LLM calls WolframAlpha tool with { "query": "current distance to Mars" }
    -> Host sends ui/notifications/tool-input to the WA viewer app
       (App shows query in query bar, displays loading state)
    -> Server's wolframAlphaToolEvaluateUI runs:
       1. Calls Chatbook with $ChatNotebookEvaluation = True
          -> Returns <| "Result" -> <pods data>, "String" -> "<text for LLM>" |>
       2. Extracts images from "String" via extractWolframAlphaImages (unchanged for LLM)
       3. Formats "Result" via FormatWolframAlphaPods (with FoldPods = True)
       4. Creates Notebook[{inputCell, outputCell}]
       5. CloudDeploys to MCPServer/Notebooks/WolframAlpha/<encoded-query>.nb
          with Permissions -> {"All" -> {"Read", "Interact"}}, AutoRemove -> True
       6. Returns content items:
          - JSON metadata item: {"notebookUrl": "https://www.wolframcloud.com/obj/..."}
          - Text items + base64 PNG images (from extractWolframAlphaImages, for LLM)
    -> Host receives tool result, sends ui/notifications/tool-result to app
    -> App parses content items, finds the JSON metadata item with "notebookUrl"
    -> App loads WolframNotebookEmbedder and embeds the cloud notebook
    -> User sees interactive formatted WA results (pods, collapsible details, etc.)
```

**Key difference from NotebookViewer:** The NotebookViewer tool receives the URL as a tool *input argument*, so the app can start embedding immediately on `tool-input`. The WolframAlpha tool *generates* the URL during execution, so the app must wait for `tool-result` to get the notebook URL.

**Follow-up queries:**

```
User edits query bar and clicks "Go"
    -> App calls tools/call "WolframAlpha" with { "query": "<new query>" }
    -> Server runs the same pipeline: Chatbook -> FormatWolframAlphaPods -> CloudDeploy
    -> App receives tools/call response with new notebookUrl
    -> App detaches previous embedded notebook, embeds the new one
```

#### 2.3 HTML App: `wolframalpha-viewer.html`

**High-level features:**

- **Notebook embed**: Uses WolframNotebookEmbedder (loaded from unpkg CDN) to render the cloud notebook -- identical library and technique as `notebook-viewer.html`
- **Query bar**: Shows the current query above the notebook embed; editable for follow-up queries
- **Loading state**: Spinner shown while the server processes the query and deploys the notebook
- **Responsive**: Fills container; auto-resize via `ui/notifications/size-changed`
- **Theming**: Uses CSS variables from host context for the query bar and chrome
- **"Open in W|A" link**: External link to `wolframalpha.com` for the current query

**Key UI components:**

- Query bar with input field, "Go" button, and "Open in W|A" link
- Notebook embed container (replaces text/image rendering with WolframNotebookEmbedder)
- Loading indicator
- Error display

**Lifecycle handling:**

```
ui/initialize
    -> Store host context, theme
    -> Load WolframNotebookEmbedder library from CDN
    -> Display empty state

ui/notifications/tool-input
    -> Extract query from tool input arguments
    -> Display query in query bar, update "Open in W|A" link
    -> Show loading indicator
    -> (Do NOT embed anything yet -- notebook URL is not known until tool-result)

ui/notifications/tool-result
    -> Parse content items
    -> Find the metadata content item containing {"notebookUrl": "https://..."}
    -> If found: embed the notebook using WolframNotebookEmbedder.embed(url, container, opts)
    -> If not found (fallback): render text/image content items directly
    -> Hide loading indicator

User edits query and clicks "Go"
    -> Call tools/call "WolframAlpha" with { "query": "<new query>" }
    -> Detach previous embedded notebook
    -> Show loading indicator
    -> On tools/call response: parse content, find notebookUrl, embed new notebook

ui/notifications/tool-cancelled
    -> Hide loading indicator

ui/resource-teardown
    -> Detach embedded notebook if any
```

**Metadata content item detection:**

The app identifies the metadata item by attempting to parse each text content item as JSON and checking for the `notebookUrl` key:

```javascript
function findNotebookUrl(content) {
    for (var i = 0; i < content.length; i++) {
        if (content[i].type === "text" && content[i].text) {
            try {
                var parsed = JSON.parse(content[i].text);
                if (parsed && parsed.notebookUrl) return parsed.notebookUrl;
            } catch (e) { /* not JSON, skip */ }
        }
    }
    return null;
}
```

**Fallback rendering:** If no `notebookUrl` is found (e.g., CloudDeploy failed and the tool fell back to standard output), the app renders text and base64 images directly, identical to the current behavior. This ensures the app works gracefully even when the server-side notebook formatting fails.

#### 2.4 CSP Metadata: `wolframalpha-viewer.json`

```json
{
    "ui": {
        "csp": {
            "connectDomains": [
                "https://www.wolframcloud.com"
            ],
            "resourceDomains": [
                "https://unpkg.com",
                "https://www.wolframcloud.com"
            ],
            "frameDomains": [
                "https://www.wolframcloud.com",
                "https://wolfr.am"
            ]
        },
        "prefersBorder": true
    }
}
```

This is identical to `notebook-viewer.json` because the WolframAlpha viewer uses the same WolframNotebookEmbedder approach:

- `connectDomains`: WolframNotebookEmbedder needs XHR/WebSocket access to wolframcloud.com
- `resourceDomains`: The embedder JS library loads from unpkg.com; notebook resources load from wolframcloud.com
- `frameDomains`: The embedded notebook renders in an iframe pointing to wolframcloud.com

#### 2.5 WolframAlpha Tool Changes

**File:** `Kernel/Tools/WolframAlpha.wl`

When `$clientSupportsUI` is `True`, the WolframAlpha tool runs an enhanced pipeline that produces a cloud notebook alongside the standard text + image output.

**Changes to `wolframAlphaToolEvaluate`:**

```wl
wolframAlphaToolEvaluate // beginDefinition;

(* When client supports UI: get structured result, format notebook, CloudDeploy *)
wolframAlphaToolEvaluate[ as_ ] /; TrueQ @ $clientSupportsUI :=
    wolframAlphaToolEvaluateUI @ as;

(* When client does not support UI: current behavior (text + base64 PNG) *)
wolframAlphaToolEvaluate[ as_ ] :=
    wolframAlphaToolEvaluate[ as, cb`$DefaultTools[ "WolframAlpha" ][ as ] ];

wolframAlphaToolEvaluate[ as_, result_String ] := extractWolframAlphaImages @ result;
wolframAlphaToolEvaluate[ as_, KeyValuePattern[ "String" -> result_String ] ] :=
    extractWolframAlphaImages @ result;

wolframAlphaToolEvaluate // endDefinition;
```

**New function `wolframAlphaToolEvaluateUI`:**

```wl
wolframAlphaToolEvaluateUI // beginDefinition;

wolframAlphaToolEvaluateUI[ as_Association ] := Enclose[
    Module[ { query, result, string, pods, inputCell, outputCell, notebook,
              target, cloudObj, url, textContent, metadataItem },

        query = ConfirmBy[ as[ "query" ], StringQ, "Query" ];

        (* Step 1: Call Chatbook with $ChatNotebookEvaluation = True *)
        result = Block[ { cb`$ChatNotebookEvaluation = True },
            cb`$DefaultTools[ "WolframAlpha" ][ as ]
        ];

        (* Step 2: Extract images from the string for the LLM (unchanged pipeline) *)
        string = ConfirmBy[ result[ "String" ], StringQ, "String" ];
        textContent = extractWolframAlphaImages @ string;

        (* Step 3: Format the Result into notebook cells *)
        pods = Block[ { cb`$DefaultToolOptions = cb`$DefaultToolOptions },
            cb`$DefaultToolOptions[ "WolframAlpha", "FoldPods" ] = True;
            cb`FormatWolframAlphaPods[ result[ "Result" ] ]
        ];
        inputCell  = Cell[ query, "WolframAlphaLong" ];
        outputCell = Cell[ BoxData @ ToBoxes @ pods, "Output" ];
        notebook   = Notebook[ { inputCell, outputCell } ];

        (* Step 4: CloudDeploy *)
        target = FileNameJoin @ {
            CloudObject[ $deployedNotebookRoot, Permissions -> "Public" ],
            "WolframAlpha",
            URLEncode[ query ] <> ".nb"
        };
        cloudObj = ConfirmMatch[
            CloudDeploy[ notebook, target,
                Permissions -> { "All" -> { "Read", "Interact" } },
                AutoRemove  -> True,
                IconRules   -> { }
            ],
            _CloudObject,
            "CloudDeploy"
        ];
        url = ConfirmBy[ First @ cloudObj, StringQ, "URL" ];

        (* Step 5: Build content items with metadata *)
        metadataItem = <|
            "type" -> "text",
            "text" -> Developer`WriteRawJSONString @ <| "notebookUrl" -> url |>
        |>;

        <| "Content" -> Flatten @ { metadataItem, toContentList @ textContent } |>
    ],
    (* On any failure, fall back to non-UI behavior *)
    Function[ { failureInfo },
        writeError[ "WolframAlpha UI formatting failed, falling back to text+image" ];
        wolframAlphaToolEvaluate[ as, cb`$DefaultTools[ "WolframAlpha" ][ as ] ]
    ]
];

wolframAlphaToolEvaluateUI // endDefinition;
```

**New variable `$deployedNotebookRoot`:**

```wl
$deployedNotebookRoot = "MCPServer/Notebooks";
```

**New helper `toContentList`:**

Normalizes the output of `extractWolframAlphaImages` (which may return a string or an association with a `"Content"` key) into a flat list of content item associations:

```wl
toContentList // beginDefinition;
toContentList[ KeyValuePattern[ "Content" -> items_List ] ] := items;
toContentList[ items_List ] := items;
toContentList[ str_String ] := { <| "type" -> "text", "text" -> str |> };
toContentList[ other_ ] := { <| "type" -> "text", "text" -> safeString @ other |> };
toContentList // endDefinition;
```

**Key design decisions:**

- **Fallback on failure**: If CloudDeploy fails (no cloud credentials, network issue, etc.), the function falls back to the standard text + image behavior. The app's fallback rendering handles this gracefully.
- **Content item ordering**: The metadata item comes first so the app can find it quickly.
- **AutoRemove -> True**: Cloud notebooks auto-expire, avoiding cleanup burden.
- **IconRules -> {}**: Skips icon generation for the temporary cloud file.

---

### Phase 3: WL Evaluator Interactive Viewer

An HTML app that renders Wolfram Language evaluator results with support for interactive graphics, cloud-deployed content, and rich formatted output.

#### 3.1 Design Goals

- Display evaluation results with syntax-highlighted code and formatted output
- Embed CloudDeploy results in iframes (for `Manipulate`, interactive plots, etc.)
- Render base64 PNG images with zoom
- Show `Print` output and messages in a console-style area
- Support re-evaluation with modified code
- Display markdown-formatted text results

#### 3.2 Data Flow

```
LLM calls WolframLanguageEvaluator tool
    -> Server evaluates code, returns structured content:
        - Text items: evaluation result as string, print output
        - Image items: base64 PNG for graphics
        - Text items with cloud URLs: "![Image](https://...)" markdown links
    -> Host receives tool result
    -> Host sends ui/notifications/tool-result to the evaluator viewer app
    -> App parses content items:
        - Detect cloud URLs (CloudObject patterns) -> render in iframe
        - Detect base64 images -> render with zoom
        - Detect text -> render with formatting
    -> User interacts (zoom images, interact with cloud content, re-evaluate)
```

#### 3.3 HTML App: `evaluator-viewer.html`

**High-level features:**

- **Code display**: Show the evaluated code with syntax highlighting (WL keywords)
- **Result area**: Formatted output with support for multiple content types
- **Cloud iframe**: When a cloud URL is detected in the result, embed it in an iframe for live interaction (e.g., `Manipulate`, `DynamicModule`)
- **Image viewer**: Zoomable PNG display for static graphics
- **Console output**: Collapsible section showing `Print` statements and messages
- **Re-evaluate**: Button/input to modify and re-run code via `tools/call`
- **Theming**: Uses host CSS variables

**Key UI components:**

- Code block with WL syntax highlighting
- Output panel (auto-switches between text, image, iframe based on content type)
- Cloud content iframe container with loading indicator
- Print/message console (collapsed by default)
- Re-evaluate input area with code editor
- Fullscreen toggle button

**Content type detection logic:**

```
For each content item in tool result:
    if type == "image":
        -> Render as zoomable <img> with base64 src
    if type == "text" and contains "![Image](https://www.wolframcloud.com/...)"
        -> Extract URL, render in <iframe> with sandbox="allow-scripts allow-same-origin"
    if type == "text" and contains "![Image](local://...)"
        -> Render as linked image (if accessible) or show URL
    if type == "text":
        -> Render as formatted text/code block
```

#### 3.4 CSP Metadata: `evaluator-viewer.json`

```json
{
    "ui": {
        "csp": {
            "connectDomains": [],
            "resourceDomains": [],
            "frameDomains": [
                "https://www.wolframcloud.com",
                "https://wolfr.am"
            ]
        },
        "prefersBorder": true
    }
}
```

The `frameDomains` entry allows embedding Wolfram Cloud deployed content in iframes within the app.

---

### Phase 4: App-Only Tools (Optional)

Hidden tools (visibility `["app"]`) that are callable only by the UI apps, not visible to the LLM. These support app-side interactivity without polluting the LLM's tool list.

**This phase is optional.** The WolframAlpha viewer (Phase 2) does not need app-only tools since follow-up queries are handled by calling the existing `WolframAlpha` tool via `tools/call` (visibility `["model", "app"]`), which triggers a new CloudDeploy and returns a fresh notebook URL. The evaluator viewer (Phase 3) can call the existing `WolframLanguageEvaluator` tool directly (visibility `["model", "app"]`). App-only tools should only be implemented if:

- We want to separate app-initiated calls from LLM-initiated calls for logging/analytics
- We discover during Phase 3 implementation that the standard tool is awkward for app use

**Go/no-go criteria:** Implement Phase 4 only after Phase 2 and Phase 3 are complete and tested. Evaluate whether the existing tools are sufficient for app interactivity.

#### 4.1 Re-Evaluate Tool

**Purpose:** Allow the evaluator viewer app to re-evaluate modified code.

**Tool definition:**

```json
{
    "name": "WolframLanguageReEvaluate",
    "description": "Re-evaluate modified Wolfram Language code from the interactive viewer.",
    "inputSchema": {
        "type": "object",
        "properties": {
            "code": { "type": "string", "description": "The modified Wolfram Language code to evaluate" },
            "timeConstraint": { "type": "integer", "description": "Time constraint in seconds (default: 60)" }
        },
        "required": ["code"]
    },
    "_meta": {
        "ui": {
            "visibility": ["app"]
        }
    }
}
```

**Implementation:** Delegates to the same `evaluateWolframLanguage` function. This is essentially the same as calling `WolframLanguageEvaluator` but hidden from the LLM to avoid confusion.

#### 4.2 Registration

App-only tools should be registered conditionally based on `$clientSupportsUI`. They should be added to `$toolList` and `$llmTools` during `startMCPServer` initialization only when UI is supported.

When building the tool list for `tools/list`, app-only tools must include `_meta.ui.visibility` set to `["app"]` so the host knows not to show them to the LLM.

---

## Protocol Messages Reference

### Initialize (with MCP Apps)

**Client request:**
```json
{
    "jsonrpc": "2.0",
    "id": 0,
    "method": "initialize",
    "params": {
        "protocolVersion": "2024-11-05",
        "capabilities": {
            "extensions": {
                "io.modelcontextprotocol/ui": {
                    "mimeTypes": ["text/html;profile=mcp-app"]
                }
            }
        },
        "clientInfo": { "name": "claude-desktop", "version": "1.0.0" }
    }
}
```

**Server response (UI-capable):**
```json
{
    "jsonrpc": "2.0",
    "id": 0,
    "result": {
        "protocolVersion": "2024-11-05",
        "capabilities": {
            "prompts": {},
            "tools": { "listChanged": true },
            "extensions": {
                "io.modelcontextprotocol/ui": {
                    "mimeTypes": ["text/html;profile=mcp-app"]
                }
            }
        },
        "serverInfo": { "name": "WolframLanguage", "version": "1.5.0" }
    }
}
```

**Server response (non-UI client, no extensions field):**
```json
{
    "jsonrpc": "2.0",
    "id": 0,
    "result": {
        "protocolVersion": "2024-11-05",
        "capabilities": {
            "prompts": {},
            "tools": { "listChanged": true }
        },
        "serverInfo": { "name": "WolframLanguage", "version": "1.5.0" }
    }
}
```

### Resources List (UI-capable client)

**Request:**
```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "resources/list",
    "params": {}
}
```

**Response:**
```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "resources": [
            {
                "uri": "ui://wolfram/wolframalpha-viewer",
                "name": "WolframAlpha Interactive Viewer",
                "description": "Interactive viewer for WolframAlpha results as cloud notebooks with follow-up queries.",
                "mimeType": "text/html;profile=mcp-app"
            },
            {
                "uri": "ui://wolfram/evaluator-viewer",
                "name": "Wolfram Language Evaluator Viewer",
                "description": "Interactive viewer for Wolfram Language evaluation results with CloudDeploy support.",
                "mimeType": "text/html;profile=mcp-app"
            }
        ]
    }
}
```

### Resources Read

**Request:**
```json
{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "resources/read",
    "params": { "uri": "ui://wolfram/wolframalpha-viewer" }
}
```

**Response:**
```json
{
    "jsonrpc": "2.0",
    "id": 2,
    "result": {
        "contents": [{
            "uri": "ui://wolfram/wolframalpha-viewer",
            "mimeType": "text/html;profile=mcp-app",
            "text": "<!DOCTYPE html><html lang=\"en\"><head>...</head><body>...</body></html>",
            "_meta": {
                "ui": {
                    "csp": {
                        "connectDomains": [],
                        "resourceDomains": [],
                        "frameDomains": []
                    },
                    "prefersBorder": true
                }
            }
        }]
    }
}
```

**Error response (unknown URI):**
```json
{
    "jsonrpc": "2.0",
    "id": 2,
    "error": { "code": -32602, "message": "UI resource not found: ui://wolfram/unknown" }
}
```

### Tools List (UI-capable client)

**Response (excerpt):**
```json
{
    "tools": [
        {
            "name": "WolframAlpha",
            "description": "Use natural language queries with Wolfram|Alpha...",
            "inputSchema": { ... },
            "_meta": {
                "ui": {
                    "resourceUri": "ui://wolfram/wolframalpha-viewer",
                    "visibility": ["model", "app"]
                }
            }
        },
        {
            "name": "WolframLanguageEvaluator",
            "description": "Evaluates Wolfram Language code...",
            "inputSchema": { ... },
            "_meta": {
                "ui": {
                    "resourceUri": "ui://wolfram/evaluator-viewer",
                    "visibility": ["model", "app"]
                }
            }
        }
    ]
}
```

### Tools Call

Tool call and result format is unchanged for most tools. The host forwards the result to the UI app via `ui/notifications/tool-result` using the standard content items format that the server already produces.

**Exception: WolframAlpha tool result (UI-capable client):**

When `$clientSupportsUI` is `True`, the WolframAlpha tool prepends a JSON metadata content item with the cloud notebook URL:

```json
{
    "jsonrpc": "2.0",
    "id": 5,
    "result": {
        "content": [
            {
                "type": "text",
                "text": "{\"notebookUrl\":\"https://www.wolframcloud.com/obj/user/MCPServer/Notebooks/WolframAlpha/current+distance+to+Mars.nb\"}"
            },
            {
                "type": "text",
                "text": "Input: current distance to Mars\n\nResult: 1.234 AU (astronomical units)..."
            },
            {
                "type": "image",
                "mimeType": "image/png",
                "data": "iVBOR..."
            }
        ],
        "isError": false
    }
}
```

**WolframAlpha tool result (non-UI client, unchanged):**

```json
{
    "jsonrpc": "2.0",
    "id": 5,
    "result": {
        "content": [
            {
                "type": "text",
                "text": "Input: current distance to Mars\n\nResult: 1.234 AU (astronomical units)..."
            },
            {
                "type": "image",
                "mimeType": "image/png",
                "data": "iVBOR..."
            }
        ],
        "isError": false
    }
}
```

---

## Security Considerations

### Content Security Policy

CSP metadata flows as follows:

1. **Server** declares CSP requirements in `_meta.ui.csp` within the `resources/read` response
2. **Host** reads the CSP metadata and constructs HTTP `Content-Security-Policy` headers (or equivalent) for the iframe
3. **Host** applies a restrictive default CSP if the server omits the `csp` field:
   ```
   default-src 'none'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; connect-src 'none'
   ```

The server does **not** generate CSP headers or embed them in the HTML. The server only declares *what external access the app requires*; the host enforces it.

**Per-app CSP:**

- **WolframAlpha viewer**: Requires `connectDomains` for `https://www.wolframcloud.com` (WolframNotebookEmbedder API communication), `resourceDomains` for `https://unpkg.com` (embedder JS library) and `https://www.wolframcloud.com` (notebook resources), and `frameDomains` for `https://www.wolframcloud.com` and `https://wolfr.am` (embedded notebook iframe). This is identical to the NotebookViewer CSP because both apps use the same WolframNotebookEmbedder approach.
- **Evaluator viewer**: Requires `frameDomains` for `https://www.wolframcloud.com` and `https://wolfr.am` to embed CloudDeploy results. No `connectDomains` needed since the app does not make direct API calls. The `script-src` and `style-src` directives use the host's defaults (`'self' 'unsafe-inline'`).

### Iframe Sandbox

All apps run in sandboxed iframes controlled by the host. The server does not control iframe sandbox attributes; it only declares CSP and permission requirements via `_meta.ui` in the `resources/read` response. The host applies sandbox attributes (typically `sandbox="allow-scripts allow-same-origin"`) and sets CSP headers based on the server's declared metadata.

### Tool Visibility

App-only tools (visibility `["app"]`) prevent the LLM from accidentally calling internal tools. Visibility enforcement is a **host responsibility**: the host filters the tool list before presenting it to the LLM. The server includes visibility metadata in the `_meta.ui.visibility` field for the host to use.

Additionally, the server excludes app-only tools from `tools/list` when `$clientSupportsUI` is `False`, as a defense-in-depth measure.

### Input Validation

- `resources/read` URIs are validated against the registry; unknown URIs return an error
- HTML apps are static assets bundled with the paclet, not dynamically generated from user input
- No user-controlled content is interpolated into HTML templates at the server level
- HTML asset files are treated as trusted (they ship with the paclet); there is no runtime sanitization of asset content
- Tool results forwarded to apps (via `ui/notifications/tool-result`) contain the same content items the server already produces; apps are responsible for safely rendering this data

---

## Testing Plan

### Unit Tests

Create `Tests/MCPApps.wlt`:

#### Extension Negotiation

1. **UI client negotiation** -- `initResponse` includes `extensions` when client advertises UI support
2. **Non-UI client** -- `initResponse` omits `extensions` when client does not advertise UI
3. **clientSupportsUIQ** -- correctly parses various client capability formats

#### Resource Registry

4. **loadUIResource** -- loads HTML file and optional JSON metadata
5. **initializeUIResources** -- populates registry from assets directory
6. **Missing assets** -- graceful fallback when assets directory is missing

#### Resource Handlers

7. **resources/list** -- returns UI resources for UI-capable clients, empty for others
8. **resources/read** -- returns HTML content and metadata for valid URI
9. **resources/read unknown URI** -- returns error for unknown URI

#### Tool Metadata

10. **toolUIMetadata** -- attaches `_meta.ui` for tools with UI associations
11. **toolUIMetadata no association** -- returns empty for tools without UI
12. **tools/list with UI** -- includes `_meta` in tool definitions for UI clients
13. **tools/list without UI** -- omits `_meta` for non-UI clients

#### App-Only Tools

14. **App-only tool registration** -- app-only tools registered when UI supported
15. **App-only tool visibility** -- visibility is `["app"]` in tool list
16. **App-only tools absent** -- not registered when UI not supported

#### WolframAlpha Tool (UI-Aware Behavior)

17. **WolframAlpha tool with UI support** -- when `$clientSupportsUI` is `True`, `wolframAlphaToolEvaluateUI` returns content items including a JSON metadata item with `notebookUrl` key
18. **WolframAlpha tool without UI support** -- when `$clientSupportsUI` is `False`, `wolframAlphaToolEvaluate` returns text + base64 PNG only (backward compatibility)
19. **WolframAlpha tool fallback on CloudDeploy failure** -- when `$clientSupportsUI` is `True` but CloudDeploy fails, the tool falls back to text + base64 PNG behavior
20. **Metadata content item format** -- the JSON metadata item parses correctly and contains a valid wolframcloud.com URL

### Integration Tests

21. **Full initialize handshake** -- send initialize with UI extension, verify response
22. **Full resource fetch** -- initialize -> resources/list -> resources/read
23. **Tool call with UI metadata** -- initialize -> tools/list, verify _meta present
24. **Backward compatibility** -- initialize without extensions, verify identical behavior to current

---

## Implementation Files Summary

| File | Action | Purpose |
|------|--------|---------|
| `Specs/MCPApps.md` | Create | This specification |
| `Kernel/UIResources.wl` | Create | UI resource registry, loading, serving |
| `Kernel/StartMCPServer.wl` | Edit | Extension negotiation, `initResult` refactor, `resources/read` handler, tool metadata |
| `Kernel/CommonSymbols.wl` | Edit | Add `$clientSupportsUI`, `$uiResourceRegistry`, `$toolUIAssociations` |
| `Kernel/Messages.wl` | Edit | Add UI-related error messages |
| `Kernel/Tools/Tools.wl` | Edit | Register `UIResources` subcontext, add app-only tools |
| `Kernel/Tools/WolframAlpha.wl` | Edit | Branch on `$clientSupportsUI`: add notebook formatting, CloudDeploy, metadata content item |
| `PacletInfo.wl` | Edit | Register `Assets/Apps` asset location |
| `Assets/Apps/wolframalpha-viewer.html` | Edit | WolframAlpha viewer -- rewrite to use WolframNotebookEmbedder for cloud notebook embedding |
| `Assets/Apps/wolframalpha-viewer.json` | Edit | CSP metadata -- change to wolframcloud.com + unpkg.com (matches notebook-viewer.json) |
| `Assets/Apps/evaluator-viewer.html` | Create | WL Evaluator interactive viewer app |
| `Assets/Apps/evaluator-viewer.json` | Create | CSP metadata for evaluator viewer |
| `Tests/MCPApps.wlt` | Create | Test suite |

---

## Phase Dependencies

```
Phase 1 (Infrastructure)
    ├── 1.1 Extension Negotiation (foundation for everything)
    ├── 1.2 UI Resource Registry (depends on 1.1)
    ├── 1.3 Resources Handler (depends on 1.2)
    ├── 1.4 Tool Metadata (depends on 1.1)
    ├── 1.5 Graceful Degradation (verified throughout)
    └── 1.6-1.8 Directory structure, messages, PacletInfo

Phase 2 (WolframAlpha App)
    └── Depends on Phase 1 complete
    └── Can be developed/tested independently once Phase 1 is in place

Phase 3 (Evaluator App)
    └── Depends on Phase 1 complete
    └── Can be developed in parallel with Phase 2

Phase 4 (App-Only Tools) [Optional]
    └── Depends on Phase 1 (tool registration) + Phase 3 (evaluator app)
    └── Can be deferred; Phase 2 uses iframe natively, Phase 3 can use existing tools
    └── Go/no-go decision after Phase 3 is implemented and tested
```

---

## Future Considerations

1. **Dynamic UI resources** -- Generate HTML apps dynamically based on tool results (e.g., specialized viewers for different WA result types)
2. **Notebook rendering** -- An MCP App that renders Wolfram notebooks in the conversation
3. **Manipulate support** -- Direct support for `Manipulate` expressions via CloudDeploy + iframe
4. **Streaming results** -- Use `ui/notifications/tool-input-partial` for streaming partial WL evaluation results
5. **Context updates** -- Use `ui/update-model-context` to feed interactive exploration results back to the LLM
6. **Additional viewers** -- Specialized apps for 3D graphics (`Graphics3D`), datasets (`Dataset`), entity stores, etc.
7. **Theme sync** -- Read host theme CSS variables and apply Wolfram-style formatting that matches the host's appearance
8. **Hot-reload for development** -- Reload HTML app assets without restarting the server (e.g., watch `Assets/Apps/` for changes)
9. **Asset versioning** -- Cache-busting mechanism so hosts re-fetch updated apps when the paclet version changes
