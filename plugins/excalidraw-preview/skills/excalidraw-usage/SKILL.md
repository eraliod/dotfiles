---
name: excalidraw-usage
description: This skill should be used when calling `mcp__excalidraw__create_view`, when the user asks to "draw a diagram", "create an excalidraw", "render an excalidraw", "show me a diagram of...", or otherwise creates visual diagrams via the Excalidraw MCP server. Defines the label, font, payload, and checkpoint conventions required by the excalidraw-preview plugin's local preview server.
---

# Excalidraw Preview Usage

The excalidraw-preview plugin runs a local HTTP server at `127.0.0.1:8080` that renders Excalidraw diagrams immediately when `mcp__excalidraw__create_view` is called. The plugin pre-processes diagram payloads through `expandLabels()` and `fixStandaloneText()` in the preview's `index.html` before handing them to Excalidraw.

The following conventions are required by the preview's polling and parsing logic. Departing from them produces silent render failures or zero-sized elements.

## Payload Conventions

- **Always send the full diagram.** The preview replaces the entire scene on each poll; it has no checkpoint or diff mechanism.
- **Never use `restoreCheckpoint`.** The preview filters this pseudo-element out — referencing prior checkpoints will not restore them.
- **Re-send the entire elements array every time.** The previous render is wiped before each new payload is applied.

## Fonts

- Default to `fontFamily: 1` (Excalifont).
- Use `fontFamily: 2` (clean sans-serif) only when the user explicitly requests "clean labels".

## Labels on Shapes

The preview's `expandLabels()` converts a `label` field on a shape into a bound text element. Two forms are accepted:

- **Full form (preferred):** `label: { text: "...", fontSize: 20, fontFamily: 1, strokeColor: "..." (optional) }`
- **Shorthand:** `label: "..."` — equivalent to `{ text: "..." }`. `fontSize` defaults to 20, `fontFamily` defaults to 1.

Include `fontSize` explicitly whenever text size matters for layout.

## Standalone Text Elements

For top-level text elements not bound to a shape:

- Always provide `fontSize`. The preview's `fixStandaloneText()` estimates `width` and `height` from `fontSize` and `text` length — omitting it produces zero-sized text that Excalidraw refuses to render.

## Multi-Line Text

- Use `\n` inside the label or text string. Works for both bound labels and standalone text elements.
