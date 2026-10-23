# yt-dlp Audio & Video Browser Downloader

Detailed setup and operations guide for
[`FxP1998/yt-dlp-audio-video-extension`](https://github.com/FxP1998/yt-dlp-audio-video-extension).
For the project overview and quick start, see the [repository root
README](../README.md).

## Contents

- [Overview and architecture](#overview-and-architecture)
- [Project files](#project-files)
- [Requirements and packages](#requirements-and-packages)
- [Install on Linux](#install-on-linux)
- [Install extensions in browsers](#install-extensions-in-browsers)
- [Download media](#download-media)
- [Quality and output behavior](#quality-and-output-behavior)
- [Updates and packaging](#updates-and-packaging)
- [Troubleshooting](#troubleshooting)
- [Uninstall](#uninstall)
- [Privacy and responsible use](#privacy-and-responsible-use)

## Overview and architecture

The project provides two browser extensions: **yt-dlp Audio** and **yt-dlp
Video**. Click an extension's toolbar icon on an active YouTube video page to
start a download. Progress and completion are shown using browser
notifications.

```text
YouTube tab
    -> Audio or Video extension
    -> Browser Native Messaging API
    -> native/linux/host
    -> bin/download
    -> yt-dlp + FFmpeg
    -> ~/Downloads/yt-dlp/Audio or Videos
```

The native host validates requests and accepts HTTPS YouTube URLs only from
the configured extension IDs. The host starts the downloader locally and
relays progress events back to the extension. This project does not provide a
remote download service.

The included native-host installer supports **Linux**. Windows and macOS
require their own native-host installation and registration; this repository
does not currently include installers for those systems.

## Project files

```text
yt-dlp/
├── README.md
├── install.sh                    # Linux dependency checks and setup
├── bin/
│   └── download                  # CLI downloader used by the host
├── extensions/
│   ├── audio/                    # Audio extension source
│   └── video/                    # Video extension source
├── native/
│   └── linux/
│       ├── host                  # Native Messaging bridge
│       └── install               # Registers the bridge with browsers
├── packages/
│   └── amo-upload/               # ZIP archives submitted to AMO
└── tools/
    └── package-extensions        # Rebuilds the AMO submission archives
```

Keep the whole project at a permanent path. The browser's native-host
registration stores an absolute path to `native/linux/host`; the host locates
`bin/download` relative to itself. Moving the project requires rerunning
`./install.sh`.

## Requirements and packages

Required:

- Linux and Python 3.
- `yt-dlp` available on `PATH`.
- `ffmpeg` and `ffprobe` available on `PATH`.
- Python package `mutagen`, importable by the Python environment used by
  yt-dlp. Mutagen is needed to embed thumbnail artwork in audio.
- Firefox 136 or newer, Chromium, or Google Chrome.

Recommended:

- Node.js, for YouTube JavaScript challenge support and access to available
  formats.

Verify the tools:

```sh
python3 --version
yt-dlp --version
ffmpeg -version
ffprobe -version
node --version
python3 -c 'import mutagen; print(mutagen.version_string)'
```

Node.js is optional, but without a supported JavaScript runtime YouTube may
return fewer formats or extraction may fail. The other dependencies are
needed for the corresponding download and post-processing features.

### Arch Linux

```sh
sudo pacman -Syu
sudo pacman -S yt-dlp ffmpeg python-mutagen nodejs
```

### Debian or Ubuntu

```sh
sudo apt update
sudo apt install yt-dlp ffmpeg python3-mutagen nodejs
```

On another distribution, install equivalent packages using its package
manager. If the repository's yt-dlp package is outdated, update yt-dlp using
the same installation method you originally used.

**Python environment note:** Mutagen must be importable in the Python
environment that runs yt-dlp. If yt-dlp is installed in an isolated
environment, install Mutagen into that environment rather than relying on a
different system Python.

## Install on Linux

### Clone the repository

Clone the repository using HTTPS:

```sh
mkdir -p ~/Applications
cd ~/Applications
git clone https://github.com/FxP1998/yt-dlp-audio-video-extension.git
cd yt-dlp-audio-video-extension/yt-dlp
```

If using the GitHub **Download ZIP** option, extract the repository and open
a terminal in its `yt-dlp/` directory.

### Run the installer

```sh
./install.sh
```

Run the script as your regular user—**do not use `sudo ./install.sh`**. It:

1. Checks that the downloader and native-host helper files are present.
2. Checks for `yt-dlp`, `ffmpeg`, and Python `mutagen`.
3. Detects Arch Linux or Debian/Ubuntu if dependencies are missing.
4. Asks for confirmation before installing packages through the system
   package manager; package installation may request your password via `sudo`.
5. Marks the helper scripts executable.
6. Registers the native host for Firefox, Chromium, and Google Chrome.
7. Prints the extension folders and browser setup instructions.

The installer is safe to run again; it rewrites the same per-user host
registrations. Node.js is recommended but optional. If it is absent, the
installer displays a notice.

If you install all prerequisites manually or use a distribution the installer
does not detect, register the host manually:

```sh
chmod +x bin/download native/linux/host native/linux/install
python3 native/linux/install
```

The installer creates these per-user registration files:

```text
~/.mozilla/native-messaging-hosts/com.broken.ytdlp.json
~/.config/chromium/NativeMessagingHosts/com.broken.ytdlp.json
~/.config/google-chrome/NativeMessagingHosts/com.broken.ytdlp.json
```

They point to the absolute path of `native/linux/host`. Do not move or rename
the project after registration without running `./install.sh` again.

## Install extensions in browsers

### Chromium and Google Chrome

The included Chromium extension source can be loaded unpacked for personal
use:

1. Open `chrome://extensions`.
2. Turn on **Developer mode**.
3. Choose **Load unpacked**.
4. Select `extensions/audio/`.
5. Repeat **Load unpacked** and select `extensions/video/`.
6. Pin the Audio and Video icons from the extensions menu.
7. Restart the browser after registering the native host.

After changing extension code, return to `chrome://extensions` and click
**Reload** for each extension. Google Chrome and Chromium use separate
Native Messaging directories; `./install.sh` registers both.

### Firefox

Install each signed add-on from its AMO page, or use the signed `.xpi` files
downloaded from AMO:

1. Open `about:addons`.
2. Open the gear menu and choose **Install Add-on From File…**.
3. Select the signed Audio `.xpi`.
4. Repeat for the signed Video `.xpi`.
5. Pin both extensions and restart Firefox.

The `extensions/audio/` and `extensions/video/` folders are source code, not
signed Firefox installers. Loading them through `about:debugging` is temporary;
they disappear when Firefox closes. The files under `packages/amo-upload/`
are ZIP submission archives for AMO and **are not signed `.xpi` files**.

The Firefox extension IDs must match the `allowed_extensions` entries in the
native-host manifest:

```text
yt-dlp-audio@broken.local
yt-dlp-video@broken.local
```

If a signed extension has a different ID, update the Firefox allow-list in
`native/linux/install`, register the host again, and ensure the add-on's
manifest ID matches the signed extension.

### Optional: automatic Firefox installation with policy

For a locally managed Linux Firefox installation, the Firefox
`ExtensionSettings` policy can install signed XPIs at startup. Installing
the add-ons from AMO normally is simpler and handles updates through AMO.

First download both signed `.xpi` files from AMO and place them in stable,
readable locations. Then create `/etc/firefox/policies/policies.json`.
Replace `YOUR_USER` and the file paths below with the actual home-directory
name and paths:

```sh
sudo install -d -m 755 /etc/firefox/policies
sudo tee /etc/firefox/policies/policies.json >/dev/null <<'JSON'
{
  "policies": {
    "ExtensionSettings": {
      "yt-dlp-audio@broken.local": {
        "installation_mode": "normal_installed",
        "install_url": "file:///home/YOUR_USER/Applications/yt-dlp-audio.xpi"
      },
      "yt-dlp-video@broken.local": {
        "installation_mode": "normal_installed",
        "install_url": "file:///home/YOUR_USER/Applications/yt-dlp-video.xpi"
      }
    }
  }
}
JSON
```

Restart Firefox and visit `about:policies` to confirm the policy loaded.
Use the exact IDs and absolute file URLs of your signed add-ons, and keep the
XPI files at those paths. Firefox policy locations can vary by Linux
distribution.

## Download media

### One-click browser downloads

1. Open a YouTube video page (not a playlist or unrelated website).
2. Click the pinned **yt-dlp Audio** or **yt-dlp Video** icon.
3. Follow browser notifications for preparation, download percentage, and
   completion or errors.

Audio and Video have independent download connections. Files go to:

```text
~/Downloads/yt-dlp/Audio/
~/Downloads/yt-dlp/Videos/
```

### Command-line downloads

Run commands from this `yt-dlp/` directory:

```sh
./bin/download audio 'https://www.youtube.com/watch?v=VIDEO_ID'
./bin/download video 'https://youtu.be/VIDEO_ID'
```

Quote URLs that contain `?` or `&`; zsh and other shells may interpret those
characters as patterns or background-job operators.

The destination directories are created automatically. To use another output
root:

```sh
./bin/download video --output-dir ~/Media 'https://youtu.be/VIDEO_ID'
```

This writes video files under `~/Media/Videos/`.

### Simulate format selection

Check which format yt-dlp selects without downloading media:

```sh
./bin/download audio --simulate 'https://youtu.be/VIDEO_ID'
./bin/download video --simulate 'https://youtu.be/VIDEO_ID'
```

Simulation verifies extraction and format choice, but does not verify
post-processing or thumbnail embedding.

### Use browser cookies

For videos requiring an authenticated session, yt-dlp can read cookies from
Firefox or Chromium:

```sh
./bin/download audio --browser firefox 'https://www.youtube.com/watch?v=VIDEO_ID'
./bin/download video --browser chromium 'https://www.youtube.com/watch?v=VIDEO_ID'
```

To choose a browser profile:

```sh
./bin/download video --browser chromium --profile Default 'https://youtu.be/VIDEO_ID'
```

`--profile` requires `--browser`. If cookie access fails while the browser is
open, close the browser and retry. Some encrypted browser profiles may require
additional OS configuration.

## Quality and output behavior

### Audio

- Selects yt-dlp's best available audio-only format.
- Extracts `.opus` audio using FFmpeg and best conversion quality.
- When the selected source is already Opus, yt-dlp can generally copy the
  encoded audio rather than re-encode it. Converting another codec to Opus is
  lossy.
- Embeds metadata and the video's thumbnail. This requires Mutagen and FFmpeg.

### Video

- Selects the best video stream with a height of at most **1440 pixels** and
  the best available audio stream.
- If 1440p is unavailable, selects the best available lower resolution.
- Merges separate audio/video streams with FFmpeg. The final container and
  filename extension depend on the selected streams.
- Does not request thumbnail embedding in video files.

Audio and video are stored in separate folders, so downloading both for the
same video does not overwrite one with the other.

## Update and package extensions

After changing files in `extensions/audio/` or `extensions/video/`, rebuild
the AMO submission ZIPs:

```sh
./tools/package-extensions
```

Generated archives:

```text
packages/amo-upload/yt-dlp-audio-upload.zip
packages/amo-upload/yt-dlp-video-upload.zip
```

Upload these ZIPs as new versions in AMO. After signing/approval, download
the signed `.xpi` files for Firefox. For Chromium, reload the unpacked
extensions from `chrome://extensions`.

If the project directory moves, rerun:

```sh
./install.sh
```

If an extension ID changes, update its manifest and the allow-lists in
`native/linux/install` and `native/linux/host`, then rerun the installer,
rebuild the ZIPs, and reload/re-submit the affected extension. The Chromium
`key` fields in the extension manifests establish stable Chromium IDs; do
not casually remove or replace them.

## Troubleshooting

### “This extension is not allowed”

The native host did not recognize the caller's extension ID. Confirm that the
intended Audio/Video add-on is installed, rerun `./install.sh`, and restart
the browser. Do not change the extension IDs or Chromium manifest keys unless
you also update the host allow-lists.

### “Specified native messaging host not found”

Check the registration for the browser you are using:

```sh
ls -l ~/.mozilla/native-messaging-hosts/com.broken.ytdlp.json
ls -l ~/.config/chromium/NativeMessagingHosts/com.broken.ytdlp.json
ls -l ~/.config/google-chrome/NativeMessagingHosts/com.broken.ytdlp.json
```

Run `./install.sh` again and restart the browser. If you moved the repository,
make sure you ran the installer from its new location.

### Native helper does not start

Verify executable permissions and dependencies:

```sh
ls -l bin/download native/linux/host native/linux/install
command -v yt-dlp
command -v ffmpeg
command -v ffprobe
python3 -c 'import mutagen'
```

### Audio thumbnail or post-processing failed

Check FFmpeg and Mutagen:

```sh
ffmpeg -version
python3 -c 'import mutagen; print(mutagen.version_string)'
```

On Arch, install Mutagen with `sudo pacman -S python-mutagen`; on Debian or
Ubuntu use `sudo apt install python3-mutagen`. If yt-dlp uses an isolated
Python environment, install Mutagen in that same environment.

### YouTube formats are missing or extraction fails

Update yt-dlp and install Node.js. This downloader automatically selects Node
when available. Use `--simulate` to see which formats yt-dlp currently
selects.

### Progress notifications do not appear

Allow desktop notifications for Firefox or Chromium in your operating
system's notification settings.

### A download seems stuck

Wait for its completion or failure notification. If needed, close and restart
the browser before retrying. Audio and Video downloads are independent.

## Uninstall

Remove the per-user native-host manifests:

```sh
rm -f ~/.mozilla/native-messaging-hosts/com.broken.ytdlp.json
rm -f ~/.config/chromium/NativeMessagingHosts/com.broken.ytdlp.json
rm -f ~/.config/google-chrome/NativeMessagingHosts/com.broken.ytdlp.json
```

Then remove both extensions using the browser's extension manager. This does
not remove downloaded media, the project directory, or system packages.

## Privacy and responsible use

The host accepts HTTPS YouTube URLs only and only from the configured
extension IDs. The browser extensions do not upload URLs to a project server;
yt-dlp and FFmpeg run locally. Browser cookies are read only when explicitly
requested with the command-line `--browser` option.

Use this software only for content you are authorized to download and in
accordance with applicable service terms and local law. The project does not
grant rights to content hosted by YouTube or other services.
