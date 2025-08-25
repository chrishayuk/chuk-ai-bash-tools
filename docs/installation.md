# Installation Guide

Complete installation guide for chuk-ai-bash-tools.

## Table of Contents
- [Quick Start](#quick-start)
- [System Requirements](#system-requirements)
- [Installation Methods](#installation-methods)
- [Installation Options](#installation-options)
- [Platform-Specific Instructions](#platform-specific-instructions)
- [Verifying Installation](#verifying-installation)
- [Updating Tools](#updating-tools)
- [Uninstalling](#uninstalling)
- [Troubleshooting](#troubleshooting)

## Quick Start

```bash
# Install a single tool
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
  bash -s -- hello.world

# Test it works
echo '{"name":"World"}' | hello.world | jq
```

## System Requirements

### Required Dependencies
- **bash** 4.0 or higher
- **curl** - For downloading tools and API calls
- **jq** 1.6 or higher - For JSON processing

### Optional Dependencies
- **git** - For cloning the repository
- **diff** - For filesystem comparison tools
- **pup** - For HTML parsing (web.scrape)

### Checking Dependencies
```bash
# Check all at once
for cmd in bash curl jq; do
  command -v $cmd >/dev/null && echo "✓ $cmd" || echo "✗ $cmd missing"
done

# Check versions
bash --version
curl --version
jq --version
```

## Installation Methods

### Method 1: Direct from GitHub (Recommended)
```bash
# Install specific tools
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
  bash -s -- wiki.search fs.read

# Install a tool group
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
  bash -s -- --group wiki
```

### Method 2: Clone and Install
```bash
# Clone the repository
git clone https://github.com/chrishayuk/chuk-ai-bash-tools.git
cd chuk-ai-bash-tools

# Install tools
./install.sh wiki.search web.fetch
./install.sh --group fs
./install.sh --all
```

### Method 3: Download Installer
```bash
# Download installer
wget https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh
chmod +x install.sh

# Use installer
./install.sh --list
./install.sh hello.world
```

### Method 4: Agent Mode (For Automation)
```bash
# Non-interactive JSON output
AGENT_MODE=1 curl -fsSL .../install.sh | bash -s -- wiki.search

# In CI/CD environments (auto-detects)
CI=true curl -fsSL .../install.sh | bash -s -- --group wiki
```

## Installation Options

### Listing Available Tools
```bash
# See all available tools
./install.sh --list

# Agent mode (JSON output)
AGENT_MODE=1 ./install.sh --list
```

### Installing Individual Tools
```bash
# Single tool
./install.sh wiki.search

# Multiple tools
./install.sh wiki.search fs.read web.fetch json.query

# With custom prefix
./install.sh --prefix chuk- wiki.search
# Creates: chuk-wiki.search
```

### Installing Tool Groups
```bash
# Install all wiki tools
./install.sh --group wiki

# Install multiple groups
./install.sh --group wiki --group fs

# Install all tools
./install.sh --all

# Install essential bundle
./install.sh --essential
# Installs: wiki.search, fs.read, fs.write, web.fetch, json.query
```

### Custom Installation Directory
```bash
# Install to custom directory
INSTALL_DIR=/opt/ai-tools ./install.sh wiki.search

# Or use flag
./install.sh --dir /usr/local/bin wiki.search

# User-local installation (default)
./install.sh wiki.search  # Goes to ~/.local/bin
```

### Dry Run Mode
```bash
# See what would be installed without installing
./install.sh --dry-run wiki.search
./install.sh --dry-run --group wiki
./install.sh --dry-run --all
```

### Force Installation
```bash
# Skip all confirmations
./install.sh --force wiki.search

# Reinstall/overwrite existing
./install.sh --force --group wiki
```

## Platform-Specific Instructions

### Linux (Ubuntu/Debian)
```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y curl jq

# Install tools
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | bash

# Add to PATH (if needed)
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Linux (RHEL/CentOS/Fedora)
```bash
# Install dependencies
sudo yum install -y curl jq
# or
sudo dnf install -y curl jq

# Install tools
curl -fsSL .../install.sh | bash
```

### macOS
```bash
# Install dependencies via Homebrew
brew install curl jq

# Install tools
curl -fsSL .../install.sh | bash

# Add to PATH (if using zsh)
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Windows (WSL2) - Recommended
```powershell
# In PowerShell as Administrator
wsl --install

# Restart computer, then in WSL2:
sudo apt-get update
sudo apt-get install -y curl jq

# Install tools normally
curl -fsSL .../install.sh | bash
```

### Windows (Git Bash)
```bash
# Install jq manually first
# Download from: https://github.com/stedolan/jq/releases
# Place jq.exe in /usr/bin/ or anywhere in PATH

# Then install tools
curl -fsSL .../install.sh | bash

# Note: Performance may be slower than WSL2
```

### Docker Container
```dockerfile
FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install tools
RUN curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
    bash -s -- --all

# Add to PATH
ENV PATH="$PATH:/root/.local/bin"
```

## Verifying Installation

### Basic Verification
```bash
# Test a tool
echo '{"name":"Test"}' | hello.world | jq

# Check installation location
which wiki.search

# List installed tools
ls -la ~/.local/bin/ | grep -E "(wiki|fs|web|json|llm)\."
```

### Comprehensive Test
```bash
#!/bin/bash
# Test all installed tools

TOOLS="hello.world wiki.search fs.read web.fetch json.query"

for tool in $TOOLS; do
  if command -v $tool >/dev/null 2>&1; then
    echo "✓ $tool installed"
    # Test each tool
    case $tool in
      hello.world)
        echo '{"name":"Test"}' | $tool >/dev/null && echo "  ✓ Working"
        ;;
      wiki.search)
        echo '{"q":"test"}' | $tool >/dev/null && echo "  ✓ Working"
        ;;
      *)
        $tool --help >/dev/null && echo "  ✓ Has help"
        ;;
    esac
  else
    echo "✗ $tool not found"
  fi
done
```

## Updating Tools

### Update Individual Tools
```bash
# Reinstall to get latest version
./install.sh --force wiki.search
```

### Update All Tools
```bash
# Pull latest and reinstall
cd chuk-ai-bash-tools
git pull
./install.sh --force --all
```

### Update to Specific Version
```bash
# Install specific release
VERSION=v1.2.0 ./install.sh wiki.search

# Or checkout tag
git checkout v1.2.0
./install.sh --force --all
```

## Uninstalling

### Remove Individual Tools
```bash
# Remove specific tools
rm ~/.local/bin/wiki.search
rm ~/.local/bin/fs.read
```

### Remove All Tools
```bash
# Remove all tools with pattern
rm ~/.local/bin/*.{world,search,read,write,fetch,query}

# Or if installed with prefix
rm ~/.local/bin/chuk-*
```

### Complete Uninstall Script
```bash
#!/bin/bash
# Uninstall all chuk-ai-bash-tools

INSTALL_DIR="${HOME}/.local/bin"
TOOLS=(
  "hello.world"
  "wiki.search" "wiki.summary" "wiki.page"
  "fs.read" "fs.write" "fs.diff" "fs.list"
  "web.fetch" "web.scrape"
  "json.query" "json.format" "json.validate"
)

echo "Removing tools from $INSTALL_DIR..."
for tool in "${TOOLS[@]}"; do
  if [ -f "$INSTALL_DIR/$tool" ]; then
    rm "$INSTALL_DIR/$tool"
    echo "  ✓ Removed $tool"
  fi
done

echo "Uninstall complete"
```

## Troubleshooting

### PATH Issues
```bash
# Check if install directory is in PATH
echo $PATH | grep -q "$HOME/.local/bin" && echo "✓ In PATH" || echo "✗ Not in PATH"

# Add to PATH permanently
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc

# For zsh users
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Permission Issues
```bash
# If permission denied
chmod +x ~/.local/bin/wiki.search

# If can't create directory
mkdir -p ~/.local/bin

# Alternative: install to /tmp for testing
INSTALL_DIR=/tmp/test-tools ./install.sh hello.world
```

### Network Issues
```bash
# Test connectivity
curl -I https://api.github.com

# Use proxy if needed
export HTTP_PROXY=http://proxy.example.com:8080
export HTTPS_PROXY=http://proxy.example.com:8080
./install.sh wiki.search

# Increase timeout
curl --max-time 60 -fsSL .../install.sh | bash
```

### Dependency Issues
```bash
# Missing jq on systems without package manager
# Download jq binary directly
curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o ~/.local/bin/jq
chmod +x ~/.local/bin/jq

# Test jq works
echo '{"test":"value"}' | jq
```

### Agent Mode Issues
```bash
# Debug agent mode
AGENT_MODE=1 ./install.sh wiki.search 2>debug.log
cat debug.log

# Parse JSON output
AGENT_MODE=1 ./install.sh --list | jq '.tools[]'
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `INSTALL_DIR` | Where to install tools | `~/.local/bin` |
| `AGENT_MODE` | Enable JSON output mode | `0` |
| `GITHUB_OWNER` | Repository owner | `chrishayuk` |
| `GITHUB_REPO` | Repository name | `chuk-ai-bash-tools` |
| `VERSION` | Specific version to install | `main` |
| `TOOL_PREFIX` | Prefix for tool names | (empty) |
| `CI` | Auto-enables agent mode | (empty) |

## Advanced Usage

### Custom Installation Script
```bash
#!/bin/bash
# Custom installation with logging

LOG_FILE="install.log"
TOOLS_TO_INSTALL="wiki.search fs.read web.fetch"

{
  echo "Installation started: $(date)"
  echo "Installing to: ${INSTALL_DIR:-~/.local/bin}"
  echo "Tools: $TOOLS_TO_INSTALL"
  echo "---"
  
  curl -fsSL .../install.sh | bash -s -- $TOOLS_TO_INSTALL
  
  echo "---"
  echo "Installation completed: $(date)"
} | tee -a "$LOG_FILE"
```

### Ansible Playbook
```yaml
---
- name: Install chuk-ai-bash-tools
  hosts: all
  tasks:
    - name: Install dependencies
      package:
        name:
          - curl
          - jq
        state: present
    
    - name: Download installer
      get_url:
        url: https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh
        dest: /tmp/install-ai-tools.sh
        mode: '0755'
    
    - name: Install tools
      shell: /tmp/install-ai-tools.sh --group wiki --group fs
      environment:
        INSTALL_DIR: /usr/local/bin
```

## Security Considerations

- Tools are downloaded over HTTPS
- No elevated privileges required for user installation
- Tools run with user permissions
- No persistent daemons or services
- No data collection or telemetry

## Getting Help

- Run any tool with `--help` for usage
- Check [troubleshooting guide](troubleshooting.md)
- Open an [issue on GitHub](https://github.com/chrishayuk/chuk-ai-bash-tools/issues)
- See [FAQ](faq.md) for common questions