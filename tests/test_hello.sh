#!/usr/bin/env bash
# Test suite for hello.world tool

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "Testing hello.world tool..."

# Test 1: Basic greeting
echo -n "  Test 1: Basic greeting... "
result=$(echo '{"name":"Test"}' | ./tools/hello/world)
if echo "$result" | jq -e '.ok == true and .message == "Hello, Test."' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Output: $result"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 2: Custom greeting with excitement
echo -n "  Test 2: Custom greeting... "
result=$(echo '{"name":"AI","greeting":"Hey","excited":true}' | ./tools/hello/world)
if echo "$result" | jq -e '.ok == true and .message == "Hey, AI!"' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Output: $result"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 3: Repeat parameter
echo -n "  Test 3: Repeat parameter... "
result=$(echo '{"name":"Bot","repeat":3}' | ./tools/hello/world)
if echo "$result" | jq -e '.ok == true and .count == 3 and (.messages | length) == 3' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Output: $result"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 4: Default values
echo -n "  Test 4: Default values... "
result=$(echo '{}' | ./tools/hello/world)
if echo "$result" | jq -e '.ok == true and .greeted == "World"' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Output: $result"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 5: Invalid repeat value
echo -n "  Test 5: Invalid repeat... "
result=$(echo '{"repeat":15}' | ./tools/hello/world)
if echo "$result" | jq -e '.ok == false' > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Output: $result"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 6: Schema flag
echo -n "  Test 6: Schema flag... "
result=$(./tools/hello/world --schema)
if echo "$result" | jq -e '.type == "object" and .properties.name.type == "string"' > /dev/null 2>&1; then
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