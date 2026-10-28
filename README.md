# os-beszel-agent — OPNsense Plugin

[![Beszel](https://img.shields.io/badge/Beszel-Agent-00ff88?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiPjxwYXRoIGQ9Ik0yMiAxMmgtNGwtMyA5TDkgM2wtMyA5SDIiLz48L3N2Zz4=)](https://github.com/henrygd/beszel)
[![OPNsense](https://img.shields.io/badge/OPNsense-Plugin-f39c12?style=for-the-badge)](https://opnsense.org)
[![FreeBSD](https://img.shields.io/badge/FreeBSD-Compatible-red?style=for-the-badge)](https://www.freebsd.org)

---

## 📖 Description

**os-beszel-agent** is a community plugin for [OPNsense](https://opnsense.org) that provides a web-based interface to install, configure, and manage the [Beszel Agent](https://github.com/henrygd/beszel) — a lightweight server monitoring agent.

Beszel Agent connects to a Beszel Hub instance and reports system metrics (CPU, memory, disk, network, etc.) in real-time.

---

## ✨ Features

- **Enable/Disable** the Beszel Agent service from the OPNsense GUI
- **Configure connection** to your Beszel Hub:
  - Hub URL
  - Listen port
  - SSH public key
  - Authentication token
  - Extra filesystems to monitor
- **View logs** in real-time from the OPNsense web interface
- **Automatic binary download** from GitHub releases (FreeBSD amd64/arm64)
- **rc.d integration** — starts on boot when enabled

---

## 📸 Screenshots

### Settings Page
Access via **Services > Beszel Agent > General**

Configure the connection settings and enable/disable the agent.

### Log Viewer
Access via **Services > Beszel Agent > Log File**

View service logs in a terminal-style display with refresh controls.

---

## 📦 Installation

### Method 1: Build from Source (Development)

1. SSH into your OPNsense firewall as root:
   ```bash
   ssh root@your-opnsense-ip
   ```

2. Clone this repository:
   ```bash
   cd /usr/plugins
   git clone https://github.com/YOUR_USERNAME/os-beszel-agent.git sysutils/beszel-agent
   cd sysutils/beszel-agent
   ```

3. Build and install:
   ```bash
   make package
   pkg add work/pkg/os-beszel-agent-*.pkg
   ```

4. Clear the cache:
   ```bash
   configctl template reload OPNsense/BeszelAgent
   rm -rf /tmp/cache/*
   ```

5. Refresh the web interface (Ctrl+F5)

### Method 2: Manual File Placement

Copy the contents of `src/opnsense/` to `/usr/local/opnsense/` on your OPNsense system:

```bash
# Copy MVC files
cp -r src/opnsense/mvc/* /usr/local/opnsense/mvc/

# Copy service files
cp -r src/opnsense/service/* /usr/local/opnsense/service/

# Copy scripts
cp -r src/opnsense/scripts/* /usr/local/opnsense/scripts/

# Install rc.d script
cp src/opnsense/scripts/OPNsense/BeszelAgent/beszel_agent.rc /usr/local/etc/rc.d/beszel_agent
chmod +x /usr/local/etc/rc.d/beszel_agent

# Make scripts executable
chmod +x /usr/local/opnsense/scripts/OPNsense/BeszelAgent/*.sh

# Reload templates and clear cache
configctl template reload OPNsense/BeszelAgent
rm -rf /tmp/cache/*
service configd restart
```

---

## ⚙️ Configuration

1. Navigate to **Services > Beszel Agent > General**
2. Enter the connection details provided by your Beszel Hub:
   - **Hub URL**: The full URL of your Beszel Hub (e.g., `http://192.168.1.50:8090`)
   - **Listen Port**: Port for the agent to listen on (default: `45876`)
   - **Public Key**: The SSH public key shown when adding a system in the Hub
   - **Token**: Authentication token from the Hub
3. Check **Enable Beszel Agent**
4. Click **Save**

The plugin will:
- Download the `beszel-agent` binary for FreeBSD (if not already present)
- Generate the configuration file
- Start the agent as a daemon
- Enable it to start on boot

---

## 📋 Logs

Navigate to **Services > Beszel Agent > Log File** to view the service logs.

- Adjust the number of lines displayed (default: 500)
- Click **Refresh** to reload the logs
- Click **Clear Display** to clear the log viewer

Log file location: `/var/log/beszel-agent.log`

---

## 🏗️ Project Structure

```
os-beszel-agent/
├── Makefile                          # FreeBSD ports Makefile
├── pkg-descr                         # Package description
├── README.md                         # This file
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
        └── setup.sh                  # Binary download script
```

---

## 🔧 Requirements

- **OPNsense** 23.x or later
- **FreeBSD** amd64 or arm64 architecture
- **Internet access** (for initial binary download from GitHub)
- A running **Beszel Hub** instance

---

## 📝 License

BSD-2-Clause License

---

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

---

## 🔗 Links

- [Beszel GitHub Repository](https://github.com/henrygd/beszel)
- [Beszel Documentation](https://beszel.dev)
- [OPNsense Plugin Development Guide](https://docs.opnsense.org/development/frontend.html)
- [OPNsense Plugins Repository](https://github.com/opnsense/plugins)
