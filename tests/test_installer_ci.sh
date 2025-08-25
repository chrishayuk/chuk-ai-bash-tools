#!/usr/bin/env bash
# Test suite for installer (CI version - skips network tests)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "Testing installer (CI mode)..."

# Test 1: Bash 3.2 compatibility (no associative arrays)
echo -n "  Test 1: Bash 3.2 compat... "
# Check for actual associative array declarations (not in comments or strings)
if ! grep -E '^[[:space:]]*declare[[:space:]]+-A' install.sh > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Found associative array usage"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 2: Script syntax check
echo -n "  Test 2: Script syntax... "
if bash -n install.sh 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Syntax errors found"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 3: Required functions exist
echo -n "  Test 3: Required functions... "
if grep -q "^need()" install.sh && \
   grep -q "^info()" install.sh && \
   grep -q "^error()" install.sh; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    echo "    Missing required functions"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test 4: Help flag
echo -n "  Test 4: Help flag... "
if bash ./install.sh --help > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Note: Skipping network-dependent tests in CI
echo ""
echo "Note: Skipping network-dependent tests in CI environment"

# Summary
echo ""
echo "Results: $TESTS_PASSED passed, $TESTS_FAILED failed"

if [[ $TESTS_FAILED -gt 0 ]]; then
    exit 1
fi