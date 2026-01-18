# Claude Code Documentation Index

Complete documentation for your Claude Code configuration setup.

## Quick Start

1. **[One-Command Setup](../README.md#one-command-setup-new-machine)**
   - Clone and run `./sync-to-global.sh`

2. **[Statusline Setup](STATUSLINE_SETUP_GUIDE.md)**
   - Custom status line with model, branch, context info

## Configuration Guides

### Authentication
**[AUTHENTICATION.md](AUTHENTICATION.md)**
- Switch between API key and OAuth login
- Using custom API endpoints
- Third-party API integration

### Settings Reference
**[SETTINGS_REFERENCE.md](SETTINGS_REFERENCE.md)**
- Common configuration options
- Settings file locations
- Permission rules
- Model selection

### Hooks Guide
**[HOOKS_GUIDE.md](HOOKS_GUIDE.md)**
- Automate workflows
- Auto-format code
- Block sensitive files
- Custom notifications

### Environment Variables
**[ENVIRONMENT_VARIABLES.md](ENVIRONMENT_VARIABLES.md)**
- Complete variable reference
- Authentication variables
- Model configuration
- Performance tuning

## Sync Scripts

| Script | Purpose |
|--------|---------|
| `../sync-to-global.sh` | Deploy local config to `~/.claude` |
| `../sync-from-global.sh` | Pull from `~/.claude` to local |

## File Structure

```
claude-code/
├── .claude/                    # Your configuration (tracked in git)
│   ├── skills/                 # Custom skills
│   ├── agents/                 # Custom agents
│   ├── settings.json           # Main settings
│   └── settings.local.json     # Local overrides
├── documentation/              # This folder
│   ├── INDEX.md               # This file
│   ├── STATUSLINE_SETUP_GUIDE.md
│   ├── AUTHENTICATION.md
│   ├── SETTINGS_REFERENCE.md
│   ├── HOOKS_GUIDE.md
│   └── ENVIRONMENT_VARIABLES.md
├── sync-to-global.sh           # Deploy script
└── sync-from-global.sh         # Pull script
```

## Common Tasks

### Set up on a new machine
```bash
git clone <your-repo>
cd <repo>
./sync-to-global.sh
claude login  # Authenticate with Claude
```

### Add a new skill
1. Create file in `.claude/skills/my-skill/SKILL.md`
2. Run `./sync-to-global.sh`

### Configure authentication
See [AUTHENTICATION.md](AUTHENTICATION.md)

### Add a hook
See [HOOKS_GUIDE.md](HOOKS_GUIDE.md)

### Change model settings
Edit `.claude/settings.json`:
```json
{
  "model": "claude-sonnet-4-5-20250929"
}
```

### Exclude sensitive files
Edit `.claude/settings.json`:
```json
{
  "permissions": {
    "deny": ["Read(./secrets/**)", "Read(./*.pem)"]
  }
}
```

## Official Resources

- [Claude Code Docs](https://code.claude.com/docs)
- [Settings Reference](https://code.claude.com/docs/en/settings)
- [CLI Reference](https://code.claude.com/docs/en/cli-reference)
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [GitHub Issues](https://github.com/anthropics/claude-code/issues)

## Troubleshooting

### Claude Code not loading my config
1. Check settings file location: `jq . ~/.claude/settings.json`
2. Check for syntax errors: `jq . ~/.claude/settings.json`
3. Restart Claude Code

### Authentication not working
1. Run `claude login` to authenticate
2. Check `ANTHROPIC_BASE_URL` is correct (if using custom endpoint)
3. See [AUTHENTICATION.md](AUTHENTICATION.md)

### Hook not executing
1. Check hook syntax: `jq .hooks ~/.claude/settings.json`
2. Test hook manually
3. Enable debug: `claude --debug`

### Statusline not showing
1. Run `./documentation/setup-statusline.sh`
2. Check `.claude/settings.json` has `statusLine` config
3. Restart Claude Code

## Contributing

Found something missing? Add documentation:

1. Create new markdown file in `documentation/`
2. Add link to this index
3. Submit a PR

---

**Last Updated:** 2025-01-18
