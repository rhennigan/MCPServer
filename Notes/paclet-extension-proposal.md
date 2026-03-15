# Proposal: Paclet Extension for MCP Servers and Tools

## Overview

We want a way for people to implement new named MCP servers and tools that would be easily available to all users of the Wolfram/MCPServer paclet.

## Motivation

There have been several suggestions and even pull requests to implement new built-in servers and tools for the MCPServer paclet. However, many of these are fairly niche, so adding lots of these would create a large monolithic source for predefined tools in this paclet that would be increasingly difficult to maintain.

These suggested servers and tools definitely have significant utility for some users though, so we would like a way for others to create predefined tools and have them available to all users of the paclet, without having MCPServer paclet developers be the ones responsible for maintaining them.

One way of achieving this is to define a new paclet extension, e.g. "MCP", that declares servers, tools, etc. We could then use PacletManager functionality to discover these paclets and expose the servers and tools they define via ``InstallMCPServer``, ``MCPServerObject``, etc. This effectively allows us to leverage the existing Paclet Repository as a way to distribute extensions for the MCPServer paclet.

## Examples

```wl
In[1]:=
PacletDirectoryLoad["MCPServer"];
<<Wolfram`MCPServer`;
```

We can currently retrieve built-in MCP servers by name:

```wl
In[3]:= MCPServerObject["WolframLanguage"]

Out[3]=
MCPServerObject[Association["LLMEvaluator" ->
   Association["Tools" -> {"WolframLanguageContext", "WolframLanguageEvaluator", "ReadNotebook",
      "WriteNotebook", "SymbolDefinition", "CodeInspector", "TestReport"},
    "MCPPrompts" -> {"WolframLanguageSearch", "Notebook"}], "Name" -> "WolframLanguage",
  "ObjectVersion" -> 1, "ServerVersion" -> "1.8.0", "Transport" -> "StandardInputOutput",
  "Location" -> "BuiltIn"]]
```

**Proposal:** We reserve the name format ``"PacletName/ServerName"`` to represent servers defined via paclets.

For example, this would get the ``"ProjectManagement"`` server, which is defined in the ``"Wolfram/JIRALink"`` paclet:

```wl
MCPServerObject["Wolfram/JIRALink/ProjectManagement"]
```

How it would look to install it:

```wl
InstallMCPServer["Claude", "Wolfram/JIRALink/ProjectManagement"]
```

We can also do this for tools that are defined in the paclet. For example, a simple custom server that references tools defined in a paclet:

```wl
CreateMCPServer["MyJIRAServer", <|"Tools" -> {"Wolfram/JIRALink/GetIssue", "Wolfram/JIRALink/SearchIssues"}|>]
```

Mix of default tools, paclet tools, and custom tools:

```wl
CreateMCPServer[
	"MyMCPServer",
	<|"Tools" -> {
	"Wolfram/JIRALink/GetIssue", (* external paclet tool *)
	"WolframAlpha", (* built-in tool *)
	LLMTool[Association["Name" -> "PrimeFinder", "Description" -> "",
  "Parameters" -> {"n" -> Association["Interpreter" -> "Integer",
      "Help" -> Missing["NotSpecified"], "Required" -> True]}, "Function" -> (Prime[#n] & ),
  "Options" -> {}, "LLMPacletVersion" -> "2.2.10"]] (* custom tool *)
	}|>
	]
```

## Implementation Notes

Here is what a PacletInfo file that declares servers and tools might look like:

```wl
In[4]:= FilePrint["JIRALink/PacletInfo.wl"]

PacletObject[ <|
    "Name"           -> "Wolfram/JIRALink",
    "Description"    -> "Access JIRA from Wolfram Language",
    "Version"        -> "0.0.1",
    "WolframVersion" -> "14.3+",
    "PublisherID"    -> "Wolfram",
    "PrimaryContext" -> "Wolfram`JIRALink`",
    "Extensions"     -> {
        { "Kernel",
            "Root"    -> "Kernel",
            "Context" -> { "Wolfram`JIRALink`" },
            "Symbols" -> {
                "Wolfram`JIRALink`CreateIssue",
                "Wolfram`JIRALink`DeleteIssue",
                "Wolfram`JIRALink`EditIssue",
                "Wolfram`JIRALink`GetIssue",
                "Wolfram`JIRALink`SearchIssues"
            }
        },
        { "MCP",
            "Root"    -> "MCPServerData",
            "Servers" -> { "ProjectManagement" },
            "Tools"   -> { "CreateIssue", "DeleteIssue", "EditIssue", "GetIssue", "SearchIssues" }
        }
    }
|> ]
```

This effectively simulates having this paclet installed on the machine:

```wl
In[5]:= PacletDirectoryLoad["JIRALink"];
```

We can discover all available paclets that declare this extension using the following:

```wl
In[6]:= paclets = First /@ SplitBy[PacletFind[All, <|"Extension" -> "MCP"|>], #["Name"]&]

Out[6]=
{PacletObject[Association["Name" -> "Wolfram/JIRALink",
  "Description" -> "Access JIRA from Wolfram Language", "Version" -> "0.0.1",
  "WolframVersion" -> "14.3+", "PublisherID" -> "Wolfram", "PrimaryContext" -> "Wolfram`JIRALink`",
  "Extension ... "Wolfram`JIRALink`SearchIssues"}}, {"MCP", "Root" -> "MCPServerData",
     "Servers" -> {"ProjectManagement"}, "Tools" -> {"CreateIssue", "DeleteIssue", "EditIssue",
       "GetIssue", "SearchIssues"}}}, "Location" -> "H:\\Documents\\JIRALink"]]}
```

We can use ``PacletTools`` to extract the relevant extension:

```wl
In[7]:= Needs["PacletTools`"]

In[8]:= paclet = First[paclets];

In[9]:= extensions = PacletTools`PacletExtensions[paclet, "MCP"]

Out[9]= {{"MCP", <|"Root" -> "MCPServerData", "Servers" -> {"ProjectManagement"}, "Tools" -> {"CreateIssue", "DeleteIssue", "EditIssue", "GetIssue", "SearchIssues"}|>}}
```

**Note:** That looks like a trivial extraction, but paclet extensions can have complex qualifiers (e.g. OS, Wolfram kernel version, etc.). We can rely on ``PacletExtensions`` to filter extensions properly for the current environment.

```wl
In[10]:= extension = First[extensions]

Out[10]= {"MCP", <|"Root" -> "MCPServerData", "Servers" -> {"ProjectManagement"}, "Tools" -> {"CreateIssue", "DeleteIssue", "EditIssue", "GetIssue", "SearchIssues"}|>}
```

Get the corresponding directory for an extension:

```wl
In[11]:= dir = PacletTools`PacletExtensionDirectory[paclet, extension]

Out[11]= "H:\\Documents\\JIRALink\\MCPServerData"
```

Now, the meaning and implementation of the ``"Servers"`` and ``"Tools"`` properties are completely up to us, since this is a custom extension.

### Extension Properties

* **Root** (optional)

	* This is an extension property handled by the PacletManager, so we don't need to define any behavior for this. ``PacletExtensionDirectory`` knows what to do with this.

* **Servers** (optional)

	* Declares names of MCP servers defined in this paclet

	* The names do not need to be fully qualified, e.g. ``"ProjectManagement"`` implicitly means ``"Wolfram/JIRALink/ProjectManagement"``.

	* We should use the paclet version for the ``"ServerVersion"`` property if not declared.

* **Tools** (optional)

	* Declares the names of ``"Tools"`` defined in this paclet

	* The names do not need to be fully qualified, e.g. ``"GetIssue"`` implicitly means ``"Wolfram/JIRALink/GetIssue"``.

* **Prompts** (optional)

	* Declares the names of ``"MCPPrompts"`` defined in this paclet

	* The names do not need to be fully qualified, e.g. ``"IssueText"`` implicitly means ``"Wolfram/JIRALink/IssueText"``.

#### MCP Definition File Locations

##### Default

Here is where each server, tool, and prompt are defined:

* **Servers** - ``"dir/Servers/<serverName>.wl"``

* **Tools** - ``"dir/Tools/<toolName>.wl"``

* **Prompts** - ``"dir/Prompts/<promptName>.wl"``

##### Combined Alternative

We could also support using a single file like so:

* **Servers** - ``"dir/Servers.wl"``

* **Tools** - ``"dir/Tools.wl"``

* **Prompts** - ``"dir/Prompts.wl"``

#### Loading MCP Definition Files

When discovering these, we do not want to actually read in any of the files until actually needed, since there might someday be many paclets that declare these.

We also do not need to restrict these to ``wl`` files. We could also support ``mx`` and ``wxf``. For these we would use ``Import[file, "MX"]`` or ``Import[file, "WXF"]`` instead of ``Get`` to read in data.

We do not need to worry about loading supporting package files for any needed definitions. We already have the ``Initialization`` property for servers, which can be used for this purpose.

```wl
In[12]:= Get[FileNameJoin[{dir, "Servers", "ProjectManagement.wl"}]]

Out[12]= <|"Name" -> "ProjectManagement", "Initialization" :> Needs["Wolfram`JIRALink`"], "LLMEvaluator" -> <|"Tools" -> {"CreateIssue", "DeleteIssue", "EditIssue", "GetIssue", "SearchIssues"}|>|>
```

### Discovering Paclets

``PacletFind`` only gives paclets that are available on the current machine. We can also use ``PacletFindRemote`` to include paclets that haven't been installed yet:

```wl
PacletFindRemote[All, <|"Extension" -> "MCP"|>]
```

When listing available MCP servers, we should only include locally available servers by default:

```wl
MCPServerObjects[]
```

Including servers from not yet installed paclets can be optional:

```wl
MCPServerObjects["AllowUninstalled" -> True]
```

When getting a single server, we should automatically check remote if a local version is not found:

```wl
MCPServerObject["MyPublisher/MyPaclet/MyMCPServer"]
```

### IMPORTANT: Security Concerns

We should **not** ``PacletInstall`` a paclet just to get the necessary info to create an ``MCPServerObject``. A user might just want to know what's available by evaluating:

```wl
MCPServerObjects["AllowUninstalled" -> True]
```

Automatically installing paclets would be very dangerous, since they might have auto-load on startup enabled, which could potentially run malicious code.

We need to make sure that ``MCPServerObject`` has all the info it needs from a remote paclet without actually installing it. This means that we can only rely on info declared in the PacletInfo file of the paclet.

#### Potential Issues

Some properties of an ``MCPServerObject`` would require actually loading paclet files, which we do not want to do if it's not already installed. For example, the ``"Tools"`` property cannot work like it currently does with an uninstalled paclet, since it would need to load files that define the tools.

```wl
In[13]:= MCPServerObject["Wolfram"]["Tools"]

Out[13]=
{LLMTool[Association["Name" -> "WolframContext", "DisplayName" -> "Wolfram Context",
  "Description" -> "Uses semantic search to retrieve any relevant information from Wolfram. Always \
use this tool at the start of new conversations or if the top ... rver`Tools`Private`args$]], HoldAllComplete], "Options" -> {},
  "Parameters" -> {"query" -> Association["Interpreter" -> "String",
      "Help" -> "The query to send to Wolfram|Alpha.", "Required" -> True]},
  "LLMPacletVersion" -> "2.2.10"]]}
```

We need to figure out what to do for these kinds of things for uninstalled paclets. For example,

```wl
MCPServerObject["MaliciousPaclet/DangerousServer"]["Tools"]
```

This could return a ``Failure["PacletNotInstalled", ...]`` and issue an appropriate message saying that this property is not available for uninstalled paclets and suggest the proper ``InstallPaclet[...]`` code if they want it.

We could also implement a new property ``"ToolNames"``, which just gives the tool names as strings for those wanting to know what the MCP server offers.

```wl
MCPServerObject["MaliciousPaclet/DangerousServer"]["ToolNames"]
(* gives a list of strings *)
```

##### Alternative Approach

We could require that all the necessary information appears in the PacletInfo file itself. However, this has limitations, since PacletInfo files do not allow arbitrary expressions. For example, this ``"Function"`` property of a tool could not appear in a PacletInfo file:

```wl
In[14]:= Get[FileNameJoin[{dir, "Tools", "CreateIssue.wl"}]]

Out[14]= <|"Name" -> "CreateIssue", "Description" -> "Create a new JIRA issue", "Function" -> Wolfram`JIRALink`CreateIssue, "Parameters" -> {"description" -> <|"Interpreter" -> "String", "Help" -> "The description of the issue", "Required" -> True|>, "summary" -> <|"Interpreter" -> "String", "Help" -> "The summary of the issue", "Required" -> True|>}|>
```

We could have something like ``"Function" -> "Wolfram`JIRALink`CreateIssue"`` and assume that a string implies a symbol name.

Also, not all ``"Interpreter"`` specifications are a simple string. Many of them rely on things like ``DelimitedSequence``, ``Restricted``, or even arbitrary validation functions.

Similarly, this ``Initialization`` property is a no-go for PacletInfo files:

```wl
In[15]:= Get[FileNameJoin[{dir, "Servers", "ProjectManagement.wl"}]]

Out[15]= <|"Name" -> "ProjectManagement", "Initialization" :> Needs["Wolfram`JIRALink`"], "LLMEvaluator" -> <|"Tools" -> {"CreateIssue", "DeleteIssue", "EditIssue", "GetIssue", "SearchIssues"}|>|>
```

We could potentially define syntax for common initialization patterns, e.g.

* ``"Wolfram`JIRALink`"`` a raw context name implies ``Needs``

* ``Automatic``  implies ``Needs["Wolfram`JIRALink`"]`` since the ``"PrimaryContext"`` property is declared in the PacletInfo

* ``{"Needs", "Wolfram`JIRALink`"}`` implies ``Needs["Wolfram`JIRALink`"]``

## Developer Utilities

For paclet developers that want to use this MCP extension, we should offer them a function to validate their implementation. This function would scan the paclet directory and validate that the files are in the correct locations and that the content is valid.


Successful validation:

```wl
In[16]:= ValidateMCPPacletExtension[PacletObject[...]]

Out[16]= Success[...]
```

Invalid server specification:

```wl
In[17]:= ValidateMCPPacletExtension[PacletObject[...]

ValidateMCPPacletExtension::InvalidServerSpecification: The server specification in `path/to/paclet/Servers/ServerName.wl` is invalid.

Out[17]= Failure[...]
```

We would have something similar for tools, etc.