using GLib;

void setNextcloudStatus(string title, string artist, string nc_user, string nc_pass, string nc_url) {
    string status = "🎵 Höre gerade: %s - %s".printf(artist, title);
    string data = "message=" + Uri.escape_string(status, null, false);

    try {
        string[] argv = {
            "curl", "-s", "-X", "PUT",
            "-u", "%s:%s".printf(nc_user, nc_pass),
            "-H", "OCS-APIRequest: true",
            "-d", data,
            nc_url
        };
        Process.spawn_sync(null, argv, null, SpawnFlags.SEARCH_PATH, null);
    } catch (Error e) {
        stderr.printf("Fehler beim Setzen des Status: %s\n", e.message);
    }
}

bool get_current_music(out string? title, out string? artist) {
    title = null;
    artist = null;
    
    // Alle möglichen MPRIS-Player durchprobieren
    string[] players = {
        "org.mpris.MediaPlayer2.spotify",
        "org.mpris.MediaPlayer2.vlc", 
        "org.mpris.MediaPlayer2.firefox",
        "org.mpris.MediaPlayer2.chromium",
        "org.mpris.MediaPlayer2.chrome",
        "org.mpris.MediaPlayer2.plasma-browser-integration",
        "org.mpris.MediaPlayer2.rhythmbox",
        "org.mpris.MediaPlayer2.clementine",
        "org.mpris.MediaPlayer2.brave"
    };
    
    try {
        var bus = Bus.get_sync(BusType.SESSION, null);
        
        foreach (string player in players) {
            try {
                var proxy = new DBusProxy.sync(
                    bus,
                    DBusProxyFlags.NONE,
                    null,
                    player,
                    "/org/mpris/MediaPlayer2",
                    "org.mpris.MediaPlayer2.Player"
                );
                
                Variant? metadata = proxy.get_cached_property("Metadata");
                if (metadata != null) {
                    // Titel extrahieren
                    Variant? title_var = metadata.lookup_value("xesam:title", null);
                    if (title_var != null) {
                        title = title_var.get_string();
                    }

                    // Künstler extrahieren
                    Variant? artist_var = metadata.lookup_value("xesam:artist", null);
                    if (artist_var != null && artist_var.n_children() > 0) {
                        artist = artist_var.get_child_value(0).get_string();
                    }
                    
                    // Wenn wir einen Titel haben, sind wir fertig
                    if (title != null && title.length > 0) {
                        return true;
                    }
                }
            } catch (Error e) {
                // Nächsten Player versuchen
            }
        }
    } catch (Error e) {
        stderr.printf("Fehler beim Suchen nach Musik: %s\n", e.message);
    }
    
    return false;
}

public class MprisNextcloudStatus : Object {
    public static int main(string[] args) {
        if (args.length < 4) {
            stderr.printf("Usage: %s <nc_user> <nc_pass> <nc_url>\n", args[0]);
            return 1;
        }

        string nc_user = args[1];
        string nc_pass = args[2];
        string nc_url  = args[3];

        string? title, artist;
        if (get_current_music(out title, out artist)) {
            if (artist == null || artist.length == 0) {
                artist = "Unbekannter Künstler";
            }
            
            print("🎵 %s - %s\n", artist, title);
            setNextcloudStatus(title, artist, nc_user, nc_pass, nc_url);
        } else {
            print("Keine Musik läuft gerade.\n");
        }

        return 0;
    }
}