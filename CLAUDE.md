# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains **agent-friendly bash tools** that follow a strict JSON stdin/stdout contract. Each tool is designed to be composable, stateless, and easily usable by AI agents and automation pipelines.

**CRITICAL FOR AI AGENTS**: Tools MUST be installed before use! They are NOT available by default on any system. Always install first, then use.

**Cross-platform support**: Works on Linux, macOS (Bash 3.2+), and Windows (Git Bash). All platforms are tested via GitHub Actions CI/CD.

## How to Use These Tools - AI Agent Quick Reference

### Example: Wikipedia Search for "Alan Turing"
```bash
# Step 1: ALWAYS install the tool first
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
  bash -s -- wiki.search

# Step 2: Now you can use it
echo '{"q":"Alan Turing"}' | wiki.search | jq
```

### Example: Test Tool Installation
```bash
# Install hello.world tool
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
  bash -s -- hello.world

# Test it works
echo '{"name":"Claude"}' | hello.world | jq
```

## Core Architecture

### Tool Contract
Every tool MUST follow these rules:
- **Input**: JSON via stdin
- **Output**: JSON via stdout  
- **Errors**: stderr with non-zero exit codes
- **Schema Discovery**: `--schema` flag returns JSON schema
- **Help**: `--help` flag returns usage information

### Directory Structure
- `tools/` - All tool implementations organized by namespace
  - `hello/` - Test/example tools
  - `wiki/` - Wikipedia operations
  - `fs/` - Filesystem operations (planned)
  - `web/` - Web/HTTP operations (planned)
  - `json/` - JSON processing (planned)
- `docs/` - Documentation
  - `api-contract.md` - Formal API specification
  - `development.md` - Tool development guide
  - `installation.md` - Installation documentation
- `install.sh` - Installation script with multiple modes

## Common Development Tasks

### Using Make

The project includes a comprehensive Makefile for common tasks:

```bash
# Essential commands
make help          # Show all available commands
make test          # Run all tests
make check         # Check dependencies
make install       # Install all tools
make list          # List available tools

# Testing
make test-hello    # Test hello.world tool
make test-wiki     # Test wiki.search tool
make test-coverage # Check test coverage
make test-contract # Validate API contract

# Development
make lint          # Run shellcheck
make validate      # Validate all tools
make clean         # Clean temporary files
make version       # Show version info
```

### Using Tools in Practice

**Remember: ALWAYS install before using!**

```bash
# Wikipedia Search
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | bash -s -- wiki.search
echo '{"q":"artificial intelligence"}' | wiki.search | jq

# Multiple searches
for term in "Alan Turing" "Ada Lovelace" "Charles Babbage"; do
  echo "{\"q\":\"$term\"}" | wiki.search | jq -r '.results[0].title'
done
```

### Running Tests

```bash
# Using Make (recommended)
make test
make test-coverage

# Run directly
bash tests/run_all.sh

# Test a tool directly (from repo)
echo '{"name":"Test"}' | tools/hello/world | jq
echo '{"q":"Linux"}' | tools/wiki/search | jq
```

### Creating a New Tool

1. Create tool in appropriate namespace:
```bash
mkdir -p tools/NAMESPACE
vim tools/NAMESPACE/TOOLNAME
```

2. Follow the template structure (see `tools/hello/world` for reference)

3. Make executable:
```bash
chmod +x tools/NAMESPACE/TOOLNAME
```

4. Test locally:
```bash
echo '{"param":"value"}' | tools/NAMESPACE/TOOLNAME
```

5. Install for system use:
```bash
./install.sh NAMESPACE.TOOLNAME
```

### Testing Tools

```bash
# Run complete test suite
bash tests/run_all.sh

# Test installation from GitHub
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
  FORCE=1 bash -s -- --dry-run hello.world

# Test with trace mode for debugging
echo '{"q":"test"}' | tools/wiki/search --trace
```

### Installing Tools - CRITICAL STEP

**ALWAYS install tools before trying to use them! This is not optional.**

#### Most Common Pattern for AI Agents:
```bash
# Install and use wiki.search
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
  bash -s -- wiki.search
echo '{"q":"search term"}' | wiki.search | jq

# Install and use hello.world for testing
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
  bash -s -- hello.world
echo '{"name":"Test"}' | hello.world | jq
```

#### Other Installation Options:
```bash
# If you have the repo cloned:
./install.sh wiki.search

# Install all tools in a namespace
./install.sh --group wiki

# Dry run to see what would be installed
./install.sh --dry-run wiki.search

# Install with custom prefix
./install.sh --prefix chuk- wiki.search
```

## Tool Implementation Guidelines

### Required Components
1. **Shebang**: `#!/usr/bin/env bash`
2. **Error handling**: `set -euo pipefail`
3. **Argument parsing**: Handle `--schema`, `--help`, optionally `--trace`
4. **Dependency checking**: Use `need()` function to verify commands exist
5. **JSON validation**: Validate input and provide clear error messages
6. **Exit codes**: 
   - 0: Success
   - 2: Invalid input
   - 22: Network error
   - 127: Missing dependency

### JSON Output Format
Success:
```json
{"ok": true, "result": "..."}
```

Error:
```json
{"ok": false, "error": "descriptive_error", "details": "..."}
```

## Cross-Platform Considerations

When modifying or creating tools, ensure compatibility across all platforms:

### Bash 3.2 Compatibility (macOS)
- Don't use associative arrays (`declare -A`)
- Don't use `mapfile` or `readarray`
- Avoid regex matching with `=~` (use `case` statements instead)
- Always include explicit `exit 0` at end of scripts

### Windows (Git Bash) Compatibility
- Use `.gitattributes` to enforce LF line endings
- Prefer simple file operations over complex `find` commands
- Use `/tmp` for temporary files (Git Bash emulates it)
- Be aware that Windows paths may need conversion

### CI/CD Testing
- Installer prefers local files when available (important for testing)
- GitHub Actions tests on Ubuntu, macOS, and Windows
- Use `RUNNER_TEMP` environment variable when available

## Important Patterns

### Reading JSON Input
```bash
input="$(cat)"
field="$(jq -r '.field // "default"' <<<"$input")"
```

### Error Handling
```bash
if [[ -z "$required_field" ]]; then
  jq -n '{ok:false, error:"missing_required_field"}'
  exit 2
fi
```

### Dependency Checking
```bash
need() { 
  command -v "$1" >/dev/null 2>&1 || { 
    echo "Missing dependency: $1" >&2
    exit 127
  }
}
need jq
need curl
```

## Key Files to Reference

- **Tool examples**: `tools/hello/world` (simple), `tools/wiki/search` (API integration)
- **API Contract**: `docs/api-contract.md` for formal specification
- **Development Guide**: `docs/development.md` for detailed patterns
- **Install Script**: `install.sh` for understanding tool installation

## CI/CD

The repository includes GitHub Actions workflows:
- `.github/workflows/test.yml` - Runs tests on push/PR
- `.github/workflows/release.yml` - Creates releases on tags

Tests run on both Ubuntu and macOS to ensure compatibility.

## Notes

- **Bash 3.2 Compatibility**: The installer and tools work with macOS's default Bash 3.2
- Tools should be stateless and have no side effects unless explicitly requested
- All tools must be pure bash (with common utilities like jq, curl)
- Focus on composability - tools should work well in pipelines
- Agent mode (`AGENT_MODE=1`) provides JSON output for installation and errors
- Wikipedia API requires User-Agent header (already configured in wiki.search)