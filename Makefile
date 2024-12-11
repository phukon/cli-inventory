# Binary name
BINARY_NAME=inventory-cli

# Build directories
BUILD_DIR=builds
WINDOWS_BUILD_DIR=$(BUILD_DIR)/windows
LINUX_BUILD_DIR=$(BUILD_DIR)/linux
MACOS_BUILD_DIR=$(BUILD_DIR)/darwin

# Version information
VERSION?=1.0.0
BUILD_TIME=$(shell date +%FT%T%z)

# Build flags
LDFLAGS=-ldflags "-X main.Version=${VERSION} -X main.BuildTime=${BUILD_TIME}"

# Default target
.DEFAULT_GOAL := help

.PHONY: all build build-windows build-linux build-macos clean help

help: ## Display available commands
	@echo "Available commands:"
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: clean build-windows build-linux build-macos ## Build binaries for all platforms

build: ## Build for current OS and architecture
	go build ${LDFLAGS} -o $(BINARY_NAME)

build-windows: ## Build for Windows
	mkdir -p $(WINDOWS_BUILD_DIR)
	GOOS=windows GOARCH=amd64 go build ${LDFLAGS} -o $(WINDOWS_BUILD_DIR)/$(BINARY_NAME).exe

build-linux: ## Build for Linux
	mkdir -p $(LINUX_BUILD_DIR)
	GOOS=linux GOARCH=amd64 go build ${LDFLAGS} -o $(LINUX_BUILD_DIR)/$(BINARY_NAME)

build-macos: ## Build for macOS
	mkdir -p $(MACOS_BUILD_DIR)
	GOOS=darwin GOARCH=amd64 go build ${LDFLAGS} -o $(MACOS_BUILD_DIR)/$(BINARY_NAME)

clean: ## Remove build artifacts
	rm -rf $(BUILD_DIR)
	rm -f $(BINARY_NAME)
	rm -f $(BINARY_NAME).exe

run: build ## Build and run the application
	./$(BINARY_NAME)