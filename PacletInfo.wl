PacletObject[ <|
    "Name"             -> "RickHennigan/MCPServer",
    "Description"      -> "Implements a model context protocol server using Wolfram Language",
    "Creator"          -> "Richard Hennigan (Wolfram Research)",
    "Version"          -> "0.0.4",
    "WolframVersion"   -> "14.1+",
    "PublisherID"      -> "RickHennigan",
    "License"          -> "MIT",
    "ReleaseID"        -> "$RELEASE_ID$",
    "ReleaseDate"      -> "$RELEASE_DATE$",
    "ReleaseURL"       -> "$RELEASE_URL$",
    "ActionURL"        -> "$ACTION_URL$",
    "CommitURL"        -> "$COMMIT_URL$",
    "PrimaryContext"   -> "RickHennigan`MCPServer`",
    "DocumentationURL" -> "https://resources.wolframcloud.com/PacletRepository/resources",
    "Extensions"       -> {
        { "Kernel",
            "Root"         -> "Kernel",
            "Context"      -> { "RickHennigan`MCPServer`" },
            "HiddenImport" -> True,
            "Loading"      -> Automatic,
            "Symbols"      -> { "RickHennigan`MCPServer`StartMCPServer" } (* only one symbol needs to autoload *)
        }
    }
|> ]