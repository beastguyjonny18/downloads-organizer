#!/bin/bash

# --- CONFIGURATION ---
DOWNLOADS="$HOME/Downloads"
MUSIC="$HOME/Music"
VIDEOS="$HOME/Videos"
PICTURES="$HOME/Pictures"
DOCS="$HOME/Documents"
LOG_FILE="$HOME/.downloads_organizer.log"

# --- PREPARATION ---
mkdir -p "$DOWNLOADS" "$MUSIC" "$VIDEOS" "$PICTURES" "$DOCS"
touch "$LOG_FILE"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

move_file() {
    local src="$1"
    local dest_dir="$2"
    local filename=$(basename "$src")
    local target="$dest_dir/$filename"

    # Handle name collisions
    if [[ -e "$target" ]]; then
        local timestamp=$(date +%s)
        local base="${filename%.*}"
        local ext="${filename##*.}"
        target="$dest_dir/${base}_${timestamp}.${ext}"
    fi

    if mv "$src" "$target"; then
        log_message "MOVED: $filename -> $target"
    else
        log_message "ERROR: Failed to move $filename"
    fi
}

log_message "Hourly Cleanup Started"

# Find files in Downloads root (maxdepth 1, not directories)
find "$DOWNLOADS" -maxdepth 1 -type f | while read -r FILEPATH; do
    filename=$(basename "$FILEPATH")

    # Skip hidden/temp files
    if [[ "$filename" == .* ]] || [[ "$filename" == *.part ]] || [[ "$filename" == *.crdownload ]] || [[ "$filename" == *.tmp ]]; then
        continue
    fi

    # Check if file is busy (browser still writing)
    if fuser "$FILEPATH" >/dev/null 2>&1; then
        log_message "SKIPPING: $filename is currently in use."
        continue
    fi

    # Get extension info
    EXT="${filename##*.}"
    if [[ "$filename" == "$EXT" ]]; then EXT="MISC"; fi
    EXT_FOLDER="${EXT^^}"

    case "${filename,,}" in
        *.mp3|*.wav|*.flac)
            move_file "$FILEPATH" "$MUSIC" ;;
        *.mp4|*.mkv|*.mov|*.avi)
            move_file "$FILEPATH" "$VIDEOS" ;;
        *.png|*.jpg|*.jpeg|*.gif|*.webp)
            move_file "$FILEPATH" "$PICTURES" ;;
        *.pdf|*.html|*.txt|*.docx|*.xlsx)
            move_file "$FILEPATH" "$DOCS" ;;
        *)
            # Create extension folder in Downloads
            TARGET_DIR="$DOWNLOADS/$EXT_FOLDER"
            mkdir -p "$TARGET_DIR"
            move_file "$FILEPATH" "$TARGET_DIR" ;;
    esac
done

# Cleanup empty folders in Downloads
find "$DOWNLOADS" -maxdepth 1 -type d -empty -delete

log_message "Hourly Cleanup Finished"
