# Quick Start: Wolfram MCP Server for Chat Clients

This guide walks you through adding Wolfram computational capabilities to chat clients like Claude Desktop. By the end, your AI assistant will be able to evaluate Wolfram Language code, answer computational questions via Wolfram Alpha, and search Wolfram documentation.

## Recommended Server

For general-purpose chat, use the **Wolfram** server (the default). It combines code execution with natural language computation:

| Tool | Description |
|------|-------------|
| `WolframContext` | Semantic search across Wolfram resources (documentation, Wolfram Alpha, repositories, and more) |
| `WolframLanguageEvaluator` | Execute Wolfram Language code |
| `WolframAlpha` | Natural language queries to Wolfram Alpha |

## Installation

### Claude Desktop

Open a Wolfram Language session and run:

```wl
InstallMCPServer["ClaudeDesktop"]
```

This installs the default Wolfram server into Claude Desktop's configuration file.

**Configuration file locations:**

| OS | Path |
|----|------|
| macOS | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Windows | `%APPDATA%\Claude\claude_desktop_config.json` |

After installation, **fully restart Claude Desktop** to load the new tools.

### Other Chat Clients

For other MCP-compatible chat clients, generate the raw JSON configuration:

```wl
MCPServerObject["Wolfram"]["JSONConfiguration"]
```

Then adapt this to your client's configuration format.

### Verifying the Installation

After restarting your chat client, try asking:

> "What is the integral of sin(x)cos(x)?"

If the AI uses Wolfram tools to compute the answer, the installation is working.

## Understanding the Tools

The Wolfram server provides three tools that the AI uses automatically based on your questions:

| Tool | What It Does | When the AI Uses It |
|------|-------------|---------------------|
| **WolframContext** | Searches Wolfram resources (documentation, Wolfram Alpha, repositories, and more) | When it needs to look up functions, syntax, or factual data before responding |
| **WolframLanguageEvaluator** | Runs Wolfram Language code and returns results | When a computation, visualization, or data processing task is needed |
| **WolframAlpha** | Sends natural language queries to Wolfram Alpha | When answering factual, mathematical, or scientific questions in natural language |

You do not need to tell the AI which tool to use. It selects the appropriate tool based on your request.

## Example Use Cases

### Mathematics and Computation

- "Solve the equation x^3 - 6x^2 + 11x - 6 = 0"
- "Find the eigenvalues of the matrix {{1,2},{3,4}}"
- "Compute the Taylor series of e^x around x=0 to order 5"
- "What is the derivative of log(sin(x))?"

### Data and Facts

- "What is the population of France?"
- "How far is Mars from Earth right now?"
- "What is the boiling point of ethanol at 0.5 atm?"
- "Compare the GDP of Japan and Germany over the last 10 years"

### Visualization

- "Plot sin(x) and cos(x) from 0 to 2pi"
- "Create a bar chart comparing the populations of the 10 largest US cities"
- "Show a 3D plot of sin(x*y) for x and y from -pi to pi"

### Documentation Lookup

- "How does the Wolfram Language `NestList` function work?"
- "What options does `ListPlot` support?"
- "Show me examples of using `Association` with `GroupBy`"

### Code Assistance

- "Write a Wolfram Language function that finds all prime factors of a number"
- "How do I read a CSV file and compute column averages in Wolfram Language?"
- "Explain what this code does: `FoldList[Plus, 0, Range[10]]`"

## Writing Persistent Instructions

### What Are Persistent Instructions?

Persistent instructions are custom text that your chat client sends to the AI at the start of every conversation. They act like standing orders, ensuring the AI always follows your preferences without you having to repeat them.

### How to Set Them

**Claude Desktop:**
1. Open Claude Desktop
2. Go to Settings (gear icon)
3. Select the "General" tab
4. Enter your instructions in the text field under the "Profile" section
5. Save changes

Other chat clients may have similar settings. Consult your client's documentation.

### What to Include

Persistent instructions work best when they describe:
- **How you want results presented** (plain language, code, step-by-step)
- **Your background** (helps the AI calibrate explanation depth)
- **Preferred tools** (when to use Wolfram Alpha vs. code evaluation)
- **Common tasks** (what you typically ask about)

### Ready-to-Use Templates

Copy and paste any of these templates into your persistent instructions. Modify them to suit your needs.

#### General Computational Use

```markdown
When I ask mathematical or scientific questions, use Wolfram tools to compute
exact answers rather than approximating. Show the Wolfram Language code you used
so I can learn from it.

For factual questions (population, distance, chemical properties, etc.), use
WolframAlpha for up-to-date data.

When producing plots or visualizations, use clear labels and legends.
```

#### Learning Wolfram Language

```markdown
I am learning Wolfram Language. When I ask how to do something:

1. First use WolframContext to find relevant functions and documentation
2. Write the code using WolframLanguageEvaluator and show me the result
3. Explain each part of the code
4. Suggest related functions I might find useful

Prefer idiomatic Wolfram Language style. Use functional programming patterns
(Map, Select, Fold, etc.) over procedural loops when appropriate. Show
alternative approaches when they exist.
```

#### Research and Data Analysis

```markdown
I use Wolfram tools for research and data analysis. When I ask questions:

- Use WolframAlpha for current data and facts
- Use WolframLanguageEvaluator for computations, statistics, and visualizations
- Always cite the source of factual data (e.g., "According to Wolfram Alpha...")
- When creating visualizations, export them at high resolution

For statistical analysis, show the code and interpret the results in plain
language. Include relevant measures of uncertainty (confidence intervals,
p-values) when appropriate.
```

### Tips for Customizing Instructions

- Be specific about your field or domain (e.g., "I work in signal processing" or "I teach undergraduate calculus")
- Mention output preferences (e.g., "Always show LaTeX-formatted equations" or "Include units in all physical quantities")
- State your experience level so explanations are calibrated appropriately
- Keep instructions concise; overly long instructions may dilute their effect

## Tips for Best Results

- **Be specific.** "Plot the Bessel function J0 from 0 to 20" works better than "Show me a Bessel function."
- **Ask for explanations.** "Solve this and explain each step" produces more useful responses than just "Solve this."
- **Iterate on visualizations.** Start with a basic plot, then refine: "Make the axes larger and add a grid."
- **Combine tools.** "Look up the formula for black body radiation and then plot it for T = 3000K, 5000K, and 7000K" uses both documentation search and code evaluation.
- **Request code.** If you want to learn, ask "Show me the Wolfram Language code" to see what the AI runs.

## Troubleshooting

### Tools not appearing in chat

- Fully restart your chat client after installing (closing the window often just minimizes it to the system tray)
- Manually inspect the configuration file returned by `InstallMCPServer` to ensure the server is configured correctly
- Check your client's documentation for location of log files and check for errors

### Slow first response

The first tool call in a session starts a Wolfram Language kernel. This initial startup is slow but subsequent calls reuse the running kernel and are faster.

### WolframContext not working as expected

The `WolframContext` tool requires an [LLM Kit subscription](https://www.wolfram.com/notebook-assistant-llm-kit/) for full functionality. Without it, Wolfram Alpha results will not be included and the documentation search will be less accurate. The `WolframLanguageEvaluator` and `WolframAlpha` tools work without LLM Kit.

### Computation timeouts

By default, evaluations have a 60-second time limit. For long-running computations, ask the AI to increase the timeout or break the computation into smaller steps.

### Server is using the wrong version of Wolfram Language

The installed MCP server will use the same version of Wolfram Language as the session it was installed from. If you want to use a different version of Wolfram Language, you need to install the MCP server in a session of that version or manually edit the configuration file to point to a different Wolfram kernel.
