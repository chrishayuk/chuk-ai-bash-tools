# Testing Guide

Comprehensive guide for testing chuk-ai-bash-tools.

## Table of Contents
- [Quick Start](#quick-start)
- [Test Structure](#test-structure)
- [Running Tests](#running-tests)
- [Writing Tests](#writing-tests)
- [CI/CD Integration](#cicd-integration)
- [Test Coverage](#test-coverage)
- [Debugging Tests](#debugging-tests)
- [Best Practices](#best-practices)

## Quick Start

### Using Make (Recommended)
```bash
# Run all tests
make test

# Run specific test suites
make test-hello
make test-wiki
make test-installer

# Check test coverage
make test-coverage

# Validate API contract compliance
make test-contract
```

### Direct Execution
```bash
# Run all tests
bash tests/run_all.sh

# Run specific test suite
bash tests/test_hello.sh
bash tests/test_installer.sh
bash tests/test_wiki.sh

# Test a specific tool directly
echo '{"name":"Test"}' | tools/hello/world | jq
```

## Test Structure

### Directory Organization
```
tests/
├── run_all.sh           # Main test runner
├── test_hello.sh        # Tests for hello.world tool
├── test_installer.sh    # Tests for installation script
└── test_wiki.sh         # Tests for wiki.search tool
```

### Test Suite Components
Each test file follows this structure:
1. **Setup**: Define colors and counters
2. **Test Cases**: Individual test functions
3. **Assertions**: Validate JSON output
4. **Summary**: Report results

## Running Tests

### Running All Tests
```bash
# Using Make (recommended)
make test

# Direct execution
bash tests/run_all.sh

# With coverage report
make test-coverage
```

### Running Individual Test Suites
```bash
# Using Make
make test-hello        # Test hello.world tool
make test-installer    # Test installer
make test-wiki        # Test wiki tools

# Direct execution
bash tests/test_hello.sh
bash tests/test_installer.sh
bash tests/test_wiki.sh
```

### Test Output
```
================================
chuk-ai-bash-tools Test Suite
================================

Checking dependencies...
  bash: ✓
  jq: ✓
  curl: ✓

Running test_hello.sh...
Testing hello.world tool...
  Test 1: Basic greeting... ✓
  Test 2: Custom greeting... ✓
  Test 3: Repeat parameter... ✓
  Test 4: Default values... ✓
  Test 5: Invalid repeat... ✓
  Test 6: Schema flag... ✓

Results: 6 passed, 0 failed
```

## Writing Tests

### Test File Template
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
result=$(echo '{"input":"test"}' | ./tools/namespace/tool)
if echo "$result" | jq -e '.ok == true' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Output: $result"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Summary
echo ""
echo "Results: $TESTS_PASSED passed, $TESTS_FAILED failed"

if [[ $TESTS_FAILED -gt 0 ]]; then
    exit 1
fi
```

### Testing JSON Output
```bash
# Test for successful response
if echo "$result" | jq -e '.ok == true' > /dev/null 2>&1; then
    # Test passed
fi

# Test specific field values
if echo "$result" | jq -e '.message == "Hello, Test."' > /dev/null 2>&1; then
    # Test passed
fi

# Test array length
if echo "$result" | jq -e '(.results | length) == 3' > /dev/null 2>&1; then
    # Test passed
fi

# Test nested fields
if echo "$result" | jq -e '.metadata.count > 0' > /dev/null 2>&1; then
    # Test passed
fi
```

### Testing Error Conditions
```bash
# Test missing required field
echo -n "  Test: Missing field... "
result=$(echo '{}' | ./tools/namespace/tool)
if echo "$result" | jq -e '.ok == false and .error == "missing_field"' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

# Test invalid JSON
echo -n "  Test: Invalid JSON... "
result=$(echo 'not json' | ./tools/namespace/tool 2>/dev/null || echo '{"ok":false}')
if echo "$result" | jq -e '.ok == false' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi
```

### Testing Command Flags
```bash
# Test --help flag
echo -n "  Test: Help flag... "
if ./tools/namespace/tool --help | grep -q "namespace.tool"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

# Test --schema flag
echo -n "  Test: Schema flag... "
if ./tools/namespace/tool --schema | jq -e '.type == "object"' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi
```

## CI/CD Integration

### GitHub Actions
The repository includes automated testing via GitHub Actions:

```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    steps:
    - uses: actions/checkout@v4
    - name: Run tests
      run: bash tests/run_ci.sh
      shell: bash
```

### Test Matrix
Tests run on:
- **Operating Systems**: Ubuntu, macOS, Windows (Git Bash)
- **Bash Versions**: 3.2+ (macOS default), 4.0+ (Linux), Git Bash (Windows)
- **Dependencies**: Various versions of jq and curl
- **Line Endings**: Enforced via `.gitattributes` for cross-platform compatibility

### ShellCheck Linting
```yaml
- name: Run ShellCheck
  uses: ludeeus/action-shellcheck@master
  with:
    severity: warning
```

## Test Coverage

### What Gets Tested

#### Tool Functionality
- ✅ Basic input/output processing
- ✅ Required field validation
- ✅ Optional field defaults
- ✅ Error handling
- ✅ Edge cases
- ✅ Command line flags (--help, --schema)

#### Installer
- ✅ List available tools
- ✅ Dry run mode
- ✅ Invalid tool handling
- ✅ Bash 3.2 compatibility
- ✅ Agent mode JSON output

#### Contract Compliance
- ✅ JSON input validation
- ✅ JSON output format
- ✅ Exit codes
- ✅ Error response format
- ✅ Schema validity

### Coverage Report
```bash
# Generate simple coverage report
for tool in tools/*/*; do
    echo "Testing $tool..."
    if $tool --help > /dev/null 2>&1; then
        echo "  ✓ Has --help"
    fi
    if $tool --schema | jq -e . > /dev/null 2>&1; then
        echo "  ✓ Has valid --schema"
    fi
done
```

## Debugging Tests

### Verbose Output
```bash
# Run with bash tracing
bash -x tests/test_hello.sh

# Add debug output to tests
echo "DEBUG: Result = $result" >&2

# Use tool's trace mode
echo '{"input":"test"}' | ./tools/namespace/tool --trace
```

### Common Issues

#### Test Hangs
```bash
# Issue: jq waiting for input
# Solution: Ensure proper output redirection
if echo "$result" | jq -e '.ok == true' > /dev/null 2>&1; then
```

#### False Negatives
```bash
# Issue: Exit code interfering with test
# Solution: Remove 'set -e' from test scripts
#!/usr/bin/env bash
# NOT: set -e
```

#### JSON Parsing Errors
```bash
# Debug JSON issues
echo "$result" | jq '.' || echo "Invalid JSON: $result"

# Pretty print for debugging
echo "$result" | jq '.' 2>&1
```

## Best Practices

### 1. Test Organization
- One test file per tool/component
- Group related tests together
- Use descriptive test names
- Number tests for easy reference

### 2. Test Independence
- Each test should be independent
- Don't rely on test order
- Clean up any temporary files
- Reset state between tests

### 3. Clear Output
```bash
# Good: Clear pass/fail indication
echo -n "  Test 1: Basic test... "
if [[ condition ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "    Expected: X, Got: Y"
fi
```

### 4. Comprehensive Coverage
Test all:
- Happy paths
- Error conditions
- Edge cases
- Command line flags
- Different input variations

### 5. Fast Execution
- Keep tests fast (< 1 second each)
- Use local data when possible
- Mock network calls if needed
- Run tests in parallel when safe

### 6. Maintainable Tests
```bash
# Use functions for repeated assertions
assert_ok() {
    local result="$1"
    echo "$result" | jq -e '.ok == true' > /dev/null 2>&1
}

# Use clear variable names
expected_message="Hello, World."
actual_message=$(echo "$result" | jq -r '.message')
```

### 7. Exit Codes
```bash
# Always exit with proper code
if [[ $TESTS_FAILED -gt 0 ]]; then
    exit 1  # Failure
else
    exit 0  # Success
fi
```

## Makefile Integration

The project includes comprehensive Make targets for testing:

### Test Targets
```bash
make test              # Run all test suites
make test-hello        # Test hello.world tool
make test-wiki         # Test wiki.search tool
make test-installer    # Test installer script
make test-coverage     # Generate coverage report
make test-contract     # Validate API contract compliance
```

### Development Targets
```bash
make check            # Check dependencies
make validate         # Validate all tools
make lint             # Run shellcheck
make clean            # Clean test artifacts
```

### Workflow Example
```bash
# Before committing
make validate         # Ensure tools are valid
make test            # Run all tests
make lint            # Check for issues

# Check everything
make check && make test && make validate
```

## Adding New Tests

### Step 1: Create Test File
```bash
# Create new test file
cat > tests/test_newtool.sh << 'EOF'
#!/usr/bin/env bash
# Test suite for new.tool
# ... test content ...
EOF

chmod +x tests/test_newtool.sh
```

### Step 2: Add to Test Runner
The `run_all.sh` automatically finds all `test_*.sh` files.

### Step 3: Document Tests
Add test documentation to tool's documentation:
```markdown
## Testing
Run tests with:
\```bash
bash tests/test_newtool.sh
\```
```

### Step 4: Add to CI
Tests are automatically included in CI if they follow the naming convention.

## Performance Testing

### Basic Timing
```bash
# Time tool execution
time echo '{"input":"test"}' | ./tools/namespace/tool

# Multiple iterations
for i in {1..100}; do
    echo '{"input":"test"}' | ./tools/namespace/tool > /dev/null
done
```

### Load Testing
```bash
# Parallel execution
for i in {1..10}; do
    echo '{"input":"test$i"}' | ./tools/namespace/tool &
done
wait
```

## References

- [API Contract](api-contract.md) - Tool contract specification
- [Development Guide](development.md) - Creating new tools
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Bash Testing Best Practices](https://github.com/bats-core/bats-core)