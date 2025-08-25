# Makefile for chuk-ai-bash-tools
# Provides common tasks for development, testing, and installation

# Default shell
SHELL := /bin/bash

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Directories
TOOLS_DIR := tools
TESTS_DIR := tests
DOCS_DIR := docs
INSTALL_DIR := $(HOME)/.local/bin

# Find all tools
TOOLS := $(shell find $(TOOLS_DIR) -type f -name '*' ! -name '.*' 2>/dev/null | sed 's|$(TOOLS_DIR)/||' | tr '/' '.')

# Default target
.PHONY: help
help:
	@echo "$(BLUE)chuk-ai-bash-tools Makefile$(NC)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@echo "  $(GREEN)help$(NC)           - Show this help message"
	@echo ""
	@echo "$(YELLOW)Testing:$(NC)"
	@echo "  $(GREEN)test$(NC)           - Run all tests"
	@echo "  $(GREEN)test-hello$(NC)     - Test hello.world tool"
	@echo "  $(GREEN)test-wiki$(NC)      - Test wiki.search tool"
	@echo "  $(GREEN)test-installer$(NC) - Test installer script"
	@echo "  $(GREEN)test-coverage$(NC)  - Check test coverage"
	@echo "  $(GREEN)test-contract$(NC)  - Test API contract compliance"
	@echo ""
	@echo "$(YELLOW)Installation:$(NC)"
	@echo "  $(GREEN)install$(NC)        - Install all tools"
	@echo "  $(GREEN)install-hello$(NC)  - Install hello.world tool"
	@echo "  $(GREEN)install-wiki$(NC)   - Install wiki tools"
	@echo "  $(GREEN)install-local$(NC)  - Install from local repository"
	@echo "  $(GREEN)uninstall$(NC)      - Remove all installed tools"
	@echo ""
	@echo "$(YELLOW)Development:$(NC)"
	@echo "  $(GREEN)check$(NC)          - Check dependencies"
	@echo "  $(GREEN)lint$(NC)           - Run shellcheck on scripts"
	@echo "  $(GREEN)format$(NC)         - Format shell scripts"
	@echo "  $(GREEN)validate$(NC)       - Validate all tools"
	@echo "  $(GREEN)list$(NC)           - List available tools"
	@echo ""
	@echo "$(YELLOW)Maintenance:$(NC)"
	@echo "  $(GREEN)clean$(NC)          - Clean temporary files"
	@echo "  $(GREEN)update$(NC)         - Update from upstream"
	@echo "  $(GREEN)version$(NC)        - Show version information"

# Testing targets
.PHONY: test
test:
	@echo "$(BLUE)Running all tests...$(NC)"
	@bash $(TESTS_DIR)/run_all.sh

.PHONY: test-hello
test-hello:
	@echo "$(BLUE)Testing hello.world tool...$(NC)"
	@bash $(TESTS_DIR)/test_hello.sh

.PHONY: test-wiki
test-wiki:
	@echo "$(BLUE)Testing wiki.search tool...$(NC)"
	@bash $(TESTS_DIR)/test_wiki.sh

.PHONY: test-installer
test-installer:
	@echo "$(BLUE)Testing installer...$(NC)"
	@bash $(TESTS_DIR)/test_installer.sh

.PHONY: test-coverage
test-coverage:
	@echo "$(BLUE)Checking test coverage...$(NC)"
	@echo ""
	@for tool in $(TOOLS_DIR)/*/*; do \
		if [[ -f "$$tool" ]]; then \
			name=$$(echo "$$tool" | sed 's|$(TOOLS_DIR)/||' | tr '/' '.'); \
			echo -n "$$name: "; \
			if $$tool --help > /dev/null 2>&1; then \
				echo -n "$(GREEN)✓$(NC) "; \
			else \
				echo -n "$(RED)✗$(NC) "; \
			fi; \
			if $$tool --schema | jq -e . > /dev/null 2>&1; then \
				echo -n "$(GREEN)✓$(NC) "; \
			else \
				echo -n "$(RED)✗$(NC) "; \
			fi; \
			echo ""; \
		fi; \
	done

.PHONY: test-contract
test-contract:
	@echo "$(BLUE)Testing API contract compliance...$(NC)"
	@for tool in $(TOOLS_DIR)/*/*; do \
		if [[ -f "$$tool" ]]; then \
			name=$$(basename "$$tool"); \
			echo -n "Testing $$name... "; \
			if $$tool --schema | jq -e '.type' > /dev/null 2>&1 && \
			   echo '{}' | $$tool 2>/dev/null | jq -e '.ok' > /dev/null 2>&1; then \
				echo "$(GREEN)✓$(NC)"; \
			else \
				echo "$(RED)✗$(NC)"; \
			fi; \
		fi; \
	done

# Installation targets
.PHONY: install
install:
	@echo "$(BLUE)Installing all tools...$(NC)"
	@FORCE=1 bash ./install.sh --all

.PHONY: install-hello
install-hello:
	@echo "$(BLUE)Installing hello.world...$(NC)"
	@FORCE=1 bash ./install.sh hello.world

.PHONY: install-wiki
install-wiki:
	@echo "$(BLUE)Installing wiki tools...$(NC)"
	@FORCE=1 bash ./install.sh --group wiki

.PHONY: install-local
install-local:
	@echo "$(BLUE)Installing tools locally...$(NC)"
	@mkdir -p $(INSTALL_DIR)
	@for tool in $(TOOLS_DIR)/*/*; do \
		if [[ -f "$$tool" ]]; then \
			namespace=$$(basename $$(dirname "$$tool")); \
			name=$$(basename "$$tool"); \
			install_name="$$namespace.$$name"; \
			echo "Installing $$install_name..."; \
			cp "$$tool" "$(INSTALL_DIR)/$$install_name"; \
			chmod +x "$(INSTALL_DIR)/$$install_name"; \
		fi; \
	done
	@echo "$(GREEN)Installation complete!$(NC)"

.PHONY: uninstall
uninstall:
	@echo "$(BLUE)Uninstalling tools...$(NC)"
	@for tool in $(TOOLS_DIR)/*/*; do \
		if [[ -f "$$tool" ]]; then \
			namespace=$$(basename $$(dirname "$$tool")); \
			name=$$(basename "$$tool"); \
			install_name="$$namespace.$$name"; \
			if [[ -f "$(INSTALL_DIR)/$$install_name" ]]; then \
				echo "Removing $$install_name..."; \
				rm -f "$(INSTALL_DIR)/$$install_name"; \
			fi; \
		fi; \
	done
	@echo "$(GREEN)Uninstall complete!$(NC)"

# Development targets
.PHONY: check
check:
	@echo "$(BLUE)Checking dependencies...$(NC)"
	@for cmd in bash jq curl; do \
		if command -v $$cmd > /dev/null 2>&1; then \
			echo "  $$cmd: $(GREEN)✓$(NC)"; \
		else \
			echo "  $$cmd: $(RED)✗ Missing$(NC)"; \
		fi; \
	done
	@echo ""
	@echo "Bash version: $$(bash --version | head -1)"
	@echo "jq version: $$(jq --version 2>/dev/null || echo 'Not installed')"
	@echo "curl version: $$(curl --version | head -1)"

.PHONY: lint
lint:
	@echo "$(BLUE)Running shellcheck...$(NC)"
	@if command -v shellcheck > /dev/null 2>&1; then \
		shellcheck -S warning install.sh $(TOOLS_DIR)/*/* $(TESTS_DIR)/*.sh 2>/dev/null || true; \
	else \
		echo "$(YELLOW)Warning: shellcheck not installed$(NC)"; \
		echo "Install with: brew install shellcheck (macOS) or apt install shellcheck (Linux)"; \
	fi

.PHONY: format
format:
	@echo "$(BLUE)Formatting shell scripts...$(NC)"
	@if command -v shfmt > /dev/null 2>&1; then \
		shfmt -i 2 -w install.sh $(TOOLS_DIR)/*/* $(TESTS_DIR)/*.sh; \
		echo "$(GREEN)Formatting complete!$(NC)"; \
	else \
		echo "$(YELLOW)Warning: shfmt not installed$(NC)"; \
		echo "Install with: brew install shfmt (macOS) or apt install shfmt (Linux)"; \
	fi

.PHONY: validate
validate:
	@echo "$(BLUE)Validating all tools...$(NC)"
	@errors=0; \
	for tool in $(TOOLS_DIR)/*/*; do \
		if [[ -f "$$tool" ]]; then \
			name=$$(echo "$$tool" | sed 's|$(TOOLS_DIR)/||' | tr '/' '.'); \
			echo -n "Validating $$name... "; \
			if [[ ! -x "$$tool" ]]; then \
				echo "$(RED)✗ Not executable$(NC)"; \
				errors=$$((errors + 1)); \
			elif ! $$tool --help > /dev/null 2>&1; then \
				echo "$(RED)✗ Missing --help$(NC)"; \
				errors=$$((errors + 1)); \
			elif ! $$tool --schema > /dev/null 2>&1; then \
				echo "$(RED)✗ Missing --schema$(NC)"; \
				errors=$$((errors + 1)); \
			else \
				echo "$(GREEN)✓$(NC)"; \
			fi; \
		fi; \
	done; \
	if [[ $$errors -gt 0 ]]; then \
		echo "$(RED)Validation failed with $$errors errors$(NC)"; \
		exit 1; \
	else \
		echo "$(GREEN)All tools validated successfully!$(NC)"; \
	fi

.PHONY: list
list:
	@echo "$(BLUE)Available tools:$(NC)"
	@for namespace in $(TOOLS_DIR)/*; do \
		if [[ -d "$$namespace" ]]; then \
			ns_name=$$(basename "$$namespace"); \
			echo "$(YELLOW)$$ns_name/:$(NC)"; \
			for tool in "$$namespace"/*; do \
				if [[ -f "$$tool" ]]; then \
					tool_name=$$(basename "$$tool"); \
					echo "  • $$ns_name.$$tool_name"; \
				fi; \
			done; \
		fi; \
	done

# Maintenance targets
.PHONY: clean
clean:
	@echo "$(BLUE)Cleaning temporary files...$(NC)"
	@find . -name '*.tmp' -delete
	@find . -name '*.log' -delete
	@find . -name '.DS_Store' -delete
	@rm -rf /tmp/wikisearch.* /tmp/test-install
	@echo "$(GREEN)Clean complete!$(NC)"

.PHONY: update
update:
	@echo "$(BLUE)Updating from upstream...$(NC)"
	@if [[ -d .git ]]; then \
		git pull origin main; \
		echo "$(GREEN)Update complete!$(NC)"; \
	else \
		echo "$(RED)Not a git repository$(NC)"; \
	fi

.PHONY: version
version:
	@echo "$(BLUE)Version Information:$(NC)"
	@if [[ -f VERSION ]]; then \
		echo "chuk-ai-bash-tools version: $$(cat VERSION)"; \
	else \
		echo "chuk-ai-bash-tools version: development"; \
	fi
	@if [[ -d .git ]]; then \
		echo "Git commit: $$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"; \
		echo "Git branch: $$(git branch --show-current 2>/dev/null || echo 'unknown')"; \
	fi

# Shortcut targets
.PHONY: t
t: test

.PHONY: i
i: install

.PHONY: c
c: check

.PHONY: l
l: lint

# Default target if no target specified
.DEFAULT_GOAL := help