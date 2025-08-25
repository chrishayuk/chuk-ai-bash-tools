# wiki.search

Search Wikipedia articles and return structured results.

## Installation

```bash
# Install individually
./install.sh wiki.search

# Install with wiki group
./install.sh --group wiki
```

## Usage

```bash
# Basic search
echo '{"q":"artificial intelligence"}' | wiki.search | jq

# Search with options
echo '{"q":"café","lang":"fr","limit":3}' | wiki.search | jq

# Using jq to build input
jq -n '{q:"quantum computing",limit:10}' | wiki.search | jq
```

## Input Schema

```json
{
  "type": "object",
  "properties": {
    "q": {
      "type": "string",
      "description": "Search query"
    },
    "query": {
      "type": "string",
      "description": "Alias for 'q'"
    },
    "lang": {
      "type": "string",
      "description": "Wikipedia language code",
      "default": "en",
      "examples": ["en", "fr", "de", "es", "ja"]
    },
    "limit": {
      "type": "integer",
      "description": "Number of results to return",
      "minimum": 1,
      "maximum": 50,
      "default": 5
    },
    "timeout": {
      "type": "integer",
      "description": "Request timeout in seconds",
      "minimum": 1,
      "maximum": 60,
      "default": 10
    }
  },
  "anyOf": [
    {"required": ["q"]},
    {"required": ["query"]}
  ]
}
```

## Output Schema

```json
{
  "type": "object",
  "properties": {
    "ok": {
      "type": "boolean",
      "description": "Success status"
    },
    "count": {
      "type": "integer",
      "description": "Number of results returned"
    },
    "results": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "title": {
            "type": "string",
            "description": "Article title"
          },
          "pageid": {
            "type": "integer",
            "description": "Wikipedia page ID"
          },
          "snippet": {
            "type": "string",
            "description": "Text snippet with HTML stripped"
          },
          "url": {
            "type": "string",
            "format": "uri",
            "description": "Direct URL to article"
          }
        }
      }
    },
    "error": {
      "type": "string",
      "description": "Error message (when ok=false)"
    },
    "status": {
      "type": "integer",
      "description": "HTTP status code (on failure)"
    }
  }
}
```

## Examples

### Basic Search
```bash
$ echo '{"q":"bash scripting"}' | wiki.search | jq
{
  "ok": true,
  "count": 5,
  "results": [
    {
      "title": "Bash (Unix shell)",
      "pageid": 4739,
      "snippet": "Bash is a Unix shell and command language written by Brian Fox...",
      "url": "https://en.wikipedia.org/?curid=4739"
    },
    ...
  ]
}
```

### Search in Different Language
```bash
$ echo '{"q":"Paris","lang":"fr","limit":2}' | wiki.search | jq
{
  "ok": true,
  "count": 2,
  "results": [
    {
      "title": "Paris",
      "pageid": 681159,
      "snippet": "Paris est la capitale de la France...",
      "url": "https://fr.wikipedia.org/?curid=681159"
    },
    ...
  ]
}
```

### Extract URLs Only
```bash
$ echo '{"q":"python programming"}' | wiki.search | jq -r '.results[].url'
https://en.wikipedia.org/?curid=23862
https://en.wikipedia.org/?curid=18938536
https://en.wikipedia.org/?curid=166132
```

### Get First Result Title
```bash
$ echo '{"q":"linux"}' | wiki.search | jq -r '.results[0].title'
Linux
```

### Error Handling
```bash
$ echo '{}' | wiki.search | jq
{
  "ok": false,
  "error": "missing_query"
}
```

## Command Line Options

- `--help` - Show usage information
- `--schema` - Output JSON schema
- `--trace` - Enable debug output to stderr

## Exit Codes

- `0` - Success
- `2` - Invalid input (missing query)
- `22` - HTTP/network error
- `127` - Missing dependencies

## Dependencies

- `bash` 4.0+
- `curl`
- `jq` 1.6+

## Advanced Usage

### Pipeline with Other Tools
```bash
# Search and get summary of first result
echo '{"q":"artificial intelligence"}' | wiki.search | \
  jq -r '.results[0].pageid' | \
  xargs -I {} echo '{"pageid":"{}"}' | \
  wiki.summary | jq
```

### Batch Searching
```bash
#!/bin/bash
# Search multiple terms
terms=("python" "ruby" "golang" "rust")
for term in "${terms[@]}"; do
  echo "=== $term ==="
  echo "{\"q\":\"$term programming\",\"limit\":1}" | \
    wiki.search | \
    jq -r '.results[0] | "\(.title): \(.url)"'
done
```

### Python Integration
```python
import subprocess
import json

def wiki_search(query, lang="en", limit=5):
    """Search Wikipedia and return results."""
    input_data = {
        "q": query,
        "lang": lang,
        "limit": limit
    }
    
    result = subprocess.run(
        ["wiki.search"],
        input=json.dumps(input_data),
        capture_output=True,
        text=True,
        check=True
    )
    
    response = json.loads(result.stdout)
    if not response["ok"]:
        raise Exception(f"Search failed: {response.get('error')}")
    
    return response["results"]

# Example usage
results = wiki_search("machine learning", limit=3)
for article in results:
    print(f"{article['title']}")
    print(f"  URL: {article['url']}")
    print(f"  Snippet: {article['snippet'][:100]}...")
    print()
```

### Node.js Integration
```javascript
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

async function wikiSearch(query, options = {}) {
  const input = JSON.stringify({
    q: query,
    lang: options.lang || 'en',
    limit: options.limit || 5
  });
  
  const { stdout } = await execPromise(`echo '${input}' | wiki.search`);
  return JSON.parse(stdout);
}

// Usage
wikiSearch('javascript').then(result => {
  result.results.forEach(article => {
    console.log(`- ${article.title}: ${article.url}`);
  });
});
```

### Error Recovery
```bash
# Retry with exponential backoff
wiki_search_retry() {
  local query="$1"
  local max_retries=3
  local retry=0
  local wait=1
  
  while [ $retry -lt $max_retries ]; do
    if echo "{\"q\":\"$query\"}" | wiki.search | jq -e '.ok' > /dev/null; then
      return 0
    fi
    
    echo "Retry $((retry + 1))/$max_retries in ${wait}s..." >&2
    sleep $wait
    wait=$((wait * 2))
    retry=$((retry + 1))
  done
  
  return 1
}
```

## Performance

- Default timeout: 10 seconds
- Maximum results: 50
- Caching: None (always fetches fresh results)
- Rate limiting: None imposed by tool

## Limitations

- HTML is stripped from snippets
- Search uses Wikipedia's OpenSearch API
- Results are limited to title and snippet
- No full-text search within articles

## Troubleshooting

### No results found
- Check spelling of search query
- Try broader search terms
- Verify language code is correct

### Network errors
```bash
# Test with longer timeout
echo '{"q":"test","timeout":30}' | wiki.search --trace
```

### Missing dependencies
```bash
# Check what's missing
wiki.search --help

# Install on Ubuntu/Debian
sudo apt-get install curl jq

# Install on macOS
brew install curl jq
```

## See Also

- [wiki.summary](wiki-summary.md) - Get article summaries
- [wiki.page](wiki-page.md) - Fetch full articles
- [Wikipedia API](https://www.mediawiki.org/wiki/API:Main_page) - API documentation