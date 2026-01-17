# Claude Code Configuration

This project contains my personal Claude Code configuration, skills, agents, and plugins.

## Structure

```
claude-code/
├── .claude/                 # Claude Code configuration (tracked in git)
│   ├── skills/             # Custom skills
│   ├── agents/             # Custom agents
│   ├── settings.json       # Main settings (with placeholder token)
│   └── settings.local.json # Local overrides
├── .env                     # API token (not in git)
├── .env.example             # Template for .env
├── sync-to-global.sh       # Deploy local config to ~/.claude
├── sync-from-global.sh     # Pull from ~/.claude to local
└── README.md
```

## Usage

### Edit Configuration Locally

1. Make changes to files in `.claude/`
2. Run the sync script to deploy globally:

```bash
./sync-to-global.sh
```

3. Restart Claude Code for changes to take effect

### API Token Management

The `ANTHROPIC_AUTH_TOKEN` in `.claude/settings.json` is a placeholder. The actual token is read from `.env` during sync:

1. Copy `.env.example` to `.env`
2. Add your actual token: `ANTHROPIC_AUTH_TOKEN=your_token_here`
3. `.env` is in `.gitignore` so it won't be committed to git

### Pull Latest from Global

If you've made changes outside this project and want to pull them in:

```bash
./sync-from-global.sh
```

## What Gets Synced

- `skills/` - Custom skills
- `agents/` - Custom agents
- `settings.json` - Main Claude Code settings
- `settings.local.json` - Local overrides

## What's NOT Synced (machine-specific)

- `plugins/` - Installed plugins (cached data, has absolute paths)
- `cache/` - Cache files
- `history.jsonl` - Chat history
- And other runtime-generated files (see .gitignore)

## Safety

The `sync-to-global.sh` script automatically creates a backup of your existing global config at `~/.claude.backup.YYYYMMDD_HHMMSS` before overwriting.
