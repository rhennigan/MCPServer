# Tool Options — Design Specification

## Overview

Tool Options is a mechanism for users to customize the behavior of built-in MCP tools at install time. By passing a `"ToolOptions"` option to `InstallMCPServer`, users can override default values for tool-specific settings without modifying source code.

## Goals

- Allow users to customize tool behavior (e.g., MaxItems, evaluator Method) via `InstallMCPServer`
- Persist options through environment variables so they're available at server runtime
- Provide a clean `toolOptionValue` API for tool implementations to read options with fallback to defaults
- ~~Deprecate the existing per-tool environment variables~~ (removed — legacy env vars are no longer supported)

---

## API Surface

### InstallMCPServer Option

Add `"ToolOptions"` to the options of `InstallMCPServer`:

```wl
InstallMCPServer // Options = {
    "ApplicationName"    -> Automatic,
    "DevelopmentMode"    -> False,
    "EnableMCPApps"      -> True,
    "ProcessEnvironment" -> Automatic,
    "ToolOptions"        -> <||>,         (* NEW *)
    "VerifyLLMKit"       -> True
};
```

### Usage

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

The value must be an `Association` where:
- Keys are tool names (strings matching keys in `$DefaultMCPTools`)
- Values are associations of option name → option value

---

## Storage Mechanism

### Serialization at Install Time

When `InstallMCPServer` is called with a non-empty `"ToolOptions"`:

1. Serialize the tool options association to a JSON string using ``Developer`WriteRawJSONString[..., "Compact" -> True]``
2. Set `"MCP_TOOL_OPTIONS"` in the server's environment variables to this JSON string

This happens inside `addEnvironmentVariables` (or a new helper called from the same location), alongside the existing `MCP_APPS_ENABLED` logic.

### JSON Format

The environment variable value is a flat JSON object of the form:

```json
{
    "WolframLanguageContext": {"MaxItems": 5},
    "WolframLanguageEvaluator": {"Method": "Local", "TimeConstraint": 120}
}
```

### Value Mapping (Wolfram Language → JSON)

At runtime, the JSON is read with ``Developer`ReadRawJSONString`` and then processed by `parseToolOptions0`, which converts string values to their corresponding Wolfram Language symbols during parsing:

- `"Automatic"` → `Automatic`
- `"None"` → `None`

This conversion happens at parse time (in `parseToolOptions0`), not at lookup time.

### Size Considerations

Environment variable limits are generous (32,767 chars on Windows; ~128KB+ combined on Linux/macOS). Typical tool options JSON will be well under 1KB. If a `file://` fallback is ever needed, it can be added later without changing the runtime API.

---

## Runtime Retrieval

### New Shared Symbols

Add to `Kernel/CommonSymbols.wl`:

```wl
`$toolOptions;
`$defaultToolOptions;
`toolOptionValue;
```

### Initialization in StartMCPServer

At server startup (in `startMCPServer`, before the main request loop), read and parse the environment variable:

```wl
$toolOptions = parseToolOptions @ Environment["MCP_TOOL_OPTIONS"];
```

Where `parseToolOptions` handles:
- `$Failed` or non-string → `<||>` (no options set)
- Valid JSON string → parsed and validated association (via `parseToolOptions0`)

`parseToolOptions0` recursively processes the parsed JSON:
1. At the top level, validates that the result is an `Association` (returns `<||>` otherwise)
2. For each tool entry, validates that the options value is an `Association` (drops non-association values via `Nothing`)
3. For each individual option value, converts symbol strings (`"Automatic"` → `Automatic`, `"None"` → `None`)

### $defaultToolOptions

Define default values alongside `$defaultMCPTools` in `Kernel/Tools/Tools.wl`:

```wl
$defaultToolOptions = <|
    "WolframLanguageEvaluator" -> <|
        "Method"            -> "Session",
        "ImageExportMethod" -> None,
        "TimeConstraint"    -> 60
    |>,
    "WolframLanguageContext" -> <|
        "MaxItems" -> 10
    |>,
    "WolframAlphaContext" -> <|
        "MaxItems"                       -> Automatic,
        "IncludeWolframLanguageResults"  -> Automatic
    |>,
    "WolframContext" -> <|
        "WolframLanguageMaxItems" -> 10,
        "WolframAlphaMaxItems"    -> Automatic
    |>
|>;
```

### toolOptionValue

```wl
toolOptionValue[ toolName_String, optionName_String ] := Enclose[
    Catch @ Module[ { options },
        options = ConfirmBy[ Lookup[ $toolOptions, toolName, <| |> ], AssociationQ, "ToolOptions" ];
        Lookup[
            options,
            optionName,
            Lookup[
                ConfirmBy[ Lookup[ $defaultToolOptions, toolName, <| |> ], AssociationQ, "Defaults" ],
                optionName,
                Missing[ "ToolOption", { toolName, optionName } ]
            ]
        ]
    ],
    throwInternalFailure
];
```

This provides a two-level fallback: user-specified → default → `Missing`. The `ConfirmBy` calls validate that the looked-up values are associations, following the project's error handling patterns.

---

## Per-Tool Option Tables

### WolframLanguageEvaluator

| Option | Type | Default | Description |
|---|---|---|---|
| `Method` | `String` | `"Session"` | Evaluation method. `"Session"` uses the server kernel; `"Local"` spawns a separate kernel. |
| `ImageExportMethod` | `String` or `None` | `None` | How to export graphics. `None`, `"Local"`, `"Cloud"`, or `"CloudPublic"`. |
| `TimeConstraint` | `Integer` | `60` | Default time limit (seconds) when the LLM doesn't specify `timeConstraint`. The LLM can still override this per-call via the `timeConstraint` parameter. |

**Implementation notes:**
- Replace `$evaluatorMethod` and `$imageExportMethod` (currently read from `Environment[]`) with calls to `toolOptionValue["WolframLanguageEvaluator", "Method"]` and `toolOptionValue["WolframLanguageEvaluator", "ImageExportMethod"]`.
- For `TimeConstraint`: in `evaluateWolframLanguage`, when `timeConstraint` is `_Missing`, use `toolOptionValue["WolframLanguageEvaluator", "TimeConstraint"]` instead of the hard-coded `60`.

### WolframLanguageContext

| Option | Type | Default | Description |
|---|---|---|---|
| `MaxItems` | `Integer` | `10` | The effective number of documentation results to return. |

**Implementation notes:**

`MaxItems` maps differently depending on LLMKit subscription status:

Both subscribed and unsubscribed paths use the same call signature:
```wl
cb`RelatedDocumentation[
    context, "Prompt",
    "PromptHeader"    -> False,
    "FilterResults"   -> subscribed,
    "FilteredCount"   -> max,       (* Ignored when "FilterResults" is False *)
    MaxItems          -> If[ subscribed, max * 5, max ]
]
```

Where `max = toolOptionValue["WolframLanguageContext", "MaxItems"]`.

The current hard-coded values are `MaxItems -> 50` (subscribed) and `MaxItems -> 10` (unsubscribed). With the new mapping, the default `MaxItems -> 10` preserves the unsubscribed behavior (`MaxItems -> 10`) and changes the subscribed behavior to `FilteredCount -> 10, MaxItems -> 50` — matching the current behavior.

### WolframAlphaContext

| Option | Type | Default | Description |
|---|---|---|---|
| `MaxItems` | `Integer` or `Automatic` | `Automatic` | Maximum number of Wolfram\|Alpha results. `Automatic` defers to `RelatedWolframAlphaResults` defaults. |
| `IncludeWolframLanguageResults` | `Boolean` or `Automatic` | `Automatic` | Whether to include Wolfram Language code results. Maps to `"IncludeWLResults"` option in `cb`RelatedWolframAlphaResults`. |

**Implementation notes:**
- `relatedWolframAlphaResults` must be updated to pass these options through to `cb`RelatedWolframAlphaResults`:
  ```wl
  cb`RelatedWolframAlphaResults[
      context, "Prompt",
      "MaxItems"        -> toolOptionValue["WolframAlphaContext", "MaxItems"],
      "IncludeWLResults" -> toolOptionValue["WolframAlphaContext", "IncludeWolframLanguageResults"]
  ]
  ```
- When values are `Automatic`, `RelatedWolframAlphaResults` uses its own defaults (no behavioral change).

### WolframContext

| Option | Type | Default | Description |
|---|---|---|---|
| `WolframLanguageMaxItems` | `Integer` | `10` | Max documentation results (same semantics as `WolframLanguageContext.MaxItems`). |
| `WolframAlphaMaxItems` | `Integer` or `Automatic` | `Automatic` | Max Wolfram\|Alpha results. |

**Implementation notes:**
- `IncludeWLResults` is always set to `True` when called from `WolframContext` (as stated in the proposal).
- These options are independent of the individual tool options. Setting `"WolframContext" -> <|"WolframLanguageMaxItems" -> 20|>` does *not* affect calls to the standalone `WolframLanguageContext` tool, and vice versa.
- `relatedWolframContext` must be updated to pass these values to the underlying `relatedDocumentation` and `relatedWolframAlphaPrompt` calls, using new internal argument signatures (e.g., adding a `maxItems` parameter to the internal functions).

### Tools Without Options (Phase 1)

The following tools have no configurable options in Phase 1:

- **CodeInspector** — No options
- **SymbolDefinition** — No options
- **TestReport** — No options
- **WolframAlpha** — No options
- **WriteNotebook** — No options
- **ReadNotebook** — No options

---

## Backward Compatibility

### Removed: Legacy Environment Variables

The following environment variables have been **removed** and are no longer supported:

| Removed Variable | Replaced By |
|---|---|
| `WOLFRAM_LANGUAGE_EVALUATOR_METHOD` | `"WolframLanguageEvaluator" -> <\|"Method" -> ...\|>` |
| `WOLFRAM_LANGUAGE_EVALUATOR_IMAGE_EXPORT_METHOD` | `"WolframLanguageEvaluator" -> <\|"ImageExportMethod" -> ...\|>` |

### Resolution Priority

When determining the value for any tool option:

1. `$toolOptions` (from `MCP_TOOL_OPTIONS` env var) — highest priority
2. `$defaultToolOptions` — lowest priority

The previously planned three-level fallback (user option → legacy env var → default) was simplified to a two-level fallback, since the legacy `migrateLegacyEnvVars` mechanism was removed before release.

---

## Validation

### At Install Time

When `InstallMCPServer` processes the `"ToolOptions"` value:

1. **Type check**: Confirm the value is an `Association` (or `<||>`).
2. **Tool name check**: For each key, verify it matches a tool name in the server's tool list. Issue a warning (via `messagePrint`) for unrecognized tool names, but do **not** fail — this allows forward compatibility.
3. **Option name check**: For each tool's options, verify the option names are recognized by checking against `$defaultToolOptions`. Issue a warning for unrecognized option names.
4. **Value type check**: Validate that option values have the expected types (e.g., `Method` is a string, `MaxItems` is an integer or `Automatic`). Issue a warning for type mismatches.

Warnings are non-fatal so that users aren't blocked by version mismatches or typos in non-critical options.

---

## New Symbols in CommonSymbols.wl

Add the following to `Kernel/CommonSymbols.wl`:

```wl
(* Tool options: *)
`$toolOptions;
`$defaultToolOptions;
`toolOptionValue;
```

---

## Files Modified

| File | Changes |
|---|---|
| `Kernel/CommonSymbols.wl` | Declare `$toolOptions`, `$defaultToolOptions`, `toolOptionValue` |
| `Kernel/InstallMCPServer.wl` | Add `"ToolOptions"` option; serialize to `MCP_TOOL_OPTIONS` env var; add validation |
| `Kernel/StartMCPServer.wl` | Parse `MCP_TOOL_OPTIONS` at startup; populate `$toolOptions` via `parseToolOptions`/`parseToolOptions0` with validation and symbol conversion |
| `Kernel/Tools/Tools.wl` | Define `$defaultToolOptions`; define `toolOptionValue`; add `$DefaultMCPToolOptions` to MX initialization |
| `Kernel/Tools/WolframLanguageEvaluator.wl` | Replace `$evaluatorMethod`/`$imageExportMethod` with `toolOptionValue` calls; use `toolOptionValue` for `TimeConstraint` default |
| `Kernel/Tools/Context.wl` | Use `toolOptionValue` in `relatedDocumentation0`, `relatedWolframAlphaResults`, and `relatedWolframContext`; pass options through to `cb` functions |

---

## Phase 2 Preview (Future — Not for Initial Implementation)

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

---

## Verification Steps

### Unit Tests

1. **Serialization round-trip**: Verify that tool options survive `Association → JSON → Association` conversion.
2. **toolOptionValue fallback**: Verify the two-level priority (user option → default).
3. **WolframLanguageEvaluator**: Verify that `Method`, `ImageExportMethod`, and `TimeConstraint` are read from tool options.
4. **WolframLanguageContext MaxItems**: Verify subscribed vs unsubscribed mapping with custom `MaxItems`.
5. **WolframAlphaContext**: Verify `MaxItems` and `IncludeWolframLanguageResults` are passed through.
6. **WolframContext**: Verify `WolframLanguageMaxItems` and `WolframAlphaMaxItems` are used independently of individual tool settings.
7. **Validation warnings**: Verify warnings are issued for unrecognized tool names and option names.
8. **Symbol conversion**: Verify that `parseToolOptions` converts `"Automatic"` → `Automatic` and `"None"` → `None` during parsing.
9. **Non-association value handling**: Verify that `parseToolOptions` drops tool entries whose values are not associations (e.g., `"WolframLanguageEvaluator": 123` is silently discarded).

### Integration Test

1. Call `InstallMCPServer` with `"ToolOptions"` set.
2. Verify the generated config file contains `"MCP_TOOL_OPTIONS"` in the `"env"` block.
3. Start the server and confirm tools use the custom option values.
