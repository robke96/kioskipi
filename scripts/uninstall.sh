#!/bin/bash

PROGRAM_DIR="$HOME/.kioskipi"
SERVICE_NAME="kioskipi"
SERVICE_FILE="$HOME/.config/systemd/user/${SERVICE_NAME}.service"

# stop the service
if systemctl --user is-active --quiet "$SERVICE_NAME"; then
  systemctl --user stop "$SERVICE_NAME"
fi

if systemctl --user is-enabled --quiet "$SERVICE_NAME"; then
  systemctl --user disable "$SERVICE_NAME"
fi

# Unmask service
systemctl --user unmask "$SERVICE_NAME"

# Remove service file
if [ -f "$SERVICE_FILE" ]; then
  rm -f "$SERVICE_FILE"
  echo "Removed systemd service file: $SERVICE_FILE"
else
  echo "Service file not found, skipping removal."
fi

systemctl --user daemon-reload

if [ -d "$PROGRAM_DIR" ]; then
  rm -rf "$PROGRAM_DIR"
  echo "Removed program directory: $PROGRAM_DIR"
else
  echo "Program directory not found, skipping removal."
fi

echo "✅ Uninstall complete."