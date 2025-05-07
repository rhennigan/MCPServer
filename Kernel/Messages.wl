BeginPackage[ "RickHennigan`MCPServer`" ];

MCPServer::usage                   = "MCPServer is a symbol for miscellaneous messages.";
MCPServer::DeleteBuiltInMCPServer  = "The MCP server named \"`1`\" is built-in and cannot be deleted.";
MCPServer::Internal                = "An unexpected error occurred. `1`";
MCPServer::InstallMCPServer        = "Successfully installed MCP server \"`1`\".";
MCPServer::InstallMCPServerNamed   = "Successfully installed MCP server \"`1`\" for `2`.";
MCPServer::InvalidArguments        = "Invalid arguments given for `1` in `2`.";
MCPServer::InvalidMCPConfiguration = "Invalid MCP configuration file: `1`.";
MCPServer::InvalidMCPServerFile    = "Invalid MCPServerObject file: \"`1`\".";
MCPServer::InvalidMCPServerObject  = "Invalid MCPServerObject argument: `1`.";
MCPServer::InvalidSession          = "StartMCPServer must run in a standalone kernel.";
MCPServer::MCPServerExists         = "MCP server named \"`1`\" already exists. Use `2` to overwrite it.";
MCPServer::MCPServerFileNotFound   = "MCPServerObject file not found for MCPServer named \"`1`\".";
MCPServer::MCPServerNotFound       = "No MCPServerObject found for name \"`1`\".";
MCPServer::UnknownInstallLocation  = "Unable to determine install location for `1` on `2`. Use File[\[Ellipsis]] to specify a custom location.";

EndPackage[ ];