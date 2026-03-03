# Agent Skills

## Goals

- Create distributable agent skills that use functionality from this paclet.
- Initial skills to create:
  - wolfram-language
  - wolfram-alpha
  - wolfram-notebooks

## Requirements

- Convert tools to scripts that can be bundled with skills
- Write sensible content for skill SKILL.md files that includes instructions on how to:
  - Use the MCP server if available
  - Otherwise, use the included scripts
- Combine skills into plugins if possible for Claude Code marketplace

## Implementation Notes

Some initial placeholder content has been created in the `AgentSkills` directory. We don't need to use this exactly, but it can serve as a starting point for ideas.

There is also a new script `Scripts/BuildAgentSkills.wls` with some initial placeholder content.

### Converting tools to scripts

```wl
In[10]:=
PacletDirectoryLoad["MCPServer"];
<<Wolfram`MCPServer`;

In[21]:= toolName = "TestReport";

In[36]:= tool = $DefaultMCPTools[toolName]

Out[36]= LLMTool[...]

In[37]:= data = tool["Data"]

Out[37]= <|"Name" -> "TestReport", "DisplayName" -> "Test Report", "Description" -> "Runs Wolfram Language test files (.wlt) and returns a report of the results", "Function" -> Wolfram`MCPServer`Tools`TestReport`Private`testReport, "Options" -> {}, "Paramet ...  constraint (in bytes) for each test file", "Required" -> False|>, "newKernel" -> <|"Interpreter" -> "Boolean", "Help" -> "Whether to use a fresh kernel for running tests (default is true)", "Required" -> False|>}, "LLMPacletVersion" -> "2.2.10"|>
```

Script name:

```wl
In[24]:= scriptName = data["Name"] <> ".wls"

Out[24]= "TestReport.wls"
```

Get script arguments and options:

```wl
In[33]:= params = Association@data["Parameters"];

In[34]:= arguments = Select[params, #["Required"]&]

Out[34]= <|"paths" -> <|"Interpreter" -> "String", "Help" -> "Comma separated list of paths to Wolfram Language test files (.wlt) or directories of test files", "Required" -> True|>|>

In[35]:= options = Select[params, !#["Required"]&]

Out[35]= <|"timeConstraint" -> <|"Interpreter" -> "Integer", "Help" -> "An optional time constraint (in seconds) for each test file", "Required" -> False|>, "memoryConstraint" -> <|"Interpreter" -> "Integer", "Help" -> "An optional memory constraint (in bytes) for each test file", "Required" -> False|>, "newKernel" -> <|"Interpreter" -> "Boolean", "Help" -> "Whether to use a fresh kernel for running tests (default is true)", "Required" -> False|>|>
```

There is no need to parse script argument strings, since the tool does it automatically:

```wl
In[38]:= tool[<|"paths" -> "MCPServer/Tests/Files.wlt", "timeConstraint" -> "10", "newKernel" -> "true"|>]

Out[38]=
"# Test Results Summary

| Metric | Value |
| --- | --- |
| **Overall Result** | Success |
| **Total Files** | 1 |
| **Total Tests** | 6 |
| **Passed** | 6 (100%) |
| **Failed** | 0 (0%) |
| **Total Time** | 4. s |

## Files.wlt

| Metric | Value |
| --- | --- |
| **Tests** | 6 |
| **Passed** | 6 (100%) |
| **Failed** | 0 (0%) |
| **Time** | 4. s |"
```