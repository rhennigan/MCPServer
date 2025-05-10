# [MCPServer](https://paclets.com/RickHennigan/MCPServer)

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Wolfram Version](https://img.shields.io/badge/Wolfram-14.2%2B-red.svg)](https://www.wolfram.com/language/)

Implements a [Model Context Protocol (MCP)](https://modelcontextprotocol.io) server using Wolfram Language, enabling LLMs to access Wolfram Language computation capabilities.

## Features

- Create custom MCP servers with tailored tools
- Easily integrate with popular AI assistants like Claude and Cursor
- Use Wolfram Language's computational power directly in AI conversations
- Pre-configured servers for common use cases

## Requirements

- Wolfram Language 14.2 or higher
- Claude Desktop, Cursor, or other MCP-compatible client applications

## Installation

### Install the Paclet

```wolfram
PacletInstall["RickHennigan/MCPServer"]
```

### Load the Package

```wolfram
Needs["RickHennigan`MCPServer`"]
```

## Quick Start

### Using Pre-configured Servers

Install a Wolfram MCP server for Claude Desktop:

```wolfram
InstallMCPServer["ClaudeDesktop"]
(* Out: Success["InstallMCPServer", <|...|>] *)
```

After restarting Claude Desktop, it will have access to Wolfram knowledge and tools:

![Claude Desktop Screenshot](.github/images/sk6raevruc0q.png)

### Creating Custom Servers

1. Create an MCP server with custom tools using [LLMConfiguration](https://reference.wolfram.com/language/ref/LLMConfiguration.html):

```wolfram
config = LLMConfiguration[<|
    "Tools" -> {LLMTool["PrimeFinder", {"n" -> "Integer"}, Prime[#n]&]}
|>];

server = CreateMCPServer["My MCP Server", config]
(* Out: MCPServerObject[...] *)
```

2. Install for use in Claude Desktop:

```wolfram
InstallMCPServer["ClaudeDesktop", server]
(* Out: Success["InstallMCPServer", <|...|>] *)
```

After restarting Claude Desktop, your custom tools will be available:

![Claude Desktop Screenshot](.github/images/1j9zrhp9b1y8.png)

## Supported Clients

### Claude Desktop

Claude Desktop offers an excellent integration experience with MCPServer, providing seamless access to Wolfram Language's computational capabilities.

### Cursor

Install an MCP server for use in Cursor:

```wolfram
InstallMCPServer["Cursor", server]
(* Out: Success["InstallMCPServer", <|...|>] *)
```

Check the MCP tab in Cursor settings to verify the server connection:

![Cursor MCP Settings Screenshot](.github/images/nldzo3f42xid.png)

Your Wolfram tools will now be available in Cursor agent chat:

![Cursor MCP Chat Screenshot](.github/images/o6ltldxumzkx.png)

## Advanced Usage

For more details on creating custom MCP servers, configuring tools, and advanced options, please refer to the [documentation](https://paclets.com/RickHennigan/MCPServer).

## Development

See [CLAUDE.md](CLAUDE.md) for development guidelines and commands.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Richard Hennigan (Wolfram Research)