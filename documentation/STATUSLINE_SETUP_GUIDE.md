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

- **Model name** - Which Claude model is active
- **Current directory** - Your working directory
- **Git branch** - Current branch if in a git repository
- **Output style** - When using a non-default output style
- **Vim mode** - Current vim mode when active
- **Context usage** - Percentage of context window used

Example output:
```
Claude 3.5 Sonnet | in claude-code on main | (12% context)
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
output_style=$(echo "$input" | jq -r '.output_style.name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

# Get git branch if in a git repo
git_branch=""
git_info=$(cd "$current_dir" 2>/dev/null && git rev-parse --is-inside-work-tree 2>/dev/null)
if [ "$git_info" = "true" ]; then
    git_branch=$(cd "$current_dir" 2>/dev/null && git branch --show-current 2>/dev/null)
    if [ -n "$git_branch" ]; then
        git_branch=" on $git_branch"
    fi
fi

# Build status line components
status_parts=()

# Add model and directory
status_parts+=("$model_display")

# Add output style if set
if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
    status_parts+=("[$output_style]")
fi

# Add vim mode if active
if [ -n "$vim_mode" ]; then
    status_parts+=("($vim_mode)")
fi

# Add directory with git branch
basename_dir=$(basename "$current_dir")
if [ "$current_dir" != "$project_dir" ]; then
    # Show relative path from project root
    relative_path="${current_dir#$project_dir/}"
    if [ "$relative_path" = "$current_dir" ]; then
        status_parts+=("in $basename_dir$git_branch")
    else
        status_parts+=("in $relative_path$git_branch")
    fi
else
    status_parts+=("in $basename_dir$git_branch")
fi

# Add context usage if available
if [ -n "$used_pct" ]; then
    status_parts+=("($used_pct% context)")
fi

# Join parts with " | "
separator=" | "
status_line=$(IFS="$separator"; echo "${status_parts[*]}")

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

**Show only model and directory:**
```bash
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name')
dir=$(echo "$input" | jq -r '.workspace.current_dir')
echo "$model in $dir"
```

**Show context remaining:**
```bash
input=$(cat)
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
[ -n "$remaining" ] && echo "Context: $remaining% remaining"
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
   echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"/tmp","project_dir":"/tmp"},"context_window":{"used_percentage":50}}' | ~/.claude/statusline-command.sh
   ```
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
