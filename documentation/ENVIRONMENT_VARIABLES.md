# Claude Code Environment Variables Reference

Complete reference for environment variables that control Claude Code behavior.

## Authentication Variables

| Variable | Purpose |
|----------|---------|
| `ANTHROPIC_API_KEY` | API key sent as `X-Api-Key` header |
| `ANTHROPIC_AUTH_TOKEN` | Custom `Authorization: Bearer` header value |
| `ANTHROPIC_CUSTOM_HEADERS` | Custom headers (`Name: Value` format) |
| `CLAUDE_CODE_CLIENT_CERT` | Path to client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Path to client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted private key |

### Example

```bash
export ANTHROPIC_AUTH_TOKEN="sk-your-key"
export ANTHROPIC_BASE_URL="https://api.example.com"
claude
```

## Model Configuration

| Variable | Purpose |
|----------|---------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Default Opus-class model |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Default Sonnet-class model |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Default Haiku-class model |
| `ANTHROPIC_MODEL` | Model setting name to use |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagent tasks |

### Example

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-4-5-20250929"
export ANTHROPIC_DEFAULT_SONNET_MODEL="claude-sonnet-4-5-20250929"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="claude-haiku-4-5-20250929"
```

## Bash Tool Settings

| Variable | Purpose |
|----------|---------|
| `BASH_DEFAULT_TIMEOUT_MS` | Default timeout for commands |
| `BASH_MAX_OUTPUT_LENGTH` | Max characters before truncation |
| `BASH_MAX_TIMEOUT_MS` | Maximum timeout allowed |
| `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR` | Reset to project dir after each command |

### Example

```bash
export BASH_DEFAULT_TIMEOUT_MS=120000
export BASH_MAX_TIMEOUT_MS=600000
```

## Context & Performance

| Variable | Purpose |
|----------|---------|
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Context % to trigger compaction (1-100) |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens (default: 32000, max: 64000) |
| `CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS` | Override file read token limit |
| `MAX_THINKING_TOKENS` | Extended thinking budget (default: 31999) |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching (all models) |
| `DISABLE_PROMPT_CACHING_OPUS` | Disable for Opus only |
| `DISABLE_PROMPT_CACHING_SONNET` | Disable for Sonnet only |
| `DISABLE_PROMPT_CACHING_HAIKU` | Disable for Haiku only |

### Example

```bash
# Compact earlier (50% instead of default 95%)
export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50

# Limit extended thinking
export MAX_THINKING_TOKENS=10000

# Disable prompt caching
export DISABLE_PROMPT_CACHING=1
```

## Network & Proxy

| Variable | Purpose |
|----------|---------|
| `HTTP_PROXY` | HTTP proxy server |
| `HTTPS_PROXY` | HTTPS proxy server |
| `NO_PROXY` | Domains to bypass proxy |
| `CLAUDE_CODE_PROXY_RESOLVES_HOSTS` | Allow proxy to do DNS resolution |

### Example

```bash
export HTTP_PROXY=http://proxy.example.com:8080
export HTTPS_PROXY=http://proxy.example.com:8080
export NO_PROXY=localhost,127.0.0.1,.internal.com
```

## MCP (Model Context Protocol)

| Variable | Purpose |
|----------|---------|
| `MCP_TIMEOUT` | Server startup timeout (ms) |
| `MCP_TOOL_TIMEOUT` | Tool execution timeout (ms) |
| `ENABLE_TOOL_SEARCH` | Enable MCP tool search (`auto`, `auto:N`, `true`, `false`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens in MCP responses (default: 25000) |

### Example

```bash
export MCP_TIMEOUT=30000
export MCP_TOOL_TIMEOUT=60000
export ENABLE_TOOL_SEARCH=auto:5  # Enable at 5% context
```

## UI & Display

| Variable | Purpose |
|----------|---------|
| `CLAUDE_CODE_DISABLE_TERMINAL_TITLE` | Don't update terminal title |
| `CLAUDE_CODE_HIDE_ACCOUNT_INFO` | Hide email/org from UI |
| `IS_DEMO` | Enable demo mode (hide sensitive info) |
| `SHOW_SPINNER_TIPS` | Show tips in spinner (default: true) |
| `terminalProgressBarEnabled` | Enable terminal progress bar |

### Example

```bash
# For streaming/recording sessions
export CLAUDE_CODE_HIDE_ACCOUNT_INFO=1
export IS_DEMO=true
```

## Updates & Telemetry

| Variable | Purpose |
|----------|---------|
| `DISABLE_AUTOUPDATER` | Disable automatic updates |
| `DISABLE_TELEMETRY` | Opt out of Statsig telemetry |
| `DISABLE_ERROR_REPORTING` | Opt out of Sentry error reporting |
| `DISABLE_BUG_COMMAND` | Disable `/bug` command |
| `DISABLE_COST_WARNINGS` | Disable cost warning messages |
| `FORCE_AUTOUPDATE_PLUGINS` | Force plugin updates even if autoupdate disabled |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Disable all non-essential traffic |

### Example

```bash
# Full privacy mode
export DISABLE_TELEMETRY=1
export DISABLE_ERROR_REPORTING=1
export DISABLE_AUTOUPDATER=1
```

## Debugging & Development

| Variable | Purpose |
|----------|---------|
| `CLAUDE_CODE_SHELL` | Override shell detection |
| `CLAUDE_CODE_SHELL_PREFIX` | Prefix all bash commands |
| `CLAUDE_CODE_TMPDIR` | Override temp directory |
| `CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL` | Skip IDE extension auto-install |
| `SLASH_COMMAND_TOOL_CHAR_BUDGET` | Max chars for slash command metadata |

### Example

```bash
# Use specific shell
export CLAUDE_CODE_SHELL=/bin/bash

# Log all commands
export CLAUDE_CODE_SHELL_PREFIX="/usr/bin/logger -t claude-code"

# Custom temp directory
export CLAUDE_CODE_TMPDIR=/tmp/claude-temp
```

## Feature Flags

| Variable | Purpose |
|----------|---------|
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Disable all background tasks |
| `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS` | Disable anthropic-beta headers |
| `CLAUDE_CODE_EXIT_AFTER_STOP_DELAY` | Auto-exit delay after idle (ms) |
| `CLAUDE_CODE_DISABLE_NON_ESSENTIAL_MODEL_CALLS` | Disable non-critical model calls |

### Example

```bash
# For CI/CD automation
export CLAUDE_CODE_EXIT_AFTER_STOP_DELAY=1000
```

## AWS & Cloud Providers

| Variable | Purpose |
|----------|---------|
| `CLAUDE_CODE_USE_BEDROCK` | Use AWS Bedrock |
| `AWS_BEARER_TOKEN_BEDROCK` | Bedrock API key for auth |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | Skip Bedrock auth (for gateways) |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Skip Vertex auth |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Skip Foundry auth |
| `ANTHROPIC_FOUNDRY_API_KEY` | Foundry API key |

### Example

```bash
# Use AWS Bedrock
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_BEARER_TOKEN_BEDROCK=your-token

# Use with LLM gateway
export CLAUDE_CODE_SKIP_BEDROCK_AUTH=1
```

## Region Overrides

| Variable | Purpose |
|----------|---------|
| `VERTEX_REGION_CLAUDE_3_5_HAIKU` | Vertex region for Haiku 3.5 |
| `VERTEX_REGION_CLAUDE_3_7_SONNET` | Vertex region for Sonnet 3.7 |
| `VERTEX_REGION_CLAUDE_4_0_OPUS` | Vertex region for Opus 4.0 |
| `VERTEX_REGION_CLAUDE_4_0_SONNET` | Vertex region for Sonnet 4.0 |
| `VERTEX_REGION_CLAUDE_4_1_OPUS` | Vertex region for Opus 4.1 |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | AWS region for Haiku |

## File & Tool Behavior

| Variable | Purpose |
|----------|---------|
| `USE_BUILTIN_RIPGREP` | Use built-in rg (`0` = use system) |
| `CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS` | Override file read token limit |
| `respectGitignore` | Statusline respects .gitignore (default: true) |

### Example

```bash
# Use system ripgrep
export USE_BUILTIN_RIPGREP=0

# Allow larger file reads
export CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS=100000
```

## Setting Variables

### Temporary (Session Only)

```bash
export VARIABLE_NAME="value"
claude
```

### Permanent (Shell Profile)

Add to `~/.zshrc` or `~/.bashrc`:

```bash
export ANTHROPIC_AUTH_TOKEN="sk-your-key"
export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-4-5-20250929"
```

### Per Project (settings.json)

Add to `.claude/settings.json`:

```json
{
  "env": {
    "NODE_ENV": "development",
    "DATABASE_URL": "postgresql://localhost/mydb"
  }
}
```

## Checking Current Values

```bash
# Check all Claude Code variables
env | grep ANTHROPIC
env | grep CLAUDE_CODE

# Check specific variable
echo $ANTHROPIC_AUTH_TOKEN
```

## Best Practices

1. **Security**: Never commit API keys. Use `.env` or shell profiles
2. **Per-project**: Use `settings.json` `env` for project-specific variables
3. **Global**: Use shell profiles for user-wide preferences
4. **Testing**: Set `CLAUDE_CODE_HIDE_ACCOUNT_INFO=1` for demos
5. **Performance**: Lower `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` for longer context

## See Also

- [AUTHENTICATION.md](AUTHENTICATION.md) - Authentication setup
- [SETTINGS_REFERENCE.md](SETTINGS_REFERENCE.md) - Settings file configuration
- [Official Settings Docs](https://code.claude.com/docs/en/settings) - Full documentation
