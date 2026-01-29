# Dockerfile for Wolfram MCP Server
# https://github.com/rhennigan/MCPServer
#
# This image provides a containerized MCP server that enables LLMs to access
# Wolfram Language computation capabilities via the Model Context Protocol.
#
# Usage:
#   docker run -i --rm \
#     -e WOLFRAMSCRIPT_ENTITLEMENTID=your-entitlement-id \
#     -e MCP_SERVER_NAME=Wolfram \
#     ghcr.io/rhennigan/mcpserver:latest
#
# For node-locked licensing (free but requires persistent storage):
#   docker run -i --rm \
#     -v ./Licensing:/root/.WolframEngine/Licensing \
#     -e MCP_SERVER_NAME=Wolfram \
#     ghcr.io/rhennigan/mcpserver:latest

FROM wolframresearch/wolframengine:14.3

LABEL org.opencontainers.image.title="Wolfram MCP Server"
LABEL org.opencontainers.image.description="Model Context Protocol server for Wolfram Language"
LABEL org.opencontainers.image.source="https://github.com/rhennigan/MCPServer"
LABEL org.opencontainers.image.licenses="MIT"

# Set working directory
WORKDIR /opt/MCPServer

# Copy paclet files (order matters for layer caching)
# Copy metadata first (changes less frequently)
COPY PacletInfo.wl .

# Copy kernel implementation
COPY Kernel/ Kernel/

# Copy startup scripts
COPY Scripts/Common.wl Scripts/
COPY Scripts/StartMCPServer.wls Scripts/

# Copy assets needed at runtime
COPY Assets/ Assets/
COPY AGENTS.md .

# Environment variables
# MCP_SERVER_NAME: Which server configuration to use
#   - "Wolfram" (default): General-purpose computation + Wolfram|Alpha
#   - "WolframLanguage": Development & learning focused
#   - "WolframAlpha": Natural language queries only
#   - "WolframPacletDevelopment": Full development toolset
ENV MCP_SERVER_NAME="Wolfram"

# Wolfram system configuration
ENV WOLFRAM_SYSTEM_ID="Linux-x86-64"

# Disable automatic paclet updates
ENV WOLFRAMINIT="-pacletreadonly"

# Entry point - MCP servers communicate via stdin/stdout
CMD ["wolframscript", "-f", "/opt/MCPServer/Scripts/StartMCPServer.wls"]
