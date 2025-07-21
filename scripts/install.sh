#!/usr/bin/env bash
DEV_MODE=false

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
mkdir -p $PROGRAM_DIR

# === Detect architecture ===
platform=$(uname -ms)
github_repo="robke96/kioskipi"
BINARY_NAME=kioskipi

case "$platform" in
  "Linux aarch64" | "Linux arm64")
    target="linux-arm64"
    ;;
  "Linux x86_64")
    target="linux-amd64"
    ;;
  "Linux armv7l")
    target="linux-armv7"
    ;;
  *)
    error "Unsupported platform: $platform"
    exit 1
    ;;
esac

if [ $DEV_MODE = true ]; then
    if ! command -v go &>/dev/null; then
        error "Missing go compiler!"
    fi
    
    go build -o $PROGRAM_DIR/kioskipi .
    chmod +x "$PROGRAM_DIR/kioskipi"
else
    # get program from github releases
    asset_name="${BINARY_NAME}-${target}.tar.gz"

    download_url=$(curl -s "https://api.github.com/repos/${github_repo}/releases/latest" \
    | grep "browser_download_url" \
    | grep "$asset_name" \
    | cut -d '"' -f 4)

    if [ -z "$download_url" ]; then
        error "Error: Failed to find download URL for $asset_name"
        exit 1
    fi

    info "Downloading $asset_name..."
    curl -L "$download_url" -o "$asset_name"

    tar -xzf "$asset_name"
    chmod +x "$BINARY_NAME"
    sudo mv "$BINARY_NAME" "$PROGRAM_DIR/"

    rm "$asset_name"

    info "Installed $BINARY_NAME to $INSTALL_DIR"
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
