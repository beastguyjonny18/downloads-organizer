#!/bin/bash

# Define paths
SCRIPTS_DIR="$HOME/.scripts"
SERVICE_DIR="$HOME/.config/systemd/user"

echo "Creating directories..."
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$SERVICE_DIR"

echo "Installing organizer script..."
cp organizer.sh "$SCRIPTS_DIR/downloads_watcher.sh"
chmod +x "$SCRIPTS_DIR/downloads_watcher.sh"

echo "Setting up systemd service..."
# Update the template with the actual home directory
sed "s|\$HOME|$HOME|g" downloads-organizer.service.template > "$SERVICE_DIR/downloads-organizer.service"

echo "Reloading systemd and starting service..."
systemctl --user daemon-reload
systemctl --user enable downloads-organizer.service
systemctl --user restart downloads-organizer.service

echo "Installation complete!"
echo "You can view logs at: ~/.downloads_organizer.log"
