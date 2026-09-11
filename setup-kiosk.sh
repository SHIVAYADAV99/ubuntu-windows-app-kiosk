#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# Ubuntu 24.04 GNOME Native Windows App Kiosk Setup
# ============================================================

SCRIPT_NAME="$(basename "$0")"

# Root privilege check & sudo fallback
if [[ "${EUID}" -ne 0 ]]; then
    if ! sudo -v; then
        echo "ERROR: sudo access is required."
        exit 1
    fi
    SUDO="sudo"
else
    SUDO=""
fi

if [[ ! -r /etc/os-release ]]; then
    echo "ERROR: Cannot determine operating system."
    exit 1
fi

. /etc/os-release

if [[ "${ID}" != "ubuntu" || "${VERSION_ID}" != "24.04" ]]; then
    echo "ERROR: This installer requires Ubuntu 24.04."
    exit 1
fi

KIOSK_USER="${1:-kiosk.user}"

# Regex allows lowercase letters, numbers, underscores, hyphens, and dots (.)
if [[ ! "${KIOSK_USER}" =~ ^[a-z_][a-z0-9_.-]*[$]?$ ]]; then
    echo "ERROR: Invalid Linux username: ${KIOSK_USER}"
    exit 1
fi

echo "Setting up kiosk for user: ${KIOSK_USER}"

# ------------------------------------------------------------
# Detect Windows App Executable
# ------------------------------------------------------------

APP_PATH=""
for path in "$(command -v windows-app-linux 2>/dev/null)" "/usr/bin/windows-app-linux" "/usr/local/bin/windows-app-linux" "/snap/bin/windows-app-linux"; do
    if [[ -n "${path}" && -x "${path}" ]]; then
        APP_PATH="${path}"
        break
    fi
done

if [[ -z "${APP_PATH}" ]]; then
    echo "ERROR: windows-app-linux executable was not found."
    exit 1
fi

REAL_APP_PATH="$(readlink -f "${APP_PATH}" 2>/dev/null || true)"
if [[ -n "${REAL_APP_PATH}" && -x "${REAL_APP_PATH}" ]]; then
    APP_PATH="${REAL_APP_PATH}"
fi

echo "Windows App detected at: ${APP_PATH}"

# ------------------------------------------------------------
# Manage User Creation & AccountsService Settings
# ------------------------------------------------------------

if ! id "${KIOSK_USER}" >/dev/null 2>&1; then
    ${SUDO} useradd --create-home --shell /bin/bash "${KIOSK_USER}"
    echo "Set password for ${KIOSK_USER}:"
    ${SUDO} passwd "${KIOSK_USER}"
fi

USER_HOME="$(getent passwd "${KIOSK_USER}" | cut -d: -f6)"

for GROUP in sudo admin adm docker lxd; do
    if getent group "${GROUP}" >/dev/null 2>&1; then
        ${SUDO} gpasswd -d "${KIOSK_USER}" "${GROUP}" >/dev/null 2>&1 || true
    fi
done

# Force X11 session for wmctrl compatibility under GDM
${SUDO} mkdir -p /var/lib/AccountsService/users
${SUDO} tee "/var/lib/AccountsService/users/${KIOSK_USER}" > /dev/null << EOF
[User]
Language=en_US.UTF-8
XSession=ubuntu-xorg
SystemAccount=false
EOF

# ------------------------------------------------------------
# Install Dependencies
# ------------------------------------------------------------

${SUDO} apt-get update
${SUDO} apt-get install -y \
    gnome-shell \
    gnome-session \
    gnome-settings-daemon \
    gnome-control-center \
    gsettings-desktop-schemas \
    dconf-cli \
    dbus-x11 \
    xdg-utils \
    wmctrl \
    gdm3 \
    policykit-1

# Use standard display manager alias target for Ubuntu 24.04
${SUDO} systemctl enable gdm || ${SUDO} systemctl enable gdm3 || true

# ------------------------------------------------------------
# Allow Kiosk User Power & Session Actions via Polkit
# ------------------------------------------------------------

${SUDO} mkdir -p /etc/polkit-1/rules.d
${SUDO} tee /etc/polkit-1/rules.d/49-kiosk-power.rules >/dev/null <<EOF
polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.login1.power-off" ||
         action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
         action.id == "org.freedesktop.login1.reboot" ||
         action.id == "org.freedesktop.login1.reboot-multiple-sessions") &&
        subject.user == "${KIOSK_USER}") {
        return polkit.Result.YES;
    }
});
EOF

# ------------------------------------------------------------
# Global GNOME dconf Lockdown
# ------------------------------------------------------------

${SUDO} mkdir -p /etc/dconf/profile
${SUDO} mkdir -p /etc/dconf/db/kiosk.d/locks

# Master user profile configuration
${SUDO} tee /etc/dconf/profile/user >/dev/null <<EOF
user-db:user
system-db:kiosk
EOF

${SUDO} tee /etc/dconf/db/kiosk.d/00-kiosk >/dev/null <<'EOF'
[org/gnome/desktop/lockdown]
disable-command-line=true
disable-user-switching=true
disable-lock-screen=true
disable-log-out=false

[org/gnome/shell]
development-tools=false
favorite-apps=['windows-app-kiosk.desktop']
enabled-extensions=@as []
disabled-extensions=['ubuntu-dock@ubuntu.com', 'dash-to-dock@micxgx.gmail.com', 'ding@rastersoft.com', 'desktop-icons@csoriano']

[org/gnome/shell/extensions/dash-to-dock]
autohide=true
dock-fixed=false
intellihide=true
show-show-apps-button=false

[org/gnome/desktop/wm/preferences]
button-layout='appmenu:minimize,maximize,close'

[org/gnome/desktop/interface]
enable-hot-corners=false

[org/gnome/desktop/session]
idle-delay=uint32 0

[org/gnome/mutter]
overlay-key=''

[org/gnome/settings-daemon/plugins/media-keys]
terminal=@as []
www=@as []

[org/gnome/shell/keybindings]
toggle-overview=@as []
toggle-application-view=@as []
toggle-message-tray=@as []
toggle-quick-settings=@as []
toggle-applications=@as []
show-screenshot-ui=@as []
show-screen-recording-ui=@as []

[org/gnome/desktop/wm/keybindings]
panel-main-menu=@as []
panel-run-dialog=@as []
activate-window-menu=@as []
show-desktop=@as []
switch-applications=@as []
switch-applications-backward=@as []
switch-windows=@as []
switch-windows-backward=@as []
cycle-windows=@as []
cycle-windows-backward=@as []
minimize=@as []
maximize=@as []
unmaximize=@as []
close=['<Alt>F4']

[org/gnome/desktop/background]
show-desktop-icons=false

[org/nautilus/desktop]
home-icon-visible=false
trash-icon-visible=false
volumes-visible=false
EOF

${SUDO} tee /etc/dconf/db/kiosk.d/locks/00-kiosk-locks >/dev/null <<'EOF'
/org/gnome/desktop/lockdown/disable-command-line
/org/gnome/desktop/lockdown/disable-user-switching
/org/gnome/desktop/lockdown/disable-lock-screen
/org/gnome/shell/development-tools
/org/gnome/shell/favorite-apps
/org/gnome/shell/enabled-extensions
/org/gnome/shell/disabled-extensions
/org/gnome/shell/extensions/dash-to-dock/show-show-apps-button
/org/gnome/desktop/wm/preferences/button-layout
/org/gnome/desktop/interface/enable-hot-corners
/org/gnome/desktop/session/idle-delay
/org/gnome/mutter/overlay-key
/org/gnome/settings-daemon/plugins/media-keys/terminal
/org/gnome/settings-daemon/plugins/media-keys/www
/org/gnome/shell/keybindings/toggle-overview
/org/gnome/shell/keybindings/toggle-application-view
/org/gnome/shell/keybindings/toggle-message-tray
/org/gnome/shell/keybindings/toggle-quick-settings
/org/gnome/shell/keybindings/toggle-applications
/org/gnome/shell/keybindings/show-screenshot-ui
/org/gnome/shell/keybindings/show-screen-recording-ui
/org/gnome/desktop/wm/keybindings/panel-main-menu
/org/gnome/desktop/wm/keybindings/panel-run-dialog
/org/gnome/desktop/wm/keybindings/activate-window-menu
/org/gnome/desktop/wm/keybindings/show-desktop
/org/gnome/desktop/wm/keybindings/switch-applications
/org/gnome/desktop/wm/keybindings/switch-applications-backward
/org/gnome/desktop/wm/keybindings/switch-windows
/org/gnome/desktop/wm/keybindings/switch-windows-backward
/org/gnome/desktop/wm/keybindings/cycle-windows
/org/gnome/desktop/wm/keybindings/cycle-windows-backward
/org/gnome/desktop/wm/keybindings/minimize
/org/gnome/desktop/wm/keybindings/maximize
/org/gnome/desktop/wm/keybindings/unmaximize
/org/gnome/desktop/background/show-desktop-icons
EOF

${SUDO} dconf update

# ------------------------------------------------------------
# Block All App Launchers from Grid Menu for Kiosk User
# ------------------------------------------------------------

${SUDO} mkdir -p "${USER_HOME}/.local/share/applications"

# Override all existing system desktop launchers so they do not show in grid
if [[ -d /usr/share/applications ]]; then
    for app in /usr/share/applications/*.desktop; do
        if [[ -f "$app" ]]; then
            filename="$(basename "$app")"
            if [[ "$filename" != "windows-app-kiosk.desktop" ]]; then
                ${SUDO} tee "${USER_HOME}/.local/share/applications/${filename}" >/dev/null <<EOF
[Desktop Entry]
Type=Application
Name=${filename}
Exec=true
NoDisplay=true
Hidden=true
EOF
            fi
        fi
    done
fi

# Override extra snap apps explicitly
EXTRA_BLOCKS=(
    "ubuntu-app-center_ubuntu-app-center.desktop"
    "snap.ubuntu-app-center.ubuntu-app-center.desktop"
    "firefox.desktop"
    "firefox_firefox.desktop"
    "firmware-updater_firmware-updater.desktop"
    "thunderbird.desktop"
    "thunderbird_thunderbird.desktop"
    "org.gnome.Software.desktop"
    "snap-store_snap-store.desktop"
)

for file in "${EXTRA_BLOCKS[@]}"; do
    ${SUDO} tee "${USER_HOME}/.local/share/applications/${file}" >/dev/null <<EOF
[Desktop Entry]
Type=Application
Name=Blocked
Exec=true
NoDisplay=true
Hidden=true
EOF
done

# ------------------------------------------------------------
# Configure Kiosk User Session Environment & Launchers
# ------------------------------------------------------------

${SUDO} mkdir -p "${USER_HOME}/.config/environment.d"
${SUDO} tee "${USER_HOME}/.config/environment.d/90-windows-app-kiosk.conf" >/dev/null <<'EOF'
GTK_USE_PORTAL=1
GDK_BACKEND=x11
WEBKIT_DISABLE_COMPOSITING_MODE=1
EOF

# Primary Desktop Launcher (Pinned to Dash)
${SUDO} tee "${USER_HOME}/.local/share/applications/windows-app-kiosk.desktop" >/dev/null <<EOF
[Desktop Entry]
Type=Application
Name=Windows App
Exec=${USER_HOME}/.local/bin/windows-app-kiosk-launcher
Icon=preferences-desktop-remote-desktop
Terminal=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Phase=Application
EOF

# Copy desktop entry to autostart
${SUDO} mkdir -p "${USER_HOME}/.config/autostart"
${SUDO} cp "${USER_HOME}/.local/share/applications/windows-app-kiosk.desktop" "${USER_HOME}/.config/autostart/"

# Launcher Script with Daily Cache Cleanup & Auto-Restart Loop
${SUDO} mkdir -p "${USER_HOME}/.local/bin"
${SUDO} tee "${USER_HOME}/.local/bin/windows-app-kiosk-launcher" >/dev/null <<EOF
#!/usr/bin/env bash

set -u

APP="${APP_PATH}"
LOG="\${HOME}/.windows-app-kiosk.log"

# Perform daily/session start cache purge to prevent white screen issues
rm -rf \${HOME}/.config/windows-app \${HOME}/.cache/windows-app

sleep 1

# Exit GNOME startup overview mode immediately using DBus
dbus-send --session --dest=org.gnome.Shell --type=method_call /org/gnome/Shell org.gnome.Shell.Eval string:'Main.overview.hide();' 2>/dev/null || true

sleep 2

while true; do
    WINDOW_EXISTS=""
    if command -v wmctrl >/dev/null 2>&1; then
        WINDOW_EXISTS=\$(wmctrl -l 2>/dev/null | grep -i -E 'Windows App|WindowsApp|windows-app-linux' || true)
    fi

    if [[ -z "\${WINDOW_EXISTS}" ]]; then
        echo "\$(date '+%F %T') Window closed or missing. Starting Windows App..." >> "\${LOG}"

        "\${APP}" \
            --no-sandbox \
            --disable-gpu \
            --disable-gpu-compositing \
            --window-size=1100,750 \
            --start-maximized=false \
            >> "\${LOG}" 2>&1 &

        sleep 3
    fi

    sleep 1
done
EOF

${SUDO} chmod 755 "${USER_HOME}/.local/bin/windows-app-kiosk-launcher"

# Window Sizing & Positioning Helper
${SUDO} tee "${USER_HOME}/.local/bin/windows-app-window-manager" >/dev/null <<'EOF'
#!/usr/bin/env bash

sleep 4

while true; do
    WINDOW_ID=""
    if command -v wmctrl >/dev/null 2>&1; then
        WINDOW_ID="$(wmctrl -l 2>/dev/null | grep -i -E 'Windows App|WindowsApp|windows-app-linux' | head -n1 | awk '{print $1}' || true)"
    fi

    if [[ -n "${WINDOW_ID}" ]]; then
        wmctrl -ir "${WINDOW_ID}" -b remove,fullscreen 2>/dev/null || true
        wmctrl -ir "${WINDOW_ID}" -b remove,maximized_vert,maximized_horz 2>/dev/null || true
        wmctrl -ir "${WINDOW_ID}" -e 0,-1,-1,1100,750 2>/dev/null || true
        exit 0
    fi
    sleep 1
done
EOF

${SUDO} chmod 755 "${USER_HOME}/.local/bin/windows-app-window-manager"

${SUDO} tee "${USER_HOME}/.config/autostart/windows-app-window-manager.desktop" >/dev/null <<EOF
[Desktop Entry]
Type=Application
Name=Windows App Window Manager
Exec=${USER_HOME}/.local/bin/windows-app-window-manager
Terminal=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOF

# Disable GNOME initial setup/welcome overview screens
${SUDO} mkdir -p "${USER_HOME}/.config"
${SUDO} touch "${USER_HOME}/.config/gnome-initial-setup-done"

# Disable DING Extension per-user directly
${SUDO} mkdir -p "${USER_HOME}/.config/dconf"
${SUDO} chown -R "${KIOSK_USER}:${KIOSK_USER}" "${USER_HOME}/.config"
${SUDO} chown -R "${KIOSK_USER}:${KIOSK_USER}" "${USER_HOME}/.local"
${SUDO} chown -R "${KIOSK_USER}:${KIOSK_USER}" "${USER_HOME}/.local/share"

echo "Setup complete. Desktop right-click menu disabled."
