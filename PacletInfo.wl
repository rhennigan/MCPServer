PacletObject[ <|
    "Name"             -> "Wolfram/MCPServer",
    "Description"      -> "Implements a model context protocol server using Wolfram Language",
    "Creator"          -> "Richard Hennigan (Wolfram Research)",
    "Version"          -> "1.8.5",
    "WolframVersion"   -> "14.3+",
    "PublisherID"      -> "Wolfram",
    "License"          -> "MIT",
    "ReleaseID"        -> "$RELEASE_ID$",
    "ReleaseDate"      -> "$RELEASE_DATE$",
    "ReleaseURL"       -> "$RELEASE_URL$",
    "ActionURL"        -> "$ACTION_URL$",
    "CommitURL"        -> "$COMMIT_URL$",
    "PrimaryContext"   -> "Wolfram`MCPServer`",
    "DocumentationURL" -> "https://paclets.com",
    "Loading"          -> Automatic,
    "Extensions"       -> {
        { "Kernel",
            "HiddenImport" -> None,
            "Root"         -> "Kernel",
            "Context"      -> { "Wolfram`MCPServer`" },
            "Symbols"      -> {
                "System`AgentToolsDeployment",
                "System`DeployAgentTools",
                "System`DeployedAgentTools",
                "Wolfram`MCPServer`$DefaultMCPPrompts",
                "Wolfram`MCPServer`$DefaultMCPServers",
                "Wolfram`MCPServer`$DefaultMCPToolOptions",
                "Wolfram`MCPServer`$DefaultMCPTools",
                "Wolfram`MCPServer`$LastMCPServerFailure",
                "Wolfram`MCPServer`$LastMCPServerFailureText",
                "Wolfram`MCPServer`$MCPServerContexts",
                "Wolfram`MCPServer`$MCPServerProtectedNames",
                "Wolfram`MCPServer`$MCPServerSymbolNames",
                "Wolfram`MCPServer`$SupportedMCPClients",
                "Wolfram`MCPServer`CodeInspectorToolFunction",
                "Wolfram`MCPServer`CreateMCPServer",
                "Wolfram`MCPServer`InstallMCPServer",
                "Wolfram`MCPServer`MCPServer",
                "Wolfram`MCPServer`MCPServerObject",
                "Wolfram`MCPServer`MCPServerObjectQ",
                "Wolfram`MCPServer`MCPServerObjects",
                "Wolfram`MCPServer`StartMCPServer",
                "Wolfram`MCPServer`TestReportToolFunction",
                "Wolfram`MCPServer`UninstallMCPServer",
                "Wolfram`MCPServer`ValidateAgentToolsPacletExtension"
            }
        },
        { "Documentation",
            "Root"     -> "Documentation",
            "Language" -> "English"
        },
        { "Asset",
            "Assets" -> {
                { "Apps"               , "Assets/Apps"                    },
                { "SymbolPageTemplate" , "Assets/Templates/SymbolPage.wl" },
                { "TestReportScript"   , "Assets/TestReport.wls"          },
                { "AGENTS.md"          , "AGENTS.md"                      }
            }
        }
    }
|> ]