# Running MCPServer with Docker

This guide explains how to run the Wolfram MCP Server using Docker containers.

## Quick Start

Pull and run the image:

```bash
docker run -i --rm \
  -e WOLFRAMSCRIPT_ENTITLEMENTID=your-entitlement-id \
  ghcr.io/rhennigan/mcpserver:latest
```

## Prerequisites

### Wolfram Engine License

The MCP server requires a valid Wolfram Engine license. You have two options:

#### Option 1: Entitlement ID (Recommended for Containers)

Use a Wolfram Service Credits entitlement ID. This is ideal for ephemeral containers since no persistent storage is needed.

1. Obtain an entitlement ID from [Wolfram Service Credits](https://www.wolfram.com/service-credits/)
2. Pass it via environment variable:
   ```bash
   -e WOLFRAMSCRIPT_ENTITLEMENTID=O-XXXX-XXXXXXXXXXXXX
   ```

**Note:** Service credits are consumed while the kernel is running.

#### Option 2: Node-Locked License (Free)

Use a free [Wolfram Engine Developer License](https://www.wolfram.com/developer-license/). This requires persistent storage for the license file.

1. Get a free license at https://www.wolfram.com/developer-license/
2. Activate once interactively:
   ```bash
   docker run -it \
     -v ./Licensing:/root/.WolframEngine/Licensing \
     ghcr.io/rhennigan/mcpserver:latest \
     wolframscript
   ```
3. Enter your Wolfram ID credentials when prompted
4. For subsequent runs, mount the same licensing directory:
   ```bash
   docker run -i --rm \
     -v ./Licensing:/root/.WolframEngine/Licensing \
     ghcr.io/rhennigan/mcpserver:latest
   ```

**Note:** The license expires periodically and will auto-renew automatically when the Wolfram kernel starts and the container has internet connectivity. Ensure that the `./Licensing` directory is kept persistent and mounted on every run so that the renewed license is preserved across container restarts.

## Server Configurations

The `MCP_SERVER_NAME` environment variable selects which server configuration to use:

| Name | Description | Best For |
|------|-------------|----------|
| `Wolfram` (default) | General computation + Wolfram\|Alpha | Most users |
| `WolframLanguage` | Code execution + documentation tools | Developers |
| `WolframAlpha` | Natural language queries only | Simple Q&A |
| `WolframPacletDevelopment` | Full development toolset | Paclet authors |

Example:
```bash
docker run -i --rm \
  -e WOLFRAMSCRIPT_ENTITLEMENTID=your-id \
  -e MCP_SERVER_NAME=WolframLanguage \
  ghcr.io/rhennigan/mcpserver:latest
```

## MCP Client Configuration

### Claude Desktop

Add to `~/.config/claude/claude_desktop_config.json` (Linux) or `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS):

```json
{
  "mcpServers": {
    "wolfram": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "WOLFRAMSCRIPT_ENTITLEMENTID=your-entitlement-id",
        "-e", "MCP_SERVER_NAME=Wolfram",
        "ghcr.io/rhennigan/mcpserver:latest"
      ]
    }
  }
}
```

### Claude Code

Add to your project's `.mcp.json` or global `~/.claude.json`:

```json
{
  "mcpServers": {
    "wolfram": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "WOLFRAMSCRIPT_ENTITLEMENTID=your-entitlement-id",
        "-e", "MCP_SERVER_NAME=WolframLanguage",
        "ghcr.io/rhennigan/mcpserver:latest"
      ]
    }
  }
}
```

### GitHub Copilot

For GitHub Copilot integration in a repository, add to your repository settings (`.github/copilot-instructions.md` or via GitHub UI):

```json
{
  "mcpServers": {
    "wolfram": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", ".:/workspace",
        "-e", "WOLFRAMSCRIPT_ENTITLEMENTID=$COPILOT_MCP_WOLFRAMSCRIPT_ENTITLEMENTID",
        "-e", "MCP_SERVER_NAME=WolframLanguage",
        "ghcr.io/rhennigan/mcpserver:latest"
      ],
      "tools": ["*"]
    }
  }
}
```

**Important:** To avoid startup timeouts, this repository includes a GitHub Actions workflow (`.github/workflows/copilot-setup-steps.yml`) that pre-pulls the Docker image on GitHub's runners. The workflow runs automatically on pushes to main and release branches, and can also be triggered manually. This ensures that when GitHub Copilot starts the MCP server, the Docker image is already cached and doesn't need to be downloaded, significantly reducing startup time.

### With Node-Locked License

For clients using node-locked licensing, include the volume mount:

```json
{
  "mcpServers": {
    "wolfram": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "/path/to/Licensing:/root/.WolframEngine/Licensing",
        "-e", "MCP_SERVER_NAME=Wolfram",
        "ghcr.io/rhennigan/mcpserver:latest"
      ]
    }
  }
}
```

## Building Locally

To build the image locally:

```bash
git clone https://github.com/rhennigan/MCPServer.git
cd MCPServer
docker build -t mcpserver:local .
```

### With Pre-built MX Files

For faster startup, build the MX files first:

```bash
# Build MX files (requires local Wolfram Engine)
wolframscript -f Scripts/BuildMX.wls

# Build Docker image including MX files
docker build -t mcpserver:local .
```

## Development Mode

For development, mount the local source directory:

```bash
docker run -i --rm \
  -v $(pwd):/opt/MCPServer \
  -e WOLFRAMSCRIPT_ENTITLEMENTID=your-id \
  ghcr.io/rhennigan/mcpserver:latest
```

This allows you to test changes without rebuilding the image.

## Troubleshooting

### "Kernel initialization failed"

This usually indicates a licensing issue. Verify:
- Your entitlement ID is valid and has available credits
- Or your node-locked license directory is mounted correctly

### Slow startup

The first kernel startup takes several seconds. This is normal for Wolfram Engine. Pre-building MX files can improve this.

For GitHub Copilot specifically, if you experience timeout issues:
1. Ensure the `.github/workflows/copilot-setup-steps.yml` workflow has run successfully
2. The workflow pre-caches the Docker image on GitHub's runners, avoiding the need to pull it when Copilot starts
3. Check the Actions tab in your repository to verify the workflow completed
4. You can manually trigger the workflow from the Actions tab if needed

Note: Each Copilot invocation starts a fresh Docker container, so the main optimization is having the image cached rather than installed paclets.

### Container exits immediately

MCP servers communicate via stdin/stdout. Ensure you're using `-i` (interactive) flag to keep stdin open.

### View server logs

The server logs to stderr:
```bash
docker run -i --rm \
  -e WOLFRAMSCRIPT_ENTITLEMENTID=your-id \
  ghcr.io/rhennigan/mcpserver:latest 2>server.log
```

## Image Tags

| Tag | Description |
|-----|-------------|
| `latest` | Most recent release |
| `x.y.z` | Specific version (e.g., `1.6.25`) |
| `sha-xxxxx` | Specific commit |

## Architecture

The Docker image is built on `wolframresearch/wolframengine:14.2` and includes:

- Wolfram Engine 14.2
- MCPServer paclet (Kernel/, Scripts/)
- Startup script configured for MCP protocol

The server communicates via JSON-RPC over stdin/stdout, which is the standard transport for MCP subprocess servers.
