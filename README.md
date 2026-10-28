# os-beszel-agent — OPNsense Plugin

[![Beszel](https://img.shields.io/badge/Beszel-Agent-00ff88?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiPjxwYXRoIGQ9Ik0yMiAxMmgtNGwtMyA5TDkgM2wtMyA5SDIiLz48L3N2Zz4=)](https://github.com/henrygd/beszel)
[![OPNsense](https://img.shields.io/badge/OPNsense-Plugin-f39c12?style=for-the-badge)](https://opnsense.org)
[![FreeBSD](https://img.shields.io/badge/FreeBSD-Compatible-red?style=for-the-badge)](https://www.freebsd.org)
[![Build and Release](https://github.com/lamekemal/opns.beszel/actions/workflows/build-pkg.yml/badge.svg)](https://github.com/lamekemal/opns.beszel/actions/workflows/build-pkg.yml)

---

## 📖 Description

**os-beszel-agent** is a community plugin for [OPNsense](https://opnsense.org) that provides a web-based interface to install, configure, and manage the [Beszel Agent](https://github.com/henrygd/beszel) — a lightweight server monitoring agent.

Beszel Agent connects to a Beszel Hub instance and reports system metrics (CPU, memory, disk, network, temperature, etc.) in real-time.

---

## ✨ Features

- **One-command installation** (similar to AdGuard Home)
- **Precompiled `.pkg` packages** built automatically via GitHub Actions
- **Native OPNsense GUI integration** under **Services > Beszel Agent**
- **Enable/Disable** the service with one click
- **Configure connection** to your Beszel Hub:
  - Hub URL
  - Listen port (default: `45876`)
  - SSH public key
  - Authentication token
  - Extra filesystems to monitor
- **Live log viewer** directly in the OPNsense Web UI
- **Automatic binary management** for FreeBSD (amd64 and arm64)
- **rc.d daemon integration** — automatically starts on boot when enabled

---

## 📦 Installation

### Method 1: Easy 1-Line Installer (Recommended)

Connect to your OPNsense firewall via SSH as `root` (or launch the shell from the console menu, option 8), then run:

```bash
fetch -o - https://raw.githubusercontent.com/lamekemal/opns.beszel/main/install.sh | sh
```

*This script automatically fetches the precompiled `.pkg` release (or falls back to direct deployment), installs the OPNsense interface, downloads the official FreeBSD `beszel-agent` binary, and reloads OPNsense services.*

---

### Method 2: Direct Precompiled `.pkg` Install

If you prefer installing the official FreeBSD package directly:

```bash
pkg add https://github.com/lamekemal/opns.beszel/releases/latest/download/os-beszel-agent-1.0.pkg
configctl template reload OPNsense/BeszelAgent
service configd restart
rm -rf /tmp/cache/*
```

---

### Method 3: Build from Source

#### Option A: Quick build script
```bash
git clone https://github.com/lamekemal/opns.beszel.git
cd opns.beszel
sh build.sh
pkg add dist/os-beszel-agent-*.pkg
```

#### Option B: Official `/usr/plugins` build
```bash
git clone https://github.com/opnsense/plugins.git /usr/plugins
cd /usr/plugins
git clone https://github.com/lamekemal/opns.beszel.git sysutils/beszel-agent
cd sysutils/beszel-agent
make package
pkg add work/pkg/os-beszel-agent-*.pkg
```

---

## ⚙️ Configuration

1. Log into your **OPNsense Web GUI**.
2. Navigate to **Services > Beszel Agent > General**.
3. Fill in the connection settings provided by your Beszel Hub:
   - **Hub URL**: The full URL of your Beszel Hub (e.g. `http://192.168.1.50:8090`).
   - **Listen Port**: Port for the agent to listen on (default: `45876`).
   - **Public Key**: The public key shown when adding a system in the Hub.
   - **Token**: Authentication token from your Hub.
   - **Extra Filesystems** *(optional)*: Comma-separated list of mountpoints to monitor.
4. Check **Enable Beszel Agent**.
5. Click **Save**.

The agent is now active and communicating with your Beszel Hub.

---

## 📋 Logs

Navigate to **Services > Beszel Agent > Log File** to view the service logs in real time.

- Adjust the number of lines displayed (default: 500)
- Click **Refresh** to reload the logs
- Log file location on disk: `/var/log/beszel-agent.log`

---

## 🗑️ Uninstallation

To cleanly remove the plugin and all associated files, run:

```bash
fetch -o - https://raw.githubusercontent.com/lamekemal/opns.beszel/main/install.sh | sh -s -- --uninstall
```

Or if you have the script locally:
```bash
sh install.sh --uninstall
```

---

## 🏗️ Project Structure

```
os-beszel-agent/
├── .github/
│   └── workflows/
│       └── build-pkg.yml             # GitHub Actions CI/CD to build & release .pkg
├── build.sh                          # Local package build script
├── install.sh                        # Easy 1-line installer & uninstaller
├── Makefile                          # FreeBSD ports Makefile
├── pkg-descr                         # Package description
├── README.md                         # Documentation
└── src/opnsense/
    ├── mvc/app/
    │   ├── models/OPNsense/BeszelAgent/
    │   │   ├── BeszelAgent.xml       # Configuration model
    │   │   ├── BeszelAgent.php       # Model PHP class
    │   │   ├── ACL/ACL.xml           # API access control
    │   │   └── Menu/Menu.xml         # Menu definition
    │   ├── controllers/OPNsense/BeszelAgent/
    │   │   ├── IndexController.php   # GUI controller
    │   │   ├── forms/general.xml     # Form field definitions
    │   │   └── Api/
    │   │       ├── ServiceController.php   # Service API
    │   │       └── SettingsController.php  # Settings API
    │   └── views/OPNsense/BeszelAgent/
    │       ├── general.volt          # Settings page
    │       └── diagnostics.volt      # Log viewer page
    ├── service/
    │   ├── conf/actions.d/
    │   │   └── actions_beszelagent.conf
    │   └── templates/OPNsense/BeszelAgent/
    │       ├── +TARGETS
    │       └── beszel-agent.conf     # Config template
    └── scripts/OPNsense/BeszelAgent/
        ├── beszel_agent.rc           # rc.d daemon script
        ├── reconfigure.sh            # Reconfigure script
        └── setup.sh                  # Binary download & extract script
```

---

## 📝 License

BSD-2-Clause License
