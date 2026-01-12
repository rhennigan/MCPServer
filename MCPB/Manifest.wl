<|
    "manifest_version" -> "0.3",
    "name"             -> "wolfram-engine",
    "display_name"     -> "Wolfram Engine",
    "version"          -> TemplateSlot[ "PacletVersion" ],
    "description"      -> "Implements a model context protocol server using Wolfram Language",
    "long_description" -> TemplateSlot[ "LongDescription" ],
    "author"           -> <| "name" -> "Richard Hennigan (Wolfram Research)", "email" -> "richardh@wolfram.com" |>,
    "repository"       -> <| "type" -> "git", "url" -> "https://github.com/rhennigan/MCPServer" |>,
    "homepage"         -> "https://paclets.com/Wolfram/MCPServer",
    "support"          -> "https://github.com/rhennigan/MCPServer/issues",
    "icon"             -> "Images/Icon.png",
    "screenshots"      -> { "Images/Screenshot-1.png" },
    "tools_generated"  -> True,
    "keywords"         -> { "wolfram", "alpha", "mathematica", "computation" },
    "license"          -> "MIT",
    "compatibility"    -> <| "claude_desktop" -> ">=0.12.0", "platforms" -> { "darwin", "win32", "linux" } |>,

    "server" -> <|
        "type" -> "binary",
        "entry_point" -> "server/empty",
        "mcp_config" -> <|
            "command" -> "${user_config.wolfram_executable}",
            "args" -> {
                "-run",
                "PacletSymbol[\"Wolfram/MCPServer\",\"Wolfram`MCPServer`StartMCPServer\"][]",
                "-noinit",
                "-noprompt"
            },
            "env" -> <|
                "MCP_SERVER_NAME" -> "${user_config.mcp_server_name}"
            |>,
            "platform_overrides" -> <|
                "win32" -> <|
                    "env" -> <|
                        "MCP_SERVER_NAME" -> "${user_config.mcp_server_name}",
                        "APPDATA"         -> "${HOME}/AppData/Roaming"
                    |>
                |>
            |>
        |>
    |>,

    "tools" -> {
        <|
            "name"        -> "WolframContext",
            "description" -> "Provides context from Wolfram Language documentation, resources, and Wolfram Alpha"
        |>,
        <|
            "name"        -> "WolframAlpha",
            "description" -> "Provides access to Wolfram|Alpha"
        |>,
        <|
            "name"        -> "WolframLanguageEvaluator",
            "description" -> "Evaluates Wolfram Language code"
        |>
    },

    "user_config" -> <|
        "wolfram_executable" -> <|
            "type"        -> "file",
            "title"       -> "Path to Wolfram Kernel executable",
            "description" -> "Path to the wolfram binary executable (e.g. `C:\\Program Files\\Wolfram Research\\Wolfram\\14.2\\wolfram.exe`)",
            "required"    -> True
        |>,
        "mcp_server_name" -> <|
            "type"        -> "string",
            "title"       -> "MCP Server Name",
            "description" -> "The name of the MCP server to run (e.g. 'Wolfram', 'WolframLanguage', 'WolframAlpha')",
            "required"    -> False,
            "default"     -> "Wolfram"
        |>
    |>
|>