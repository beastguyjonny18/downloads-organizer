# Downloads Organizer

An instant, automated file organizer for Linux that uses `inotify` to monitor your Downloads folder and sort files into appropriate categories as soon as they finish downloading.

## Features
- **Instant Sorting:** Moves files the moment they are written to disk.
- **Smart Detection:** Waits for downloads to fully finish (using `fuser`) before moving.
- **Conflict Resolution:** Prevents overwriting by appending timestamps to duplicate filenames.
- **Dynamic Categories:** Automatically creates folders for unknown file types (e.g., `.zip` goes to `ZIP/`).
- **Standard Integration:** Moves common media and documents to standard XDG folders (`Music`, `Videos`, etc.).
- **Minecraft Support:** Built-in sorting for `.jar` plugins to a server directory.

## Requirements
- `inotify-tools`: To monitor file system events.
- `psmisc`: For `fuser` support.
- `systemd`: For running as a background service.

## Installation

1. **Clone the repo:**
   ```bash
   git clone https://github.com/yourusername/downloads-organizer.git
   cd downloads-organizer
   ```

2. **Run the installer:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

## Usage
The script runs in the background. You can check its status or logs:
```bash
systemctl --user status downloads-organizer
tail -f ~/.downloads_organizer.log
```
