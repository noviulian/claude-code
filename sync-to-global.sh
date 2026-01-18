#!/bin/bash
# Sync Claude Code config from local project to global ~/.claude
# Run this script after making changes to files in this project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$PROJECT_ROOT/.claude"
GLOBAL_CLAUDE="$HOME/.claude"

echo -e "${YELLOW}Syncing Claude Code config to global...${NC}"

# Backup existing global config
BACKUP_DIR="$GLOBAL_CLAUDE.backup.$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

backup_item() {
    local item="$1"
    if [ -e "$GLOBAL_CLAUDE/$item" ]; then
        cp -r "$GLOBAL_CLAUDE/$item" "$BACKUP_DIR/"
        echo -e "${GREEN}✓${NC} Backed up $item"
    fi
}

# Backup existing items
backup_item "skills"
backup_item "agents"
backup_item "settings.json"
backup_item "settings.local.json"

echo -e "${YELLOW}Backup created at: $BACKUP_DIR${NC}"

# Sync items
sync_item() {
    local item="$1"
    if [ -e "$CONFIG_DIR/$item" ]; then
        rm -rf "$GLOBAL_CLAUDE/$item"
        cp -r "$CONFIG_DIR/$item" "$GLOBAL_CLAUDE/$item"
        echo -e "${GREEN}✓${NC} Synced $item"
    else
        echo -e "${YELLOW}⚠${NC} $item not found in local config, skipping"
    fi
}

# Sync items
sync_item "skills"
sync_item "agents"
sync_item "settings.local.json"

# Sync settings.json with token injection from .env
if [ -e "$CONFIG_DIR/settings.json" ]; then
    # Read token from .env file
    if [ -e "$PROJECT_ROOT/.env" ]; then
        AUTH_TOKEN=$(grep "^ANTHROPIC_AUTH_TOKEN=" "$PROJECT_ROOT/.env" | cut -d'=' -f2)
        if [ -n "$AUTH_TOKEN" ]; then
            # Copy and replace token
            sed "s/\"ANTHROPIC_AUTH_TOKEN\": \"ANTHROPIC_AUTH_TOKEN\"/\"ANTHROPIC_AUTH_TOKEN\": \"$AUTH_TOKEN\"/" \
                "$CONFIG_DIR/settings.json" > "$GLOBAL_CLAUDE/settings.json"
            echo -e "${GREEN}✓${NC} Synced settings.json (with token from .env)"
        else
            cp "$CONFIG_DIR/settings.json" "$GLOBAL_CLAUDE/settings.json"
            echo -e "${YELLOW}⚠${NC} No ANTHROPIC_AUTH_TOKEN found in .env, copied as-is"
        fi
    else
        cp "$CONFIG_DIR/settings.json" "$GLOBAL_CLAUDE/settings.json"
        echo -e "${YELLOW}⚠${NC} No .env file found, copied settings.json as-is"
    fi
else
    echo -e "${YELLOW}⚠${NC} settings.json not found in local config, skipping"
fi

echo -e "${GREEN}✓ Sync complete!${NC}"

# Run statusline setup
echo -e "${YELLOW}Setting up statusline...${NC}"
if [ -f "$PROJECT_ROOT/documentation/setup-statusline.sh" ]; then
    bash "$PROJECT_ROOT/documentation/setup-statusline.sh"
else
    echo -e "${YELLOW}⚠${NC} Statusline setup script not found, skipping"
fi

echo -e "${YELLOW}Note: You may need to restart Claude Code for changes to take effect.${NC}"
