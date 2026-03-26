PacletObject[ <|
    "Name"             -> "Wolfram/AgentTools",
    "Description"      -> "Implements a model context protocol server using Wolfram Language",
    "Creator"          -> "Richard Hennigan (Wolfram Research)",
    "Version"          -> "1.8.6",
    "WolframVersion"   -> "14.3+",
    "PublisherID"      -> "Wolfram",
    "License"          -> "MIT",
    "ReleaseID"        -> "$RELEASE_ID$",
    "ReleaseDate"      -> "$RELEASE_DATE$",
    "ReleaseURL"       -> "$RELEASE_URL$",
    "ActionURL"        -> "$ACTION_URL$",
    "CommitURL"        -> "$COMMIT_URL$",
    "PrimaryContext"   -> "Wolfram`AgentTools`",
    "DocumentationURL" -> "https://paclets.com",
    "Loading"          -> Automatic,
    "Extensions"       -> {
        { "Kernel",
            "HiddenImport" -> None,
            "Root"         -> "Kernel",
            "Context"      -> { "Wolfram`AgentTools`" },
            "Symbols"      -> {
                "System`AgentToolsDeployment",
                "System`DeployAgentTools",
                "System`DeployedAgentTools",
                "Wolfram`AgentTools`$DefaultMCPPrompts",
                "Wolfram`AgentTools`$DefaultMCPServers",
                "Wolfram`AgentTools`$DefaultMCPToolOptions",
                "Wolfram`AgentTools`$DefaultMCPTools",
                "Wolfram`AgentTools`$LastMCPServerFailure",
                "Wolfram`AgentTools`$LastMCPServerFailureText",
                "Wolfram`AgentTools`$MCPServerContexts",
                "Wolfram`AgentTools`$MCPServerProtectedNames",
                "Wolfram`AgentTools`$MCPServerSymbolNames",
                "Wolfram`AgentTools`$SupportedMCPClients",
                "Wolfram`AgentTools`CodeInspectorToolFunction",
                "Wolfram`AgentTools`CreateMCPServer",
                "Wolfram`AgentTools`InstallMCPServer",
                "Wolfram`AgentTools`MCPServer",
                "Wolfram`AgentTools`MCPServerObject",
                "Wolfram`AgentTools`MCPServerObjectQ",
                "Wolfram`AgentTools`MCPServerObjects",
                "Wolfram`AgentTools`StartMCPServer",
                "Wolfram`AgentTools`TestReportToolFunction",
                "Wolfram`AgentTools`UninstallMCPServer",
                "Wolfram`AgentTools`ValidateAgentToolsPacletExtension"
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