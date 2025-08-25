#!/usr/bin/env bash
# CI test runner - runs tests appropriate for CI environment

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}CI Test Suite${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Check dependencies
echo "Checking dependencies..."
for cmd in bash jq curl; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "  $cmd: ${GREEN}✓${NC}"
    else
        echo -e "  $cmd: ${RED}✗ Missing${NC}"
        exit 1
    fi
done

echo ""
echo "Bash version: $(bash --version | head -1)"
echo ""

# Make tools executable
chmod +x tools/hello/world 2>/dev/null || true
chmod +x tools/wiki/search 2>/dev/null || true
chmod +x install.sh 2>/dev/null || true
chmod +x tests/*.sh 2>/dev/null || true

# Track overall results
TOTAL_PASSED=0
TOTAL_FAILED=0
FAILED_SUITES=()

# Run hello test
echo -e "${YELLOW}Running test_hello.sh...${NC}"
if bash tests/test_hello.sh; then
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
else
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
    FAILED_SUITES+=("test_hello.sh")
fi
echo ""

# Run installer test (CI version)
echo -e "${YELLOW}Running test_installer_ci.sh...${NC}"
if bash tests/test_installer_ci.sh; then
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
else
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
    FAILED_SUITES+=("test_installer_ci.sh")
fi
echo ""

# Run wiki test
echo -e "${YELLOW}Running test_wiki.sh...${NC}"
if bash tests/test_wiki.sh; then
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
else
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
    FAILED_SUITES+=("test_wiki.sh")
fi
echo ""

# Summary
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}CI Test Results${NC}"
echo -e "${BLUE}================================${NC}"
echo "Test suites passed: $TOTAL_PASSED"
echo "Test suites failed: $TOTAL_FAILED"

if [[ ${#FAILED_SUITES[@]} -gt 0 ]]; then
    echo ""
    echo -e "${RED}Failed test suites:${NC}"
    for suite in "${FAILED_SUITES[@]}"; do
        echo "  - $suite"
    done
    echo ""
    echo -e "${RED}TESTS FAILED${NC}"
    exit 1
else
    echo ""
    echo -e "${GREEN}ALL TESTS PASSED!${NC}"
    exit 0
fi