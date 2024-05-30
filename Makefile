SHELL := /bin/bash

.DEFAULT_GOAL := help

tools-install: ## Install dependencies for the scanner
	@bash scripts/dependency-install.sh

custom-task: ## Upload the scanned results.
	@bash scripts/new-custom-task.sh $(ARGS)

custom-task-arg: ## Upload the scanned results.
	@bash scripts/new-custom-task.sh $(ARGS)

tools-upgrade: ## Upgrade the scanner.
	@bash scripts/upgrade-install.sh

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk -F ':.*?## ' '/^[a-zA-Z0-9_-]+:.*?##/ {printf "  \033[1;32m%-20s\033[0m :  %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo -e "\033[1;31mNOTE: Please run every option starting with 'make'\033[0m"
	@echo -e "\033[1;34m E.g. make tools-install\033[0m"
	@echo ""
	@echo "Upload Usage examples:"
	@echo "  custom-task-arg ARGS=\"-u jiwan@gmail.com -p password -s file -d Mega_any_dir\""
	@echo "  custom-task-arg ARGS=\"-u subash@gmail.com -p password -s /home/jiwan/any_dir -d Mega_any_dir\""
	@echo ""
	@echo "Wildcard Upload Usage examples:"
	@echo "  custom-task-arg ARGS=\"-u subash@gmail.com -p password -s \\\"/home/subash/*.txt\\\" -d /Mega_any_dir1/dir_lvl_2\""
	@echo ""
