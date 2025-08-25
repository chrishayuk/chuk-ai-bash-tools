# API Contract Specification

The formal specification for the JSON stdin/stdout contract that all tools must follow.

## Table of Contents
- [Overview](#overview)
- [Core Principles](#core-principles)
- [Input Specification](#input-specification)
- [Output Specification](#output-specification)
- [Command Line Interface](#command-line-interface)
- [Exit Codes](#exit-codes)
- [Error Handling](#error-handling)
- [Schema Discovery](#schema-discovery)
- [Examples](#examples)
- [Validation](#validation)

## Overview

All tools in chuk-ai-bash-tools follow a strict contract:

```
JSON → [TOOL] → JSON
```

This enables:
- **Composability**: Tools can be chained together
- **Predictability**: Consistent behavior across all tools
- **Discoverability**: Self-documenting via schemas
- **Automation**: AI agents can use tools reliably

## Core Principles

### 1. Stateless Operation
Tools must be pure functions with no side effects unless explicitly requested.

```bash
# Good: No side effects by default
echo '{"path":"file.txt"}' | fs.read  # Only reads

# Good: Explicit side effect flag
echo '{"path":"file.txt","content":"data"}' | fs.write --apply
```

### 2. JSON Only
All input and output must be valid JSON.

```bash
# Good: JSON in, JSON out
echo '{"name":"World"}' | hello.world
# Output: {"ok":true,"message":"Hello, World!"}

# Bad: Plain text output
echo '{"name":"World"}' | bad.tool
# Output: Hello, World!  ← WRONG
```

### 3. Self-Documenting
Tools must provide their schema and help.

```bash
tool --schema  # Returns JSON schema
tool --help    # Returns usage information
```

## Input Specification

### Format
- Must be valid JSON
- Sent via stdin
- Single JSON object (not array)
- UTF-8 encoded

### Structure
```json
{
  "required_field": "value",
  "optional_field": "value",
  "nested": {
    "field": "value"
  },
  "array": ["item1", "item2"]
}
```

### Validation
Tools must validate input and provide clear errors:

```bash
# Missing required field
echo '{}' | tool
# Output: {"ok":false,"error":"missing_required_field","field":"required_field"}

# Invalid JSON
echo 'not json' | tool
# Output: {"ok":false,"error":"invalid_json"}

# Invalid field type
echo '{"number":"not_a_number"}' | tool
# Output: {"ok":false,"error":"invalid_type","field":"number","expected":"integer"}
```

## Output Specification

### Success Response
Every successful response must include `"ok": true`:

```json
{
  "ok": true,
  "result": "primary result",
  "metadata": {
    "additional": "information"
  }
}
```

### Error Response
Every error response must include `"ok": false`:

```json
{
  "ok": false,
  "error": "error_code",
  "message": "Human-readable description",
  "details": {
    "additional": "context"
  }
}
```

### Standard Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ok` | boolean | Yes | Success indicator |
| `error` | string | If ok=false | Error code (snake_case) |
| `message` | string | No | Human-readable message |
| `result` | any | If ok=true | Primary result data |
| `metadata` | object | No | Additional information |
| `timestamp` | string | No | ISO 8601 timestamp |

## Command Line Interface

### Required Flags

| Flag | Description | Output |
|------|-------------|--------|
| `--help` | Show usage information | Text to stdout |
| `--schema` | Output JSON schema | JSON to stdout |

### Optional Flags

| Flag | Description | Behavior |
|------|-------------|----------|
| `--version` | Show version | Text to stdout |
| `--trace` | Debug mode | Debug info to stderr |
| `--verbose` | Verbose output | Extra info to stderr |
| `--dry-run` | Preview without executing | Normal JSON output |
| `--apply` | Execute side effects | Performs actual changes |

### Flag Processing
```bash
# Flags must be processed before reading stdin
tool --schema  # Returns immediately
tool --help    # Returns immediately

# Flags can be combined with stdin
echo '{"data":"value"}' | tool --trace  # Processes input with tracing
```

## Exit Codes

Tools must use standard exit codes:

| Code | Meaning | When to Use |
|------|---------|-------------|
| `0` | Success | Operation completed successfully |
| `1` | General error | Unspecified error |
| `2` | Usage error | Invalid arguments or input |
| `22` | Network error | HTTP/network failure |
| `127` | Dependency missing | Required command not found |

### Examples
```bash
# Success
echo '{"valid":"input"}' | tool
echo $?  # 0

# Invalid input
echo 'invalid' | tool
echo $?  # 2

# Missing dependency
tool --help  # If jq is missing
echo $?  # 127
```

## Error Handling

### Error Response Format
```json
{
  "ok": false,
  "error": "error_code",
  "message": "Description for humans",
  "details": {}
}
```

### Standard Error Codes

| Code | Description | Example |
|------|-------------|---------|
| `invalid_json` | Input is not valid JSON | Malformed JSON |
| `missing_field` | Required field missing | No 'query' field |
| `invalid_type` | Field has wrong type | String instead of number |
| `invalid_value` | Value outside constraints | Negative when positive required |
| `not_found` | Resource doesn't exist | File/URL not found |
| `permission_denied` | Insufficient permissions | Can't read file |
| `timeout` | Operation timed out | Network timeout |
| `rate_limited` | API rate limit hit | Too many requests |
| `dependency_missing` | Required tool missing | jq not installed |
| `internal_error` | Unexpected error | Bug in tool |

### Error Examples
```bash
# Missing required field
echo '{}' | wiki.search
{
  "ok": false,
  "error": "missing_field",
  "message": "Required field 'q' or 'query' is missing",
  "field": "query"
}

# Network error
echo '{"url":"http://invalid"}' | web.fetch
{
  "ok": false,
  "error": "network_error",
  "message": "Failed to fetch URL",
  "status_code": 0,
  "details": "Could not resolve host"
}
```

## Schema Discovery

### Schema Format
Tools must output valid JSON Schema (draft-07 or later):

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "field1": {
      "type": "string",
      "description": "Description of field1"
    },
    "field2": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100,
      "default": 10
    }
  },
  "required": ["field1"],
  "additionalProperties": false
}
```

### Schema Fields

| Field | Purpose | Example |
|-------|---------|---------|
| `type` | Data type | "string", "integer", "object" |
| `description` | Field documentation | "Search query" |
| `default` | Default value | "en" for language |
| `required` | Required fields array | ["query"] |
| `minimum`/`maximum` | Numeric constraints | 1/100 |
| `minLength`/`maxLength` | String constraints | 1/1000 |
| `enum` | Allowed values | ["en", "fr", "de"] |
| `pattern` | Regex pattern | "^[a-z]+$" |

### Discovery Example
```bash
# Get schema
wiki.search --schema | jq

# Use schema to build valid input
wiki.search --schema | jq '.properties | keys'
# ["lang", "limit", "q", "query", "timeout"]

# Check required fields
wiki.search --schema | jq '.required'
# ["q"] or ["query"]
```

## Examples

### Minimal Tool Implementation
```bash
#!/usr/bin/env bash
set -euo pipefail

# Handle flags
case "${1:-}" in
  --schema)
    echo '{"type":"object","properties":{"input":{"type":"string"}}}'
    exit 0
    ;;
  --help)
    echo "tool - Tool description"
    exit 0
    ;;
esac

# Process input
input="$(cat)"
result="processed"

# Output result
echo "{\"ok\":true,\"result\":\"$result\"}"
```

### Complete Tool Implementation
```bash
#!/usr/bin/env bash
set -euo pipefail

# Schema function
schema() {
  cat <<'JSON'
{
  "type": "object",
  "properties": {
    "text": {
      "type": "string",
      "description": "Text to process"
    },
    "uppercase": {
      "type": "boolean",
      "description": "Convert to uppercase",
      "default": false
    }
  },
  "required": ["text"]
}
JSON
}

# Handle flags
case "${1:-}" in
  --schema) schema; exit 0;;
  --help) echo "text.process - Process text"; exit 0;;
esac

# Read and validate input
input="$(cat)"
if ! echo "$input" | jq -e . >/dev/null 2>&1; then
  echo '{"ok":false,"error":"invalid_json"}'
  exit 2
fi

# Parse fields
text="$(echo "$input" | jq -r '.text // empty')"
uppercase="$(echo "$input" | jq -r '.uppercase // false')"

# Validate required fields
if [[ -z "$text" ]]; then
  echo '{"ok":false,"error":"missing_field","field":"text"}'
  exit 2
fi

# Process
if [[ "$uppercase" == "true" ]]; then
  result="$(echo "$text" | tr '[:lower:]' '[:upper:]')"
else
  result="$text"
fi

# Output
jq -n --arg result "$result" '{ok:true, result:$result}'
```

### Using Tools in Pipelines
```bash
# Chain tools together
echo '{"q":"bash"}' | wiki.search | \
  jq '{url: .results[0].url}' | \
  web.fetch | \
  jq '{content: .body}'

# Parallel processing
for term in python ruby go; do
  echo "{\"q\":\"$term\"}" | wiki.search &
done | jq -s 'map(.results[0].title)'
```

### AI Agent Integration
```python
import subprocess
import json

def call_tool(tool_name, input_data):
    """Call a tool with JSON input and return JSON output."""
    
    # Get schema first
    schema_result = subprocess.run(
        [tool_name, "--schema"],
        capture_output=True,
        text=True
    )
    schema = json.loads(schema_result.stdout)
    
    # Validate input against schema
    # (validation code here)
    
    # Call tool
    result = subprocess.run(
        [tool_name],
        input=json.dumps(input_data),
        capture_output=True,
        text=True
    )
    
    # Parse output
    output = json.loads(result.stdout)
    
    # Check for errors
    if not output.get("ok"):
        raise Exception(f"Tool error: {output.get('error')}")
    
    return output

# Example usage
result = call_tool("wiki.search", {"q": "artificial intelligence"})
print(f"Found {result['count']} results")
```

## Validation

### Input Validation Checklist
- [ ] Valid JSON syntax
- [ ] Required fields present
- [ ] Field types correct
- [ ] Values within constraints
- [ ] No unknown fields (if additionalProperties: false)

### Output Validation Checklist
- [ ] Valid JSON syntax
- [ ] Contains "ok" field
- [ ] If ok=true, has result
- [ ] If ok=false, has error
- [ ] Timestamps in ISO 8601 format
- [ ] Arrays properly formatted

### Testing Contract Compliance
```bash
#!/bin/bash
# Test tool contract compliance

TOOL="$1"

echo "Testing $TOOL contract compliance..."

# Test: Has help
if $TOOL --help >/dev/null 2>&1; then
  echo "✓ Has --help"
else
  echo "✗ Missing --help"
fi

# Test: Has schema
if $TOOL --schema | jq -e . >/dev/null 2>&1; then
  echo "✓ Has valid --schema"
else
  echo "✗ Invalid or missing --schema"
fi

# Test: Handles invalid JSON
if echo "invalid" | $TOOL 2>/dev/null | jq -e '.ok == false' >/dev/null; then
  echo "✓ Handles invalid JSON"
else
  echo "✗ Doesn't handle invalid JSON properly"
fi

# Test: Returns JSON
if echo '{}' | $TOOL 2>/dev/null | jq -e . >/dev/null; then
  echo "✓ Returns valid JSON"
else
  echo "✗ Doesn't return valid JSON"
fi

# Test: Uses correct exit codes
echo '{}' | $TOOL >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo "✓ Uses non-zero exit code for errors"
else
  echo "✗ Should use non-zero exit code for errors"
fi
```

## Best Practices

### Do's
- ✅ Always validate input JSON
- ✅ Return consistent error formats
- ✅ Use meaningful error codes
- ✅ Document all fields in schema
- ✅ Keep schemas simple and flat when possible
- ✅ Use semantic field names
- ✅ Include examples in help text
- ✅ Write to stderr for debugging

### Don'ts
- ❌ Don't write non-JSON to stdout
- ❌ Don't use exit code 0 for errors
- ❌ Don't have side effects without --apply
- ❌ Don't require configuration files
- ❌ Don't store state between invocations
- ❌ Don't output HTML or XML
- ❌ Don't require interactive input
- ❌ Don't modify input files

## Versioning

### Semantic Versioning
Tools should follow semantic versioning:
- **Major**: Breaking changes to contract
- **Minor**: New optional fields/features
- **Patch**: Bug fixes

### Version in Output
```json
{
  "ok": true,
  "result": "data",
  "version": "1.2.3"
}
```

### Backward Compatibility
- New optional fields: OK
- Changing field types: Breaking change
- Removing fields: Breaking change
- Changing error codes: Breaking change

## Extensions

### Streaming Output
For tools that process large data:
```json
{"ok":true,"stream":true,"chunk":1,"data":"..."}
{"ok":true,"stream":true,"chunk":2,"data":"..."}
{"ok":true,"stream":true,"chunk":3,"data":"...","final":true}
```

### Progress Reporting
For long-running operations (to stderr):
```
PROGRESS: 10%
PROGRESS: 50%
PROGRESS: 100%
```

### Batch Processing
```json
{
  "batch": true,
  "items": [
    {"input": "item1"},
    {"input": "item2"}
  ]
}
```

Output:
```json
{
  "ok": true,
  "batch": true,
  "results": [
    {"ok": true, "result": "..."},
    {"ok": true, "result": "..."}
  ]
}
```

## Compliance

Tools MUST comply with this contract to be included in chuk-ai-bash-tools. Non-compliant tools will be rejected or require updates.

## References

- [JSON Schema Specification](https://json-schema.org/)
- [JSON RFC 7159](https://tools.ietf.org/html/rfc7159)
- [Exit Codes](https://www.gnu.org/software/bash/manual/html_node/Exit-Status.html)
- [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601)