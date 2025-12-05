.PHONY: lint

lint: ## Format Swift code using swift-format
	swift-format --in-place --recursive .
