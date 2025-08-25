#!/usr/bin/env bash
# Test suite for wiki.search tool

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "Testing wiki.search tool..."

# Test 1: Basic search
echo -n "  Test 1: Basic search... "
result=$(echo '{"q":"Linux"}' | ./tools/wiki/search)
if echo "$result" | jq -e '.ok == true and .count > 0' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Output: $result"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 2: Search with limit
echo -n "  Test 2: Search with limit... "
result=$(echo '{"q":"Python","limit":2}' | ./tools/wiki/search)
if echo "$result" | jq -e '.ok == true and (.results | length) <= 2' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Output: $result"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 3: Search with language
echo -n "  Test 3: Language search... "
result=$(echo '{"q":"Paris","lang":"fr","limit":1}' | ./tools/wiki/search)
if echo "$result" | jq -e '.ok == true' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Output: $result"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 4: Missing query
echo -n "  Test 4: Missing query... "
result=$(echo '{}' | ./tools/wiki/search)
if echo "$result" | jq -e '.ok == false' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Output: $result"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 5: Schema flag
echo -n "  Test 5: Schema flag... "
result=$(./tools/wiki/search --schema)
if echo "$result" | jq -e '.type == "object" and .properties.q.type == "string"' > /dev/null 2>&1; then
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