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
	@printf "$(BLUE)chuk-ai-bash-tools Makefile$(NC)\n"
	@printf "\n"
	@printf "$(YELLOW)Available targets:$(NC)\n"
	@printf "  $(GREEN)help$(NC)           - Show this help message\n"
	@printf "\n"
	@printf "$(YELLOW)Testing:$(NC)\n"
	@printf "  $(GREEN)test$(NC)           - Run all tests\n"
	@printf "  $(GREEN)test-ci$(NC)        - Run CI-compatible tests\n"
	@printf "  $(GREEN)test-hello$(NC)     - Test hello.world tool\n"
	@printf "  $(GREEN)test-wiki$(NC)      - Test wiki.search tool\n"
	@printf "  $(GREEN)test-installer$(NC) - Test installer script\n"
	@printf "  $(GREEN)test-coverage$(NC)  - Check test coverage\n"
	@printf "  $(GREEN)test-contract$(NC)  - Test API contract compliance\n"
	@printf "\n"
	@printf "$(YELLOW)Installation:$(NC)\n"
	@printf "  $(GREEN)install$(NC)        - Install all tools\n"
	@printf "  $(GREEN)install-hello$(NC)  - Install hello.world tool\n"
	@printf "  $(GREEN)install-wiki$(NC)   - Install wiki tools\n"
	@printf "  $(GREEN)install-local$(NC)  - Install from local repository\n"
	@printf "  $(GREEN)uninstall$(NC)      - Remove all installed tools\n"
	@printf "\n"
	@printf "$(YELLOW)Development:$(NC)\n"
	@printf "  $(GREEN)check$(NC)          - Check dependencies\n"
	@printf "  $(GREEN)lint$(NC)           - Run shellcheck on scripts\n"
	@printf "  $(GREEN)format$(NC)         - Format shell scripts\n"
	@printf "  $(GREEN)validate$(NC)       - Validate all tools\n"
	@printf "  $(GREEN)list$(NC)           - List available tools\n"
	@printf "\n"
	@printf "$(YELLOW)Maintenance:$(NC)\n"
	@printf "  $(GREEN)clean$(NC)          - Clean temporary files\n"
	@printf "  $(GREEN)update$(NC)         - Update from upstream\n"
	@printf "  $(GREEN)version$(NC)        - Show version information\n"

# Testing targets
.PHONY: test
test:
	@printf "$(BLUE)Running all tests...$(NC)\n"
	@bash $(TESTS_DIR)/run_all.sh

.PHONY: test-ci
test-ci:
	@printf "$(BLUE)Running CI tests...$(NC)\n"
	@bash $(TESTS_DIR)/run_ci.sh

.PHONY: test-hello
test-hello:
	@printf "$(BLUE)Testing hello.world tool...$(NC)\n"
	@bash $(TESTS_DIR)/test_hello.sh

.PHONY: test-wiki
test-wiki:
	@printf "$(BLUE)Testing wiki.search tool...$(NC)\n"
	@bash $(TESTS_DIR)/test_wiki.sh

.PHONY: test-installer
test-installer:
	@printf "$(BLUE)Testing installer...$(NC)\n"
	@bash $(TESTS_DIR)/test_installer.sh

.PHONY: test-coverage
test-coverage:
	@printf "$(BLUE)Checking test coverage...$(NC)\n"
	@printf "\n"
	@for tool in $(TOOLS_DIR)/*/*; do \
		if [[ -f "$$tool" ]]; then \
			name=$$(echo "$$tool" | sed 's|$(TOOLS_DIR)/||' | tr '/' '.'); \
			printf "$$name: "; \
			if $$tool --help > /dev/null 2>&1; then \
				printf "$(GREEN)✓$(NC) "; \
			else \
				printf "$(RED)✗$(NC) "; \
			fi; \
			if $$tool --schema | jq -e . > /dev/null 2>&1; then \
				printf "$(GREEN)✓$(NC) "; \
			else \
				printf "$(RED)✗$(NC) "; \
			fi; \
			printf "\n"; \
		fi; \
	done

.PHONY: test-contract
test-contract:
	@printf "$(BLUE)Testing API contract compliance...$(NC)\n"
	@for tool in $(TOOLS_DIR)/*/*; do \
		if [[ -f "$$tool" ]]; then \
			name=$$(basename "$$tool"); \
			printf "Testing $$name... "; \
			if $$tool --schema | jq -e '.type' > /dev/null 2>&1 && \
			   echo '{}' | $$tool 2>/dev/null | jq -e '.ok' > /dev/null 2>&1; then \
				printf "$(GREEN)✓$(NC)\n"; \
			else \
				printf "$(RED)✗$(NC)\n"; \
			fi; \
		fi; \
	done

# Installation targets
.PHONY: install
install:
	@printf "$(BLUE)Installing all tools...$(NC)\n"
	@FORCE=1 bash ./install.sh --all

.PHONY: install-hello
install-hello:
	@printf "$(BLUE)Installing hello.world...$(NC)\n"
	@FORCE=1 bash ./install.sh hello.world

.PHONY: install-wiki
install-wiki:
	@printf "$(BLUE)Installing wiki tools...$(NC)\n"
	@FORCE=1 bash ./install.sh --group wiki

.PHONY: install-local
install-local:
	@printf "$(BLUE)Installing tools locally...$(NC)\n"
	@mkdir -p $(INSTALL_DIR)
	@for tool in $(TOOLS_DIR)/*/*; do \
		if [[ -f "$$tool" ]]; then \
			namespace=$$(basename $$(dirname "$$tool")); \
			name=$$(basename "$$tool"); \
			install_name="$$namespace.$$name"; \
			printf "Installing $$install_name...\n"; \
			cp "$$tool" "$(INSTALL_DIR)/$$install_name"; \
			chmod +x "$(INSTALL_DIR)/$$install_name"; \
		fi; \
	done
	@printf "$(GREEN)Installation complete!$(NC)\n"

.PHONY: uninstall
uninstall:
	@printf "$(BLUE)Uninstalling tools...$(NC)\n"
	@for tool in $(TOOLS_DIR)/*/*; do \
		if [[ -f "$$tool" ]]; then \
			namespace=$$(basename $$(dirname "$$tool")); \
			name=$$(basename "$$tool"); \
			install_name="$$namespace.$$name"; \
			if [[ -f "$(INSTALL_DIR)/$$install_name" ]]; then \
				printf "Removing $$install_name...\n"; \
				rm -f "$(INSTALL_DIR)/$$install_name"; \
			fi; \
		fi; \
	done
	@printf "$(GREEN)Uninstall complete!$(NC)\n"

# Development targets
.PHONY: check
check:
	@printf "$(BLUE)Checking dependencies...$(NC)\n"
	@for cmd in bash jq curl; do \
		if command -v $$cmd > /dev/null 2>&1; then \
			printf "  $$cmd: $(GREEN)✓$(NC)\n"; \
		else \
			printf "  $$cmd: $(RED)✗ Missing$(NC)\n"; \
		fi; \
	done
	@printf "\n"
	@printf "Bash version: $$(bash --version | head -1)\n"
	@printf "jq version: $$(jq --version 2>/dev/null || echo 'Not installed')\n"
	@printf "curl version: $$(curl --version | head -1)\n"

.PHONY: lint
lint:
	@printf "$(BLUE)Running shellcheck...$(NC)\n"
	@if command -v shellcheck > /dev/null 2>&1; then \
		shellcheck -S warning install.sh $(TOOLS_DIR)/*/* $(TESTS_DIR)/*.sh 2>/dev/null || true; \
	else \
		printf "$(YELLOW)Warning: shellcheck not installed$(NC)\n"; \
		printf "Install with: brew install shellcheck (macOS) or apt install shellcheck (Linux)\n"; \
	fi

.PHONY: format
format:
	@printf "$(BLUE)Formatting shell scripts...$(NC)\n"
	@if command -v shfmt > /dev/null 2>&1; then \
		shfmt -i 2 -w install.sh $(TOOLS_DIR)/*/* $(TESTS_DIR)/*.sh; \
		printf "$(GREEN)Formatting complete!$(NC)\n"; \
	else \
		printf "$(YELLOW)Warning: shfmt not installed$(NC)\n"; \
		printf "Install with: brew install shfmt (macOS) or apt install shfmt (Linux)\n"; \
	fi

.PHONY: validate
validate:
	@printf "$(BLUE)Validating all tools...$(NC)\n"
	@errors=0; \
	for tool in $(TOOLS_DIR)/*/*; do \
		if [[ -f "$$tool" ]]; then \
			name=$$(echo "$$tool" | sed 's|$(TOOLS_DIR)/||' | tr '/' '.'); \
			printf "Validating $$name... "; \
			if [[ ! -x "$$tool" ]]; then \
				printf "$(RED)✗ Not executable$(NC)\n"; \
				errors=$$((errors + 1)); \
			elif ! $$tool --help > /dev/null 2>&1; then \
				printf "$(RED)✗ Missing --help$(NC)\n"; \
				errors=$$((errors + 1)); \
			elif ! $$tool --schema > /dev/null 2>&1; then \
				printf "$(RED)✗ Missing --schema$(NC)\n"; \
				errors=$$((errors + 1)); \
			else \
				printf "$(GREEN)✓$(NC)\n"; \
			fi; \
		fi; \
	done; \
	if [[ $$errors -gt 0 ]]; then \
		printf "$(RED)Validation failed with $$errors errors$(NC)\n"; \
		exit 1; \
	else \
		printf "$(GREEN)All tools validated successfully!$(NC)\n"; \
	fi

.PHONY: list
list:
	@printf "$(BLUE)Available tools:$(NC)\n"
	@for namespace in $(TOOLS_DIR)/*; do \
		if [[ -d "$$namespace" ]]; then \
			ns_name=$$(basename "$$namespace"); \
			printf "$(YELLOW)$$ns_name/:$(NC)\n"; \
			for tool in "$$namespace"/*; do \
				if [[ -f "$$tool" ]]; then \
					tool_name=$$(basename "$$tool"); \
					printf "  • $$ns_name.$$tool_name\n"; \
				fi; \
			done; \
		fi; \
	done

# Maintenance targets
.PHONY: clean
clean:
	@printf "$(BLUE)Cleaning temporary files...$(NC)\n"
	@find . -name '*.tmp' -delete
	@find . -name '*.log' -delete
	@find . -name '.DS_Store' -delete
	@rm -rf /tmp/wikisearch.* /tmp/test-install
	@printf "$(GREEN)Clean complete!$(NC)\n"

.PHONY: update
update:
	@printf "$(BLUE)Updating from upstream...$(NC)\n"
	@if [[ -d .git ]]; then \
		git pull origin main; \
		printf "$(GREEN)Update complete!$(NC)\n"; \
	else \
		printf "$(RED)Not a git repository$(NC)\n"; \
	fi

.PHONY: version
version:
	@printf "$(BLUE)Version Information:$(NC)\n"
	@if [[ -f VERSION ]]; then \
		printf "chuk-ai-bash-tools version: $$(cat VERSION)\n"; \
	else \
		printf "chuk-ai-bash-tools version: development\n"; \
	fi
	@if [[ -d .git ]]; then \
		printf "Git commit: $$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')\n"; \
		printf "Git branch: $$(git branch --show-current 2>/dev/null || echo 'unknown')\n"; \
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