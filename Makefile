default: help ## Default target, shows help

help: ## Display this help
	@echo "📖 Project help"
	@echo "✍️ Usage: make [command]"
	@echo "👉 Available commands open Makefile to see all commands"

swift-format: ## Format Swift code using swift-format
	@echo "Formatting Swift code..."
	swift-format --in-place --recursive .
