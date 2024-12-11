# Binary name
BINARY_NAME=inventory-cli

# Build directories
BUILD_DIR=builds
WINDOWS_BUILD_DIR=$(BUILD_DIR)/windows
LINUX_BUILD_DIR=$(BUILD_DIR)/linux
MACOS_BUILD_DIR=$(BUILD_DIR)/darwin

# Version information
VERSION?=1.0.0
# Use PowerShell compatible date command
ifeq ($(OS),Windows_NT)
    BUILD_TIME=$(shell powershell -Command "Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'")
else
    BUILD_TIME=$(shell date +%FT%T%z)
endif

# Build flags
LDFLAGS=-ldflags "-X main.Version=${VERSION} -X main.BuildTime=${BUILD_TIME}"

# Default target
.DEFAULT_GOAL := help

.PHONY: all build build-windows build-linux build-macos clean help

# Platform independent help command
help: ## Display available commands
	@echo Available commands:
ifeq ($(OS),Windows_NT)
	@powershell -Command "Get-Content $(MAKEFILE_LIST) | Select-String '^[a-zA-Z_-]+:.*?## .*$$' | ForEach-Object { $$tag = $$_.Line -split ':.*?## '; Write-Host \"$$($${tag}[0].PadRight(30, ' '))$($${tag}[1])\" }"
else
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
endif

# Platform independent clean command
clean: ## Remove build artifacts
ifeq ($(OS),Windows_NT)
	@if exist $(BUILD_DIR) rd /s /q $(BUILD_DIR)
	@if exist $(BINARY_NAME) del $(BINARY_NAME)
	@if exist $(BINARY_NAME).exe del $(BINARY_NAME).exe
else
	rm -rf $(BUILD_DIR)
	rm -f $(BINARY_NAME)
	rm -f $(BINARY_NAME).exe
endif

all: clean build-windows build-linux build-macos ## Build binaries for all platforms

build: ## Build for current OS and architecture
	go build ${LDFLAGS} -o $(BINARY_NAME)

build-windows: ## Build for Windows
ifeq ($(OS),Windows_NT)
	@powershell -Command "if (!(Test-Path '$(WINDOWS_BUILD_DIR)')) { New-Item -ItemType Directory -Force -Path '$(WINDOWS_BUILD_DIR)' }"
	set GOOS=windows& set GOARCH=amd64& go build ${LDFLAGS} -o $(WINDOWS_BUILD_DIR)/$(BINARY_NAME).exe
else
	mkdir -p $(WINDOWS_BUILD_DIR)
	GOOS=windows GOARCH=amd64 go build ${LDFLAGS} -o $(WINDOWS_BUILD_DIR)/$(BINARY_NAME).exe
endif

build-linux: ## Build for Linux
ifeq ($(OS),Windows_NT)
	@powershell -Command "if (!(Test-Path '$(LINUX_BUILD_DIR)')) { New-Item -ItemType Directory -Force -Path '$(LINUX_BUILD_DIR)' }"
	set GOOS=linux& set GOARCH=amd64& go build ${LDFLAGS} -o $(LINUX_BUILD_DIR)/$(BINARY_NAME)
else
	mkdir -p $(LINUX_BUILD_DIR)
	GOOS=linux GOARCH=amd64 go build ${LDFLAGS} -o $(LINUX_BUILD_DIR)/$(BINARY_NAME)
endif

build-macos: ## Build for macOS
ifeq ($(OS),Windows_NT)
	@powershell -Command "if (!(Test-Path '$(MACOS_BUILD_DIR)')) { New-Item -ItemType Directory -Force -Path '$(MACOS_BUILD_DIR)' }"
	set GOOS=darwin& set GOARCH=amd64& go build ${LDFLAGS} -o $(MACOS_BUILD_DIR)/$(BINARY_NAME)
else
	mkdir -p $(MACOS_BUILD_DIR)
	GOOS=darwin GOARCH=amd64 go build ${LDFLAGS} -o $(MACOS_BUILD_DIR)/$(BINARY_NAME)
endif

run: build ## Build and run the application
	./$(BINARY_NAME)