#!/bin/bash

# --- CONFIGURATION ---
DOWNLOADS="$HOME/Downloads"
MUSIC="$HOME/Music"
VIDEOS="$HOME/Videos"
PICTURES="$HOME/Pictures"
DOCS="$HOME/Documents"
MINECRAFT_PLUGINS="$HOME/Documents/Minecraft_Server/plugins"
LOG_FILE="$HOME/.downloads_organizer.log"

# --- PREPARATION ---
mkdir -p "$DOWNLOADS" "$MUSIC" "$VIDEOS" "$PICTURES" "$DOCS" "$MINECRAFT_PLUGINS"
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

# --- MONITORING ---
log_message "Service Started: Watching $DOWNLOADS"

# Monitor for finished writes and moved files
inotifywait -m "$DOWNLOADS" -e close_write -e moved_to |
    while read -r directory events filename; do
        # Skip hidden/temp files
        if [[ "$filename" == .* ]] || [[ "$filename" == *.part ]] || [[ "$filename" == *.crdownload ]] || [[ "$filename" == *.tmp ]]; then
            continue
        fi

        FILEPATH="$DOWNLOADS/$filename"
        
        # Check if file still exists (might have been moved/deleted already)
        [ ! -f "$FILEPATH" ] && continue

        # --- BUG FIX: Wait until file is no longer being written to ---
        # We wait until 'fuser' returns non-zero (meaning no process has the file open)
        MAX_RETRIES=30
        RETRY_COUNT=0
        while fuser "$FILEPATH" >/dev/null 2>&1; do
            if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
                log_message "TIMEOUT: $filename is still busy, skipping for now."
                continue 2
            fi
            sleep 2
            ((RETRY_COUNT++))
        done

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
            *.jar)
                move_file "$FILEPATH" "$MINECRAFT_PLUGINS" ;;
            *)
                # Create extension folder in Downloads
                TARGET_DIR="$DOWNLOADS/$EXT_FOLDER"
                mkdir -p "$TARGET_DIR"
                move_file "$FILEPATH" "$TARGET_DIR"
                
                # BUG FIX: Cleanup empty folders in Downloads every 10 moves
                ((CLEANUP_COUNTER++))
                if [ $((CLEANUP_COUNTER % 10)) -eq 0 ]; then
                    find "$DOWNLOADS" -maxdepth 1 -type d -empty -delete
                fi
                ;;
        esac
    done
