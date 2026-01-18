#!/bin/bash
# Sync Claude Code config from global ~/.claude to local project
# Use this to pull latest changes from global config into this project

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

printf "${YELLOW}Syncing Claude Code config from global to local project...${NC}\n"

# Sync items
sync_item() {
    local item="$1"
    if [ -e "$GLOBAL_CLAUDE/$item" ]; then
        rm -rf "$CONFIG_DIR/$item"
        cp -r "$GLOBAL_CLAUDE/$item" "$CONFIG_DIR/$item"
        printf "${GREEN}✓${NC} Synced %s\n" "$item"
    else
        printf "${YELLOW}⚠${NC} %s not found in global config, skipping\n" "$item"
    fi
}

# Sync items
sync_item "skills"
sync_item "agents"
sync_item "settings.json"
sync_item "settings.local.json"
sync_item "CLAUDE.md"

printf "${GREEN}✓ Sync complete!${NC}\n"
printf "${YELLOW}Note: Don't forget to commit your changes to git.${NC}\n"
