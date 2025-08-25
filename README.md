# chuk-ai-bash-tools

Agent-friendly bash tools with a pure JSON stdin/stdout contract. Built for AI assistants, automation, and pipeline processing.

## 🚀 Quick Start

```bash
# Install a specific tool
curl -fsSL https://raw.githubusercontent.com/chrishayuk/chuk-ai-bash-tools/main/install.sh | \
  bash -s -- hello.world

# Try it out
echo '{"name":"World"}' | hello.world | jq

# Or if you've cloned the repo, use Make
make install-hello
make test
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

- `bash` 3.2+ (compatible with macOS default shell)
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

Use WSL2 for best compatibility:
```powershell
# Install WSL2 (PowerShell as Admin)
wsl --install

# Then use normally in WSL2
curl -fsSL .../install.sh | bash -s -- hello.world
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