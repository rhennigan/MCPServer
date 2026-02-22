(* ::Section::Closed:: *)
(*Package Header*)
BeginPackage[ "Wolfram`MCPServer`SupportedClients`" ];
Begin[ "`Private`" ];

Needs[ "Wolfram`MCPServer`"        ];
Needs[ "Wolfram`MCPServer`Common`" ];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*$SupportedMCPClients*)
$SupportedMCPClients := WithCleanup[
    Unprotect @ $SupportedMCPClients,
    $SupportedMCPClients = KeySort @ AssociationMap[ clientMetadata, Keys @ $supportedMCPClients ],
    Protect @ $SupportedMCPClients
];

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$supportedMCPClients*)
$supportedMCPClients = <|
    "ClaudeDesktop" -> <|
        "DisplayName"     -> "Claude Desktop",
        "Aliases"         -> { "Claude" },
        "ConfigFormat"    -> "JSON",
        "ConfigKey"       -> { "mcpServers" },
        "URL"             -> "https://claude.ai/download",
        "InstallLocation" -> <|
            "MacOSX"  :> { $HomeDirectory, "Library", "Application Support", "Claude", "claude_desktop_config.json" },
            "Windows" :> { $HomeDirectory, "AppData", "Roaming", "Claude", "claude_desktop_config.json" }
        |>
    |>,
    "ClaudeCode" -> <|
        "DisplayName"     -> "Claude Code",
        "Aliases"         -> { },
        "ConfigFormat"    -> "JSON",
        "ConfigKey"       -> { "mcpServers" },
        "URL"             -> "https://code.claude.com",
        "ProjectPath"     -> { ".mcp.json" },
        "InstallLocation" :> { $HomeDirectory, ".claude.json" }
    |>,
    "Cursor" -> <|
        "DisplayName"     -> "Cursor",
        "Aliases"         -> { },
        "ConfigFormat"    -> "JSON",
        "ConfigKey"       -> { "mcpServers" },
        "URL"             -> "https://www.cursor.com",
        "InstallLocation" :> { $HomeDirectory, ".cursor", "mcp.json" }
    |>,
    "GeminiCLI" -> <|
        "DisplayName"     -> "Gemini CLI",
        "Aliases"         -> { "Gemini" },
        "ConfigFormat"    -> "JSON",
        "ConfigKey"       -> { "mcpServers" },
        "URL"             -> "https://github.com/google-gemini/gemini-cli",
        "InstallLocation" :> { $HomeDirectory, ".gemini", "settings.json" }
    |>,
    "Antigravity" -> <|
        "DisplayName"     -> "Antigravity",
        "Aliases"         -> { "GoogleAntigravity" },
        "ConfigFormat"    -> "JSON",
        "ConfigKey"       -> { "mcpServers" },
        "URL"             -> "https://antigravity.google",
        "InstallLocation" :> { $HomeDirectory, ".gemini", "antigravity", "mcp_config.json" }
    |>,
    "Codex" -> <|
        "DisplayName"     -> "Codex CLI",
        "Aliases"         -> { "OpenAICodex" },
        "ConfigFormat"    -> "TOML",
        "ConfigKey"       -> { "mcp_servers" },
        "URL"             -> "https://openai.com/codex",
        "InstallLocation" :> { $HomeDirectory, ".codex", "config.toml" }
    |>,
    "CopilotCLI" -> <|
        "DisplayName"     -> "Copilot CLI",
        "Aliases"         -> { "Copilot" },
        "ConfigFormat"    -> "JSON",
        "ConfigKey"       -> { "mcpServers" },
        "URL"             -> "https://github.com/features/copilot/cli",
        "InstallLocation" :> { $HomeDirectory, ".copilot", "mcp-config.json" }
    |>,
    "OpenCode" -> <|
        "DisplayName"     -> "OpenCode",
        "Aliases"         -> { },
        "ConfigFormat"    -> "JSON",
        "ConfigKey"       -> { "mcp" },
        "URL"             -> "https://opencode.ai",
        "ProjectPath"     -> { "opencode.json" },
        "InstallLocation" :> { $HomeDirectory, ".config", "opencode", "opencode.json" }
    |>,
    "VisualStudioCode" -> <|
        "DisplayName"     -> "Visual Studio Code",
        "Aliases"         -> { "VSCode" },
        "ConfigFormat"    -> "JSON",
        "ConfigKey"       -> { "mcp", "servers" },
        "URL"             -> "https://code.visualstudio.com",
        "ProjectPath"     -> { ".vscode", "settings.json" },
        "InstallLocation" -> <|
            "MacOSX"  :> { $HomeDirectory, "Library", "Application Support", "Code", "User", "settings.json" },
            "Windows" :> { $HomeDirectory, "AppData", "Roaming", "Code", "User", "settings.json" },
            "Unix"    :> { $HomeDirectory, ".config", "Code", "User", "settings.json" }
        |>
    |>,
    "Windsurf" -> <|
        "DisplayName"     -> "Windsurf",
        "Aliases"         -> { "Codeium" },
        "ConfigFormat"    -> "JSON",
        "ConfigKey"       -> { "mcpServers" },
        "URL"             -> "https://codeium.com/windsurf",
        "InstallLocation" :> { $HomeDirectory, ".codeium", "windsurf", "mcp_config.json" }
    |>,
    "Cline" -> <|
        "DisplayName"     -> "Cline",
        "Aliases"         -> { },
        "ConfigFormat"    -> "JSON",
        "ConfigKey"       -> { "mcpServers" },
        "URL"             -> "https://cline.bot",
        "InstallLocation" -> <|
            "MacOSX"  :> { $HomeDirectory, "Library", "Application Support", "Code", "User", "globalStorage",
                           "saoudrizwan.claude-dev", "settings", "cline_mcp_settings.json" },
            "Windows" :> { $HomeDirectory, "AppData", "Roaming", "Code", "User", "globalStorage",
                           "saoudrizwan.claude-dev", "settings", "cline_mcp_settings.json" },
            "Unix"    :> { $HomeDirectory, ".config", "Code", "User", "globalStorage", "saoudrizwan.claude-dev",
                           "settings", "cline_mcp_settings.json" }
        |>
    |>,
    "Zed" -> <|
        "DisplayName"     -> "Zed",
        "Aliases"         -> { },
        "ConfigFormat"    -> "JSON",
        "ConfigKey"       -> { "context_servers" },
        "URL"             -> "https://zed.dev",
        "ProjectPath"     -> { ".zed", "settings.json" },
        "InstallLocation" -> <|
            "MacOSX"  :> { $HomeDirectory, ".config", "zed", "settings.json" },
            "Windows" :> { $HomeDirectory, "AppData", "Roaming", "Zed", "settings.json" },
            "Unix"    :> { $HomeDirectory, ".config", "zed", "settings.json" }
        |>
    |>
|>;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*clientMetadata*)
clientMetadata // beginDefinition;

clientMetadata[ name_String ] := Enclose[
    Module[ { data, projectSupport },
        data = ConfirmBy[ $supportedMCPClients @ name, AssociationQ, "Data" ];
        projectSupport = MatchQ[ data[ "ProjectPath" ], { __String } ];
        KeySort @ <| data, "Name" -> name, "ProjectSupport" -> projectSupport |>
    ],
    throwInternalFailure
];

clientMetadata // endDefinition;

(* ::**************************************************************************************************************:: *)
(* ::Subsection::Closed:: *)
(*$aliasToCanonicalName*)
$aliasToCanonicalName := $aliasToCanonicalName = Association @ Flatten @ KeyValueMap[
    Function[ { name, meta }, Thread[ meta[ "Aliases" ] -> name ] ],
    $supportedMCPClients
];

(* ::**************************************************************************************************************:: *)
(* ::Section::Closed:: *)
(*Package Footer*)
addToMXInitialization[
    $SupportedMCPClients;
    $aliasToCanonicalName;
];

End[ ];
EndPackage[ ];
