# Claude Code Statusline Setup Guide for macOS

This guide will help you set up a custom statusline for Claude Code on macOS.

## Quick Start

The easiest way to set up the statusline is to run the setup script:

```bash
# From the directory you cloned this repo to:
bash documentation/setup-statusline.sh
```

## What the Setup Script Does

The setup script (`documentation/setup-statusline.sh`) automates the entire configuration process:

1. **Checks dependencies** - Ensures `jq` and `git` are installed (installs via Homebrew if missing)
2. **Creates the statusline script** - Sets up `~/.claude/statusline-command.sh`
3. **Configures project settings** - Updates or creates `.claude/settings.json` in your project

## What Gets Configured

After running the setup script, you'll have:

### 1. Statusline Command Script
- **Location**: `~/.claude/statusline-command.sh`
- **Purpose**: Receives JSON session data and outputs a formatted status line

### 2. Project Settings
- **Location**: `.claude/settings.json` (in your project directory)
- **Configuration**: Adds the `statusLine` command reference

## Features Included

The default statusline configuration shows:

- **Model name** - Which Claude model is active (colored cyan)
- **Progress bar** - Visual representation of context usage with color coding:
  - Green (0-39%)
  - Yellow (40-69%)
  - Orange (70-89%)
  - Red (90-100%)
- **Percentage** - Calculated as: `(total_input_tokens + total_output_tokens) / context_window_size × 100`
- **Token count** - Shows `tokens_used / max_context_size` with comma formatting
- **Git branch** - Current branch if in a git repository (colored magenta)
- **Project name** - Current project directory (colored green)

Example output:
```
Claude Sonnet | [███████░░░░░░░░░░░░░] 38% | 77,000/200,000 tokens | main | claude-code
```

## Requirements

- macOS (Darwin)
- Homebrew (for installing dependencies)
- jq (JSON processor)
- git (version control)

## Manual Setup

If you prefer to set things up manually without the script:

### Step 1: Install Dependencies

```bash
brew install jq git
```

### Step 2: Create the Statusline Script

Create `~/.claude/statusline-command.sh` with the following content:

```bash
#!/bin/bash

# Claude Code Statusline Command
# This script receives JSON input via stdin with session information
# and outputs a formatted status line

# Read the JSON input
input=$(cat)

# Extract relevant fields using jq
model_display=$(echo "$input" | jq -r '.model.display_name // "Claude"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // "Unknown"')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // "Unknown"')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

# Calculate total tokens used and percentage
total_used=$((total_input + total_output))
if [ "$context_window_size" -gt 0 ]; then
    used_pct=$((total_used * 100 / context_window_size))
else
    used_pct=0
fi

# Get project name
project_name=$(basename "$project_dir")

# Get git branch if in a git repo
git_branch=""
git_info=$(cd "$current_dir" 2>/dev/null && git rev-parse --is-inside-work-tree 2>/dev/null)
if [ "$git_info" = "true" ]; then
    git_branch=$(cd "$current_dir" 2>/dev/null && git branch --show-current 2>/dev/null)
fi

# NOTE: For full implementation including progress bar and colors,
# see the generated script at ~/.claude/statusline-command.sh
# This is a simplified example showing the key token calculations

# Build basic status line
status_line="$model_display"

# Add percentage if available
if [ -n "$used_pct" ] && [ "$used_pct" != "0" ]; then
    status_line+=" | ${used_pct}%"
fi

# Add token count
if [ "$total_used" != "0" ]; then
    total_used_formatted=$(printf "%'d" "$total_used")
    context_size_formatted=$(printf "%'d" "$context_window_size")
    status_line+=" | ${total_used_formatted}/${context_size_formatted} tokens"
fi

# Add git branch if available
if [ -n "$git_branch" ]; then
    status_line+=" | $git_branch"
fi

# Add project name
if [ -n "$project_name" ] && [ "$project_name" != "Unknown" ]; then
    status_line+=" | $project_name"
fi

# Output the final status line
echo "$status_line"
```

Make it executable:

```bash
chmod +x ~/.claude/statusline-command.sh
```

### Step 3: Configure Project Settings

Add or update the `statusLine` configuration in your project's `.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline-command.sh"
  }
}
```

If you already have a settings.json file, use jq to merge:

```bash
cd /path/to/your/project
jq '.statusLine = {"type": "command", "command": "~/.claude/statusline-command.sh"}' .claude/settings.json > .claude/settings.json.tmp
mv .claude/settings.json.tmp .claude/settings.json
```

## Customizing the Statusline

You can customize the statusline by editing `~/.claude/statusline-command.sh`. The script receives JSON input with the following structure:

```json
{
  "session_id": "string",
  "transcript_path": "string",
  "cwd": "string",
  "model": {
    "id": "string",
    "display_name": "string"
  },
  "workspace": {
    "current_dir": "string",
    "project_dir": "string"
  },
  "version": "string",
  "output_style": {
    "name": "string"
  },
  "context_window": {
    "total_input_tokens": number,
    "total_output_tokens": number,
    "context_window_size": number,
    "current_usage": {
      "input_tokens": number,
      "output_tokens": number
    } | null,
    "used_percentage": number | null,
    "remaining_percentage": number | null
  },
  "vim": {
    "mode": "INSERT" | "NORMAL"
  }
}
```

### Examples

**Show only model and token usage:**
```bash
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
total_used=$((total_input + total_output))
echo "$model | $total_used/$context_size tokens"
```

**Calculate and show percentage:**
```bash
input=$(cat)
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
total_used=$((total_input + total_output))
used_pct=$((total_used * 100 / context_size))
echo "Context: $used_pct% used ($total_used/$context_size tokens)"
```

## Importing Your Shell Prompt

You can convert your existing shell PS1 prompt to work with the statusline. Ask Claude to help you convert your shell prompt configuration by using the statusline-setup agent.

## Troubleshooting

### Statusline not appearing

1. Ensure the script is executable: `chmod +x ~/.claude/statusline-command.sh`
2. Check that `.claude/settings.json` has the correct statusLine configuration
3. Verify jq is installed: `which jq`
4. Restart Claude Code

### Script errors

1. Test the script manually:
   ```bash
   echo '{"model":{"display_name":"Claude"},"workspace":{"current_dir":"/tmp","project_dir":"/tmp"},"context_window":{"total_input_tokens":45000,"total_output_tokens":32000,"context_window_size":200000}}' | ~/.claude/statusline-command.sh
   ```
   Expected output should show progress bar, 38%, and 77,000/200,000 tokens
2. Check for syntax errors: `bash -n ~/.claude/statusline-command.sh`

## Making Further Changes

To make additional changes to your statusline configuration, simply ask Claude to help. The statusline-setup agent is specifically designed to handle status line modifications and can help you:

- Convert your shell PS1 prompt to a statusline
- Add or remove statusline features
- Customize the display format
- Debug statusline issues

---

**File Locations Reference:**
- Setup script: `documentation/setup-statusline.sh` (from the repo root)
- Statusline command: `~/.claude/statusline-command.sh`
- Project settings: `.claude/settings.json` (in your project directory)
