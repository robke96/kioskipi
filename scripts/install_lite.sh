#!/bin/bash
set -e

### === CONFIG === ###
readonly KIOSK_USER=$(whoami)
readonly KIOSK_APP_PATH="$HOME/.kioskipi/kioskipi"
readonly DEV_MODE=false  # Set to true if building from source
readonly INSTALL_DIR="$HOME/.kioskipi"
readonly GITHUB_REPO="robke96/kioskipi"
readonly BINARY_NAME="kioskipi"

### === UTILITY === ###
info() { echo -e "\033[1;32m[INFO]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*" >&2; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }

### === DETECT PACKAGE MANAGER === ###
detect_package_manager() {
    if command -v apt-get &>/dev/null; then
        PKG_MANAGER="apt"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
    elif command -v yum &>/dev/null; then
        PKG_MANAGER="yum"
    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
    else
        error "Unsupported package manager. Please install packages manually."
    fi
}

### === INSTALL PACKAGES === ###
install_packages() {
    info "Installing required packages..."
    case "$PKG_MANAGER" in
        apt)
            sudo apt update && sudo apt install -y greetd sway chromium-browser curl tar foot
            ;;
        dnf|yum)
            sudo "$PKG_MANAGER" install -y greetd sway chromium curl tar foot
            ;;
        pacman)
            sudo pacman -Syu --noconfirm greetd sway chromium curl tar foot
            ;;
        *)
            error "Package installation not implemented for $PKG_MANAGER"
            ;;
    esac
}

### === CONFIGURE GREETD === ###
configure_greetd() {
    info "Configuring greetd..."

    sudo tee /etc/greetd/config.toml > /dev/null <<EOF
[terminal]
vt = 1

[default_session]
command = "sway"
user = "$KIOSK_USER"
EOF
}

### === SETUP SWAY CONFIG === ###
setup_sway_config() {
    info "Creating minimal sway config..."
    mkdir -p "$HOME/.config/sway"

    # Overwrite existing config
    cat > "$HOME/.config/sway/config" <<EOF
set \$mod Mod1
bindsym \$mod+Return exec foot
bindsym \$mod+q kill
bindsym \$mod+d exit
bindsym \$mod+1 workspace number 1
bindsym \$mod+2 workspace number 2
bindsym \$mod+3 workspace number 3
exec $KIOSK_APP_PATH
EOF
}

### === INSTALL KIOSKIPI BINARY === ###
install_kioskipi_binary() {
    info "Installing kioskipi..."

    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"

    platform=$(uname -ms)
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
            ;;
    esac

    if [ "$DEV_MODE" = true ]; then
        if ! command -v go &>/dev/null; then
            error "Missing Go compiler!"
        fi
        go build -o "$INSTALL_DIR/$BINARY_NAME" .
        chmod +x "$INSTALL_DIR/$BINARY_NAME"
    else
        asset_name="${BINARY_NAME}-${target}.tar.gz"
        download_url=$(curl -s "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" \
            | grep "browser_download_url" \
            | grep "$asset_name" \
            | cut -d '"' -f 4)

        if [ -z "$download_url" ]; then
            error "Failed to find download URL for $asset_name"
        fi

        info "Downloading $asset_name..."
        curl -L "$download_url" -o "$asset_name"

        TMPDIR=$(mktemp -d)
        tar -xzf "$asset_name" -C "$TMPDIR"
        chmod +x "$TMPDIR/$BINARY_NAME"
        mv "$TMPDIR/$BINARY_NAME" "$INSTALL_DIR/"
        rm "$asset_name"
        rm -r "$TMPDIR"

        info "Installed $BINARY_NAME to $INSTALL_DIR"
    fi
}

### === ENABLE GREETD SERVICE === ###
enable_greetd_service() {
    info "Enabling greetd service..."
    if systemctl list-unit-files | grep -q greetd.service; then
        sudo systemctl enable greetd --force
        sudo systemctl restart greetd
        sudo systemctl set-default graphical.target
    else
        warn "greetd service not found. Ensure it's properly installed."
    fi
}

### === MAIN EXECUTION === ###
main() {
    detect_package_manager
    install_packages
    configure_greetd
    setup_sway_config
    install_kioskipi_binary
    enable_greetd_service

    info "✅ Kiosk setup complete. Reboot to start in kiosk mode."
}

main "$@"
