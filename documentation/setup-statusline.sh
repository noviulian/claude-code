#!/bin/bash

###############################################################################
# Claude Code Statusline Setup Script
# Supports macOS and Linux
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

# Print functions using printf for portability
print_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

print_header() {
    printf "\n"
    printf "${BLUE}========================================${NC}\n"
    printf "${BLUE}%s${NC}\n" "$1"
    printf "${BLUE}========================================${NC}\n"
    printf "\n"
}

# Detect OS
OS_TYPE="$(uname -s)"
case "$OS_TYPE" in
    Darwin)
        OS_NAME="macOS"
        ;;
    Linux)
        OS_NAME="Linux"
        ;;
    *)
        print_error "Unsupported OS: $OS_TYPE"
        exit 1
        ;;
esac

print_header "Claude Code Statusline Setup ($OS_NAME)"

# Check for required dependencies
print_info "Checking dependencies..."

# Install jq based on OS
install_jq() {
    case "$OS_TYPE" in
        Darwin)
            if command -v brew >/dev/null 2>&1; then
                brew install jq
            else
                print_error "Homebrew is not installed. Please install jq manually:"
                printf "  brew install jq\n"
                printf "  Or install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"\n"
                exit 1
            fi
            ;;
        Linux)
            if command -v apt-get >/dev/null 2>&1; then
                print_info "Installing jq via apt-get..."
                sudo apt-get update && sudo apt-get install -y jq
            elif command -v dnf >/dev/null 2>&1; then
                print_info "Installing jq via dnf..."
                sudo dnf install -y jq
            elif command -v yum >/dev/null 2>&1; then
                print_info "Installing jq via yum..."
                sudo yum install -y jq
            elif command -v pacman >/dev/null 2>&1; then
                print_info "Installing jq via pacman..."
                sudo pacman -S --noconfirm jq
            elif command -v zypper >/dev/null 2>&1; then
                print_info "Installing jq via zypper..."
                sudo zypper install -y jq
            else
                print_error "Could not detect package manager. Please install jq manually."
                exit 1
            fi
            ;;
    esac
}

# Check for jq
if ! command -v jq >/dev/null 2>&1; then
    print_warning "jq is not installed. Attempting to install..."
    install_jq
    # Verify installation
    if ! command -v jq >/dev/null 2>&1; then
        print_error "Failed to install jq. Please install it manually."
        exit 1
    fi
fi
print_success "jq is installed"

# Check for git
if ! command -v git >/dev/null 2>&1; then
    print_warning "git is not installed (optional, needed for branch display)"
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
# Enhanced with colors and progress bar
# This script receives JSON input via stdin with session information
# and outputs a formatted status line
#
# Key insight: We read the transcript file directly to get accurate token counts
# that properly reset after /clear commands (similar to ccstatusline approach)

# ANSI Color codes
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
ORANGE='\033[38;5;208m'
RED='\033[31m'
MAGENTA='\033[35m'
GRAY='\033[90m'
WHITE='\033[97m'
BOLD='\033[1m'
RESET='\033[0m'

# Progress bar colors
BAR_LOW='\033[32m'    # Green
BAR_MED='\033[33m'    # Yellow
BAR_HIGH='\033[38;5;208m'  # Orange
BAR_FULL='\033[31m'   # Red
BAR_EMPTY='\033[90m'  # Gray

# Get context window size for a model (portable function, no associative arrays)
get_context_size() {
    case "$1" in
        claude-opus-4-5-*|claude-sonnet-4-*|claude-3-5-*|claude-3-opus-*|claude-3-sonnet-*|claude-3-haiku-*)
            echo 200000 ;;
        *)
            echo 200000 ;;  # Default
    esac
}

# Read the JSON input
input=$(cat)

# Extract relevant fields using jq
model_id=$(printf '%s' "$input" | jq -r '.model.id // ""')
model_display=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')
current_dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // "Unknown"')
project_dir=$(printf '%s' "$input" | jq -r '.workspace.project_dir // "Unknown"')
transcript_path=$(printf '%s' "$input" | jq -r '.transcript_path // ""')

# Get context window size for this model
context_window_size=$(get_context_size "$model_id")

# Calculate tokens from transcript file (accurate, resets with /clear)
context_length=0
total_input=0
total_output=0

if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    # Use jq to process entire transcript in one pass (fast)
    # Returns: total_input total_output context_length
    read -r total_input total_output context_length < <(
        jq -s '
            # Calculate totals from all messages
            (map(select(.message.usage) |
                (.message.usage.input_tokens // 0) +
                (.message.usage.cache_read_input_tokens // 0) +
                (.message.usage.cache_creation_input_tokens // 0)
            ) | add // 0) as $total_in |

            (map(select(.message.usage) |
                .message.usage.output_tokens // 0
            ) | add // 0) as $total_out |

            # Context length from most recent main-chain message with tokens
            (map(select((.isSidechain | not) and .message.usage.input_tokens > 0)) |
                last |
                ((.message.usage.input_tokens // 0) +
                 (.message.usage.cache_read_input_tokens // 0) +
                 (.message.usage.cache_creation_input_tokens // 0))
            ) // 0 as $ctx_len |

            "\($total_in) \($total_out) \($ctx_len)"
        ' -r "$transcript_path" 2>/dev/null || printf "0 0 0"
    )
fi

# Calculate percentage based on context length (current context window usage)
total_used=$((total_input + total_output))
if [ "$context_window_size" -gt 0 ] && [ "$context_length" -gt 0 ]; then
    used_pct=$((context_length * 100 / context_window_size))
else
    used_pct=0
fi

# Get project name
project_name=$(basename "$project_dir")

# Get git branch if in a git repo
git_branch=""
if command -v git >/dev/null 2>&1; then
    git_info=$(cd "$current_dir" 2>/dev/null && git rev-parse --is-inside-work-tree 2>/dev/null)
    if [ "$git_info" = "true" ]; then
        git_branch=$(cd "$current_dir" 2>/dev/null && git branch --show-current 2>/dev/null)
    fi
fi

# Create progress bar
create_progress_bar() {
    local percentage=$1
    local bar_width=20
    local filled=$(( percentage * bar_width / 100 ))
    local empty=$(( bar_width - filled ))

    # Choose color based on usage
    local bar_color
    if [ "$percentage" -ge 90 ]; then
        bar_color=$BAR_FULL
    elif [ "$percentage" -ge 70 ]; then
        bar_color=$BAR_HIGH
    elif [ "$percentage" -ge 40 ]; then
        bar_color=$BAR_MED
    else
        bar_color=$BAR_LOW
    fi

    # Build the bar
    local bar="${bar_color}"
    local i=0
    while [ $i -lt $filled ]; do
        bar="${bar}#"
        i=$((i + 1))
    done
    bar="${bar}${BAR_EMPTY}"
    i=0
    while [ $i -lt $empty ]; do
        bar="${bar}-"
        i=$((i + 1))
    done
    bar="${bar}${RESET}"

    printf '%b' "$bar"
}

# Choose percentage color based on usage
get_percentage_color() {
    local pct=$1
    if [ "$pct" -ge 90 ]; then
        printf '%b' "$RED"
    elif [ "$pct" -ge 70 ]; then
        printf '%b' "$ORANGE"
    elif [ "$pct" -ge 40 ]; then
        printf '%b' "$YELLOW"
    else
        printf '%b' "$GREEN"
    fi
}

# Build status line with colors
# Format: Model | [Progress Bar] | XX% | Tokens: input/output | branch | project

status_line=""

# 1. Model name (Cyan)
status_line="${status_line}${CYAN}${BOLD}${model_display}${RESET}"

# 2. Progress bar (always show, even at 0% after /clear)
status_line="${status_line} ${GRAY}|${RESET} "
status_line="${status_line}$(create_progress_bar "$used_pct")"

# 3. Percentage (colored based on usage)
pct_color=$(get_percentage_color "$used_pct")
status_line="${status_line} ${pct_color}${used_pct}%${RESET}"

# 4. Context size (current window usage) / max
context_len_formatted=$(printf "%'d" "$context_length" 2>/dev/null || printf "%d" "$context_length")
context_size_formatted=$(printf "%'d" "$context_window_size" 2>/dev/null || printf "%d" "$context_window_size")
status_line="${status_line} ${GRAY}|${RESET} ${WHITE}${context_len_formatted}${RESET}${GRAY}/${RESET}${WHITE}${context_size_formatted}${RESET}"

# 5. Git branch (Magenta)
if [ -n "$git_branch" ]; then
    status_line="${status_line} ${GRAY}|${RESET} ${MAGENTA}${git_branch}${RESET}"
fi

# 6. Project name (Green)
if [ -n "$project_name" ] && [ "$project_name" != "Unknown" ]; then
    status_line="${status_line} ${GRAY}|${RESET} ${GREEN}${project_name}${RESET}"
fi

# Output the final status line
printf '%b\n' "$status_line"
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
            temp_file=$(mktemp -t claude.XXXXXX)
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
    printf '{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline-command.sh"
  }
}\n'
fi

print_header "Setup Complete!"

print_success "Claude Code statusline has been configured"
printf "\n"
print_info "What was configured:"
printf "  1. Statusline command script: %s\n" "$STATUSLINE_SCRIPT"
printf "  2. Project settings: %s\n" "$PROJECT_SETTINGS"
printf "\n"
print_info "Features included:"
printf "  - Model display name (colored cyan)\n"
printf "  - Progress bar with color-coded usage (green -> yellow -> orange -> red)\n"
printf "  - Context usage percentage (calculated from actual token usage)\n"
printf "  - Token usage: total_used/max_context_size with comma formatting\n"
printf "  - Git branch (colored magenta)\n"
printf "  - Project name (colored green)\n"
printf "\n"
print_info "Customizing the statusline:"
printf "  You can edit the script at: %s\n" "$STATUSLINE_SCRIPT"
printf "\n"
print_info "To test the statusline, restart Claude Code and the status bar will appear."
