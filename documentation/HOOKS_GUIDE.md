# Claude Code Hooks Guide

Hooks let you run custom commands at specific points during Claude Code's operation. They provide deterministic control over behavior.

## What Are Hooks?

Hooks are shell commands that run automatically when certain events occur:

- **Before** tool calls (can block them)
- **After** tool calls
- When permissions are requested
- When notifications appear
- When sessions start/end

## Hook Events

| Event | When It Runs | Can Block? |
|-------|--------------|------------|
| `PreToolUse` | Before any tool call | Yes |
| `PermissionRequest` | When permission dialog shows | Yes |
| `PostToolUse` | After tool completes | No |
| `UserPromptSubmit` | When user submits prompt | Yes |
| `Notification` | When Claude sends notification | No |
| `Stop` | When Claude finishes responding | No |
| `SubagentStop` | When subagent completes | No |
| `PreCompact` | Before context compaction | No |
| `SessionStart` | When session starts/resumes | No |
| `SessionEnd` | When session ends | No |

## Quick Start

### 1. Interactive Setup

```bash
/hooks
```

Select `PreToolUse` → Add matcher → Add hook command.

### 2. Manual Configuration

Edit `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "echo 'Running:' $(tool_input.command)"
        }]
      }
    ]
  }
}
```

## Hook Input

Hooks receive JSON via stdin with event-specific data:

**PreToolUse example:**
```json
{
  "tool": "Bash",
  "tool_input": {
    "command": "npm test",
    "description": "Run tests"
  }
}
```

**PostToolUse example:**
```json
{
  "tool": "Edit",
  "tool_input": {
    "file_path": "src/app.ts"
  },
  "tool_result": {
    "success": true
  }
}
```

## Hook Output

### Command Hooks

Exit codes control behavior:
- `0` - Allow operation
- `1` - Allow, show warning
- `2` - Block operation

### Prompt Hooks

Output JSON to respond:

```json
{
  "allow": true,
  "message": "Optional feedback to Claude"
}
```

## Common Examples

### Auto-format TypeScript Files

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_input.file_path' | grep -q '\\.ts$' && npx prettier --write -"
      }]
    }]
  }
}
```

### Log All Bash Commands

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "jq -r '[.tool, .tool_input.command] | @tsv' >> ~/.claude/command-log.txt"
      }]
    }]
  }
}
```

### Block Sensitive File Edits

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "prompt",
        "prompt": "Block edits to production or secrets files",
        "when": {
          "tool_input.file_path": [
            "./production/**",
            "./.env",
            "./secrets/**"
          ]
        },
        "response": {
          "allow": false,
          "message": "Cannot edit protected file"
        }
      }]
    }]
  }
}
```

### Desktop Notifications

```json
{
  "hooks": {
    "Notification": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "notify-send 'Claude Code' 'Awaiting input'"
      }]
    }]
  }
}
```

### Run Tests Before Git Push

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_input.command' | grep -q '^git push' && npm test || exit 0"
      }]
    }]
  }
}
```

### Count Tool Usage

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool' >> ~/.claude/tool-usage-log.txt"
      }]
    }]
  }
}
```

### Auto-run Lint After Edits

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit",
      "hooks": [{
        "type": "command",
        "command": "FILE=$(jq -r '.tool_input.file_path'); [ -f '$CLAUDE_PROJECT_DIR/.clinerules' ] && npx eslint $FILE 2>/dev/null || true"
      }]
    }]
  }
}
```

### Session Setup

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "startup",
      "hooks": [{
        "type": "command",
        "command": "echo 'Session started in:' $CLAUDE_PROJECT_DIR"
      }]
    }]
  }
}
```

## Matcher Patterns

Match tools and operations:

| Pattern | Matches |
|---------|---------|
| `Bash` | Only Bash tool |
| `Edit\|Write` | Edit OR Write |
| `Read.*` | Read with any permission |
| `Bash(git:*)` | Git commands only |
| `*.ts` | TypeScript files (in file_path) |
| `./src/**` | Files in src directory |
| `""` | Everything (no filter) |

## Storing Hooks

### User Hooks (`~/.claude/settings.json`)

Apply to all projects:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit",
      "hooks": [{
        "type": "command",
        "command": "npx prettier --write $(tool_input.file_path)"
      }]
    }]
  }
}
```

### Project Hooks (`.claude/settings.json`)

Team-specific rules, shared via git:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Write(./production/**)",
      "hooks": [{
        "type": "prompt",
        "prompt": "Require confirmation for production writes"
      }]
    }]
  }
}
```

## Hook Script Files

For complex hooks, use separate script files:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/formatter.sh"
      }]
    }]
  }
}
```

Create `.claude/hooks/formatter.sh`:

```bash
#!/bin/bash
FILE=$(jq -r '.tool_input.file_path')

case "$FILE" in
  *.ts|*.tsx)
    npx prettier --write "$FILE"
    ;;
  *.go)
    gofmt -w "$FILE"
    ;;
  *.py)
    black "$FILE"
    ;;
esac
```

Make it executable:

```bash
chmod +x .claude/hooks/formatter.sh
```

## Available Environment Variables

Hook commands have access to:

| Variable | Description |
|----------|-------------|
| `CLAUDE_PROJECT_DIR` | Current project directory |
| `CLAUDE_SESSION_ID` | Current session UUID |
| `CLAUDE_ENV_FILE` | Path to environment file for sourcing |

## Debugging Hooks

### Test Hook Manually

```bash
# Simulate hook input
echo '{"tool":"Bash","tool_input":{"command":"ls"}}' | jq -r '.tool_input.command'
```

### Enable Debug Logging

```bash
claude --debug hooks
```

### Check Hook Configuration

```bash
jq .hooks ~/.claude/settings.json
jq .hooks .claude/settings.json
```

## Disabling Hooks

### Disable All Hooks

```json
{
  "disableAllHooks": true
}
```

### Disable Specific Hooks

Comment them out in settings.json:

```json
{
  "hooks": {
    // "PostToolUse": [...]
  }
}
```

## Best Practices

1. **Keep hooks fast** - They block Claude's operation
2. **Use matchers** - Don't run hooks unnecessarily
3. **Log for debugging** - Write to `~/.claude/hooks.log`
4. **Test interactively** - Use `/hooks` command first
5. **Document complex hooks** - Add comments in script files

## See Also

- [Hooks Reference](https://code.claude.com/docs/en/hooks) - Full API documentation
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide) - Official guide
- [SETTINGS_REFERENCE.md](SETTINGS_REFERENCE.md) - Settings configuration
