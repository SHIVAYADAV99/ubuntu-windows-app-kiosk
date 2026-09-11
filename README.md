# ubuntu-windows-app-kiosk
🚀 A GNOME-native kiosk solution for running Windows App on Ubuntu 24.04.  This project provides an automated Bash script to configure a controlled kiosk environment using the native GNOME desktop environment.
Run the Windows App while restricting unnecessary access to the Ubuntu system.

✨ Features
👤 Dedicated kiosk user
🖥️ GNOME-native kiosk environment
🚀 Automatic Windows App launch
🔄 Automatic application restart if closed
🔐 GNOME lockdown policies
🚫 Ubuntu Dock restrictions
⚙️ Settings access restrictions
⌨️ Command-line restrictions
👥 User switching restrictions
🔌 Controlled Power Off and Restart options
🪟 Windows App window management
🤖 Automated deployment using Bash scripting
📋 Requirements
Ubuntu 24.04 LTS
GNOME Desktop Environment
sudo access
Internet connection
Windows App for Linux
1️⃣ Install Windows App for Linux

Download the Windows App package from:

https://github.com/imamAtif/windows-app-linux/releases

Open Terminal and run:

wget https://github.com/imamAtif/windows-app-linux/releases/download/v0.2.0/windows-app-linux_0.1.0_amd64.deb

Make the package executable:

sudo chmod +x windows-app-linux_0.1.0_amd64.deb

Install the package:

sudo apt install ./windows-app-linux_0.1.0_amd64.deb

Verify the installation:

which windows-app-linux
2️⃣ Download This Repository

Clone the repository:

git clone https://github.com/YOUR-USERNAME/ubuntu-windows-app-kiosk.git

Move into the project directory:

cd ubuntu-windows-app-kiosk
3️⃣ Make the Script Executable
chmod +x setup-kiosk.sh
4️⃣ Run the Kiosk Setup

Run the script:

sudo ./setup-kiosk.sh

Or specify a custom kiosk username:

sudo ./setup-kiosk.sh kiosk.user
🔧 What Does the Script Configure?

The script automatically configures:

👤 User Management
Creates a dedicated kiosk user
Removes unnecessary administrative access
Configures the kiosk user session
🖥️ GNOME Configuration
Configures the GNOME environment
Applies GNOME lockdown policies
Restricts unnecessary desktop functionality
Disables Ubuntu Dock access
🔐 Security Restrictions
Restricts command-line access
Restricts user switching
Restricts GNOME Settings access
Disables unnecessary keyboard shortcuts
🚀 Windows App Management
Automatically detects the Windows App executable
Automatically launches Windows App
Monitors the application
Restarts the application if it closes
🔌 System Controls

The kiosk environment provides controlled access to:

Power Off
Restart
🏗️ How It Works
Ubuntu 24.04
      │
      ▼
GNOME Desktop Session
      │
      ▼
Dedicated Kiosk User
      │
      ▼
GNOME Lockdown Policies
      │
      ▼
Windows App Auto Launch
      │
      ▼
Application Monitoring
      │
      ▼
Automatic Recovery
🔄 Removing Kiosk Mode

An uninstall/restore script will be provided to remove the kiosk configuration and restore the system settings.
chmod +x uninstall-kiosk.sh
sudo ./uninstall-kiosk.sh kiosk.user
sudo reboot

⚠️ Important Notes

This project modifies GNOME and system configuration for kiosk usage.

It is recommended to:

Test the script on a non-production system first
Keep an administrator account available
Review the script before deploying it in production
Create a system backup before large-scale deployment
🛠️ Technologies Used
Ubuntu 24.04 LTS
GNOME
Windows App for Linux
Bash
dconf
PolicyKit
GDM
wmctrl
X11
🤝 Contributions

Contributions, improvements, bug reports, and suggestions are welcome.

Feel free to:

Fork the repository
Open an issue
Submit a pull request
