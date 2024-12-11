# Inventory CLI

A simple Terminal User Interface (TUI) application for managing inventory items. Built with Go and the `tview` library.

## Features

- View a list of inventory items with their stock levels
- Add new items to the inventory
- Delete existing items by ID
- Persistent storage using JSON
- User-friendly terminal interface
- Cross-platform support (Windows, Linux, macOS)

## Prerequisites

- Go 1.16 or higher
- [tview](https://github.com/rivo/tview) library
- Make (for using Makefile commands)

## Installation

1. Clone the repository:
```bash
git clone <your-repository-url>
cd inventory-cli
```

2. Install dependencies:
```bash
go mod tidy
```

## Building the Application

The project includes a Makefile with several build options:

```bash
# Show all available commands
make help

# Build for your current platform
make build

# Build for all platforms (Windows, Linux, macOS)
make all

# Build for specific platforms
make build-windows
make build-linux
make build-macos

# Build and run the application
make run

# Clean build artifacts
make clean
```

Build artifacts will be placed in the following directories:
- Windows: `builds/windows/inventory-cli.exe`
- Linux: `builds/linux/inventory-cli`
- macOS: `builds/darwin/inventory-cli`

## Usage

Run the application:
```bash
# If built using 'make build' or 'make run'
./inventory-cli

# Or run from platform-specific build directory
./builds/windows/inventory-cli.exe  # Windows
./builds/linux/inventory-cli        # Linux
./builds/darwin/inventory-cli       # macOS
```

### Managing Inventory

- **Add Item**: 
  1. Enter the item name
  2. Enter the stock quantity
  3. Click "Add Item" or press Enter

- **Delete Item**:
  1. Enter the item ID (shown in square brackets in the inventory list)
  2. Click "Delete Item"

- **Exit**:
  - Click the "Exit" button or press Ctrl+C

## Data Storage

The application stores inventory data in `inventory.json` in the same directory as the executable. This file is automatically created when you add your first item.