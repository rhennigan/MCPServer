# Paclet Extension — Design Specification

## Overview

External Wolfram paclets can contribute MCP servers, tools, and prompts by declaring a custom `"MCP"` extension in their `PacletInfo.wl`. MCPServer discovers these extensions via the PacletManager and exposes them through the existing APIs (`MCPServerObject`, `InstallMCPServer`, `CreateMCPServer`, etc.). This leverages the Wolfram Paclet Repository as a distribution mechanism for MCP extensions.

---

## Goals

- Allow third-party paclets to contribute MCP servers, tools, and prompts without modifying the MCPServer paclet.
- Leverage the Wolfram Paclet Repository for distribution and version management.
- Maintain security by never auto-installing paclets and clearly separating discovery from code execution.
- Seamlessly integrate with existing APIs.
- Support flexible declaration formats — from minimal (names only) to rich (full metadata).

---

## Naming Convention

Paclet-defined items use a fully qualified name constructed from the paclet name and the item name:

```
"PacletName/ItemName"
```

Since paclet names may include a publisher prefix (e.g., `"Wolfram/JIRALink"`), this can result in either a two-segment or three-segment name:

- **Two-segment** — for paclets without a publisher prefix: `"PacletName/ItemName"`
- **Three-segment** — for paclets with a publisher prefix: `"PublisherID/PacletShortName/ItemName"`

Examples:

```wl
(* Paclet with publisher prefix: "Wolfram/JIRALink" *)
"Wolfram/JIRALink/GetIssue"            (* tool *)
"Wolfram/JIRALink/ProjectManagement"   (* server *)
"Wolfram/JIRALink/IssueText"           (* prompt *)

(* Paclet without publisher prefix: "JIRALink" *)
"JIRALink/GetIssue"                    (* tool *)
"JIRALink/ProjectManagement"           (* server *)
"JIRALink/IssueText"                   (* prompt *)
```

Names containing `/` are reserved for paclet-defined items. Built-in names (e.g., `"WolframAlpha"`, `"WolframLanguage"`) never contain `/`.

---

## PacletInfo Extension Declaration

A paclet declares MCP items by adding an `"MCP"` extension to its `PacletInfo.wl`:

```wl
PacletObject[ <|
    "Name"           -> "Wolfram/JIRALink",
    "Version"        -> "1.0.0",
    "PublisherID"    -> "Wolfram",
    "PrimaryContext" -> "Wolfram`JIRALink`",
    "Extensions"     -> {
        { "Kernel",
            "Root"    -> "Kernel",
            "Context" -> { "Wolfram`JIRALink`" }
        },
        { "MCP",
            "Root"    -> "MCP",
            "Servers" -> { "ProjectManagement" },
            "Tools"   -> {
                { "CreateIssue",  "Create a new JIRA issue" },
                { "DeleteIssue",  "Delete a JIRA issue" },
                { "GetIssue",     "Get a JIRA issue by key" },
                { "SearchIssues", "Search for JIRA issues" }
            },
            "Prompts" -> { "IssueText" }
        }
    }
|> ]
```

### Extension Properties

| Property | Type | Required | Default | Description |
|---|---|---|---|---|
| `"Root"` | `String` | No | `"MCP"` | Subdirectory for definition files. Resolved by the built-in `PacletExtensionDirectory` function. |
| `"Servers"` | `List` | No | `{}` | Server declarations. |
| `"Tools"` | `List` | No | `{}` | Tool declarations. |
| `"Prompts"` | `List` | No | `{}` | Prompt declarations. |

### Three-Tier Declaration Format

Each of `"Servers"`, `"Tools"`, and `"Prompts"` accepts three declaration forms. All three can be mixed freely within a single list. The name + description form is encouraged but not enforced.

#### Name Only

```wl
"Tools" -> { "CreateIssue", "GetIssue" }
```

#### Name + Description (Encouraged)

```wl
"Tools" -> {
    { "CreateIssue",  "Create a new JIRA issue" },
    { "GetIssue",     "Get a JIRA issue by key" }
}
```

#### Association

```wl
"Tools" -> {
    <| "Name"        -> "CreateIssue",
       "Description" -> "Create a new JIRA issue",
       "Parameters"  -> { "summary", "description", "projectKey" } |>,
    <| "Name"        -> "GetIssue",
       "Description" -> "Get a JIRA issue by key",
       "Parameters"  -> { "issueKey" } |>
}
```

The association form supports additional keys depending on the item type:

| Item Type | Extra Keys | Description |
|---|---|---|
| Servers | `"Tools"` | List of tool names this server uses |
| Tools | `"Parameters"` | List of parameter names (strings) or basic parameter associations |
| Prompts | `"Arguments"` | List of argument names |

**Note:** Because PacletInfo files do not allow arbitrary expressions, only basic types (strings, integers, lists, associations with string keys and simple values) are permitted. Complex specifications like `Interpreter` functions, delayed rules, or symbol references belong in definition files.

---

## Definition File Layout

### Per-Item Files (Default)

Each declared item has its own file in the extension root directory:

```
MyPaclet/
    PacletInfo.wl
    Kernel/
        ...
    MCP/                             (* Root from "Root" -> "MCP" *)
        Servers/
            ProjectManagement.wl
        Tools/
            CreateIssue.wl
            DeleteIssue.wl
            GetIssue.wl
            SearchIssues.wl
        Prompts/
            IssueText.wl
```

### Combined Files (Alternative)

For simpler paclets, all items of a type can be defined in a single file. The file must evaluate to an `Association` keyed by item name.

```
MyPaclet/
    MCP/
        Servers.wl
        Tools.wl
        Prompts.wl
```

Example combined `Tools.wl`:

```wl
(* MCP/Tools.wl *)
<|
    "CreateIssue" -> <|
        "Name"        -> "CreateIssue",
        "Description" -> "Create a new JIRA issue",
        "Function"    -> Wolfram`JIRALink`CreateIssue,
        "Parameters"  -> { ... }
    |>,
    "GetIssue" -> <|
        "Name"        -> "GetIssue",
        "Description" -> "Get a JIRA issue by key",
        "Function"    -> Wolfram`JIRALink`GetIssue,
        "Parameters"  -> { ... }
    |>
|>
```

### Supported File Formats

| Extension | Load Method | Use Case |
|---|---|---|
| `.wl` | `Get` | Standard — Wolfram Language source |
| `.mx` | `Import[..., "MX"]` | Compiled — faster loading, platform-specific |
| `.wxf` | `readWXFFile[...]` | Serialized data — portable binary format |

### Resolution Order

When loading a definition for item `"GetIssue"` of type `"Tools"`:

1. **Per-item file:** `First @ FileNames[ "GetIssue." ~~ ("mx"|"wl"|"wxf"), "<root>/Tools" ]`
2. **Combined file:** `First @ FileNames[ "Tools." ~~ ("mx"|"wl"|"wxf"), "<root>" ]` — look up `"GetIssue"` key

Per-item files take precedence over combined files. If multiple definition files exist for the same item (e.g., both `GetIssue.wl` and `GetIssue.mx`), the priority order is `.mx` > `.wxf` > `.wl` (preferring compiled formats for performance). `ValidateMCPPacletExtension` warns about duplicate definition files.

---

## Definition File Contents

### Server Definitions

Importing a server definition file must give an `Association`:

```wl
(* MCP/Servers/ProjectManagement.wl *)
<|
    "Name"           -> "ProjectManagement",
    "Initialization" :> Needs[ "Wolfram`JIRALink`" ],
    "LLMEvaluator"   -> <|
        "Tools"      -> { "CreateIssue", "DeleteIssue", "GetIssue", "SearchIssues" },
        "MCPPrompts" -> { "IssueText" }
    |>
|>
```

Tool and prompt names within `"LLMEvaluator"` use short names that resolve within the paclet first (see [Name Resolution](#name-resolution)).

| Key | Type | Required | Default | Description |
|---|---|---|---|---|
| `"Name"` | `String` | No | Extension item name | Server display name |
| `"Initialization"` | `RuleDelayed` | No | `None` | Delayed initialization code |
| `"LLMEvaluator"` | `Association` | Yes | — | Server configuration (tools, prompts) |
| `"Transport"` | `String` | No | `"StandardInputOutput"` | Transport protocol |
| `"ServerVersion"` | `String` | No | Paclet version | MCP server version |

### Tool Definitions

A tool definition file must evaluate to an `Association` compatible with `LLMTool`:

```wl
(* MCP/Tools/GetIssue.wl *)
<|
    "Name"        -> "GetIssue",
    "Description" -> "Get a JIRA issue by its key",
    "Function"    -> Wolfram`JIRALink`GetIssue,
    "Parameters"  -> {
        "issueKey" -> <|
            "Interpreter" -> "String",
            "Help"        -> "The JIRA issue key (e.g. PROJ-123)",
            "Required"    -> True
        |>
    }
|>
```

| Key | Type | Required | Description |
|---|---|---|---|
| `"Name"` | `String` | Yes | Tool name |
| `"Description"` | `String` | Yes | Description shown to the LLM |
| `"Function"` | `Symbol` or `Function` | Yes | The function to call |
| `"Parameters"` | `List` | Yes | Parameter specifications |
| `"DisplayName"` | `String` | No | Human-readable display name |
| `"Initialization"` | `RuleDelayed` | No | Delayed initialization code |
| `"Options"` | `List` | No | Tool options |

### Prompt Definitions

A prompt definition file must evaluate to an `Association`:

```wl
(* MCP/Prompts/IssueText.wl *)
<|
    "Name"        -> "IssueText",
    "Description" -> "Format a JIRA issue for display",
    "Arguments"   -> {
        <| "Name" -> "issueKey", "Description" -> "The issue key", "Required" -> True |>
    },
    "Type"        -> "Function",
    "Content"     -> Wolfram`JIRALink`FormatIssueText
|>
```

### Initialization

Initialization code belongs **only** in definition files, never in PacletInfo. It uses delayed evaluation (`:>`) and runs at server start time.

Common patterns:

```wl
(* Load the paclet's primary context *)
"Initialization" :> Needs[ "Wolfram`JIRALink`" ]

(* Multiple initialization steps *)
"Initialization" :> (
    Needs[ "Wolfram`JIRALink`" ];
    Wolfram`JIRALink`ConfigureAPI[ ]
)
```

---

## Name Resolution

| Context | Short name resolves to | Example |
|---|---|---|
| User code (e.g., `CreateMCPServer`) | Built-in tools only | `"WolframAlpha"` → `$DefaultMCPTools["WolframAlpha"]` |
| Within a paclet's own definition files | Own paclet first, then built-in | `"GetIssue"` → `"Wolfram/JIRALink/GetIssue"` |
| Cross-paclet reference | Must use fully qualified name | `"Wolfram/SlackLink/PostMessage"` |
| Fully qualified name anywhere | Specific paclet tool | `"Wolfram/JIRALink/GetIssue"` |

### Resolution Chain

The existing `convertStringTools0` in `Kernel/MCPServerObject.wl` currently checks:

1. `$DefaultMCPTools[name]` — built-in MCPServer tools
2. ``cb`$AvailableTools[name]`` — Chatbook tools (where ``cb`` is a context alias for ``Wolfram`Chatbook` ``)
3. `LLMResourceTool[name]` — Wolfram resource tools

The new resolution adds a check for `/`-containing names that routes through paclet tool resolution:

```wl
convertStringTools0[ name_String ] /; KeyExistsQ[ $DefaultMCPTools, name ] :=
    $DefaultMCPTools[ name ];

convertStringTools0[ name_String ] /; pacletQualifiedNameQ[ name ] :=
    resolvePacletTool[ name ];

convertStringTools0[ name_String ] :=
    Lookup[ cb`$AvailableTools, name, tryResourceTool @ name ];
```

Built-in tools always take precedence for short (unqualified) names.

### Intra-Paclet Name Resolution

When loading a paclet's server definition file, tool and prompt names within `"LLMEvaluator"` are short names that should resolve within the owning paclet first. To support this, the system pre-qualifies short names to fully qualified names at definition file load time. When a server definition is loaded from paclet `"Wolfram/JIRALink"`, a tool reference `"GetIssue"` is rewritten to `"Wolfram/JIRALink/GetIssue"` before being stored in the metadata association. Names that already contain `/` (fully qualified or cross-paclet references) are left unchanged. This avoids the need for dynamic resolution context during tool/prompt resolution.

---

## Security Model

### Trust Levels

| Level | Trigger | PacletInfo | Definition Files | Code Execution |
|---|---|---|---|---|
| **Discovery** | `MCPServerObjects[]`, `PacletFind` | Yes | No | No |
| **Inspection** | `MCPServerObject["Wolfram/JIRALink/PM"]` | Yes | Yes (installed only) | No |
| **Execution** | `StartMCPServer`, `InstallMCPServer` | Yes | Yes | Yes |

### Installed = Trusted

When a user writes `MCPServerObject["Wolfram/JIRALink/ProjectManagement"]`, they are explicitly referencing a paclet-qualified name. If the paclet is locally installed, MCPServer loads its definition files. This is analogous to how ``Needs["Wolfram`JIRALink`"]`` trusts installed paclets.

### Paclet Installation Policy

Metadata-only operations (`MCPServerObject`, `MCPServerObjects`) must **never** call `PacletInstall` automatically. These functions work with PacletInfo metadata from `PacletFindRemote` and should not trigger code execution.

Execution-level operations (`InstallMCPServer`, `StartMCPServer`) automatically install the referenced paclet via `PacletInstall` if it is not already installed. This is safe because these operations represent explicit user intent: `InstallMCPServer` is a direct request to set up a server, and `StartMCPServer` runs only on servers the user has opted into (via `InstallMCPServer` or manual config editing). Since the user would never see error messages in a running MCP server process, failing silently with a `PacletNotInstalled` error would be unhelpful.

### Uninstalled Paclet Behavior

For uninstalled paclets discovered via `PacletFindRemote`, only PacletInfo metadata is available. `MCPServerObject` properties that require loading definition files return a failure:

```wl
MCPServerObject["Unknown/Paclet/Server"]["Tools"]
(* Failure["PacletNotInstalled", <|
       "MessageTemplate" -> "The paclet \"`1`\" is not installed. Evaluate `2` to install it.",
       "MessageParameters" -> {"Unknown/Paclet", HoldForm[PacletInstall["Unknown/Paclet"]]}
   |>] *)
```

A new `"ToolNames"` property returns just the string names from PacletInfo metadata, which is always safe:

```wl
MCPServerObject["Unknown/Paclet/Server"]["ToolNames"]
(* {"ToolA", "ToolB"} *)
```

`InstallMCPServer` and `StartMCPServer` automatically call `PacletInstall` as needed to ensure the paclet is available before proceeding (see [Paclet Installation Policy](#paclet-installation-policy)).

---

## Integration with Existing APIs

### MCPServerObject

`MCPServerObject[name_String]` is extended to handle paclet-qualified names. If `name` contains `/`, it is parsed as a paclet-qualified name and resolved via the paclet extension system.

Resolution order for `getMCPServerObjectByName`:

1. File-based servers (existing — user-created via `CreateMCPServer`)
2. Built-in servers (existing — `$DefaultMCPServers`)
3. Installed paclet servers (new — scan installed paclets with `"MCP"` extension)
4. Remote paclet servers (new — `PacletFindRemote`, metadata only; supports `UpdatePacletSites` option)

The `"Location"` property for paclet-defined servers is `PacletObject["Wolfram/JIRALink"]`:

```wl
MCPServerObject["Wolfram/JIRALink/ProjectManagement"]["Location"]
(* PacletObject["Wolfram/JIRALink"] *)
```

The `$$metadata` pattern in `Kernel/MCPServerObject.wl` must be updated to accept `_PacletObject` as a valid `"Location"` value. The `$specialProperties` list must also be updated to include `"ToolNames"` and `"PromptNames"`.

### Paclet Server Metadata Construction

When `MCPServerObject` resolves a paclet-qualified server name, it constructs a metadata association:

- **Installed paclets:** The server definition file is loaded (via `loadPacletDefinitionFile`). Short tool/prompt names in `"LLMEvaluator"` are pre-qualified to fully qualified names. The resulting metadata has `"Location" -> PacletObject[...]`.
- **Uninstalled remote paclets (metadata only):** Only PacletInfo metadata is available. A partial metadata association is constructed with `"Name"`, `"Location"`, `"Transport"` (default), `"ServerVersion"` (from paclet version), and `"LLMEvaluator"` containing only tool/prompt name strings from PacletInfo declarations (no loaded `LLMTool` objects). Properties that require definition file loading (e.g., `"Tools"`) return a `PacletNotInstalled` failure.

New properties:

| Property | Description |
|---|---|
| `"ToolNames"` | List of tool name strings from PacletInfo metadata. Safe for uninstalled paclets. |
| `"PromptNames"` | List of prompt name strings from PacletInfo metadata. Safe for uninstalled paclets. |

### MCPServerObjects

**Behavior change:** `MCPServerObjects[]` currently returns only file-based (user-created) servers. This is extended to also include built-in servers and installed paclet servers.

New options `"IncludeRemotePaclets"` and `UpdatePacletSites`:

```wl
MCPServerObjects[]                                    (* file-based + built-in + installed paclet servers *)
MCPServerObjects["IncludeRemotePaclets" -> True]      (* also includes uninstalled paclet servers from the Paclet Repository *)
MCPServerObjects["IncludeRemotePaclets" -> True,
    UpdatePacletSites -> True]                         (* force refresh of cached remote paclet site data *)
```

The function signature is extended to accept options alongside the existing pattern argument:

```wl
MCPServerObjects[ pattern: All | _String? StringQ : All, opts: OptionsPattern[] ]
```

`UpdatePacletSites` is passed through to `PacletFindRemote`. By default, the PacletManager uses cached remote paclet site data, so `"IncludeRemotePaclets" -> True` is fast after the first call. Use `UpdatePacletSites -> True` to force a refresh.

### CreateMCPServer

Paclet tool name strings (containing `/`) are stored as-is without resolving. They are resolved dynamically when `obj["Tools"]` is accessed or at `StartMCPServer` time.

**Implementation note:** The current `CreateMCPServer` flow passes tool strings through `validateMCPServerObjectData` → `validateTools` → `convertStringTools`, which attempts resolution at creation time. `convertStringTools0` and `validateTool` must be modified to pass through `/`-containing strings without attempting resolution, so that paclet-qualified names survive as plain strings in `Metadata.wxf`.

```wl
CreateMCPServer[ "MyServer", <|
    "Tools" -> {
        "Wolfram/JIRALink/GetIssue",    (* stored as string, resolved later *)
        "WolframAlpha"                   (* resolved now from $DefaultMCPTools *)
    }
|> ]
```

### InstallMCPServer

Supports paclet-qualified server names. Automatically installs the referenced paclet via `PacletInstall` if not already present:

```wl
InstallMCPServer[ "ClaudeCode", "Wolfram/JIRALink/ProjectManagement" ]
```

### StartMCPServer

At start time, referenced paclets are automatically installed via `PacletInstall` if not already present. All paclet tool and prompt references are then fully resolved: definition files are loaded, `Initialization` code is executed, and `LLMTool` objects are constructed. This is the **Execution** trust level.

### $DefaultMCPTools / $DefaultMCPServers / $DefaultMCPPrompts

These variables continue to hold only built-in items. Paclet-defined items are **not** merged into these variables. They are resolved on demand through the paclet extension system.

---

## Dynamic Resolution

Paclet tools are always resolved from the currently installed paclet version — they are never snapshotted or cached permanently:

- `CreateMCPServer` stores paclet-qualified tool names as plain strings in `Metadata.wxf`.
- Resolution occurs when `obj["Tools"]` is accessed or at `StartMCPServer` time.
- If a user updates a paclet, the next resolution picks up the new version automatically.

Per-session caching of loaded definition files is recommended for performance, with cache invalidation when paclets are installed or updated.

---

## Error Handling

New messages to add to `Kernel/Messages.wl`:

| Tag | Template | Trigger |
|---|---|---|
| `PacletNotInstalled` | ``"The paclet \"`1`\" is not installed. Evaluate `2` to install it."`` | `MCPServerObject` accessing definition-file properties of an uninstalled paclet |
| `PacletExtensionNotFound` | ``"No MCP extension found in paclet \"`1`\"."`` | Referencing a paclet that exists but has no `"MCP"` extension |
| `PacletToolNotFound` | ``"Tool \"`1`\" not found in paclet \"`2`\"."`` | Tool name not declared in the paclet's extension |
| `PacletServerNotFound` | ``"Server \"`1`\" not found in paclet \"`2`\"."`` | Server name not declared in the paclet's extension |
| `PacletPromptNotFound` | ``"Prompt \"`1`\" not found in paclet \"`2`\"."`` | Prompt name not declared in the paclet's extension |
| `InvalidPacletToolDefinition` | ``"Invalid tool definition in `1`."`` | Definition file returns malformed data |
| `InvalidPacletServerDefinition` | ``"Invalid server definition in `1`."`` | Server definition file returns malformed data |
| `PacletDependencyMissing` | ``"Server \"`1`\" references tool \"`2`\" from paclet \"`3`\", which could not be installed."`` | Cross-paclet tool reference to a paclet that fails to install at start time |
| `InvalidMCPPacletExtension` | ``"The MCP extension in paclet \"`1`\" is invalid: `2`."`` | `ValidateMCPPacletExtension` finds errors |

Example error scenarios:

```wl
(* Cross-paclet dependency that fails to install *)
StartMCPServer @ MCPServerObject["MyServer"]
(* MCPServer::PacletDependencyMissing: Server "MyServer" references tool
   "Wolfram/SlackLink/PostMessage" from paclet "Wolfram/SlackLink",
   which could not be installed. *)
```

---

## Developer Validation Utility

### ValidateMCPPacletExtension

New exported function for paclet developers to validate their MCP extension:

```wl
ValidateMCPPacletExtension[ PacletObject["Wolfram/JIRALink"] ]
```

### Validation Checks

1. **Extension structure**
   - PacletInfo contains an `"MCP"` extension
   - Extension properties use valid keys (`"Root"`, `"Servers"`, `"Tools"`, `"Prompts"`)
   - Each declared item uses a valid declaration form (name-only, name+description, or association)

2. **File existence**
   - Root directory exists
   - Each declared server, tool, and prompt has a corresponding definition file (per-item or combined)
   - Warn if multiple definition files exist for the same item (e.g., both `GetIssue.wl` and `GetIssue.mx`)

3. **File contents** (for installed paclets)
   - Each definition file evaluates without error
   - Server definitions produce valid associations with required keys
   - Tool definitions produce valid associations that can construct `LLMTool` objects
   - Prompt definitions produce valid associations with required keys

4. **Cross-references**
   - Tool names referenced by servers are declared in the same paclet or are valid fully qualified names
   - Prompt names referenced by servers exist similarly

### Example Output

Successful validation:

```wl
ValidateMCPPacletExtension[ PacletObject["Wolfram/JIRALink"] ]
(* Success["ValidMCPPacletExtension", <|
       "Servers" -> { "ProjectManagement" },
       "Tools"   -> { "CreateIssue", "DeleteIssue", "GetIssue", "SearchIssues" },
       "Prompts" -> { "IssueText" }
   |>] *)
```

Failed validation:

```wl
ValidateMCPPacletExtension[ PacletObject["Wolfram/BrokenPaclet"] ]
(* MCPServer::InvalidMCPPacletExtension: The MCP extension in paclet
   "Wolfram/BrokenPaclet" is invalid: Missing definition file for tool "MyTool". *)
(* Failure["InvalidMCPPacletExtension", <|
       "Errors" -> {
           <| "Type" -> "MissingDefinitionFile",
              "Item" -> "MyTool",
              "ExpectedPath" -> "path/to/MCP/Tools/MyTool.wl" |>
       }
   |>] *)
```

---

## Source Files Requiring Changes

Existing files:

- `Kernel/MCPServerObject.wl` — paclet name resolution in `getMCPServerObjectByName`, update `$$metadata` pattern to accept `_PacletObject` as Location, add `"ToolNames"` and `"PromptNames"` properties to `$specialProperties`, extend `convertStringTools0` with paclet tool resolution for `/`-containing names, extend `normalizePromptData` with paclet prompt resolution for `/`-containing names, extend `MCPServerObjects` to include built-in and paclet servers with new options, modify `validateTool` to pass through `/`-containing strings
- `Kernel/CreateMCPServer.wl` — store paclet-qualified tool name strings without resolving
- `Kernel/InstallMCPServer.wl` — support paclet-qualified server names
- `Kernel/StartMCPServer.wl` — resolve all paclet references at start time, run Initialization
- `Kernel/CommonSymbols.wl` — declare new shared symbols (`resolvePacletTool`, `resolvePacletServer`, `resolvePacletPrompt`, `pacletQualifiedNameQ`, `parsePacletQualifiedName`, `findMCPPaclets`, `loadPacletDefinitionFile`)
- `Kernel/Main.wl` — add `ValidateMCPPacletExtension` to exports, add new subcontexts ``Wolfram`MCPServer`PacletExtension` `` and ``Wolfram`MCPServer`ValidateMCPPacletExtension` ``
- `Kernel/Messages.wl` — add new error messages
- `PacletInfo.wl` — add `ValidateMCPPacletExtension` to Symbols list

New files:

- `Kernel/PacletExtension.wl` — core implementation: paclet discovery, name parsing, definition file loading, resolution logic
- `Kernel/ValidateMCPPacletExtension.wl` — validation utility implementation

**Note:** `convertStringTools0` and `normalizePromptData` are both defined in `Kernel/MCPServerObject.wl`, not in `Kernel/Tools/Tools.wl` or `Kernel/Prompts/Prompts.wl`. Those files (`Tools.wl`, `Prompts.wl`) only contain `$DefaultMCPTools` / `$DefaultMCPPrompts` initialization and subcontext loading — they do not need changes for paclet extension support.

---

## Edge Cases

- **Version collisions:** When multiple versions of the same paclet are installed, `PacletFind` with `SplitBy[..., #["Name"]&]` returns only the latest version.
- **Circular initialization:** If Paclet A's init loads Paclet B and Paclet B's init loads Paclet A, this is the paclet developer's responsibility to avoid.
- **Short name shadowing:** A paclet can define a tool named `"WolframAlpha"`, but the fully qualified name is `"Publisher/Paclet/WolframAlpha"`. The short name `"WolframAlpha"` always resolves to the built-in tool.
- **Paclet uninstalled while server running:** Tool calls will fail at runtime. This is expected behavior.
- **`PacletFindRemote` performance:** The PacletManager caches remote paclet site data automatically, so `MCPServerObjects["IncludeRemotePaclets" -> True]` is fast after the initial fetch. A fresh network call only occurs when `UpdatePacletSites -> True` is passed.
- **Missing root directory:** If the `"Root"` directory doesn't exist in a paclet, definition file loading fails gracefully. PacletInfo metadata remains available.

---

## Future Considerations

- Minimum MCPServer version requirements in the `"MCP"` extension
- Tool categories or tag groups in PacletInfo metadata
- Remote paclet browsing UI
- Automatic update notifications for extension paclets
- `"Dependencies"` property in the `"MCP"` extension for declaring required paclets
