#!/usr/bin/env bash
set -euo pipefail

# Configuration
GITHUB_OWNER="${GITHUB_OWNER:-chrishayuk}"
GITHUB_REPO="chuk-ai-bash-tools"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
TOOLS_BASE_DIR="tools"

# Tool naming: tools are installed as namespace.tool (e.g., wiki.search)
TOOL_PREFIX="${TOOL_PREFIX:-}"  # Optional prefix (e.g., "chuk-")

# Modes
AGENT_MODE="${AGENT_MODE:-0}"
DRY_RUN="${DRY_RUN:-0}"
LIST_MODE=0
FORCE="${FORCE:-0}"

# Auto-detect agent/CI mode
CI="${CI:-}"
if [[ -n "$CI" ]] || [[ "$AGENT_MODE" == "1" ]] || [[ ! -t 0 ]]; then
    AGENT_MODE=1
    FORCE=1
fi

# Colors (disabled in agent mode)
if [[ "$AGENT_MODE" == "1" ]] || [[ ! -t 1 ]]; then
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' BOLD='' NC=''
else
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    # MAGENTA='\033[0;35m'  # Reserved for future use
    BOLD='\033[1m'
    NC='\033[0m'
fi

# Helper functions
info() { [[ "$AGENT_MODE" == "0" ]] && echo -e "${GREEN}→${NC} $1" || true; }
warn() { [[ "$AGENT_MODE" == "0" ]] && echo -e "${YELLOW}⚠${NC} $1" >&2 || true; }
error() {
    if [[ "$AGENT_MODE" == "1" ]]; then
        jq -n --arg msg "$1" '{status:"error", message:$msg}'
    else
        echo -e "${RED}✗${NC} $1" >&2
    fi
}

need() {
    if ! command -v "$1" >/dev/null 2>&1; then
        if [[ "$AGENT_MODE" == "1" ]]; then
            jq -n --arg dep "$1" '{status:"error", message:"missing_dependency", dependency:$dep}'
            exit 127
        else
            echo -e "${RED}✗ Missing required dependency: $1${NC}" >&2
            exit 127
        fi
    fi
}

# Parse arguments
SELECTED_TOOLS=()
SELECTED_GROUPS=()

show_help() {
    cat <<EOF
${BOLD}chuk-ai-bash-tools installer${NC}

${BOLD}Usage:${NC}
    curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | bash
    curl -fsSL ... | bash -s -- wiki.search fs.read
    curl -fsSL ... | bash -s -- --group wiki
    curl -fsSL ... | bash -s -- --all

${BOLD}Options:${NC}
    ${BLUE}--list${NC}           List all available tools
    ${BLUE}--group GROUP${NC}    Install all tools from GROUP (wiki, fs, web, etc.)
    ${BLUE}--all${NC}            Install all available tools
    ${BLUE}--essential${NC}      Install essential tools bundle
    ${BLUE}--agent${NC}          Agent mode (JSON output, non-interactive)
    ${BLUE}--dry-run${NC}        Show what would be installed
    ${BLUE}--dir PATH${NC}       Install to PATH instead of ~/.local/bin
    ${BLUE}--prefix PREFIX${NC}  Add PREFIX to tool names (e.g., chuk-)
    ${BLUE}--force${NC}          Skip confirmations
    ${BLUE}--help${NC}           Show this help

${BOLD}Examples:${NC}
    # Install specific tools
    bash install.sh wiki.search web.fetch

    # Install all wiki tools
    bash install.sh --group wiki

    # Install with prefix
    bash install.sh --prefix chuk- wiki.search
    # Creates: chuk-wiki.search

    # Agent mode
    AGENT_MODE=1 bash install.sh wiki.search

${BOLD}Environment Variables:${NC}
    INSTALL_DIR      Installation directory (default: ~/.local/bin)
    TOOL_PREFIX      Prefix for tool names
    AGENT_MODE       Set to 1 for JSON output
    GITHUB_OWNER     Override repo owner (default: chrishayuk)
    VERSION          Install specific version/tag

EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --list)
            LIST_MODE=1
            shift
            ;;
        --group)
            SELECTED_GROUPS+=("$2")
            shift 2
            ;;
        --all)
            SELECTED_GROUPS+=("ALL")
            shift
            ;;
        --essential)
            # Define essential tools
            SELECTED_TOOLS+=("wiki.search" "fs.read" "fs.write" "web.fetch" "json.query")
            shift
            ;;
        --agent|--json)
            AGENT_MODE=1
            FORCE=1
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        --prefix)
            TOOL_PREFIX="$2"
            shift 2
            ;;
        --force)
            FORCE=1
            shift
            ;;
        --help|-h)
            [[ "$AGENT_MODE" == "0" ]] && show_help
            exit 0
            ;;
        -*)
            error "Unknown option: $1"
            exit 1
            ;;
        *)
            # Assume it's a tool name
            SELECTED_TOOLS+=("$1")
            shift
            ;;
    esac
done

# Check dependencies
need curl
need jq

# Fetch available tools from repo
info "Fetching available tools..."
REPO_URL="https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/contents/$TOOLS_BASE_DIR"
TAG="${VERSION:-main}"

# Get list of tool directories (namespaces)
NAMESPACES=$(curl -fsSL "$REPO_URL" 2>/dev/null | jq -r '.[] | select(.type=="dir") | .name') || {
    # If we can't reach GitHub API, fall back to local tools
    if [[ -d "$TOOLS_BASE_DIR" ]]; then
        # Simple approach for Windows compatibility
        NAMESPACES=""
        for dir in "$TOOLS_BASE_DIR"/*/; do
            if [[ -d "$dir" ]]; then
                NAMESPACES="$NAMESPACES $(basename "$dir")"
            fi
        done
        warn "Using local tools (GitHub API unavailable)"
    else
        if [[ "$LIST_MODE" == "1" ]]; then
            # In list mode, we can return empty list
            NAMESPACES=""
            warn "Unable to fetch tool list from repository"
        else
            error "Failed to fetch tool list from repository"
            exit 1
        fi
    fi
}

# Build tool list (using regular array for Bash 3.2 compatibility)
AVAILABLE_TOOLS=()
for namespace in $NAMESPACES; do
    if [[ -d "$TOOLS_BASE_DIR/$namespace" ]]; then
        # Use local files if available
        # Simple file listing for Windows compatibility
        TOOLS=""
        for file in "$TOOLS_BASE_DIR/$namespace"/*; do
            if [[ -f "$file" ]]; then
                filename=$(basename "$file")
                # Skip hidden files (starting with .)
                case "$filename" in
                    .*) continue ;;
                    *) TOOLS="$TOOLS $filename" ;;
                esac
            fi
        done
    else
        # Try to fetch from GitHub API
        TOOLS=$(curl -fsSL "$REPO_URL/$namespace" 2>/dev/null | jq -r '.[] | select(.type=="file") | .name') || continue
    fi
    for tool in $TOOLS; do
        AVAILABLE_TOOLS+=("$namespace.$tool")
    done
done

# List mode
if [[ "$LIST_MODE" == "1" ]]; then
    if [[ "$AGENT_MODE" == "1" ]]; then
        # JSON output
        if [[ ${#AVAILABLE_TOOLS[@]} -gt 0 ]]; then
            tools_array=$(printf '%s\n' "${AVAILABLE_TOOLS[@]}" | sort -u | jq -R . | jq -s .)
        else
            tools_array='[]'
        fi
        jq -n --argjson tools "$tools_array" '{status:"success", tools:$tools}'
    else
        echo -e "${BOLD}Available tools:${NC}"
        echo
        if [[ ${#AVAILABLE_TOOLS[@]} -gt 0 ]]; then
            current_namespace=""
            for tool in $(printf '%s\n' "${AVAILABLE_TOOLS[@]}" | sort -u); do
                namespace="${tool%%.*}"
                name="${tool#*.}"
                if [[ "$namespace" != "$current_namespace" ]]; then
                    [[ -n "$current_namespace" ]] && echo
                    echo -e "${BLUE}${namespace}/${NC}"
                    current_namespace="$namespace"
                fi
                echo "  • $tool"
            done
        else
            echo "No tools available (unable to fetch from repository)"
        fi
    fi
    exit 0
fi

# Expand groups to tools
if [[ ${#SELECTED_GROUPS[@]} -gt 0 ]]; then
    for group in "${SELECTED_GROUPS[@]}"; do
        if [[ "$group" == "ALL" ]]; then
            if [[ ${#AVAILABLE_TOOLS[@]} -gt 0 ]]; then
                for tool in "${AVAILABLE_TOOLS[@]}"; do
                    SELECTED_TOOLS+=("$tool")
                done
            fi
        else
            if [[ ${#AVAILABLE_TOOLS[@]} -gt 0 ]]; then
                for tool in "${AVAILABLE_TOOLS[@]}"; do
                    if [[ "$tool" == "$group."* ]]; then
                        SELECTED_TOOLS+=("$tool")
                    fi
                done
            fi
        fi
    done
fi

# Default to interactive selection if no tools specified
if [[ ${#SELECTED_TOOLS[@]} -eq 0 ]] && [[ "$AGENT_MODE" == "0" ]]; then
    echo -e "${BOLD}No tools specified!${NC}"
    echo
    echo "Usage examples:"
    echo "  ${BLUE}bash install.sh wiki.search fs.read${NC}"
    echo "  ${BLUE}bash install.sh --group wiki${NC}"
    echo "  ${BLUE}bash install.sh --all${NC}"
    echo
    echo "Run ${BLUE}bash install.sh --list${NC} to see available tools"
    exit 1
fi

# Remove duplicates
# shellcheck disable=SC2207
SELECTED_TOOLS=($(printf '%s\n' "${SELECTED_TOOLS[@]}" | sort -u))

# Validate selected tools
VALID_TOOLS=()
INVALID_TOOLS=()
for tool in "${SELECTED_TOOLS[@]}"; do
    # Check if tool exists in available tools
    tool_found=0
    if [[ ${#AVAILABLE_TOOLS[@]} -gt 0 ]]; then
        for available in "${AVAILABLE_TOOLS[@]}"; do
            if [[ "$available" == "$tool" ]]; then
                tool_found=1
                break
            fi
        done
    fi
    if [[ $tool_found -eq 1 ]]; then
        VALID_TOOLS+=("$tool")
    else
        INVALID_TOOLS+=("$tool")
    fi
done

if [[ ${#INVALID_TOOLS[@]} -gt 0 ]]; then
    if [[ "$AGENT_MODE" == "1" ]]; then
        invalid_array=$(printf '%s\n' "${INVALID_TOOLS[@]}" | jq -R . | jq -s .)
        jq -n --argjson tools "$invalid_array" '{status:"error", message:"invalid_tools", tools:$tools}'
    else
        error "Invalid tools specified:"
        for tool in "${INVALID_TOOLS[@]}"; do
            echo "  • $tool"
        done
    fi
    exit 1
fi

# Show what will be installed
if [[ "$DRY_RUN" == "1" ]] || [[ "$AGENT_MODE" == "0" ]]; then
    [[ "$AGENT_MODE" == "0" ]] && echo -e "${BOLD}Will install:${NC}"
    for tool in "${VALID_TOOLS[@]}"; do
        install_name="${TOOL_PREFIX}${tool}"
        [[ "$AGENT_MODE" == "0" ]] && echo "  • $tool → $INSTALL_DIR/$install_name"
    done
    [[ "$AGENT_MODE" == "0" ]] && echo
fi

if [[ "$DRY_RUN" == "1" ]]; then
    if [[ "$AGENT_MODE" == "1" ]]; then
        tools_array=$(printf '%s\n' "${VALID_TOOLS[@]}" | jq -R . | jq -s .)
        jq -n --argjson tools "$tools_array" '{status:"dry_run", tools:$tools}'
    else
        echo "Dry run complete (nothing installed)"
    fi
    exit 0
fi

# Confirm installation (interactive mode only)
if [[ "$AGENT_MODE" == "0" ]] && [[ "$FORCE" != "1" ]]; then
    read -p "Continue with installation? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 0
    fi
fi

# Create install directory
mkdir -p "$INSTALL_DIR" || {
    error "Cannot create directory: $INSTALL_DIR"
    exit 1
}

# Create temp directory
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# Install tools
INSTALLED=()
FAILED=()

info "Installing tools..."
for tool in "${VALID_TOOLS[@]}"; do
    namespace="${tool%%.*}"
    name="${tool#*.}"
    install_name="${TOOL_PREFIX}${tool}"
    
    [[ "$AGENT_MODE" == "0" ]] && echo -n "  • $tool ... "
    
    # Try local file first, then download from GitHub
    LOCAL_FILE="$TOOLS_BASE_DIR/$namespace/$name"
    
    if [[ -f "$LOCAL_FILE" ]]; then
        # Use local file
        if cp "$LOCAL_FILE" "$TMP_DIR/$install_name" 2>/dev/null && chmod +x "$TMP_DIR/$install_name"; then
            if mv "$TMP_DIR/$install_name" "$INSTALL_DIR/$install_name" 2>/dev/null; then
                INSTALLED+=("$tool")
                [[ "$AGENT_MODE" == "0" ]] && echo -e "${GREEN}✓${NC}"
            else
                FAILED+=("$tool")
                [[ "$AGENT_MODE" == "0" ]] && echo -e "${RED}✗ (install failed)${NC}"
            fi
        else
            FAILED+=("$tool")
            [[ "$AGENT_MODE" == "0" ]] && echo -e "${RED}✗ (copy failed)${NC}"
        fi
    else
        # Download from GitHub
        URL="https://raw.githubusercontent.com/$GITHUB_OWNER/$GITHUB_REPO/$TAG/$TOOLS_BASE_DIR/$namespace/$name"
        
        if curl -fsSL "$URL" -o "$TMP_DIR/$install_name" 2>/dev/null; then
            chmod +x "$TMP_DIR/$install_name"
            
            # Move to install directory
            if mv "$TMP_DIR/$install_name" "$INSTALL_DIR/$install_name" 2>/dev/null; then
                INSTALLED+=("$tool")
                [[ "$AGENT_MODE" == "0" ]] && echo -e "${GREEN}✓${NC}"
            else
                FAILED+=("$tool")
                [[ "$AGENT_MODE" == "0" ]] && echo -e "${RED}✗ (install failed)${NC}"
            fi
        else
            FAILED+=("$tool")
            [[ "$AGENT_MODE" == "0" ]] && echo -e "${RED}✗ (download failed)${NC}"
        fi
    fi
done

# Output results
if [[ "$AGENT_MODE" == "1" ]]; then
    # JSON output
    if [[ ${#INSTALLED[@]} -gt 0 ]]; then
        installed_array=$(printf '%s\n' "${INSTALLED[@]}" | jq -R . | jq -s .)
    else
        installed_array='[]'
    fi
    if [[ ${#FAILED[@]} -gt 0 ]]; then
        failed_array=$(printf '%s\n' "${FAILED[@]}" | jq -R . | jq -s .)
    else
        failed_array='[]'
    fi
    
    if [[ ${#FAILED[@]} -gt 0 ]]; then
        jq -n \
          --argjson installed "$installed_array" \
          --argjson failed "$failed_array" \
          --arg dir "$INSTALL_DIR" \
          '{status:"partial", installed:$installed, failed:$failed, install_dir:$dir}'
        exit 1
    else
        jq -n \
          --argjson installed "$installed_array" \
          --arg dir "$INSTALL_DIR" \
          '{status:"success", installed:$installed, install_dir:$dir}'
        exit 0
    fi
else
    # Human-readable output
    echo
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [[ ${#INSTALLED[@]} -gt 0 ]]; then
        echo -e "${GREEN}✓ Successfully installed:${NC}"
        for tool in "${INSTALLED[@]}"; do
            echo "  • ${TOOL_PREFIX}${tool}"
        done
    fi
    
    if [[ ${#FAILED[@]} -gt 0 ]]; then
        echo -e "${RED}✗ Failed to install:${NC}"
        for tool in "${FAILED[@]}"; do
            echo "  • $tool"
        done
    fi
    
    echo
    
    # Check PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        echo -e "${YELLOW}ACTION REQUIRED:${NC}"
        echo "Add to your shell config:"
        echo -e "  ${BLUE}export PATH=\"\$PATH:$INSTALL_DIR\"${NC}"
        echo
    fi
    
    # Show usage example
    if [[ ${#INSTALLED[@]} -gt 0 ]]; then
        first_tool="${TOOL_PREFIX}${INSTALLED[0]}"
        echo "Try it out:"
        if [[ "$first_tool" == *"wiki.search" ]]; then
            echo -e "  ${BLUE}echo '{\"q\":\"bash scripting\"}' | $first_tool | jq${NC}"
        else
            echo -e "  ${BLUE}$first_tool --help${NC}"
        fi
    fi
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi