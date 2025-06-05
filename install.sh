#!/usr/bin/env bash

set -e

echo "🎵 MPRIS → Nextcloud Status Installer"
echo "--------------------------------------"

# 📦 Abhängigkeiten prüfen (ZUERST!)
echo "📦 Prüfe Abhängigkeiten…"

MISSING_DEPS=()

# Prüfe ob valac vorhanden ist
if ! command -v valac &> /dev/null; then
    echo "❌ valac nicht gefunden!"
    MISSING_DEPS+=("valac")
fi

# Prüfe ob curl vorhanden ist
if ! command -v curl &> /dev/null; then
    echo "❌ curl nicht gefunden!"
    MISSING_DEPS+=("curl")
fi

# Prüfe ob pkg-config vorhanden ist
if ! command -v pkg-config &> /dev/null; then
    echo "❌ pkg-config nicht gefunden!"
    MISSING_DEPS+=("pkg-config")
fi

# Prüfe ob build-essential installiert ist (gcc)
if ! command -v gcc &> /dev/null; then
    echo "❌ build-essential nicht gefunden!"
    MISSING_DEPS+=("build-essential")
fi

# Prüfe ob GIO-2.0 Development-Bibliotheken verfügbar sind
if ! pkg-config --exists gio-2.0 2>/dev/null; then
    echo "❌ GIO-2.0 Development-Bibliotheken nicht gefunden!"
    MISSING_DEPS+=("libglib2.0-dev")
fi

# Falls Abhängigkeiten fehlen, Installation vorschlagen und beenden
if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo "❌ Fehlende Abhängigkeiten gefunden!"
    echo "💡 Installiere sie mit:"
    echo "   sudo apt update"
    echo "   sudo apt install ${MISSING_DEPS[*]}"
    echo ""
    echo "Oder alle auf einmal:"
    echo "   sudo apt update && sudo apt install valac libglib2.0-dev pkg-config build-essential curl"
    echo ""
    echo "Führe das Skript nach der Installation erneut aus."
    exit 1
fi

echo "✅ Alle Abhängigkeiten sind verfügbar"

# 🧑 Zugangsdaten abfragen (ERST NACHDEM alles OK ist)
echo ""
read -p "Nextcloud-Benutzername: " NC_USER
read -s -p "Nextcloud App-Passwort: " NC_PASS
echo

read -p "Nextcloud-Domain (ohne https://, z. B. cloud.example.com): " NC_DOMAIN
NC_URL="https://${NC_DOMAIN}/ocs/v2.php/apps/user_status/api/v1/user_status/message/custom"

# 🌐 Erreichbarkeit testen
echo "🌐 Prüfe Erreichbarkeit von https://${NC_DOMAIN}…"
if ! ping -c1 -W1 "$NC_DOMAIN" >/dev/null 2>&1; then
    echo "❌ Fehler: Die Domain $NC_DOMAIN ist nicht erreichbar."
    exit 1
fi

# 💾 Konfigurationsdatei speichern
CONFIG_DIR="$HOME/.config/mpris-nextcloud-status"
mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_DIR/config.env" <<EOF
NC_USER="$NC_USER"
NC_PASS="$NC_PASS"
NC_URL="$NC_URL"
EOF

echo "✅ Zugangsdaten gespeichert in $CONFIG_DIR/config.env"

# 🔧 Kompilieren
echo "🔧 Kompiliere Vala-Tool…"
mkdir -p "$HOME/.local/bin"

# Kompiliere mit verbesserter Fehlerbehandlung
if ! valac -o "$HOME/.local/bin/mpris-nextcloud-status" \
  --pkg gio-2.0 \
  src/MprisNextcloudStatus.vala 2>&1; then
    echo "❌ Kompilierung fehlgeschlagen!"
    echo "💡 Stelle sicher, dass alle Development-Pakete installiert sind:"
    echo "   sudo apt install valac libglib2.0-dev pkg-config build-essential"
    exit 1
fi

chmod +x "$HOME/.local/bin/mpris-nextcloud-status"
echo "✅ Kompilierung erfolgreich"

# 🧾 systemd Service + Timer einrichten
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_USER_DIR"

cat > "$SYSTEMD_USER_DIR/mpris-nextcloud-status.service" <<EOF
[Unit]
Description=MPRIS → Nextcloud Status Updater

[Service]
EnvironmentFile=$CONFIG_DIR/config.env
ExecStart=$HOME/.local/bin/mpris-nextcloud-status \$NC_USER \$NC_PASS \$NC_URL
Restart=on-failure

[Install]
WantedBy=default.target
EOF

cat > "$SYSTEMD_USER_DIR/mpris-nextcloud-status.timer" <<EOF
[Unit]
Description=Alle 30 Sekunden MPRIS → Nextcloud Status setzen

[Timer]
OnBootSec=10sec
OnUnitActiveSec=30sec
AccuracySec=1sec
Unit=mpris-nextcloud-status.service

[Install]
WantedBy=default.target
EOF

# 🔄 Aktivieren
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now mpris-nextcloud-status.timer

echo "✅ Installation abgeschlossen!"
echo "Der Dienst wird nun alle 30 Sekunden deinen Status setzen."