#!/usr/bin/env bash
DEV_MODE=true
PROGRAM_DIR="/opt/kioskipi"

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

# check if program started in sudo
if (( $(id -u) != 0 )); then
    error "Program launched not in sudo"
fi

if [ $DEV_MODE = true ]; then
    if ! command -v go &>/dev/null; then
        error "Missing go compiler!"
    fi
    
    go build -o kioskipi main.go 
    mkdir -p $PROGRAM_DIR
    mv kioskipi $PROGRAM_DIR
else
    # get program from github releases
fi

# create and start service
