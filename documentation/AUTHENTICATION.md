# Claude Code Authentication Guide

This guide explains how to switch between API key authentication and OAuth login (Claude.ai/Console) in Claude Code.

## Authentication Methods

Claude Code supports three authentication methods:

| Method | Use Case | Environment Variable |
|--------|----------|----------------------|
| **OAuth (Claude.ai)** | Pro/Max subscription, interactive use | None (uses `/login`) |
| **OAuth (Console)** | API usage billing, enterprise accounts | `forceLoginMethod: "console"` |
| **API Key** | Third-party APIs, custom endpoints | `ANTHROPIC_AUTH_TOKEN` |

## Method 1: OAuth Login (Default)

### Claude.ai Subscription

Run Claude Code and log in when prompted:

```bash
claude
```

Follow the browser-based authentication flow. This uses your Claude.ai Pro or Max subscription.

### Console (API Billing)

Force Console authentication in settings:

```json
{
  "forceLoginMethod": "console"
}
```

Or set via environment variable:

```bash
export ANTHROPIC_AUTH_TOKEN=""  # Leave empty to skip API key
claude
```

Then run `/login` and select Console account.

## Method 2: API Key Authentication

### Using Your Own API Endpoint

Create or edit `.claude/settings.json`:

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "your_api_key_here",
    "ANTHROPIC_BASE_URL": "https://your-api-endpoint.com"
  }
}
```

### Using Third-Party APIs

Combine with a custom base URL:

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-your-key",
    "ANTHROPIC_BASE_URL": "https://api.openai.com/v1",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "gpt-4o"
  }
}
```

### Using Environment Variables

Set in your shell before running Claude Code:

```bash
export ANTHROPIC_AUTH_TOKEN="your_api_key"
export ANTHROPIC_BASE_URL="https://your-endpoint.com"
claude
```

Or add to `.claude/settings.json`:

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "your_api_key",
    "ANTHROPIC_BASE_URL": "https://your-endpoint.com"
  }
}
```

## Switching Between Methods

### From API Key to OAuth

1. Remove `ANTHROPIC_AUTH_TOKEN` from environment variables
2. Remove it from `.claude/settings.json` → `env`
3. Run `/logout` to clear existing session
4. Run `claude` to start fresh and login via OAuth

```bash
unset ANTHROPIC_AUTH_TOKEN
claude  # Will prompt for OAuth login
```

### From OAuth to API Key

1. Run `/logout` to clear OAuth session
2. Add `ANTHROPIC_AUTH_TOKEN` to `.claude/settings.json` or environment
3. Optionally add `ANTHROPIC_BASE_URL` for custom endpoints
4. Restart Claude Code

```bash
export ANTHROPIC_AUTH_TOKEN="sk-your-key"
claude
```

## Important Notes

### Priority Order

If multiple auth methods are configured, API key takes precedence:

1. `ANTHROPIC_AUTH_TOKEN` in settings.json `env`
2. `ANTHROPIC_AUTH_TOKEN` as environment variable
3. OAuth session (from `/login`)

### Do Not Use Both

**Never set both authentication methods simultaneously.** This will cause an error:

```json
// DON'T DO THIS - causes conflicts
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-xxx",
    "ANTHROPIC_API_KEY": "sk-yyy"  // Conflict!
  }
}
```

### Security

- **API Keys**: Store in `settings.local.json` (gitignored), not directly in committed settings
- **OAuth**: More secure for interactive use, no keys to manage
- **Settings.local.json**: Use for personal auth config, never commit it

## Troubleshooting

### "Authentication failed" error

- Verify your API key is valid
- Check `ANTHROPIC_BASE_URL` is correct
- Ensure only one auth method is configured

### Stuck on old authentication method

```bash
# Clear session and login fresh
claude /logout
unset ANTHROPIC_AUTH_TOKEN  # If switching to OAuth
claude
```

### Custom endpoint not working

```bash
# Debug authentication
claude --debug "auth test query"
```

Verify the base URL format:
- Include `https://`
- Don't include trailing slash
- Some providers use `/v1` path

## Quick Reference

| Want to... | Command |
|------------|---------|
| Use Claude.ai Pro/Max | `claude` (follow prompts) |
| Use Console billing | Add `forceLoginMethod: "console"` to settings |
| Use custom API | Set `ANTHROPIC_AUTH_TOKEN` + `ANTHROPIC_BASE_URL` |
| Switch auth methods | `/logout` → clear config → restart |
| Check current auth | Run `/config` and view "Account" section |
