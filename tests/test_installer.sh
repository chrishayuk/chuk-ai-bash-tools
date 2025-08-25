#!/usr/bin/env bash
# Test suite for installer

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "Testing installer..."

# Test 1: List tools in agent mode
echo -n "  Test 1: List tools... "
result=$(AGENT_MODE=1 bash ./install.sh --list)
if echo "$result" | jq -e '.status == "success" and (.tools | length) > 0' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Output: $result"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 2: Dry run
echo -n "  Test 2: Dry run... "
result=$(AGENT_MODE=1 bash ./install.sh --dry-run hello.world)
if echo "$result" | jq -e '.status == "dry_run"' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Output: $result"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 3: Invalid tool
echo -n "  Test 3: Invalid tool... "
result=$(AGENT_MODE=1 bash ./install.sh invalid.tool)
if echo "$result" | jq -e '.status == "error" and .message == "invalid_tools"' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Output: $result"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 4: Check Bash 3.2 compatibility (no associative arrays)
echo -n "  Test 4: Bash 3.2 compat... "
if ! grep -q "declare -A" install.sh; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Found associative array usage"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Summary
echo ""
echo "Results: $TESTS_PASSED passed, $TESTS_FAILED failed"

if [[ $TESTS_FAILED -gt 0 ]]; then
    exit 1
fi