# Benötigte Tools für das Skript:

## Arch Linux (EndeavourOS, usw.)
#sudo pacman -S ffmpeg id3v2 flac

## Fedora (Nobara, usw.)
#sudo dnf install ffmpeg id3v2 flac

## Debian (Ubuntu, Linux Mint, usw.)
#sudo apt install ffmpeg id3v2 flac

# Editor:
# Terminal: Nano oder VIM
# Desktop: Kate (oder andere)

# Info: Die Dateien müssen so benannt sein, damit das Skript funktioniert:
# 01 File Select.flac oder 01 File Select.mp3

# -----------------------------------------------------------------------------------------------

# Manuelle eintragung von Metadaten
ALBUM="Shantae: Half-Genie Hero Soundtrack"
ARTIST="Jake Kaufman"
ALBUM_ARTIST="WayForward"
DISK_NUM=1  # Hier die Nummer der Disk eintragen
YEAR=2016   # Hier das Erscheinungsjahr des Albums eintragen

# Zielordner (alle Musikdateien)
FOLDER="/home/angelo/Downloads/Shantae/"

# Prüft, ob der Ordner existiert
if [ ! -d "$FOLDER" ]; then
    echo "Fehler: Ordner '$FOLDER' existiert nicht!"
    exit 1
fi

# In den Zielordner wechseln
cd "$FOLDER" || exit

# Verarbeite alle FLAC- und MP3-Dateien
for FILE in *.flac *.mp3; do
    [[ -f "$FILE" ]] || continue  # Falls keine Musikdateien da sind, überspringen

    # Tracknummer aus dem Dateinamen extrahieren (erste Zahl vor Leerzeichen)
    TRACK_NUM=$(echo "$FILE" | grep -oP '^\d+')

    # Titel aus dem Dateinamen extrahieren (alles nach der ersten Zahl und Leerzeichen)
    TITLE=$(echo "$FILE" | sed -E 's/^[0-9]+ //; s/\.(flac|mp3)$//')

    echo "Verarbeite: $FILE -> Track: $TRACK_NUM, Titel: $TITLE"

    if [[ "$FILE" == *.flac ]]; then
        # Entferne alte Tags und setze neue Metadaten für FLAC
        metaflac --remove-all-tags "$FILE"
        metaflac --set-tag="TITLE=$TITLE" \
                 --set-tag="ARTIST=$ARTIST" \
                 --set-tag="ALBUM=$ALBUM" \
                 --set-tag="ALBUMARTIST=$ALBUM_ARTIST" \
                 --set-tag="TRACKNUMBER=$TRACK_NUM" \
                 --set-tag="DISCNUMBER=$DISK_NUM" \
                 --set-tag="DATE=$YEAR" \
                 --set-tag="YEAR=$YEAR" "$FILE"
    elif [[ "$FILE" == *.mp3 ]]; then
        # Entferne alte Tags und setze neue Metadaten für MP3
        id3v2 --delete-all "$FILE"
        id3v2 --song "$TITLE" \
              --artist "$ARTIST" \
              --album "$ALBUM" \
              --track "$TRACK_NUM" \
              --TPE2 "$ALBUM_ARTIST" \
              --TPOS "$DISK_NUM" \
              --year "$YEAR" "$FILE"
    fi
done

echo "Alle Metadaten wurden erfolgreich aktualisiert!"
