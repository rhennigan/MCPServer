---
name: verify
description: Runtime-verify AgentTools changes — drive the real MCP tool pipeline and render MCP Apps viewers in a browser to observe results at their surface.
---

# Verifying AgentTools changes at runtime

## Wolfram Language side (tools, server, UI results)

- **Always set `WOLFRAMSCRIPT_KERNELPATH="C:/Program Files/Wolfram Research/Wolfram/15.0/wolfram.exe"`** (or newer). Plain `wolframscript` may pick an older kernel; AgentTools requires 15.0+, and under an older kernel `PacletDirectoryLoad` + ``Get["Wolfram`AgentTools`"]`` *silently* falls back to the installed Repository paclet — you exercise the wrong code. Confirm with ``FindFile["Wolfram`AgentTools`"]`` → must resolve under the dev directory.
- Load the dev paclet: ``PacletDirectoryLoad["H:\\Documents\\AgentTools"]; Get["Wolfram`AgentTools`"]``.
- To drive a tool exactly as the MCP server dispatches it, call its registered `"Function"` (see `$defaultMCPTools[name]` in `Kernel/Tools/*.wl`) with the parsed-args association, e.g. ``Wolfram`AgentTools`Tools`WolframLanguageEvaluator`Private`evaluateWolframLanguage[<|"code" -> ...|>]``.
- To trigger the MCP Apps UI path (cloud-deployed notebook + `_meta.notebookUrl`), first set ``Wolfram`AgentTools`Common`$clientSupportsUI = True`` and be cloud-connected. Export the result with ``Developer`WriteRawJSONFile`` — it is the exact content/_meta payload a host forwards to a viewer.
- For an A/B against pre-change behavior, `git worktree add <scratch>/head-copy HEAD` and point `PacletDirectoryLoad` at the worktree in a second wolframscript run. Use a *different* input (the deploy target is content-hashed, same input overwrites the same cloud object). Remove the worktree afterwards.

## MCP Apps viewers (Assets/Apps/*.html)

- All viewers speak the same iframe protocol: they send `ui/initialize` (reply with `{protocolVersion, hostInfo, hostContext}`), then notify `ui/notifications/initialized`; after that, post `{jsonrpc:"2.0", method:"ui/notifications/tool-result", params:{content, _meta}}` into the iframe.
- Harness that works: a `host.html` that iframes the viewer and plays the host role over postMessage + a no-dep node static server + Playwright (`npm i playwright` locally; chromium via `npx playwright install chromium`). Set `colorScheme: "dark"` on the browser context to reproduce dark-host bugs; the embed needs real network (unpkg CDN + wolframcloud.com) and takes 10–60 s.
- The notebook embedder (`useShadowDOM: true`) attaches an **open shadow root to a wrapper `<div>` it creates inside the container**, not to the container itself. Wait for embed completion by recursively searching open shadow roots for expected notebook text; read computed styles with `getComputedStyle` on shadow-tree elements.
- Playwright frame-picking gotcha: the host page URL carries the viewer filename in its query string, so match `f !== page.mainFrame()` when locating the viewer frame.
- Verified evidence to capture: computed `color` of shadow text leaves (dark-theme leak shows as `rgb(224, 224, 224)`), computed `font-family`, and full-page screenshots.
