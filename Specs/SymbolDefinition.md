# SymbolDefinition Tool - Detailed Specification

## Overview

This specification defines an MCP tool for retrieving symbol definitions in a readable, formatted output. The tool is designed to help LLMs understand Wolfram Language code by providing clean, context-aware definition strings.

## Goals

- Create an MCP tool to get definitions of symbols in a nice readable format
- Support multiple symbols in a single request
- Handle `ReadProtected` symbols by temporarily clearing the attribute
- Provide optional context information showing which symbols belong to which contexts
- Implement sensible truncation for very large definitions
- Fall back to standard definition format if readable formatting times out

---

## Tool: SymbolDefinition

### Purpose

Retrieves the definitions of one or more Wolfram Language symbols and returns them in a readable markdown format. The tool generates clean, formatted definition strings by intelligently managing the context path to minimize fully qualified symbol names.

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `symbols` | String | Yes | - | Symbol name(s), comma-separated for multiple symbols. Can be fully qualified or unqualified. |
| `includeContextDetails` | Boolean | No | `false` | Whether to include a JSON map showing which symbols belong to which contexts |
| `maxLength` | Integer | No | `10000` | Maximum character length for output before truncation |

#### Symbols Parameter

The `symbols` parameter accepts one or more symbol names. Multiple symbols should be separated by commas. Symbol names can be either fully qualified (with context) or unqualified. Unqualified names are resolved using the current `$ContextPath`, just like `Definition` does.

**Examples:**
- Unqualified symbol: `"Plus"`
- Fully qualified symbol: ``"System`Plus"``
- Multiple unqualified symbols: `"Plus, Subtract, Times"`
- Multiple fully qualified symbols: ``"Wolfram`MCPServer`CreateMCPServer, Wolfram`MCPServer`StartMCPServer"``
- Private symbol (must be qualified): ``"Wolfram`MCPServer`Common`Private`catchMine"``
- Mixed: ``"Plus, Wolfram`MCPServer`CreateMCPServer"``

**Note:** For symbols in private contexts or contexts not on `$ContextPath`, fully qualified names are required.

The parameter goes through the Wolfram `Interpreter`, so symbol names should be valid Wolfram Language symbol specifications.

### Output Format

The tool returns a markdown-formatted string with the following structure:

#### Single Symbol

````markdown
# SymbolName

## Definition

```wl
<formatted definition code>
```

## Contexts

```json
{
  "Context1`": ["symbol1", "symbol2"],
  "Context2`": ["symbol3"]
}
```
````

The "Contexts" section is only included when `includeContextDetails` is `true`.

#### Multiple Symbols

When multiple symbols are requested, each symbol gets its own top-level heading:

````markdown
# FirstSymbolName

## Definition

```wl
<definition>
```

# SecondSymbolName

## Definition

```wl
<definition>
```

## Contexts

```json
{ ... }
```

# ThirdSymbolName

Error: ThirdSymbolName is `Locked` and `ReadProtected`
````

### Definition Formatting

The tool generates readable definition strings using the following approach:

1. **Extract Definition**: Use `Definition[symbol]` converted to a held expression via `ToExpression[ToString[Definition[symbol], InputForm], InputForm, HoldComplete]`

2. **Analyze Contexts**: Extract all symbols from the definition and determine their contexts

3. **Build Context Path**: Create an optimal `$ContextPath` that minimizes the need for fully qualified names:
   ```wl
   cPath = Reverse @ DeleteDuplicates @ Join[{"Global`", "System`"}, contexts]
   ```

4. **Generate Readable Form**: Use `ResourceFunction["ReadableForm"]` with a 5-second timeout to generate a nicely formatted definition string:
   ```wl
   TimeConstrained[
       Block[{$ContextPath = cPath, $Context = symbolContext},
           ToString[ResourceFunction["ReadableForm"][Unevaluated[expr], PageWidth -> 120]]
       ],
       5
   ]
   ```

5. **Fallback**: If `ReadableForm` times out, fall back to standard `InputForm` output

### Kernel Code Detection

Some symbols (especially built-in System symbols) have functionality implemented in compiled kernel code rather than Wolfram Language definitions. These symbols may have attributes and default values but no readable definition patterns.

**Example:**
```wl
Internal`InheritedBlock[{Plus},
    ClearAttributes[Plus, ReadProtected];
    ToString[Definition[Plus], InputForm]
]
(* Returns only attributes and defaults, no actual definition patterns *)
```

The tool should detect kernel code using the ``System`Private`Has*CodeQ`` functions and insert placeholder definitions to indicate the symbol does something:

#### Detection Functions

| Function | What It Detects | Placeholder Definition |
|----------|-----------------|------------------------|
| ``System`Private`HasDownCodeQ[sym]`` | Down values (normal function calls) | `sym[___] := <kernel function>` |
| ``System`Private`HasOwnCodeQ[sym]`` | Own values (symbol evaluates to something) | `sym := <kernel function>` |
| ``System`Private`HasSubCodeQ[sym]`` | Sub values (nested function calls) | `sym[___][___] := <kernel function>` |
| ``System`Private`HasUpCodeQ[sym]`` | Up values (pattern matching in arguments) | `_[___, sym, ___] := <kernel function>` |
| ``System`Private`HasPrintCodeQ[sym]`` | Format/print definitions | `Format[sym, _] := <kernel function>` |

All these functions have `HoldAllComplete` attribute, so they can be called directly with the symbol.

#### Implementation Logic

After extracting the standard definition, check for kernel code:

```wl
kernelDefinitions = {};

If[System`Private`HasDownCodeQ[symbol],
    AppendTo[kernelDefinitions, HoldForm[symbol[___] := "<kernel function>"]]
];

If[System`Private`HasOwnCodeQ[symbol],
    AppendTo[kernelDefinitions, HoldForm[symbol := "<kernel function>"]]
];

If[System`Private`HasSubCodeQ[symbol],
    AppendTo[kernelDefinitions, HoldForm[symbol[___][___] := "<kernel function>"]]
];

If[System`Private`HasUpCodeQ[symbol],
    AppendTo[kernelDefinitions, HoldForm[_[___, symbol, ___] := "<kernel function>"]]
];

If[System`Private`HasPrintCodeQ[symbol],
    AppendTo[kernelDefinitions, HoldForm[Format[symbol, _] := "<kernel function>"]]
];
```

These placeholder definitions should be included in the output, clearly marked as kernel implementations.

#### Example Output

For `Plus`:

````markdown
# Plus

## Definition

```wl
Attributes[Plus] = {Flat, Listable, NumericFunction, OneIdentity, Orderless, Protected}

Default[Plus] := 0

Plus[___] := <kernel function>
```
````

This indicates that while `Plus` has attributes and a default value, its actual computation is handled by the kernel.

### ReadProtected Handling

Many internal symbols have the `ReadProtected` attribute, which prevents their definitions from being read. The tool bypasses this using `Internal`InheritedBlock`:

```wl
Internal`InheritedBlock[{symbol},
    ClearAttributes[symbol, ReadProtected];
    (* generate definition *)
]
```

This temporarily clears `ReadProtected` within a local scope, ensuring the original symbol attributes are restored after the definition is extracted.

### Error Handling

#### Locked Symbols

If a symbol has both `Locked` and `ReadProtected` attributes, it cannot be accessed. The tool should return an error message under the symbol's heading:

```markdown
# SymbolName

Error: SymbolName is `Locked` and `ReadProtected`
```

#### Undefined Symbols

If a symbol exists but has no definitions:

```markdown
# SymbolName

No definitions found
```

#### Non-existent Symbols

If the symbol name doesn't correspond to any existing symbol:

```markdown
# SymbolName

Error: Symbol "SymbolName" does not exist
```

#### Invalid Symbol Names

If the symbol name is syntactically invalid:

```markdown
# InvalidName

Error: Invalid symbol name "InvalidName"
```

**Validation:** Use ``Internal`SymbolNameQ`` with the second argument set to `True` to validate symbol names (both qualified and unqualified):

```wl
Internal`SymbolNameQ["MyContext`MySymbolName", True]   (* True - valid qualified name *)
Internal`SymbolNameQ["MyContext`MySymbolName!", True]  (* False - invalid *)
Internal`SymbolNameQ["MySymbolName", True]             (* True - valid unqualified name *)
```

Note: Without the second argument, ``Internal`SymbolNameQ`` only validates simple (non-context-qualified) symbol names:

```wl
Internal`SymbolNameQ["MySymbolName"]           (* True *)
Internal`SymbolNameQ["MyContext`MySymbolName"] (* False - rejects context *)
```

### Truncation

If the formatted definition exceeds `maxLength` characters:

1. Truncate the definition at the character limit
2. Append a truncation indicator: `... [truncated, showing {n}/{total} characters]`
3. Truncation applies per-symbol, not to the total output

**Example:**
```markdown
# VeryLargeSymbol

## Definition

```wl
largeSymbol[args_] :=
    Module[{...},
        (* large body *)
        ...
... [truncated, showing 10000/45000 characters]
```

### Implementation Notes

1. **File Location**: `Kernel/Tools/SymbolDefinition.wl`

2. **Context Registration**: Add to `$subcontexts` in `Kernel/Tools/Tools.wl`:
   ```wl
   (* Tools: SymbolDefinition *)
   "Wolfram`MCPServer`Tools`SymbolDefinition`"
   ```

3. **Tool Definition Structure**:
   ```wl
   $defaultMCPTools["SymbolDefinition"] := LLMTool @ <|
       "Name"        -> "SymbolDefinition",
       "DisplayName" -> "Symbol Definition",
       "Description" -> $symbolDefinitionToolDescription,
       "Function"    -> getSymbolDefinition,
       "Parameters"  -> {
           "symbols" -> <|
               "Interpreter" -> "String",
               "Help"        -> "The symbol name (or multiple names, comma separated). Can be qualified or unqualified.",
               "Required"    -> True
           |>,
           "includeContextDetails" -> <|
               "Interpreter" -> "Boolean",
               "Help"        -> "Whether to include context details (default: false).",
               "Required"    -> False
           |>,
           "maxLength" -> <|
               "Interpreter" -> "Integer",
               "Help"        -> "Maximum character length for output (default: 10000).",
               "Required"    -> False
           |>
       }
   |>
   ```

4. **Resource Function**: The tool depends on `ResourceFunction["ReadableForm"]`. Use `importResourceFunction` to import it, which handles lazy loading and MX build optimization:

   In `Kernel/Tools/SymbolDefinition.wl`:
   ```wl
   importResourceFunction[ readableForm, "ReadableForm" ];
   ```

   Also add the version to `$resourceVersions` in `Kernel/Common.wl`:
   ```wl
   $resourceVersions = <|
       ...,
       "ReadableForm" -> "1.0.0"  (* or appropriate version *)
   |>;
   ```

   This ensures:
   - Lazy loading of the resource function when first used (avoids startup cost)
   - During MX builds, the function is baked into the MX file for faster loading without network calls
   - Version pinning for reproducibility

5. **Timeout Handling**: The 5-second timeout for `ReadableForm` should be configurable in the implementation but not exposed as a user parameter initially.

### Return Value

On success, return the formatted markdown string containing all requested symbol definitions.

On complete failure (e.g., all symbols invalid), return a descriptive error message.

---

## Examples

### Basic Usage - Unqualified Symbol

**Request:**
```json
{
  "tool": "SymbolDefinition",
  "parameters": {
    "symbols": "Map"
  }
}
```

**Response:**
````markdown
# Map

## Definition

```wl
Attributes[Map] = {Protected}

Map[___] := <kernel function>
```
````

### Basic Usage - Qualified Symbol

**Request:**
```json
{
  "tool": "SymbolDefinition",
  "parameters": {
    "symbols": "Wolfram`MCPServer`CreateMCPServer"
  }
}
```

**Response:**
````markdown
# CreateMCPServer

## Definition

```wl
CreateMCPServer[name_String] :=
    catchMine @ createMCPServer[name]

e$: HoldPattern[CreateMCPServer[___]] :=
    throwInternalFailure[e$, "UnhandledDownValues", HoldForm @ CreateMCPServer]
```
````

### With Context Details

**Request:**
```json
{
  "tool": "SymbolDefinition",
  "parameters": {
    "symbols": "Wolfram`MCPServer`Common`Private`catchMine",
    "includeContextDetails": true
  }
}
```

**Response:**
````markdown
# catchMine

## Definition

```wl
catchMine /: SetDelayed[lhs_, catchMine @ rhs_] :=
    Module[{eh$ = HoldComplete @ lhs},
        SetDelayed @@ Hold[lhs, catchTop[rhs, topLevelFailure[eh$, #] &]]
    ]
```

## Contexts

```json
{
  "System`": ["HoldComplete", "Hold", "Module", "SetDelayed"],
  "Wolfram`MCPServer`Common`Private`": ["catchMine", "catchTop", "topLevelFailure"]
}
```
````

### Multiple Symbols (Mixed Qualified/Unqualified)

**Request:**
```json
{
  "tool": "SymbolDefinition",
  "parameters": {
    "symbols": "Plus, Subtract, NonExistent`Symbol"
  }
}
```

**Response:**
````markdown
# Plus

## Definition

```wl
Attributes[Plus] = {Flat, Listable, NumericFunction, OneIdentity, Orderless, Protected}

Default[Plus] := 0

Plus[___] := <kernel function>
```

# Subtract

## Definition

```wl
Subtract[x_, y_] := x + (-1) * y
```

# Symbol

Error: Symbol "NonExistent`Symbol" does not exist
````

### Locked Symbol Error

**Request:**
```json
{
  "tool": "SymbolDefinition",
  "parameters": {
    "symbols": "System`SomeLockedSymbol"
  }
}
```

**Response:**
````markdown
# SomeLockedSymbol

Error: SomeLockedSymbol is `Locked` and `ReadProtected`
````

### Truncated Output

**Request:**
```json
{
  "tool": "SymbolDefinition",
  "parameters": {
    "symbols": "Wolfram`MCPServer`Private`veryLargeFunction",
    "maxLength": 1000
  }
}
```

**Response:**
````markdown
# veryLargeFunction

## Definition

```wl
veryLargeFunction[x_] :=
    Module[{a, b, c, d, e, f, g, h, i, j},
        a = someComputation[x];
        b = anotherComputation[a];
        (* ... more code ... *)
... [truncated, showing 1000/15000 characters]
```
````

---

## Future Considerations

1. **Additional Output Formats**: Support for JSON or structured output formats
2. **Attribute Information**: Option to include symbol attributes in the output
3. **Usage Messages**: Option to include usage messages alongside definitions
4. **Options Information**: Option to include `Options[symbol]` output
5. **Dependency Graph**: Option to show which other symbols a definition depends on
