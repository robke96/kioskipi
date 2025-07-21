#!/usr/bin/env bash
DEV_MODE=true

PROGRAM_DIR="$HOME/.kioskipi"
SERVICE_NAME="kioskipi"
SERVICE_FILE="$HOME/.config/systemd/user/${SERVICE_NAME}.service"

INFO="🔵 \033[1;34m[INFO]\033[0m"
SUCCESS="✅ \033[1;32m[SUCCESS]\033[0m"
ERROR="❌ \033[1;31m[ERROR]\033[0m"

info() {
    echo -e $INFO "$@"
}
success() {
    echo -e $SUCCESS "$@"
}
error() {
    echo -e $ERROR "$@"
    exit 1
}

info "KioskiPI Started!"

if [ $DEV_MODE = true ]; then
    if ! command -v go &>/dev/null; then
        error "Missing go compiler!"
    fi
    
    mkdir -p $PROGRAM_DIR
    go build -o $PROGRAM_DIR/kioskipi .
    chmod +x "$PROGRAM_DIR/kioskipi"
    # get program from github releases
fi

#SYSTEMD service
mkdir -p "$(dirname "$SERVICE_FILE")"

# write the systemd service file
systemctl --user unmask "$SERVICE_NAME"

# create dir for service file if needed
mkdir -p "$(dirname "$SERVICE_FILE")"

# create systemd service
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Kioskipi Go App
After=network.target

[Service]
ExecStart=${PROGRAM_DIR}/kioskipi
Restart=on-failure
WorkingDirectory=${PROGRAM_DIR}
Environment=PATH=${HOME}/.local/bin:/usr/bin:/bin
Environment=HOME=${HOME}

[Install]
WantedBy=default.target
EOF

# Reload user daemon
systemctl --user daemon-reexec
systemctl --user daemon-reload

# start the service
systemctl --user enable "$SERVICE_NAME"
systemctl --user start "$SERVICE_NAME"

sleep 1

# Check status
if systemctl --user is-active --quiet "$SERVICE_NAME"; then
  success "Systemd service started"
else
  error "Failed to start systemd service"
  systemctl --user status "$SERVICE_NAME" --no-pager
  exit 1
fi
