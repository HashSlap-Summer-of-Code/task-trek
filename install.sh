#!/bin/bash

# TaskTrek Installer

# Create installation directory
INSTALL_DIR="/usr/local/bin/tasktrek"
echo "📂 Creating installation directory: $INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"

# Copy files
echo "📦 Copying files..."
sudo cp tasktrek "$INSTALL_DIR"
sudo cp tasktrek-lib.sh "$INSTALL_DIR"

# Create data directory
DATA_DIR="$HOME/.tasktrek"
echo "📂 Creating data directory: $DATA_DIR"
mkdir -p "$DATA_DIR/data"
mkdir -p "$DATA_DIR/config"

# Create symlink
echo "🔗 Creating symlink..."
sudo ln -s "$INSTALL_DIR/tasktrek" /usr/local/bin/tasktrek

# Set permissions
echo "🔒 Setting permissions..."
sudo chmod +x "$INSTALL_DIR/tasktrek"
sudo chmod +x "$INSTALL_DIR/tasktrek-lib.sh"

# Create default files
[ -f "$DATA_DIR/data/tasks.json" ] || echo "[]" > "$DATA_DIR/data/tasks.json"
[ -f "$DATA_DIR/config/settings.cfg" ] || {
    echo "# TaskTrek Configuration" > "$DATA_DIR/config/settings.cfg"
    echo "priority_colors=true" >> "$DATA_DIR/config/settings.cfg"
    echo "date_format=%Y-%m-%d" >> "$DATA_DIR/config/settings.cfg"
}

# Install jq dependency
echo "📦 Checking for jq dependency..."
if ! command -v jq &> /dev/null; then
    echo "Installing jq..."
    sudo apt-get install jq -y || sudo brew install jq || sudo yum install jq -y
else
    echo "jq is already installed ✅"
fi

echo ""
echo "🎉 TaskTrek installed successfully!"
echo "Try it out with: tasktrek add \"My first task\""