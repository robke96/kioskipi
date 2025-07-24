# KioskiPI
<img width="642" height="410" alt="kioskipi" src="https://github.com/user-attachments/assets/0fbdf6fa-212f-4004-8bd4-c82a319efb0d" />

> [!WARNING]
> This project is not stable and currently in heavy development.

## Description
**KioskiPi** is an automated web kiosk setup written in Go, designed for Raspberry Pi systems. 


## Features
- [x] Auto-launch web in kiosk mode
- [x] No ROOT required
- [x] Hide Cursor
- [x] Custom config port
- [ ] Auto-restart on failure/crash
- [ ] Auto-scroll
- [ ] Auto-updates
- [ ] Multi-page support
- [ ] Show page on specific time
- [ ] Raspberry Pi Lite support

## Installation
```bash
curl -fsSL https://raw.githubusercontent.com/robke96/kioskipi/master/scripts/install.sh | bash
```
## Uninstall
```bash
curl -fsSL https://raw.githubusercontent.com/robke96/kioskipi/master/scripts/uninstall.sh | bash
```

## Usage
After installation, KioskiPI runs automatically.
To edit config, open a browser and go to:
```
http://<raspberry-pi-ip>:54321
```
Replace ``<raspberry-pi-ip>`` with the IP address of your Raspberry Pi on the local network.

## Requirements
- Raspberry Pi OS (Full) 32-64bit

## Contributing
Contributions are welcome!
Open an issue or submit a pull request to get started.
