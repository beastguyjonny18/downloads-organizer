#!/bin/bash

# Define paths
SCRIPTS_DIR="$HOME/.scripts"
SERVICE_DIR="$HOME/.config/systemd/user"

echo "Creating directories..."
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$SERVICE_DIR"

echo "Installing organizer script..."
cp organizer.sh "$SCRIPTS_DIR/downloads_organizer.sh"
chmod +x "$SCRIPTS_DIR/downloads_organizer.sh"

echo "Setting up systemd service and timer..."
sed "s|\$HOME|$HOME|g" downloads-organizer.service.template > "$SERVICE_DIR/downloads-organizer.service"
sed "s|\$HOME|$HOME|g" downloads-organizer.timer.template > "$SERVICE_DIR/downloads-organizer.timer"

echo "Reloading systemd and starting timer..."
systemctl --user daemon-reload
systemctl --user enable --now downloads-organizer.timer

echo "Installation complete!"
echo "The script will run every hour. Logs at: ~/.downloads_organizer.log"
