#!/bin/bash
# Sync Claude Code config from local project to global ~/.claude
# Run this script after making changes to files in this project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths - use $0 for better portability
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$PROJECT_ROOT/.claude"
GLOBAL_CLAUDE="$HOME/.claude"

printf "${YELLOW}Syncing Claude Code config to global...${NC}\n"

# Backup existing global config
BACKUP_DIR="$GLOBAL_CLAUDE.backup.$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

backup_item() {
    local item="$1"
    if [ -e "$GLOBAL_CLAUDE/$item" ]; then
        cp -r "$GLOBAL_CLAUDE/$item" "$BACKUP_DIR/"
        printf "${GREEN}✓${NC} Backed up %s\n" "$item"
    fi
}

# Backup existing items
backup_item "skills"
backup_item "agents"
backup_item "settings.json"
backup_item "settings.local.json"
backup_item "CLAUDE.md"

printf "${YELLOW}Backup created at: %s${NC}\n" "$BACKUP_DIR"

# Sync items
sync_item() {
    local item="$1"
    if [ -e "$CONFIG_DIR/$item" ]; then
        rm -rf "$GLOBAL_CLAUDE/$item"
        cp -r "$CONFIG_DIR/$item" "$GLOBAL_CLAUDE/$item"
        printf "${GREEN}✓${NC} Synced %s\n" "$item"
    else
        printf "${YELLOW}⚠${NC} %s not found in local config, skipping\n" "$item"
    fi
}

# Sync items
sync_item "skills"
sync_item "agents"
sync_item "settings.json"
sync_item "settings.local.json"
sync_item "CLAUDE.md"

# Run statusline setup
printf "${YELLOW}Setting up statusline...${NC}\n"
if [ -f "$PROJECT_ROOT/documentation/setup-statusline.sh" ]; then
    bash "$PROJECT_ROOT/documentation/setup-statusline.sh"
    printf "${GREEN}✓${NC} Statusline configured\n"
else
    printf "${YELLOW}⚠${NC} Statusline setup script not found, skipping\n"
fi

# Sync MCP config script
if [ -e "$CONFIG_DIR/mcp-config.sh" ]; then
    cp "$CONFIG_DIR/mcp-config.sh" "$GLOBAL_CLAUDE/mcp-config.sh"
    chmod +x "$GLOBAL_CLAUDE/mcp-config.sh"
    printf "${GREEN}✓${NC} Synced mcp-config.sh\n"

    # Ask if user wants to run MCP config (POSIX-compatible)
    printf "\nConfigure MCP servers now? (y/N) "
    read -r REPLY
    case "$REPLY" in
        [Yy]*)
            bash "$GLOBAL_CLAUDE/mcp-config.sh"
            ;;
        *)
            printf "${YELLOW}Skipped MCP configuration. Run manually with: ~/.claude/mcp-config.sh${NC}\n"
            ;;
    esac
else
    printf "${YELLOW}⚠${NC} mcp-config.sh not found in local config, skipping\n"
fi

printf "${GREEN}✓ Sync complete!${NC}\n"
printf "\n"
printf "${YELLOW}Note: You may need to restart Claude Code for changes to take effect.${NC}\n"
