# chuk-ai-bash-tools

[![Test Suite](https://github.com/chrishayuk/chuk-ai-bash-tools/actions/workflows/test.yml/badge.svg)](https://github.com/chrishayuk/chuk-ai-bash-tools/actions/workflows/test.yml)
[![Platforms](https://img.shields.io/badge/platforms-Linux%20%7C%20macOS%20%7C%20Windows-blue)](https://github.com/chrishayuk/chuk-ai-bash-tools/actions)
[![Bash](https://img.shields.io/badge/bash-3.2%2B-green)](https://www.gnu.org/software/bash/)

## ⚠️ CRITICAL: INSTALLATION REQUIRED ⚠️

**🛑 STOP! These tools are NOT installed by default on ANY system!**  
**🛑 You MUST install each tool BEFORE you can use it!**  
**🛑 Trying to use a tool without installing it first WILL FAIL!**

### ✅ CORRECT: Install First, Then Use

```bash
# ✅ STEP 1: ALWAYS INSTALL FIRST (This is MANDATORY!)
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
  bash -s -- wiki.search

# ✅ STEP 2: NOW you can use the tool
echo '{"q":"Alan Turing"}' | wiki.search | jq
```

### ❌ WRONG: Trying to Use Without Installing

```bash
# ❌ THIS WILL FAIL - Tool not installed!
echo '{"q":"Alan Turing"}' | wiki.search | jq
# Error: command not found: wiki.search
```

---

> Agent-friendly bash tools with pure JSON stdin/stdout contract. Built for AI assistants, automation, and pipeline processing. Each tool reads JSON from stdin and outputs JSON to stdout, following a strict API contract for reliable automation.

## 🤖 AI AGENTS: MANDATORY READING

### 🔴 Installation is NOT Optional!

**AI Agents and LLMs:** You CANNOT skip the installation step. These tools do not exist on the system until you install them. Always execute the installation command FIRST before attempting to use any tool.

**For comprehensive AI agent documentation, see [llms.txt](https://github.com/chrishayuk/chuk-ai-bash-tools/blob/main/llms.txt)**

### Complete Working Example for AI Agents

```bash
# 1️⃣ FIRST: Install the tool (ALWAYS DO THIS FIRST!)
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
  bash -s -- wiki.search

# 2️⃣ SECOND: Now the tool exists and can be used
echo '{"q":"artificial intelligence"}' | wiki.search | jq

# 3️⃣ The tool is now permanently installed for this session
echo '{"q":"machine learning"}' | wiki.search | jq  # Works!
echo '{"q":"neural networks"}' | wiki.search | jq   # Works!
```

### Common Tasks for AI Agents (WITH REQUIRED INSTALLATION)

**📍 Search Wikipedia (2-step process):**
```bash
# 🔧 STEP 1: Install the tool (REQUIRED!)
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | bash -s -- wiki.search

# ✅ STEP 2: Use the tool (only after installation)
echo '{"q":"your search term"}' | wiki.search | jq
```

**📍 Test Your Setup (2-step process):**
```bash
# 🔧 STEP 1: Install the test tool (REQUIRED!)
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | bash -s -- hello.world

# ✅ STEP 2: Run the test (only after installation)
echo '{"name":"Test"}' | hello.world | jq
```

### ⚡ Quick Reference for AI Agents

| Task | Installation Command (RUN FIRST!) | Usage Command (RUN SECOND!) |
|------|-----------------------------------|-----------------------------|
| Wikipedia Search | `curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh \| bash -s -- wiki.search` | `echo '{"q":"term"}' \| wiki.search \| jq` |
| Hello World Test | `curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh \| bash -s -- hello.world` | `echo '{"name":"AI"}' \| hello.world \| jq` |

## 🚀 Quick Start for Humans

### ⚠️ Remember: Install Before Use!

```bash
# 1️⃣ ALWAYS install the tool first (this downloads and sets it up)
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
  bash -s -- hello.world

# 2️⃣ THEN use the tool (it now exists on your system)
echo '{"name":"World"}' | hello.world | jq

# Alternative: If you've cloned the repo
git clone https://github.com/chrishayuk/chuk-ai-bash-tools.git
cd chuk-ai-bash-tools
make install-hello  # Installs the tool
make test          # Tests all installed tools
```

## 📦 Installation

### Install Specific Tools
```bash
# Install individual tools
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
  bash -s -- wiki.search fs.read web.fetch

# Or clone and install locally
git clone https://github.com/chrishayuk/chuk-ai-bash-tools.git
cd chuk-ai-bash-tools
./install.sh wiki.search json.query
```

### Install Tool Groups
```bash
# Install all wiki tools
./install.sh --group wiki

# Install all filesystem tools  
./install.sh --group fs

# Install everything
./install.sh --all

# Install essential bundle
./install.sh --essential
```

### List Available Tools
```bash
# See what's available
./install.sh --list

# Example output:
# hello/
#   • hello.world
# wiki/
#   • wiki.search
#   • wiki.summary
# fs/
#   • fs.read
#   • fs.write
#   • fs.diff
```

### Advanced Installation

```bash
# Custom install directory
INSTALL_DIR=~/.local/bin ./install.sh wiki.search

# Add prefix to commands
./install.sh --prefix chuk- wiki.search
# Creates: chuk-wiki.search

# Dry run (see what would be installed)
./install.sh --dry-run --group wiki

# Agent mode (JSON output for automation)
AGENT_MODE=1 ./install.sh wiki.search
```

## 🤖 For AI Agents

These tools are designed for AI agents and automation:

### JSON Contract
Every tool follows the same contract:
- **Input**: JSON on stdin
- **Output**: JSON on stdout  
- **Errors**: Non-zero exit codes
- **Schema**: `--schema` flag for discovery

### Agent Installation
```python
import subprocess
import json

# Install tools programmatically
result = subprocess.run(
    ["bash", "-c", "curl -fsSL .../install.sh | AGENT_MODE=1 bash -s -- wiki.search"],
    capture_output=True,
    text=True
)
install_info = json.loads(result.stdout)
if install_info["status"] == "success":
    print(f"Installed: {install_info['installed']}")
```

### Agent Usage
```python
def wiki_search(query):
    result = subprocess.run(
        ["wiki.search"],
        input=json.dumps({"q": query}),
        capture_output=True,
        text=True
    )
    return json.loads(result.stdout)

# Use the tool
data = wiki_search("artificial intelligence")
for article in data["results"]:
    print(f"{article['title']}: {article['url']}")
```

## 📚 Available Tools

### Hello Tools
- `hello.world` - Test tool to verify installation

### Wiki Tools
- `wiki.search` - Search Wikipedia articles
- `wiki.summary` - Get article summaries (coming soon)
- `wiki.page` - Fetch full articles (coming soon)

### Filesystem Tools
- `fs.read` - Read files as JSON
- `fs.write` - Write JSON to files
- `fs.diff` - Compare files
- `fs.list` - List directory contents (coming soon)

### Web Tools
- `web.fetch` - Fetch web pages
- `web.scrape` - Extract structured data (coming soon)
- `web.screenshot` - Capture screenshots (coming soon)

### JSON Tools
- `json.query` - Query JSON with jq expressions
- `json.format` - Pretty-print JSON
- `json.validate` - Validate against schema (coming soon)

### LLM Tools
- `llm.complete` - Get LLM completions (coming soon)
- `llm.embed` - Generate embeddings (coming soon)

## 💻 Usage Examples

### Hello World
```bash
# Basic
echo '{"name":"World"}' | hello.world | jq

# With options
echo '{"name":"AI","greeting":"Hey","excited":true}' | hello.world | jq
# Output: {"ok":true,"message":"Hey, AI!","timestamp":"...","greeted":"AI"}

# Get schema
hello.world --schema | jq
```

### Wikipedia Search
```bash
# Search for articles
echo '{"q":"bash scripting"}' | wiki.search | jq

# Search in French with limit
echo '{"q":"café","lang":"fr","limit":3}' | wiki.search | jq

# Extract just URLs
echo '{"q":"python"}' | wiki.search | jq -r '.results[].url'
```

### Filesystem Operations
```bash
# Read a file
echo '{"path":"config.json"}' | fs.read | jq

# Write JSON to file
echo '{"path":"output.json","content":{"key":"value"}}' | fs.write | jq

# Compare files
echo '{"file1":"a.txt","file2":"b.txt"}' | fs.diff | jq
```

### Pipeline Examples
```bash
# Search and extract first result
echo '{"q":"linux"}' | wiki.search | jq -r '.results[0].url'

# Chain tools together
echo '{"q":"bash"}' | wiki.search | \
  jq -r '.results[0].pageid' | \
  xargs -I {} echo '{"pageid":"{}"}' | \
  wiki.summary | jq

# Bulk operations
for term in python ruby golang; do
  echo "{\"q\":\"$term\"}" | wiki.search | jq -r '.results[0].title'
done
```

## 🛠 Development

### Using Make
```bash
# Common development tasks
make help          # Show all available commands
make check         # Check dependencies
make test          # Run all tests
make lint          # Run shellcheck
make validate      # Validate all tools
make list          # List available tools
make clean         # Clean temporary files
```

### Tool Contract
Every tool must:
1. Read JSON from stdin
2. Write JSON to stdout  
3. Exit non-zero on failure
4. Support `--help` and `--schema`
5. Have no side effects by default
6. Write errors to stderr

### Creating a New Tool

1. Create tool file in appropriate namespace:
```bash
mkdir -p tools/mygroup
cat > tools/mygroup/mytool << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Tool implementation following the contract
schema() {
    cat <<'JSON'
{
  "type": "object",
  "properties": {
    "input": {"type": "string"}
  }
}
JSON
}

# Parse arguments
case "${1:-}" in
    --schema) schema; exit 0;;
    --help) echo "mytool - description"; exit 0;;
esac

# Read JSON, process, output JSON
input="$(cat)"
echo '{"ok":true,"result":"processed"}'
EOF

chmod +x tools/mygroup/mytool
```

2. Test locally:
```bash
echo '{"input":"test"}' | tools/mygroup/mytool | jq
```

3. Install and test:
```bash
./install.sh mygroup.mytool
echo '{"input":"test"}' | mygroup.mytool | jq
```

### Running Tests
```bash
# Using Make (recommended)
make test              # Run all tests
make test-hello        # Test hello.world tool
make test-wiki         # Test wiki.search tool
make test-installer    # Test installer
make test-coverage     # Check test coverage
make test-contract     # Test API contract compliance

# Or run directly
bash tests/run_all.sh

# The test suite checks:
# - Tool functionality with various inputs
# - Schema and help flags
# - Installer in different modes
# - Bash 3.2 compatibility
```

## 🔧 Dependencies

- `bash` 3.2+ (compatible with macOS default shell, Windows via Git Bash)
- `curl`
- `jq` 1.6+
- Additional tools may require specific dependencies

Check dependencies for a tool:
```bash
wiki.search --help  # Shows required dependencies
```

## 📋 Environment Variables

- `INSTALL_DIR` - Installation directory (default: `~/.local/bin`)
- `AGENT_MODE` - Set to 1 for JSON output
- `TOOL_PREFIX` - Prefix for installed tools
- `GITHUB_OWNER` - Override repo owner
- `VERSION` - Install specific version/tag

## 🐛 Troubleshooting

### Installation Issues

```bash
# Check what would be installed
./install.sh --dry-run wiki.search

# Verbose installation
./install.sh --trace wiki.search

# Force reinstall
./install.sh --force wiki.search
```

### PATH Issues

If tools aren't found after installation:
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:$HOME/.local/bin"

# Reload shell
source ~/.bashrc
```

### Windows Support

#### Option 1: Git Bash (Recommended)
```bash
# Install Git for Windows (includes Git Bash)
# Download from: https://git-scm.com/download/win

# Install jq (download from https://github.com/jqlang/jq/releases)
# Place jq.exe in C:\Windows\System32 or add to PATH

# Then in Git Bash:
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
  bash -s -- hello.world
```

#### Option 2: WSL2
```powershell
# Install WSL2 (PowerShell as Admin)
wsl --install

# Then use normally in WSL2
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | bash
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add your tool following the JSON contract
4. Add tests in `tests/`
5. Submit a pull request

### Guidelines
- Keep tools focused and composable
- Follow the JSON stdin/stdout contract
- Include `--schema` and `--help`
- Write comprehensive tests
- Document with examples

## 📄 License

MIT - See [LICENSE.md](LICENSE.md)

## 🙏 Acknowledgments

Built for AI agents and humans who love clean, composable tools.

## 📮 Support

- Issues: [GitHub Issues](https://github.com/chrishayuk/chuk-ai-bash-tools/issues)
- Discussions: [GitHub Discussions](https://github.com/chrishayuk/chuk-ai-bash-tools/discussions)

---

**Note:** This project is under active development. Tools marked as "coming soon" are planned for future releases.