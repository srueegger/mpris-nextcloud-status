# 🎵 MPRIS → Nextcloud Status

Aktualisiere deinen Nextcloud-Talk-Status automatisch mit dem aktuell gespielten Song aus deinem Linux-Desktop!
Dieses Tool liest via **MPRIS** den aktuellen Titel und Künstler aus und setzt diesen als **benutzerdefinierten Status** in Nextcloud – ganz automatisch, alle 30 Sekunden.

---

## 🔍 Was ist das?

Viele Linux-Musikplayer (Spotify, YouTube Music Desktop App, VLC, Rhythmbox, Firefox, Chromium usw.) veröffentlichen Wiedergabedaten über **MPRIS**, eine D-Bus-Schnittstelle.
Dieses Projekt nutzt diese Daten, um deinen **„Höre gerade…“**-Status in Nextcloud Talk zu setzen – über die OCS-API.

---

## 🖥️ Voraussetzungen

* Linux-Desktop mit MPRIS-Unterstützung (GNOME, KDE, XFCE etc.)
* Nextcloud mit Talk-App
* App-Passwort für Nextcloud (bei aktivierter 2FA)
* Pakete: `valac`, `glib-2.0-dev`, `curl`
* systemd

---

## 📦 Installation

Du kannst das Projekt entweder:

### ➤ Per Git klonen

```bash
git clone https://github.com/dein-user/mpris-nextcloud-status.git
cd mpris-nextcloud-status
./install.sh
```

### ➤ Oder ZIP herunterladen

1. Oben auf der GitHub-Seite auf **Code > Download ZIP**
2. Entpacken, Terminal öffnen
3. Ausführen mit:

```bash
cd mpris-nextcloud-status-main
chmod +x install.sh
./install.sh
```

---

## ⚙️ Was passiert bei der Installation?

Das Skript `install.sh`:

1. Fragt dich nach Nextcloud-Login und Domain
2. Erstellt eine `.env`-Datei mit deinen Zugangsdaten
3. Kompiliert das Vala-Tool lokal
4. Erstellt einen `systemd --user`-Service + Timer (alle 30 Sekunden)
5. Aktiviert alles automatisch

---

## 🔁 Deinstallation

Falls du das Tool wieder entfernen möchtest:

```bash
./uninstall.sh
```

Das entfernt:

* Binary
* systemd-Timer und Service
* Config-Dateien

---

## 🛠️ Entwicklerinfo

* Sprache: [Vala](https://wiki.gnome.org/Projects/Vala)
* Schnittstellen: [MPRIS2 via D-Bus](https://specifications.freedesktop.org/mpris-spec/latest/)
* API: [Nextcloud OCS Status API](https://docs.nextcloud.com/server/latest/developer_manual/client_apis/OCS/ocs-status-api.html)

---

## 📄 Lizenz

Dieses Projekt steht unter der **GNU General Public License v2.0**
→ Siehe [LICENSE](./LICENSE) Datei im Repository

---

## ❤️ Mitmachen

Pull Requests, Feedback oder Issues sind jederzeit willkommen!
