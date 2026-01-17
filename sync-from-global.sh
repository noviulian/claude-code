#!/bin/bash
# Sync Claude Code config from global ~/.claude to local project
# Use this to pull latest changes from global config into this project

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

echo -e "${YELLOW}Syncing Claude Code config from global to local project...${NC}"

# Sync items
sync_item() {
    local item="$1"
    if [ -e "$GLOBAL_CLAUDE/$item" ]; then
        rm -rf "$CONFIG_DIR/$item"
        cp -r "$GLOBAL_CLAUDE/$item" "$CONFIG_DIR/$item"
        echo -e "${GREEN}✓${NC} Synced $item"
    else
        echo -e "${YELLOW}⚠${NC} $item not found in global config, skipping"
    fi
}

# Sync items
sync_item "skills"
sync_item "agents"
sync_item "settings.json"
sync_item "settings.local.json"

echo -e "${GREEN}✓ Sync complete!${NC}"
echo -e "${YELLOW}Note: Don't forget to commit your changes to git.${NC}"
