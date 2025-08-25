#!/usr/bin/env bash
# Run all tests

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}chuk-ai-bash-tools Test Suite${NC}"
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
chmod +x tools/hello/world
chmod +x tools/wiki/search
chmod +x install.sh

# Track overall results
TOTAL_PASSED=0
TOTAL_FAILED=0
FAILED_SUITES=()

# Run test suites
for test_file in tests/test_*.sh; do
    if [[ -f "$test_file" ]]; then
        echo -e "${YELLOW}Running $(basename $test_file)...${NC}"
        chmod +x "$test_file"
        
        if $test_file; then
            TOTAL_PASSED=$((TOTAL_PASSED + 1))
        else
            TOTAL_FAILED=$((TOTAL_FAILED + 1))
            FAILED_SUITES+=("$(basename $test_file)")
        fi
        echo ""
    fi
done

# Summary
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Overall Test Results${NC}"
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