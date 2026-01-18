#!/bin/bash
# MCP Server Configuration for Claude Code
# Run this script to configure useful MCP servers
# Usage: bash ~/.claude/mcp-config.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

printf "${YELLOW}Configuring MCP servers...${NC}\n"

# Check if claude CLI is available
if ! command -v claude >/dev/null 2>&1; then
    printf "${RED}Error: 'claude' CLI not found in PATH${NC}\n"
    printf "Please ensure Claude Code is installed and the 'claude' command is available.\n"
    printf "You may need to add it to your PATH or reinstall Claude Code.\n"
    exit 1
fi

# Check if npx is available
if ! command -v npx >/dev/null 2>&1; then
    printf "${RED}Error: 'npx' not found. Please install Node.js first.${NC}\n"
    exit 1
fi

# Helper function to add MCP server if not already configured
add_mcp_if_missing() {
    local name="$1"
    shift
    if claude mcp list 2>/dev/null | grep -q "^$name"; then
        printf "${YELLOW}!${NC} MCP server '%s' already configured, skipping\n" "$name"
    else
        printf "${GREEN}+${NC} Adding MCP server: %s\n" "$name"
        claude mcp add -s user "$name" "$@"
    fi
}

# Filesystem - Enhanced file operations
# Provides tools for reading, writing, and managing files
add_mcp_if_missing "filesystem" -- npx -y @anthropic-ai/mcp-server-filesystem "$HOME"

# Fetch - Web fetching capabilities
# Provides tools for fetching web content and APIs
add_mcp_if_missing "fetch" -- npx -y @anthropic-ai/mcp-server-fetch

# Memory - Persistent key-value storage
# Provides tools for storing and retrieving data across sessions
add_mcp_if_missing "memory" -- npx -y @anthropic-ai/mcp-server-memory

printf "${GREEN}MCP configuration complete!${NC}\n"
printf "\n"
printf "Configured servers:\n"
claude mcp list 2>/dev/null || printf "  (none)\n"
printf "\n"
printf "${YELLOW}Note: Restart Claude Code for changes to take effect.${NC}\n"
