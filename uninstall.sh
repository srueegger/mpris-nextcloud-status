#!/usr/bin/env bash

set -e

echo "🧹 MPRIS → Nextcloud Status Deinstallation"
echo "----------------------------------------"

read -p "⚠️ Willst du das Tool wirklich deinstallieren? [y/N]: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "❌ Abgebrochen."
    exit 0
fi

# 🔁 Dienste stoppen und deaktivieren
echo "⛔ Stoppe systemd-Timer und -Service..."
systemctl --user stop mpris-nextcloud-status.timer mpris-nextcloud-status.service || true
systemctl --user disable mpris-nextcloud-status.timer mpris-nextcloud-status.service || true
systemctl --user daemon-reload

# 🗑️ Dateien entfernen
echo "🗑️ Entferne installierte Dateien..."

rm -f "$HOME/.local/bin/mpris-nextcloud-status"
rm -f "$HOME/.config/systemd/user/mpris-nextcloud-status.service"
rm -f "$HOME/.config/systemd/user/mpris-nextcloud-status.timer"
rm -f "$HOME/.config/mpris-nextcloud-status/config.env"
rmdir --ignore-fail-on-non-empty "$HOME/.config/mpris-nextcloud-status" 2>/dev/null || true

echo "✅ Deinstallation abgeschlossen."
