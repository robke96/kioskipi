#!/bin/bash

### === CONFIG === ###
readonly PROGRAM_DIR="$HOME/.kioskipi"
readonly SERVICE_NAME="kioskipi"
readonly SERVICE_FILE="$HOME/.config/systemd/user/${SERVICE_NAME}.service"
readonly SWAY_CONFIG_DIR="$HOME/.config/sway"
readonly SWAY_CONFIG_FILE="$HOME/.config/sway/config"
readonly GREETD_CONFIG="/etc/greetd/config.toml"

### === UTILITY === ###
info() { echo -e "\033[1;32m[INFO]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*" >&2; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

### === STOP AND REMOVE USER SERVICE === ###
remove_user_service() {
    if systemctl --user is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        info "Stopping user service: $SERVICE_NAME"
        systemctl --user stop "$SERVICE_NAME" || warn "Failed to stop service"
    fi

    if systemctl --user is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
        info "Disabling user service: $SERVICE_NAME"
        systemctl --user disable "$SERVICE_NAME" || warn "Failed to disable service"
    fi

    # Unmask service
    systemctl --user unmask "$SERVICE_NAME" 2>/dev/null || true

    # Remove service file
    if [ -f "$SERVICE_FILE" ]; then
        info "Removing systemd service file: $SERVICE_FILE"
        rm -f "$SERVICE_FILE"
    else
        info "User service file not found, skipping removal."
    fi

    # Reload systemd user daemon
    systemctl --user daemon-reload 2>/dev/null || true
}

### === REMOVE GREETD CONFIGURATION === ###
remove_greetd_config() {
    if [ -f "$GREETD_CONFIG" ]; then
        info "Removing greetd configuration: $GREETD_CONFIG"
        sudo rm -f "$GREETD_CONFIG"
    else
        info "greetd configuration not found, skipping removal."
    fi

    # Disable greetd service
    if systemctl is-active --quiet greetd 2>/dev/null; then
        info "Stopping greetd service"
        sudo systemctl stop greetd || warn "Failed to stop greetd"
    fi

    if systemctl is-enabled --quiet greetd 2>/dev/null; then
        info "Disabling greetd service"
        sudo systemctl disable greetd || warn "Failed to disable greetd"
    fi
}

### === REMOVE SWAY CONFIGURATION === ###
remove_sway_config() {
    if [ -f "$SWAY_CONFIG_FILE" ]; then
        info "Removing sway configuration: $SWAY_CONFIG_FILE"
        rm -f "$SWAY_CONFIG_FILE"
    else
        info "Sway configuration not found, skipping removal."
    fi

    # Remove sway config directory if empty
    if [ -d "$SWAY_CONFIG_DIR" ] && [ -z "$(ls -A "$SWAY_CONFIG_DIR")" ]; then
        info "Removing empty sway config directory: $SWAY_CONFIG_DIR"
        rmdir "$SWAY_CONFIG_DIR" 2>/dev/null || true
    fi
}

### === REMOVE PROGRAM DIRECTORY === ###
remove_program_directory() {
    if [ -d "$PROGRAM_DIR" ]; then
        info "Removing program directory: $PROGRAM_DIR"
        rm -rf "$PROGRAM_DIR"
    else
        info "Program directory not found, skipping removal."
    fi
}

### === MAIN EXECUTION === ###
main() {
    info "Starting uninstall process..."
    
    remove_user_service
    remove_greetd_config
    remove_sway_config
    remove_program_directory

    info "✅ Uninstall complete."
    info "Note: Installed packages (greetd, sway, chromium, etc.) were not removed."
    info "To remove them, use your package manager manually."
}

main "$@"