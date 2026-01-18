# Claude Code Settings Reference

Quick reference for commonly used Claude Code settings.

## Settings File Locations

| Scope | Location | Shared? |
|-------|----------|---------|
| User | `~/.claude/settings.json` | No |
| Project | `.claude/settings.json` | Yes (git) |
| Project Local | `.claude/settings.local.json` | No (gitignored) |
| Managed | `/Library/Application Support/ClaudeCode/managed-settings.json` (macOS) | System-wide |

## Configuration Priority

From highest to lowest:
1. **Managed** - Cannot be overridden
2. **Command line flags** - Session-specific
3. **Local** - `.claude/settings.local.json`
4. **Project** - `.claude/settings.json`
5. **User** - `~/.claude/settings.json`

## Common Settings

### Environment Variables

Pass environment variables to Claude Code sessions:

```json
{
  "env": {
    "NODE_ENV": "development",
    "DATABASE_URL": "postgresql://localhost/mydb"
  }
}
```

### Model Selection

Override default models:

```json
{
  "model": "claude-sonnet-4-5-20250929"
}
```

Or set via environment:
```json
{
  "env": {
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-4-5-20250929",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4-5-20250929",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-haiku-4-5-20250929"
  }
}
```

### Permissions

Control what tools Claude can use:

```json
{
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git diff:*)",
      "Bash(npm test:*)",
      "Read(~/.config/*)"
    ],
    "deny": [
      "Bash(rm:*)",
      "WebFetch",
      "Read(./.env)",
      "Read(./secrets/**)",
      "Write(./production/**)"
    ]
  }
}
```

### Output Style

Change Claude's response style:

```json
{
  "outputStyle": "Explanatory"
}
```

Available styles: `default`, `Explanatory`, `Concise`

### Git Attribution

Customize commit/PR attribution:

```json
{
  "attribution": {
    "commit": "Generated with AI\n\nCo-Authored-By: AI <ai@example.com>",
    "pr": ""
  }
}
```

### Statusline

Custom status line (see [STATUSLINE_SETUP_GUIDE.md](STATUSLINE_SETUP_GUIDE.md)):

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline-command.sh"
  }
}
```

### Hooks

Run custom commands at specific events (see [HOOKS_GUIDE.md](HOOKS_GUIDE.md)):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{
          "type": "command",
          "command": "npx prettier --write $(tool_input.file_path)"
        }]
      }
    ]
  }
}
```

### Company Announcements

Show messages to team on startup:

```json
{
  "companyAnnouncements": [
    "Welcome to Acme Corp! Review our code guidelines at docs.acme.com",
    "Reminder: Code reviews required for all PRs"
  ]
}
```

### Session Cleanup

Auto-delete old sessions:

```json
{
  "cleanupPeriodDays": 30
}
```

Set to `0` to delete all sessions on startup.

### Plugins

Enable/disable plugins:

```json
{
  "enabledPlugins": {
    "formatter@acme-tools": true,
    "deployer@acme-tools": true,
    "experimental-features@personal": false
  }
}
```

### Language

Set preferred response language:

```json
{
  "language": "japanese"
}
```

### Update Channel

Control release updates:

```json
{
  "autoUpdatesChannel": "stable"
}
```

Options: `stable` (1 week old, more stable) or `latest` (newest features)

## Advanced Settings

### Sandbox (macOS/Linux only)

Isolate bash commands from filesystem:

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["docker", "git"],
    "network": {
      "allowUnixSockets": ["/var/run/docker.sock"],
      "allowLocalBinding": true
    }
  }
}
```

### File Suggestions

Custom `@` file autocomplete:

```json
{
  "fileSuggestion": {
    "type": "command",
    "command": "~/.claude/file-suggestion.sh"
  }
}
```

### Custom API Key Helper

Generate API keys dynamically:

```json
{
  "apiKeyHelper": "/usr/local/bin/generate_temp_api_key.sh"
}
```

### Plans Directory

Custom location for plan files:

```json
{
  "plansDirectory": "./plans"
}
```

## Settings Merging

Settings from different scopes are merged. More specific settings override general ones:

**User** (`~/.claude/settings.json`):
```json
{
  "permissions": {
    "deny": ["WebFetch"]
  }
}
```

**Project** (`.claude/settings.json`):
```json
{
  "permissions": {
    "allow": ["Bash(npm:*)"]
  }
}
```

**Result**: Both deny and apply in this project.

## Testing Settings

Check current settings interactively:

```bash
# Open settings UI
/config

# View as JSON
jq . ~/.claude/settings.json
jq . .claude/settings.json
```

## Common Patterns

### Development Team Settings

```json
{
  "permissions": {
    "allow": ["Bash(npm:*)", "Bash(git:*)"],
    "deny": ["Bash(npm publish)", "Write(./dist/**)"]
  },
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit",
      "command": "npx prettier --check $(tool_input.file_path)"
    }]
  },
  "companyAnnouncements": [
    "Run tests before pushing to main"
  ]
}
```

### Personal Settings

```json
{
  "env": {
    "EDITOR": "code --wait"
  },
  "model": "claude-sonnet-4-5-20250929",
  "outputStyle": "Concise",
  "cleanupPeriodDays": 7
}
```

## See Also

- [Claude Code Settings Documentation](https://code.claude.com/docs/en/settings)
- [AUTHENTICATION.md](AUTHENTICATION.md) - Authentication configuration
- [HOOKS_GUIDE.md](HOOKS_GUIDE.md) - Using hooks
- [ENVIRONMENT_VARIABLES.md](ENVIRONMENT_VARIABLES.md) - All environment variables
