# Downloads Organizer

An automated file organizer for Linux that runs every hour to monitor your Downloads folder and sort files into appropriate categories.

## Features
- **Hourly Sorting:** Runs automatically every hour via a systemd timer.
- **Smart Detection:** Skips files that are currently in use (using `fuser`).
- **Conflict Resolution:** Prevents overwriting by appending timestamps to duplicate filenames.
- **Dynamic Categories:** Automatically creates folders for unknown file types (e.g., `.zip` goes to `ZIP/`).
- **Standard Integration:** Moves common media and documents to standard XDG folders (`Music`, `Videos`, etc.).

## Requirements
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
The script runs every hour. You can check the timer status or logs:
```bash
systemctl --user list-timers downloads-organizer.timer
tail -f ~/.downloads_organizer.log
```
