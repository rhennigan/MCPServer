# Running AgentTools with Docker

This guide explains how to run the Wolfram MCP Server using Docker containers.

## Initial Setup

Pull the image to your local machine:

```bash
docker pull ghcr.io/wolframresearch/mcpserver:latest
```

**Note:** On Windows, you'll need to ensure that [Docker Desktop](https://www.docker.com/products/docker-desktop/) is running before using `docker` commands.

### Configure Licensing

#### Option 1: Entitlement ID

Use a Wolfram Service Credits entitlement ID. This is ideal for ephemeral containers since no persistent storage is needed.

1. Obtain an entitlement ID by evaluating the following in Wolfram Language (adjust the settings as desired):
   ```wl
   entitlement = CreateLicenseEntitlement @ <|
      (* Number of kernels to allow simultaneously: *)
      "StandardKernelLimit" -> 4,
      (* Time limit for a kernel activated using this entitlement: *)
      "LicenseExpiration" -> Quantity[ 30, "Minutes" ],
      (* Time for which the entitlement is valid: *)
      "EntitlementExpiration" -> Quantity[ 1, "Months" ]
   |>
   ```

2. Copy the entitlement ID to the clipboard:
   ```wl
   CopyToClipboard[entitlement["EntitlementID"]]
   ```

3. Pass it via environment variable in your MCP client configuration (see below for examples):
   ```json
   "-e", "WOLFRAMSCRIPT_ENTITLEMENTID=<entitlement-id>"
   ```

**Note:** Service credits are consumed while the kernel is running, so this method is best for short-lived containers.

#### Option 2: Node-Locked License (Free)

Use an existing license associated with your Wolfram ID or get a free [Wolfram Engine Developer License](https://www.wolfram.com/developer-license/). This requires persistent storage for the license file.

1. If needed, get a free license at https://www.wolfram.com/developer-license/

2. Activate once interactively:
   ```bash
   docker run -it --rm --entrypoint wolframscript \
     -v ./Licensing:/home/wolframengine/.WolframEngine/Licensing \
     ghcr.io/wolframresearch/mcpserver:latest
   ```

3. Enter your Wolfram ID credentials when prompted

4. Verify the license is activated (it should not prompt for credentials):
   ```bash
   docker run -it --rm --entrypoint wolframscript \
     -v ./Licensing:/home/wolframengine/.WolframEngine/Licensing \
     ghcr.io/wolframresearch/mcpserver:latest
   ```

5. Ensure the volume is mounted in your MCP client configuration (see below for examples):
   ```json
   "-v", "/path/to/Licensing:/home/wolframengine/.WolframEngine/Licensing"
   ```

**Note:** In MCP client configurations, use an absolute host path rather than `./Licensing`, since many clients launch `docker` with a working directory that is not the project directory. Change `/path/to/Licensing` to wherever you want to store the license information. Ensure that the licensing directory is kept persistent and mounted on every run so that the renewed license is preserved across container restarts.

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
  ghcr.io/wolframresearch/mcpserver:latest
```

## Mounting a Workspace Directory

The container starts in an empty `/workspace` directory. You can mount a host directory here to give the MCP server access to your project files:

```bash
docker run -i --rm \
  -v /path/to/your/project:/workspace \
  -e WOLFRAMSCRIPT_ENTITLEMENTID=your-id \
  ghcr.io/wolframresearch/mcpserver:latest
```

This allows the server to read and write files in your project directory. For example, mounting your current directory:

```bash
docker run -i --rm \
  -v .:/workspace \
  -e WOLFRAMSCRIPT_ENTITLEMENTID=your-id \
  ghcr.io/wolframresearch/mcpserver:latest
```

Mounting a directory is necessary if you want to use tools that need to read or write files, e.g., `ReadNotebook`, `WriteNotebook`, `TestReport`, `CodeInspector`, etc.

**Security Note:** The container will have full read/write access to the mounted directory. Only mount directories you trust the MCP server to access.

## Example MCP Client Configurations

### Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or `%APPDATA%\Claude\claude_desktop_config.json` (Windows):

```json
{
  "mcpServers": {
    "Wolfram": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "WOLFRAMSCRIPT_ENTITLEMENTID=your-entitlement-id",
        "-e", "MCP_SERVER_NAME=Wolfram",
        "ghcr.io/wolframresearch/mcpserver:latest"
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
    "Wolfram": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "/path/to/your/project:/workspace",
        "-e", "WOLFRAMSCRIPT_ENTITLEMENTID=your-entitlement-id",
        "-e", "MCP_SERVER_NAME=WolframLanguage",
        "ghcr.io/wolframresearch/mcpserver:latest"
      ]
    }
  }
}
```

### With Node-Locked License

For clients using node-locked licensing, include the licensing volume mount:

```json
{
  "mcpServers": {
    "Wolfram": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "/path/to/Licensing:/home/wolframengine/.WolframEngine/Licensing",
        "-e", "MCP_SERVER_NAME=Wolfram",
        "ghcr.io/wolframresearch/mcpserver:latest"
      ]
    }
  }
}
```

You can combine multiple volume mounts (licensing + workspace):

```json
{
  "mcpServers": {
    "Wolfram": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "/path/to/Licensing:/home/wolframengine/.WolframEngine/Licensing",
        "-v", "/path/to/your/project:/workspace",
        "-e", "MCP_SERVER_NAME=Wolfram",
        "ghcr.io/wolframresearch/mcpserver:latest"
      ]
    }
  }
}
```

## Building Locally

Building the Docker image requires a Wolfram Engine entitlement ID to pre-install dependencies during the build. The entitlement ID is passed securely via BuildKit secrets and is **not** stored in the final image.

```bash
git clone https://github.com/WolframResearch/AgentTools.git
cd AgentTools

# Set your entitlement ID
export WOLFRAMSCRIPT_ENTITLEMENTID=O-XXXX-XXXXXXXXXXXXX

# Build with BuildKit secret
docker build \
  --secret id=WOLFRAMSCRIPT_ENTITLEMENTID,env=WOLFRAMSCRIPT_ENTITLEMENTID \
  -t mcpserver:local .
```

**Note:** BuildKit is required (Docker 18.09+). If you encounter issues, ensure BuildKit is enabled:
```bash
export DOCKER_BUILDKIT=1
```

The build process automatically:
- Installs required paclets (Chatbook, LLMFunctions, SemanticSearch)
- Installs vector databases for documentation search
- Builds MX files for faster startup

## Development Mode

For development, mount the local source directory:

```bash
docker run -i --rm \
  -v $(pwd):/opt/AgentTools \
  -e WOLFRAMSCRIPT_ENTITLEMENTID=your-id \
  ghcr.io/wolframresearch/mcpserver:latest
```

This allows you to test changes without rebuilding the image.

## Troubleshooting

### MCP server fails to start on Windows

On Windows, you'll need to ensure that [Docker Desktop](https://www.docker.com/products/docker-desktop/) is running before starting the MCP server.

### "Your Wolfram Engine installation is not activated"

This usually indicates a licensing issue. Verify that:
- Your entitlement ID is valid and has available credits
- Or your node-locked license directory is mounted correctly

### MCP server startup times out

Pulling the Docker image the first time can take a while. Before running the MCP server, try pulling the image manually to ensure it is ready for fast startup:
```bash
docker pull ghcr.io/wolframresearch/mcpserver:latest
```

### Container exits immediately

MCP servers communicate via stdin/stdout. Ensure you're using `-i` (interactive) flag to keep stdin open.

### View server logs

The server logs to stderr:
```bash
docker run -i --rm \
  -e WOLFRAMSCRIPT_ENTITLEMENTID=your-id \
  ghcr.io/wolframresearch/mcpserver:latest 2>server.log
```

## Image Tags

| Tag | Description |
|-----|-------------|
| `latest` | Most recent release |
| `x.y.z` | Specific version (e.g., `2.0.13`) |
| `xxxxxxx` | Specific commit (e.g., `27f0c1f`) |

All available tags can be found [here](https://github.com/WolframResearch/AgentTools/pkgs/container/mcpserver/versions).

## Architecture

The Docker image is built on `wolframresearch/wolframengine:14.3` and includes:

- Wolfram Engine 14.3
- AgentTools paclet (Kernel/, Scripts/)
- Pre-built MX files for faster startup
- Pre-installed dependencies (Chatbook, LLMFunctions, SemanticSearch paclets)
- Pre-installed vector databases for documentation search
- Startup script configured for MCP protocol

The server communicates via JSON-RPC over stdin/stdout, which is the standard transport for MCP subprocess servers.
