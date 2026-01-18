#!/bin/bash

###############################################################################
# Claude Code Statusline Setup Script for macOS
###############################################################################

set -e

# Ensure we're in the correct directory
cd "$(dirname "$0")/.."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# Check if running on macOS
if [[ $(uname) != "Darwin" ]]; then
    print_error "This script is designed for macOS. Detected OS: $(uname)"
    exit 1
fi

print_header "Claude Code Statusline Setup"

# Check for required dependencies
print_info "Checking dependencies..."

# Check for jq
if ! command -v jq &> /dev/null; then
    print_warning "jq is not installed. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install jq
    else
        print_error "Homebrew is not installed. Please install Homebrew first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
else
    print_success "jq is installed"
fi

# Check for git
if ! command -v git &> /dev/null; then
    print_warning "git is not installed. Installing via Homebrew..."
    brew install git
else
    print_success "git is installed"
fi

# Define paths
CLAUDE_HOME="$HOME/.claude"
STATUSLINE_SCRIPT="$CLAUDE_HOME/statusline-command.sh"
PROJECT_SETTINGS="./.claude/settings.json"

# Create .claude directory in home if it doesn't exist
if [ ! -d "$CLAUDE_HOME" ]; then
    print_info "Creating $CLAUDE_HOME directory..."
    mkdir -p "$CLAUDE_HOME"
    print_success "Created $CLAUDE_HOME"
else
    print_success "$CLAUDE_HOME already exists"
fi

# Create the statusline command script
print_info "Creating statusline command script..."

cat > "$STATUSLINE_SCRIPT" << 'EOF'
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
EOF

chmod +x "$STATUSLINE_SCRIPT"
print_success "Created $STATUSLINE_SCRIPT"

# Check if we're in a project with .claude directory
if [ -d "./.claude" ]; then
    print_info "Found .claude directory in current project"
    
    # Update or create settings.json
    if [ -f "$PROJECT_SETTINGS" ]; then
        print_info "Updating existing $PROJECT_SETTINGS"
        
        # Use jq to add statusLine configuration if it doesn't exist
        if jq -e '.statusLine' "$PROJECT_SETTINGS" > /dev/null 2>&1; then
            print_info "StatusLine configuration already exists"
        else
            temp_file=$(mktemp)
            jq '.statusLine = {"type": "command", "command": "~/.claude/statusline-command.sh"}' "$PROJECT_SETTINGS" > "$temp_file"
            mv "$temp_file" "$PROJECT_SETTINGS"
            print_success "Added statusLine configuration to $PROJECT_SETTINGS"
        fi
    else
        print_info "Creating new $PROJECT_SETTINGS"
        cat > "$PROJECT_SETTINGS" << 'EOF'
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline-command.sh"
  }
}
EOF
        print_success "Created $PROJECT_SETTINGS"
    fi
else
    print_warning "No .claude directory found in current project"
    print_info "You'll need to create or update .claude/settings.json in your project with:"
    echo '{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline-command.sh"
  }
}'
fi

print_header "Setup Complete!"

print_success "Claude Code statusline has been configured"
echo ""
print_info "What was configured:"
echo "  1. Statusline command script: $STATUSLINE_SCRIPT"
echo "  2. Project settings: $PROJECT_SETTINGS"
echo ""
print_info "Features included:"
echo "  - Model display name"
echo "  - Current directory with git branch"
echo "  - Output style indicator (when non-default)"
echo "  - Vim mode indicator (when active)"
echo "  - Context window usage percentage"
echo ""
print_info "Customizing the statusline:"
echo "  You can edit the script at: $STATUSLINE_SCRIPT"
echo ""
print_info "For further changes to the status line, ask Claude to help."
echo "  The statusline-setup agent should be used for status line modifications."
echo ""
print_info "To test the statusline, restart Claude Code and the status bar will appear."
