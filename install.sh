#!/bin/bash

# TaskTrek Installation Script

set -e

echo "Installing TaskTrek..."

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Please install jq first:"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  CentOS/RHEL: sudo yum install jq"
    echo "  macOS: brew install jq"
    exit 1
fi

# Make scripts executable
chmod +x tasktrek
chmod +x tasktrek-lib.sh

# Create data directory
mkdir -p data

# Initialize tasks.json if it doesn't exist
if [[ ! -f "data/tasks.json" ]]; then
    echo '{"tasks": [], "next_id": 1}' > data/tasks.json
fi

# Create tests directory
mkdir -p tests

# Create docs directory
mkdir -p docs

echo "TaskTrek installed successfully!"
echo ""
echo "Usage:"
echo "  ./tasktrek add \"Task title\" \"Description\" --recur daily"
echo "  ./tasktrek list"
echo "  ./tasktrek complete 1"
echo "  ./tasktrek help"
echo ""
echo "To make TaskTrek available system-wide:"
echo "  sudo ln -s $(pwd)/tasktrek /usr/local/bin/tasktrek"