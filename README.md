# MCPServer

Implements a [model context protocol](https://modelcontextprotocol.io) server using Wolfram Language.

## Installation

Install the paclet:

```wl
PacletInstall["RickHennigan/MCPServer"];
```

Load the paclet:

```wl
Needs["RickHennigan`MCPServer`"];
```

### Basic Examples (2)

Install a Wolfram MCP server for use in Claude desktop:

```wl
In[1]:= InstallMCPServer["ClaudeDesktop"]

Out[1]= Success["InstallMCPServer", <|...|>]
```

Restart Claude desktop and then it will have access to Wolfram knowledge and tools:

![Claude Desktop Screenshot](.github\images\sk6raevruc0q.png)

### Scope (6)

Create an MCP server from an [LLMConfiguration](https://reference.wolfram.com/languageref/LLMConfiguration) :

```wl
In[1]:= config = LLMConfiguration[<|"Tools" -> {LLMTool["PrimeFinder", {"n" -> "Integer"}, Prime[#n]&]}|>];

In[2]:= server = CreateMCPServer["My MCP Server", config]

Out[2]= MCPServerObject[...]
```

Install the server for use in Claude desktop:

```wl
In[3]:= InstallMCPServer["ClaudeDesktop", server]

Out[3]= Success["InstallMCPServer", <|...|>]
```

Restart Claude desktop and then your tools will now be usable by Claude:

![Claude Desktop Screenshot](.github\images\1j9zrhp9b1y8.png)

Install the server for use in Cursor:

```wl
In[4]:= InstallMCPServer["Cursor", server]

Out[4]= Success["InstallMCPServer", <|...|>]
```

Check the MCP tab in Cursor settings to verify that the server is recognized:

![Cursor MCP Settings Screenshot](.github\images\nldzo3f42xid.png)

Your tools should now be available in Cursor agent chat:

![Cursor MCP Chat Screenshot](.github\images\o6ltldxumzkx.png)