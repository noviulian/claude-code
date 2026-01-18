# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository manages personal Claude Code configuration—skills, agents, settings, and a custom statusline. It syncs between a local project and `~/.claude` for portability across machines.

## Commands

### Deploy configuration to global ~/.claude
```bash
./sync-to-global.sh
```
This backs up existing global config, syncs skills/agents/settings, injects API token from `.env`, and configures the statusline.

### Pull global config into this project
```bash
./sync-from-global.sh
```

### Set up statusline only (macOS, requires jq)
```bash
./documentation/setup-statusline.sh
```

## Architecture

```
.claude/
├── skills/          # SKILL.md files define each skill's behavior
├── agents/          # Custom agent definitions
├── settings.json    # Main settings (token is placeholder, injected from .env)
└── CLAUDE.md        # This file (synced to global)

documentation/       # Guides (statusline, hooks, authentication, etc.)
sync-to-global.sh    # Deploy: local → ~/.claude
sync-from-global.sh  # Pull: ~/.claude → local
```

### Token Management
- `.env` holds the real `ANTHROPIC_AUTH_TOKEN` (gitignored)
- `settings.json` has a placeholder that gets replaced during `sync-to-global.sh`

### Statusline
The statusline script (`~/.claude/statusline-command.sh`) reads the transcript file directly for accurate token counts that reset after `/clear`. It displays: model, progress bar, percentage, context tokens, git branch, project name.

## File Creation Policy

**Before creating ANY file:**
1. Did the user explicitly request it? → If no, don't create
2. Does an existing file serve this purpose? → Update it instead
3. Is it temp/debug/analysis? → Don't persist it
4. Could it go in README.md or `documentation/`? → Put it there

**Never create:** `*ANALYSIS*.md`, `*DEBUG*.md`, `*SUMMARY*.md`, `*FIX*.md`, `CHANGELOG.md`, `TODO.md`, ad-hoc test scripts

**Prefer:** Editing existing files, using `documentation/` for new guides (only if requested)
