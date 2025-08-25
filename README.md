# ai-tools-wiki

Agent-friendly Wikipedia tools with JSON stdin/stdout contract. Built for AI assistants, automation, and pipeline processing.

## Features

- ✅ **Pure JSON I/O** - stdin JSON in, stdout JSON out
- ✅ **Schema discovery** - `--schema` flag on every tool
- ✅ **Proper exit codes** - non-zero on failure
- ✅ **No configuration files** - stateless operation
- ✅ **Minimal dependencies** - just `bash`, `curl`, `jq`
- ✅ **AI/LLM optimized** - clean, predictable interface

## Installation

```bash
# Install latest version
curl -fsSL https://raw.githubusercontent.com/chrishayuk/ai-tools-wiki/main/install.sh | bash

# Install specific version
VERSION=v0.1.0 curl -fsSL https://raw.githubusercontent.com/chrishayuk/ai-tools-wiki/main/install.sh | bash

# Custom install directory
INSTALL_DIR=~/.local/bin curl -fsSL https://raw.githubusercontent.com/chrishayuk/ai-tools-wiki/main/install.sh | bash
```

## Tools

### wiki.search

Search Wikipedia and get structured results.

**Input schema:**
```json
{
  "q": "search query",      // or use "query"
  "lang": "en",             // Wikipedia language code (optional, default: "en")
  "limit": 5,               // Number of results (optional, default: 5, max: 50)
  "timeout": 10             // Request timeout in seconds (optional, default: 10)
}
```

**Output schema:**
```json
{
  "ok": true,
  "count": 5,
  "results": [
    {
      "title": "Alan Turing",
      "pageid": 1208,
      "snippet": "Alan Mathison Turing was an English mathematician, computer scientist...",
      "url": "https://en.wikipedia.org/?curid=1208"
    }
  ]
}
```

**Examples:**

```bash
# Basic search
echo '{"q":"alan turing"}' | wiki.search | jq

# With options
echo '{"q":"café","lang":"fr","limit":3}' | wiki.search | jq

# Using jq to build input
jq -n '{q:"quantum computing",limit:10}' | wiki.search | jq

# Get just titles
echo '{"q":"python"}' | wiki.search | jq -r '.results[].title'

# Error handling
echo '{"q":"python"}' | wiki.search || echo "Search failed"
```

## Error Handling

All tools follow consistent error patterns:

- **Exit code 0**: Success
- **Exit code 2**: Invalid input
- **Exit code 22**: HTTP/network error  
- **Exit code 127**: Missing dependencies

Error responses include:
```json
{
  "ok": false,
  "error": "error_description",
  "status": 404  // HTTP status when applicable
}
```

## Dependencies

- `bash` 4.0+
- `curl`
- `jq` 1.6+

Check dependencies:
```bash
wiki.search --help  # Shows deps and usage
```

## Development

### Running tests
```bash
bats tests/
```

### Adding a new tool
1. Create tool in `bin/` following the JSON contract
2. Add to `TOOLS` array in `install.sh`
3. Update version in `VERSION`
4. Tag release: `git tag v0.2.0 && git push --tags`

### Tool contract
Every tool must:
- Read JSON from stdin
- Write JSON to stdout
- Write errors to stderr
- Exit non-zero on failure
- Support `--help` and `--schema` flags
- Have no side effects by default

## Use Cases

### AI/LLM Agents
```python
import subprocess
import json

def wiki_search(query, limit=5):
    result = subprocess.run(
        ["wiki.search"],
        input=json.dumps({"q": query, "limit": limit}),
        capture_output=True,
        text=True
    )
    return json.loads(result.stdout)

# Use in agent
data = wiki_search("artificial intelligence", limit=3)
for article in data["results"]:
    print(f"- {article['title']}: {article['url']}")
```

### Shell Pipelines
```bash
# Find and summarize
echo '{"q":"bash scripting"}' | wiki.search | \
  jq -r '.results[0].url' | \
  xargs curl -sL | \
  grep -A 5 "Bash is"

# Bulk search
for term in "python" "ruby" "golang"; do
  echo "{\"q\":\"$term programming\"}" | wiki.search | \
    jq -r '.results[0].title'
done
```

### CI/CD Integration
```yaml
- name: Search for documentation
  run: |
    echo '{"q":"github actions"}' | wiki.search > results.json
    jq -e '.count > 0' results.json || exit 1
```

## License

MIT

## Contributing

PRs welcome! Please:
- Follow the JSON stdin/stdout contract
- Add tests for new tools
- Update README with examples
- Keep tools stateless and side-effect free

## Roadmap

- [x] `wiki.search` - Search Wikipedia
- [ ] `wiki.summary` - Get article summary by pageid
- [ ] `wiki.page` - Get full article content
- [ ] `wiki.categories` - Get article categories
- [ ] `wiki.links` - Get article links

## Related Projects

- `ai-tools-fs` - Filesystem operations
- `ai-tools-net` - Network utilities
- `ai-tools-data` - Data processing

---

**Note:** Replace `chrishayuk` with your GitHub username in the installation instructions.s