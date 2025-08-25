# Development Guide

Guide for creating new tools for chuk-ai-bash-tools.

## Table of Contents
- [Quick Start](#quick-start)
- [Tool Contract](#tool-contract)
- [Creating a New Tool](#creating-a-new-tool)
- [Tool Structure](#tool-structure)
- [Testing Tools](#testing-tools)
- [Best Practices](#best-practices)
- [Common Patterns](#common-patterns)
- [Publishing Tools](#publishing-tools)

## Quick Start with Make

Use the Makefile for rapid development:

```bash
# Check your environment
make check

# See all available commands
make help

# Validate existing tools
make validate

# Run tests
make test

# Clean up
make clean
```

## Quick Start - Creating a Tool

Create a minimal tool in 5 minutes:

```bash
# 1. Create tool file
mkdir -p tools/mygroup
cat > tools/mygroup/mytool << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  --schema) 
    echo '{"type":"object","properties":{"input":{"type":"string"}}}'
    exit 0
    ;;
  --help)
    echo "mytool - My tool description"
    exit 0
    ;;
esac

input="$(cat)"
result=$(echo "$input" | jq -r '.input // "default"' | tr '[:lower:]' '[:upper:]')
jq -n --arg result "$result" '{ok:true, output:$result}'
EOF

# 2. Make executable
chmod +x tools/mygroup/mytool

# 3. Test locally
echo '{"input":"hello"}' | tools/mygroup/mytool
# Output: {"ok":true,"output":"HELLO"}

# 4. Install and test
./install.sh mygroup.mytool
echo '{"input":"world"}' | mygroup.mytool | jq
```

## Tool Contract

Every tool MUST follow these rules:

### 1. Input/Output
- **Read JSON from stdin**
- **Write JSON to stdout**
- **Write errors/logs to stderr**
- **Exit with proper codes**

### 2. Required Flags
```bash
--help    # Display usage information
--schema  # Output JSON schema for input
```

### 3. Optional Flags
```bash
--version  # Tool version
--trace    # Debug output to stderr
--verbose  # Verbose output
```

### 4. Exit Codes
- `0` - Success
- `1` - General error
- `2` - Invalid input/arguments
- `22` - Network/HTTP error
- `127` - Missing dependencies

### 5. Error Output
```json
{
  "ok": false,
  "error": "descriptive_error_message",
  "details": "optional additional context"
}
```

## Creating a New Tool

### Step 1: Choose a Namespace
Tools are organized by namespace:
- `wiki/` - Wikipedia operations
- `fs/` - Filesystem operations
- `web/` - Web/HTTP operations
- `json/` - JSON processing
- `text/` - Text processing
- `llm/` - LLM integrations
- Create new namespace if needed

### Step 2: Tool Template

```bash
#!/usr/bin/env bash
set -euo pipefail

# ================================================================
# tool-name - Brief description
# ================================================================
# Reads:  JSON with 'field1' and 'field2'
# Output: JSON with 'result' and 'metadata'
# ================================================================

# --- Functions ---

usage() {
    cat <<'EOF'
namespace.tool — Brief description (JSON in → JSON out)

Input:
  { "field1": "value", "field2": 123 }

Output:
  { "ok": true, "result": "...", "metadata": {...} }

Options:
  --schema   Output JSON schema
  --help     Show this help
  --version  Show version
  --trace    Enable debug output

Examples:
  echo '{"field1":"test"}' | namespace.tool
  jq -n '{field1:"value",field2:42}' | namespace.tool | jq

Dependencies: bash, jq, curl (if needed)
EOF
}

schema() {
    cat <<'JSON'
{
  "type": "object",
  "properties": {
    "field1": {
      "type": "string",
      "description": "Description of field1"
    },
    "field2": {
      "type": "integer",
      "description": "Description of field2",
      "default": 10
    }
  },
  "required": ["field1"]
}
JSON
}

version() {
    echo "namespace.tool v1.0.0"
}

need() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: Missing required dependency: $1" >&2
        exit 127
    fi
}

# --- Argument Parsing ---

TRACE=0
VERBOSE=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --schema)
            schema
            exit 0
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        --version|-v)
            version
            exit 0
            ;;
        --trace)
            TRACE=1
            shift
            ;;
        --verbose)
            VERBOSE=1
            shift
            ;;
        *)
            echo "Error: Unknown option: $1" >&2
            echo "Try: namespace.tool --help" >&2
            exit 2
            ;;
    esac
done

# --- Dependency Check ---

need jq
# need curl  # if needed
# need other_command

# --- Main Logic ---

# Read input
input="$(cat)"
[[ $TRACE -eq 1 ]] && echo "DEBUG: Input: $input" >&2

# Validate input
if ! echo "$input" | jq -e . >/dev/null 2>&1; then
    jq -n '{ok:false, error:"invalid_json_input"}'
    exit 2
fi

# Parse fields with defaults
field1="$(echo "$input" | jq -r '.field1 // empty')"
field2="$(echo "$input" | jq -r '.field2 // 10')"

# Validate required fields
if [[ -z "$field1" ]]; then
    jq -n '{ok:false, error:"missing_required_field", field:"field1"}'
    exit 2
fi

[[ $TRACE -eq 1 ]] && echo "DEBUG: field1='$field1', field2='$field2'" >&2

# Process (main tool logic here)
result="Processed: $field1 with $field2"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# Output result
jq -n \
    --arg result "$result" \
    --arg timestamp "$timestamp" \
    --arg field1 "$field1" \
    --argjson field2 "$field2" \
    '{
        ok: true,
        result: $result,
        metadata: {
            timestamp: $timestamp,
            input: {
                field1: $field1,
                field2: $field2
            }
        }
    }'

[[ $TRACE -eq 1 ]] && echo "DEBUG: Completed successfully" >&2
```

### Step 3: Documentation

Create `docs/tools/namespace-tool.md`:

```markdown
# namespace.tool

Brief description of what the tool does.

## Installation
\```bash
./install.sh namespace.tool
\```

## Usage
\```bash
echo '{"field1":"value"}' | namespace.tool | jq
\```

## Input Schema
[Document the input JSON structure]

## Output Schema
[Document the output JSON structure]

## Examples
[Provide 3-5 real examples with output]

## Dependencies
- bash 3.2+ (compatible with macOS default)
- jq 1.6+
- other dependencies

## See Also
- [related.tool](related-tool.md)
```

## Tool Structure

### Minimal Tool
```bash
#!/usr/bin/env bash
set -euo pipefail

[[ "${1:-}" == "--schema" ]] && echo '{"type":"object"}' && exit 0
[[ "${1:-}" == "--help" ]] && echo "tool - description" && exit 0

input="$(cat)"
echo '{"ok":true,"result":"processed"}'
```

### Standard Tool Structure
1. **Shebang and options**: `#!/usr/bin/env bash` + `set -euo pipefail`
2. **Header comment**: Tool name and description
3. **Functions**: usage(), schema(), version(), need()
4. **Argument parsing**: Process command-line flags
5. **Dependency checks**: Verify required commands exist
6. **Main logic**: Read input, process, output
7. **Error handling**: Proper JSON errors and exit codes

## Testing Tools

### Quick Testing
```bash
# Run test suite
bash tests/run_all.sh

# Test specific tool
bash tests/test_hello.sh

# Use Makefile
make test
make test-coverage
```

### Manual Testing
```bash
# Test basic functionality
echo '{"test":"data"}' | tools/namespace/tool | jq

# Test schema
tools/namespace/tool --schema | jq

# Test error handling
echo 'invalid json' | tools/namespace/tool
echo '{}' | tools/namespace/tool  # Missing required field

# Test with trace
echo '{"test":"data"}' | tools/namespace/tool --trace
```

### Writing Tests

Create `tests/test_namespace.sh`:

```bash
#!/usr/bin/env bash
# Test suite for namespace.tool

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "Testing namespace.tool..."

# Test 1: Basic functionality
echo -n "  Test 1: Basic test... "
result=$(echo '{"field1":"test"}' | ./tools/namespace/tool)
if echo "$result" | jq -e '.ok == true' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Output: $result"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 2: Schema validation
echo -n "  Test 2: Schema flag... "
result=$(./tools/namespace/tool --schema)
if echo "$result" | jq -e '.type == "object"' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Summary
echo ""
echo "Results: $TESTS_PASSED passed, $TESTS_FAILED failed"

if [[ $TESTS_FAILED -gt 0 ]]; then
    exit 1
fi
```

Run tests:
```bash
# Run test
bash tests/test_namespace.sh

# Or use Makefile
make test
```

See [Testing Guide](testing.md) for comprehensive testing documentation.

### Integration Testing
```bash
#!/bin/bash
# Integration test script

echo "Testing tool installation and usage..."

# Install
./install.sh namespace.tool

# Test installed tool
if echo '{"field1":"test"}' | namespace.tool | jq -e '.ok == true' >/dev/null; then
    echo "✓ Tool works after installation"
else
    echo "✗ Tool failed after installation"
    exit 1
fi
```

## Cross-Platform Compatibility

All tools must work on Linux, macOS, and Windows (Git Bash). Follow these guidelines:

### Bash 3.2 Compatibility (macOS)
- **Don't use** associative arrays (`declare -A`)
- **Don't use** `mapfile` or `readarray`
- **Avoid** regex matching with `=~` (use `case` statements)
- **Always** include `exit 0` at end of scripts

### Windows Compatibility
- Line endings are enforced via `.gitattributes`
- Use simple file operations over complex `find` commands
- Test with Git Bash on Windows
- Use `/tmp` for temporary files

### Example - Portable Code
```bash
# Bad (Bash 4+ only)
declare -A config
[[ "$file" =~ ^\..*$ ]] && echo "hidden"

# Good (Works everywhere)
case "$file" in
    .*) echo "hidden" ;;
esac
```

## Best Practices

### 1. Error Handling
```bash
# Always validate JSON input
if ! echo "$input" | jq -e . >/dev/null 2>&1; then
    jq -n '{ok:false, error:"invalid_json"}'
    exit 2
fi

# Check required fields
if [[ -z "${required_field:-}" ]]; then
    jq -n '{ok:false, error:"missing_field", field:"required_field"}'
    exit 2
fi

# Handle command failures
if ! result=$(some_command 2>&1); then
    jq -n --arg err "$result" '{ok:false, error:$err}'
    exit 1
fi
```

### 2. Input Parsing
```bash
# Use jq with defaults
field="$(echo "$input" | jq -r '.field // "default"')"

# Parse arrays
array="$(echo "$input" | jq -c '.items // []')"

# Parse booleans
flag="$(echo "$input" | jq -r '.flag // false')"
```

### 3. Output Generation
```bash
# Use jq for clean JSON
jq -n \
    --arg str "$string_var" \
    --argjson num "$number_var" \
    --argjson bool "$boolean_var" \
    --argjson arr "$array_json" \
    '{
        string: $str,
        number: $num,
        boolean: $bool,
        array: $arr
    }'
```

### 4. Debugging
```bash
# Use TRACE flag
[[ $TRACE -eq 1 ]] && echo "DEBUG: Variable = $var" >&2

# Conditional verbose output
[[ $VERBOSE -eq 1 ]] && echo "Processing: $item" >&2
```

### 5. Performance
```bash
# Cache repeated jq calls
name="$(echo "$input" | jq -r '.name')"
age="$(echo "$input" | jq -r '.age')"

# Better: Single jq call
eval "$(echo "$input" | jq -r '@sh "name=\(.name) age=\(.age)"')"
```

## Common Patterns

### HTTP Requests
```bash
# GET request with error handling
url="$(echo "$input" | jq -r '.url')"
timeout="$(echo "$input" | jq -r '.timeout // 10')"

response=$(curl -sS -L --max-time "$timeout" -w '\n%{http_code}' "$url") || {
    jq -n '{ok:false, error:"http_request_failed"}'
    exit 22
}

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" != "200" ]]; then
    jq -n --arg code "$http_code" '{ok:false, error:"http_error", status_code:($code|tonumber)}'
    exit 22
fi
```

### File Operations
```bash
# Read file safely
filepath="$(echo "$input" | jq -r '.path')"

# Validate path
if [[ "$filepath" =~ \.\. ]] || [[ "$filepath" =~ ^/ ]]; then
    jq -n '{ok:false, error:"invalid_path"}'
    exit 2
fi

if [[ ! -f "$filepath" ]]; then
    jq -n '{ok:false, error:"file_not_found"}'
    exit 2
fi

content="$(cat "$filepath")" || {
    jq -n '{ok:false, error:"read_failed"}'
    exit 1
}
```

### Array Processing
```bash
# Process array input
items="$(echo "$input" | jq -c '.items // []')"
results="[]"

while IFS= read -r item; do
    # Process each item
    result="$(echo "$item" | some_processing)"
    results="$(echo "$results" | jq --arg r "$result" '. + [$r]')"
done < <(echo "$items" | jq -c '.[]')

jq -n --argjson results "$results" '{ok:true, results:$results}'
```

### Pagination
```bash
# Handle paginated input
page="$(echo "$input" | jq -r '.page // 1')"
limit="$(echo "$input" | jq -r '.limit // 10')"
offset=$(( (page - 1) * limit ))

# Use in processing
results="$(fetch_data "$offset" "$limit")"

jq -n \
    --argjson results "$results" \
    --argjson page "$page" \
    --argjson limit "$limit" \
    '{
        ok: true,
        results: $results,
        pagination: {
            page: $page,
            limit: $limit,
            offset: ('$offset')
        }
    }'
```

## Publishing Tools

### Pre-Publication Checklist
- [ ] Tool follows JSON contract
- [ ] Has `--help` and `--schema` flags
- [ ] Handles errors gracefully
- [ ] Returns proper exit codes
- [ ] Documentation written
- [ ] Tests written and passing
- [ ] Dependencies documented
- [ ] Examples provided
- [ ] Validated with `make validate`
- [ ] Tests pass with `make test`

### Steps to Publish

1. **Add tool to repository**
```bash
# Add to correct namespace
cp mytool tools/namespace/tool
chmod +x tools/namespace/tool
```

2. **Add documentation**
```bash
# Create documentation
cat > docs/tools/namespace-tool.md << 'EOF'
# namespace.tool
[Documentation content]
EOF
```

3. **Add tests**
```bash
# Create test file
cat > tests/namespace/test_tool.bats << 'EOF'
#!/usr/bin/env bats
[Test content]
EOF
```

4. **Test locally**
```bash
# Run tests
bash tests/test_namespace.sh

# Test installation
./install.sh namespace.tool
echo '{"test":"data"}' | namespace.tool | jq

# Use Makefile
make test
make install
```

5. **Submit PR**
```bash
git add tools/namespace/tool docs/tools/namespace-tool.md tests/namespace/
git commit -m "Add namespace.tool for [purpose]"
git push origin feature/namespace-tool
```

### Code Review Criteria
- Follows tool contract
- Clean, readable code
- Proper error handling
- Good documentation
- Has tests
- No security issues
- Dependencies justified

## Advanced Topics

### Caching
```bash
# Simple file-based cache
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ai-tools"
mkdir -p "$CACHE_DIR"

cache_key="$(echo "$input" | sha256sum | cut -d' ' -f1)"
cache_file="$CACHE_DIR/$cache_key.json"

if [[ -f "$cache_file" ]] && [[ $(find "$cache_file" -mmin -60) ]]; then
    # Use cache (less than 60 minutes old)
    cat "$cache_file"
else
    # Generate and cache result
    result="$(generate_result)"
    echo "$result" | tee "$cache_file"
fi
```

### Configuration
```bash
# Support configuration via environment
API_KEY="${API_KEY:-}"
API_URL="${API_URL:-https://api.example.com}"
TIMEOUT="${TIMEOUT:-30}"

# Or via config file
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/ai-tools/config.json"
if [[ -f "$CONFIG_FILE" ]]; then
    API_KEY="$(jq -r '.api_key // empty' < "$CONFIG_FILE")"
fi
```

### Parallel Processing
```bash
# Process items in parallel
items="$(echo "$input" | jq -c '.items[]')"
temp_dir="$(mktemp -d)"

# Start parallel jobs
job_count=0
max_jobs=4

while IFS= read -r item; do
    (
        echo "$item" | process_item > "$temp_dir/$job_count.json"
    ) &
    
    ((job_count++))
    if [[ $((job_count % max_jobs)) -eq 0 ]]; then
        wait
    fi
done <<< "$items"

wait

# Collect results
results="[]"
for file in "$temp_dir"/*.json; do
    result="$(cat "$file")"
    results="$(echo "$results" | jq --argjson r "$result" '. + [$r]')"
done

rm -rf "$temp_dir"
```

## Getting Help

- Review existing tools for examples
- Check [API Contract](api-contract.md) for specifications
- See [Testing Guide](testing.md) for testing documentation
- Use `make help` to see available commands
- Open a [discussion](https://github.com/chrishayuk/chuk-ai-bash-tools/discussions) for questions
- Submit [issues](https://github.com/chrishayuk/chuk-ai-bash-tools/issues) for bugs