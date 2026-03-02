# Tool Options — Design Specification

## Overview

Tool Options lets users customize the behavior of built-in MCP tools at install time. By passing a `"ToolOptions"` option to `InstallMCPServer`, users can override default values for tool-specific settings without modifying source code.

---

## Usage

`InstallMCPServer` accepts a `"ToolOptions"` option whose value is an `Association` mapping tool names to option associations:

```wl
InstallMCPServer[
    "ClaudeCode",
    "WolframLanguage",
    "ToolOptions" -> <|
        "WolframLanguageContext" -> <|"MaxItems" -> 5|>,
        "WolframLanguageEvaluator" -> <|"Method" -> "Local"|>
    |>
]
```

- Keys must be tool names (strings matching keys in `$DefaultMCPTools`).
- Values must be associations of option name to option value.
- Unrecognized tool names or option names produce warnings but do not cause failure, allowing forward compatibility.

### Inspecting Defaults

The current default tool options can be inspected via:

```wl
$DefaultMCPToolOptions
```

### Resolution Priority

When determining the value for a tool option at runtime:

1. User-specified value (from `"ToolOptions"`) — highest priority
2. Built-in default — lowest priority

---

## Available Tool Options

### WolframLanguageEvaluator

| Option | Type | Default | Description |
|---|---|---|---|
| `Method` | `String` | `"Session"` | Evaluation method. `"Session"` uses the server kernel; `"Local"` spawns a separate kernel. |
| `ImageExportMethod` | `String` or `None` | `None` | How to export graphics. `None`, `"Local"`, `"Cloud"`, or `"CloudPublic"`. |
| `TimeConstraint` | `Integer` | `60` | Default time limit (seconds) when the LLM doesn't specify `timeConstraint`. The LLM can still override this per-call via the `timeConstraint` parameter. |

### WolframLanguageContext

| Option | Type | Default | Description |
|---|---|---|---|
| `MaxItems` | `Integer` | `10` | The effective number of documentation results to return. |

### WolframAlphaContext

| Option | Type | Default | Description |
|---|---|---|---|
| `MaxItems` | `Integer` or `Automatic` | `Automatic` | Maximum number of Wolfram\|Alpha results. `Automatic` defers to internal defaults. |
| `IncludeWolframLanguageResults` | `Boolean` or `Automatic` | `Automatic` | Whether to include Wolfram Language code results alongside Wolfram\|Alpha results. |

### WolframContext

| Option | Type | Default | Description |
|---|---|---|---|
| `WolframLanguageMaxItems` | `Integer` | `10` | Max documentation results (same semantics as `WolframLanguageContext` `MaxItems`). |
| `WolframAlphaMaxItems` | `Integer` or `Automatic` | `Automatic` | Max Wolfram\|Alpha results. |

Note: `WolframContext` options are independent of the individual tool options. Setting `"WolframContext" -> <|"WolframLanguageMaxItems" -> 20|>` does *not* affect calls to the standalone `WolframLanguageContext` tool, and vice versa.

### Tools Without Options

The following tools have no configurable options:

- **CodeInspector**
- **SymbolDefinition**
- **TestReport**
- **WolframAlpha**
- **WriteNotebook**
- **ReadNotebook**

---

## Backward Compatibility

The following legacy environment variables have been **removed** and are no longer supported:

| Removed Variable | Replaced By |
|---|---|
| `WOLFRAM_LANGUAGE_EVALUATOR_METHOD` | `"WolframLanguageEvaluator" -> <\|"Method" -> ...\|>` |
| `WOLFRAM_LANGUAGE_EVALUATOR_IMAGE_EXPORT_METHOD` | `"WolframLanguageEvaluator" -> <\|"ImageExportMethod" -> ...\|>` |

---

## Phase 2 Preview (Future)

### Options Derived From Parameters

For each tool in `$DefaultMCPTools`, automatically derive options from optional parameters:

- **`<ParameterName>`**: Forces a fixed value; removes the parameter from the tool schema exposed via MCP.
- **`Default<ParameterName>`**: Sets a default value; the parameter remains in the schema for LLM override.

Example:
```wl
"ToolOptions" -> <|
    "CodeInspector" -> <|
        "ConfidenceLevel" -> 0.25,              (* Forces value; removes from schema *)
        "DefaultSeverityExclusions" -> {"Remark", "Scoping"}  (* Sets default; keeps in schema *)
    |>
|>
```

### Additional Future Options

- **CodeInspector**: `MaxPageWidth`, `MaxLineCount`
- **WolframLanguageEvaluator**: `Initialization` (code to run when the evaluator kernel starts)
- **WolframContext**: `WolframLanguageSources` (control which documentation sources are searched)
