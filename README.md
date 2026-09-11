# Ubuntu Windows App Kiosk

<p align="center">
  <strong>A GNOME-native kiosk solution for running Windows App on Ubuntu 24.04.</strong>
</p>

<p align="center">
  Automated • Secure • Controlled • Repeatable
</p>

---

## 🚀 Overview

**Ubuntu Windows App Kiosk** is a Bash-based automation project that creates a controlled kiosk environment for running **Windows App for Linux** on **Ubuntu 24.04 LTS**.

Instead of replacing the Ubuntu desktop with a third-party window manager, this project uses the native **GNOME desktop environment** and configures kiosk restrictions through:

* GNOME
* dconf
* PolicyKit
* GDM
* X11
* Bash automation

The goal is simple:

> **Run Windows App while restricting unnecessary access to the rest of the Ubuntu system.**

---

# ✨ Features

## 👤 Dedicated Kiosk User

* Creates a dedicated kiosk user if it does not already exist
* Creates a home directory for the kiosk user
* Removes the kiosk user from unnecessary administrative groups

## 🖥️ GNOME-Native Environment

* Uses the Ubuntu 24.04 GNOME desktop environment
* Configures an X11 (`ubuntu-xorg`) session for compatibility with `wmctrl`
* Uses native GNOME configuration and policies

## 🔐 Desktop Lockdown

The kiosk configuration restricts or disables:

* Command-line access
* User switching
* Lock screen
* GNOME developer tools
* GNOME Overview shortcuts
* Application view shortcuts
* Run dialog
* Window switching shortcuts
* Desktop shortcuts
* Screenshot UI shortcuts
* Screen recording UI shortcuts
* Hot corners

## 🚫 Ubuntu Dock Restrictions

The setup disables the Ubuntu Dock and Dash-to-Dock extensions to create a cleaner and more focused kiosk experience.

## ⚙️ Settings Restrictions

The script hides:

* GNOME Settings
* GNOME Control Center

for the kiosk user.

## 🚀 Automatic Windows App Launch

Windows App is automatically launched when the kiosk user starts their GNOME session.

## 🔄 Automatic Application Recovery

The launcher continuously monitors the Windows App window.

If the application is closed or the window is missing, it automatically starts the application again.

## 🪟 Window Management

The script uses `wmctrl` to manage the Windows App window and apply the configured window size.

## 🔌 Controlled Power Options

The kiosk user is allowed to use:

* Power Off
* Restart

through PolicyKit rules.

## 🤖 Automated Deployment

The entire environment is configured through a single Bash setup script.

---

# 📋 Requirements

Before starting, make sure you have:

* Ubuntu **24.04 LTS**
* GNOME Desktop Environment
* sudo privileges
* Internet connection
* Windows App for Linux installed

> ⚠️ This project is designed specifically for **Ubuntu 24.04**.

---

# 🏗️ Architecture

```text
┌──────────────────────────────┐
│        Ubuntu 24.04          │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│       GNOME Desktop          │
│        X11 Session           │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│      Dedicated Kiosk User    │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│   GNOME dconf Lockdown       │
│   Security Restrictions      │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│     Windows App Launcher     │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│   Window Monitoring &        │
│   Automatic Recovery         │
└──────────────────────────────┘
```

---

# 📦 Installation

## Step 1: Install Windows App for Linux

Download the Windows App package from the official project releases:

https://github.com/imamAtif/windows-app-linux/releases

Open Terminal and download the package:

```bash
wget https://github.com/imamAtif/windows-app-linux/releases/download/v0.2.0/windows-app-linux_0.1.0_amd64.deb
```

Install the package:

```bash
sudo apt install ./windows-app-linux_0.1.0_amd64.deb
```

Verify the installation:

```bash
which windows-app-linux
```

Expected output should point to the Windows App executable, for example:

```text
/usr/bin/windows-app-linux
```

---

# Step 2: Clone This Repository

```bash
git clone https://github.com/SHIVAYADAV99/ubuntu-windows-app-kiosk.git
```

Move into the repository:

```bash
cd ubuntu-windows-app-kiosk
```

---

# Step 3: Make the Setup Script Executable

```bash
chmod +x setup-kiosk.sh
```

---

# Step 4: Run the Kiosk Setup

Run the script with the default kiosk username:

```bash
sudo ./setup-kiosk.sh
```

The default username is:

```text
kiosk.user
```

### Or Use a Custom Username

For example:

```bash
sudo ./setup-kiosk.sh kiosk.user
```

Or:

```bash
sudo ./setup-kiosk.sh windowsuser
```

The username must follow valid Linux username rules.

---

# 🔎 Windows App Detection

Before configuring the kiosk environment, the script automatically searches for the Windows App executable.

It checks common locations, including:

```text
/usr/bin/windows-app-linux
/usr/local/bin/windows-app-linux
/snap/bin/windows-app-linux
```

If the executable cannot be found, the script stops and displays an error.

---

# 👤 Kiosk User Configuration

The setup script creates the kiosk user if necessary.

The kiosk user:

* Has a dedicated home directory
* Uses `/bin/bash` as the shell
* Is removed from unnecessary administrative groups when present

The script also configures the user for an X11 GNOME session.

---

# 📦 Dependencies

The script installs the required components, including:

* `gnome-shell`
* `gnome-session`
* `gnome-settings-daemon`
* `gnome-control-center`
* `gsettings-desktop-schemas`
* `dconf-cli`
* `dbus-x11`
* `xdg-utils`
* `wmctrl`
* `gdm3`
* `policykit-1`

---

# 🔐 GNOME Lockdown Configuration

The setup applies GNOME dconf policies to create a controlled environment.

## Restricted Features

The kiosk configuration includes restrictions for:

### Command Line

```text
Command-line access restricted
```

### User Switching

```text
User switching restricted
```

### GNOME Overview

```text
Activities / Overview access restricted
```

### Application View

```text
Application view restricted
```

### Run Dialog

```text
Run dialog restricted
```

### Window Switching

Several GNOME window switching and cycling shortcuts are restricted.

### Screenshots

The GNOME screenshot UI shortcut is disabled.

### Screen Recording

The GNOME screen recording UI shortcut is disabled.

### Hot Corners

GNOME hot corners are disabled.

---

# 🚫 Settings Access

The script creates hidden desktop-entry overrides for:

```text
org.gnome.Settings.desktop
```

and:

```text
gnome-control-center.desktop
```

This prevents the kiosk user from accessing GNOME Settings through the normal application launcher.

---

# 🚀 Automatic Windows App Launch

Windows App is configured to start automatically when the kiosk user logs in.

The launcher is created under:

```text
~/.local/bin/windows-app-kiosk-launcher
```

An autostart desktop entry is configured under:

```text
~/.config/autostart/
```

---

# 🔄 Automatic Application Recovery

The launcher continuously monitors for the Windows App window.

If the application window is not detected:

1. The launcher identifies that the window is missing.
2. Windows App is started again.
3. The monitoring loop continues.

This helps maintain the kiosk environment without requiring manual intervention.

---

# 🪟 Window Management

The project uses `wmctrl` to detect and manage the Windows App window.

A helper script is used to:

* Detect the Windows App window
* Remove fullscreen mode if applied
* Remove maximized mode if applied
* Apply the configured window size

---

# 🔌 Power and Restart Controls

A PolicyKit rule allows the configured kiosk user to perform selected system actions:

* Power Off
* Restart

This provides essential system controls without granting unnecessary administrative privileges.

---

# 📁 Project Structure

```text
ubuntu-windows-app-kiosk/
│
├── setup-kiosk.sh
├── uninstall-kiosk.sh
├── README.md
├── LICENSE
│
├── screenshots/
│   ├── kiosk-overview.png
│   └── windows-app-kiosk.png
│
└── docs/
    └── troubleshooting.md
```

---

# 🔄 Uninstall / Restore

> 🚧 The uninstall/restore script can be included in this repository to help administrators remove the kiosk configuration.

Recommended file:

```text
uninstall-kiosk.sh
```

The restore script should handle:

* Removing kiosk-specific dconf configuration
* Removing PolicyKit kiosk rules
* Removing autostart launchers
* Restoring GNOME configuration
* Removing Settings overrides
* Optionally removing the kiosk user

---

# ⚠️ Important Security Notes

This project modifies:

* GNOME configuration
* dconf system databases
* PolicyKit rules
* User configuration
* Session configuration
* Application autostart settings

Before using this project in production:

✅ Test on a non-production device
✅ Keep a separate administrator account available
✅ Review the script before deployment
✅ Create a system backup or restore point where appropriate
✅ Test your Windows App connectivity before enabling kiosk restrictions

---

# 🧪 Testing Checklist

After running the setup, verify:

* [ ] Windows App starts automatically
* [ ] Windows App restarts after being closed
* [ ] Ubuntu Dock is restricted
* [ ] GNOME Settings is unavailable to the kiosk user
* [ ] Command-line access is restricted
* [ ] User switching is restricted
* [ ] Unnecessary GNOME shortcuts are disabled
* [ ] Power Off works as expected
* [ ] Restart works as expected
* [ ] Windows App window behaves correctly

---

# 🛠️ Troubleshooting

## Windows App Executable Not Found

Verify the application is installed:

```bash
which windows-app-linux
```

If nothing is returned, reinstall Windows App for Linux.

---

## Permission Denied

Make sure the script is executable:

```bash
chmod +x setup-kiosk.sh
```

Then run:

```bash
sudo ./setup-kiosk.sh
```

---

## Windows App Does Not Start

Check the kiosk log:

```bash
cat ~/.windows-app-kiosk.log
```

Also verify:

```bash
which windows-app-linux
```

---

## GNOME Session Problems

Confirm that the system is running Ubuntu 24.04:

```bash
cat /etc/os-release
```

The setup script is specifically designed for Ubuntu 24.04.

---

# 🛠️ Technologies Used

| Technology            | Purpose                         |
| --------------------- | ------------------------------- |
| Ubuntu 24.04 LTS      | Operating System                |
| GNOME                 | Native Desktop Environment      |
| Windows App for Linux | Remote Windows Application      |
| Bash                  | Automation                      |
| dconf                 | GNOME System Configuration      |
| PolicyKit             | Power and Session Authorization |
| GDM                   | GNOME Display Manager           |
| wmctrl                | Window Detection and Management |
| X11                   | Window Management Compatibility |

---

# 🤝 Contributing

Contributions are welcome!

You can help by:

1. Forking the repository
2. Creating a new branch
3. Making improvements
4. Testing changes
5. Opening a Pull Request

You can also open an Issue for:

* Bugs
* Feature requests
* Compatibility problems
* Improvement suggestions

---

# 🗺️ Roadmap

Future improvements may include:

* [ ] Complete uninstall/restore automation
* [ ] Better multi-monitor support
* [ ] Improved logging
* [ ] Configurable window sizes
* [ ] Configurable kiosk restrictions
* [ ] Automated installation of Windows App
* [ ] Improved error handling
* [ ] Deployment documentation
* [ ] Additional testing guides

---

# 📄 License

This project is released under the **MIT License**.

See the [LICENSE](LICENSE) file for details.

---

# ⭐ Support the Project

If you find this project useful:

⭐ Star the repository
🍴 Fork the project
🐛 Report issues
💡 Suggest improvements

Your feedback and contributions are welcome!

---

## 💡 Key Takeaway

> **Kiosk mode isn't just about opening one application.**

A reliable kiosk environment requires the right balance between:

🔐 **Security**
👤 **User Experience**
⚙️ **System Control**
🔄 **Reliability**
🚀 **Automation**

---

<p align="center">

### 🚀 Always learning. Always automating. Always improving.

</p>

---

## 🏷️ Topics

`ubuntu` `ubuntu-24-04` `linux` `gnome` `kiosk` `kiosk-mode` `windows-app` `windows-app-linux` `automation` `bash` `system-administration` `it-infrastructure` `endpoint-management`
