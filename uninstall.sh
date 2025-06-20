#!/bin/bash

# TaskTrek Uninstaller

# Remove symlink
echo "🔗 Removing symlink..."
sudo rm -f /usr/local/bin/tasktrek

# Remove installation directory
INSTALL_DIR="/usr/local/bin/tasktrek"
echo "🗑️ Removing installation directory: $INSTALL_DIR"
sudo rm -rf "$INSTALL_DIR"

# Remove data directory
DATA_DIR="$HOME/.tasktrek"
echo "🗑️ Removing data directory: $DATA_DIR"
rm -rf "$DATA_DIR"

echo ""
echo "🧹 TaskTrek has been completely uninstalled"