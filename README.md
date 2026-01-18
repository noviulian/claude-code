# Claude Code Configuration

This project contains my personal Claude Code configuration, skills, agents, and plugins.

## Structure

```
claude-code/
├── .claude/                 # Claude Code configuration (tracked in git)
│   ├── skills/             # Custom skills
│   ├── agents/             # Custom agents
│   ├── settings.json       # Main settings
│   ├── settings.local.json # Local overrides
│   └── CLAUDE.md           # Project-wide instructions
├── documentation/           # Detailed guides
│   ├── INDEX.md            # Documentation index
│   ├── STATUSLINE_SETUP_GUIDE.md
│   ├── AUTHENTICATION.md
│   ├── SETTINGS_REFERENCE.md
│   ├── HOOKS_GUIDE.md
│   └── ENVIRONMENT_VARIABLES.md
├── sync-to-global.sh       # Deploy local config to ~/.claude
├── sync-from-global.sh     # Pull from ~/.claude to local
└── README.md
```

## Usage

### One-Command Setup (New Machine)

Clone the repo and run:

```bash
git clone <your-repo-url>
cd <repo-directory>
./sync-to-global.sh
```

This will:
- Sync your skills, agents, and settings to `~/.claude`
- Set up the statusline with accurate token calculations
- Optionally configure MCP servers

### Authentication

Claude Code handles authentication automatically. After syncing, run:

```bash
claude login
```

### Statusline Features

- **Accurate percentage**: Calculated from actual token usage
- **Correct token display**: Shows `used/max` context window
- **Color-coded progress bar**: Green -> Yellow -> Orange -> Red
- **Comma formatting**: `77,000/200,000` for easy reading
- **Cross-platform**: Works on macOS and Linux

Example: `Claude Sonnet | [#######-------------] 38% | 77,000/200,000 | main | project`

### Edit Configuration Locally

1. Make changes to files in `.claude/`
2. Run `./sync-to-global.sh` to deploy changes
3. Restart Claude Code for changes to take effect

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
- `CLAUDE.md` - Project-wide instructions

## What's NOT Synced (machine-specific)

- `plugins/` - Installed plugins (cached data, has absolute paths)
- `cache/` - Cache files
- `history.jsonl` - Chat history
- And other runtime-generated files (see .gitignore)

## Safety

The `sync-to-global.sh` script automatically creates a backup of your existing global config at `~/.claude.backup.YYYYMMDD_HHMMSS` before overwriting.

## Cross-Platform Support

This configuration works on both **macOS** and **Linux**:

- Statusline setup detects OS and installs dependencies via the appropriate package manager
- Hooks use OS detection for notifications (`osascript` on macOS, `notify-send` on Linux)
- All shell scripts use POSIX-compatible syntax

## Documentation

See the [documentation folder](documentation/) for detailed guides:

- **[Documentation Index](documentation/INDEX.md)** - Complete documentation overview
- **[Statusline Setup Guide](documentation/STATUSLINE_SETUP_GUIDE.md)** - Custom status bar configuration
- **[Authentication Guide](documentation/AUTHENTICATION.md)** - Login and authentication
- **[Settings Reference](documentation/SETTINGS_REFERENCE.md)** - Common configuration options
- **[Hooks Guide](documentation/HOOKS_GUIDE.md)** - Automate workflows with hooks
- **[Environment Variables](documentation/ENVIRONMENT_VARIABLES.md)** - Complete variable reference
