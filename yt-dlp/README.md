# yt-dlp one-click browser downloaders

Two browser extensions send the current YouTube tab to a local `yt-dlp` native
host. The Audio extension downloads the best available audio as Opus and embeds
the thumbnail. The Video extension downloads the best available video at or
below 1440p. Both show progress and completion in browser notifications.

This project currently includes a **Linux native host installer** and browser
extension sources for Firefox and Chromium-based browsers. It is not a
cross-platform native-host installer: Windows and macOS need their own native
host registration and setup.

## Project layout

```text
yt-dlp/
├── README.md
├── install.sh                    # Checks dependencies and registers native host
├── bin/
│   └── download                  # CLI downloader
├── extensions/
│   ├── audio/                    # Audio extension source
│   └── video/                    # Video extension source
├── native/
│   └── linux/
│       ├── host                  # Native Messaging host
│       └── install               # Registers the native host for browsers
├── packages/
│   └── amo-upload/               # ZIPs prepared for AMO submissions
└── tools/
    └── package-extensions        # Rebuilds the AMO upload ZIPs
```

Keep this whole directory in a permanent location. The native host manifest
contains its absolute path; if you move the project later, run the installer
again.

## Requirements

- Linux with Python 3.
- `yt-dlp` available on `PATH`.
- `ffmpeg` available on `PATH` (also provides `ffprobe`).
- Python package `mutagen`, available to the Python installation used for
  `yt-dlp`; it is needed to embed the audio thumbnail.
- Node.js is recommended for yt-dlp's YouTube JavaScript challenge support.
- Firefox 136 or newer, or Chromium.

Install dependencies using your distribution's packages. For example:

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

If the distribution's `yt-dlp` package is missing or too old, install a current
version using your distribution's recommended method, and make sure the
`yt-dlp` command resolves on `PATH`. The downloader needs `mutagen` in the same
Python environment as yt-dlp; an isolated yt-dlp install may need mutagen
installed into that same environment.

Check the prerequisites:

```sh
python3 --version
yt-dlp --version
ffmpeg -version
node --version
python3 -c 'import mutagen; print(mutagen.version_string)'
```

The last command must succeed for audio downloads with an embedded thumbnail.

## Install on another Linux system

1. Copy the complete `yt-dlp` project directory to a permanent location, such
   as `~/Applications/yt-dlp`. Do not copy only the extensions: the native host
   launches `bin/download`.
2. Run the installer:

   ```sh
   cd ~/Applications/yt-dlp
   ./install.sh
   ```

   It checks for `yt-dlp`, `ffmpeg`, and `mutagen`. If required packages are
   missing on Arch Linux or Debian/Ubuntu, it asks before installing them with
   the system package manager. It then creates per-user native-messaging
   manifests for Firefox, Chromium, and Google Chrome. The script itself must
   be run as your normal user, not with `sudo`.

3. Install the extensions in the browser:

   **Firefox:** Install the signed Audio and Video add-ons from their AMO
   pages, or install their signed `.xpi` files through `about:addons` → gear
   menu → **Install Add-on From File…**. The unsigned source folders in this
   project are for development and cannot be permanently installed in normal
   Firefox. AMO signing and publication are separate from installing the
   native host.

   **Chromium / Google Chrome:** Open `chrome://extensions`, enable
   **Developer mode**, choose **Load unpacked**, and select each folder:

   ```text
   ~/Applications/yt-dlp/extensions/audio
   ~/Applications/yt-dlp/extensions/video
   ```

   Loading unpacked is the development/personal-install method. Keep the
   project at the same path so the native-host registration remains valid.

5. Restart the browser, pin the two toolbar icons, open a YouTube video, and
   click **yt-dlp Audio** or **yt-dlp Video**. A notification reports
   preparation, download percentage, and success/failure.

Firefox's temporary **Load Temporary Add-on** option is only for testing and
the extension disappears when Firefox closes. For automatic installation at
startup, install a signed XPI through AMO or configure Firefox enterprise
policies (`ExtensionSettings`) to install that signed XPI. A raw manifest or
unpacked extension cannot be made permanent by a startup script in normal
Firefox.

### Optional: install signed Firefox XPIs at startup with policy

This is for a locally managed Linux Firefox installation. First download the
signed Audio and Video `.xpi` files from AMO and put them in a stable readable
location. Then create `/etc/firefox/policies/policies.json` (replace
`YOUR_USER` and the two XPI paths with your real absolute paths):

```sh
sudo install -d -m 755 /etc/firefox/policies
sudo tee /etc/firefox/policies/policies.json >/dev/null <<'JSON'
{
  "policies": {
    "ExtensionSettings": {
      "yt-dlp-audio@broken.local": {
        "installation_mode": "normal_installed",
        "install_url": "file:///home/YOUR_USER/Applications/yt-dlp/packages/yt-dlp-audio.xpi"
      },
      "yt-dlp-video@broken.local": {
        "installation_mode": "normal_installed",
        "install_url": "file:///home/YOUR_USER/Applications/yt-dlp/packages/yt-dlp-video.xpi"
      }
    }
  }
}
JSON
```

Restart Firefox and visit `about:policies` to confirm the policy loaded. The
IDs in this example must match the signed add-ons. Keep the XPI files at those
paths; Firefox reads them when applying the policy. This policy is optional:
installing the signed add-ons from AMO normally is simpler and allows AMO to
handle updates.

## Command-line use

Quote URLs that contain `?` or `&` so the shell does not treat them as glob or
background-job syntax:

```sh
./bin/download audio 'https://www.youtube.com/watch?v=VIDEO_ID'
./bin/download video 'https://youtu.be/VIDEO_ID'
```

Files go to:

```text
~/Downloads/yt-dlp/Audio/
~/Downloads/yt-dlp/Videos/
```

Use browser cookies for videos that require an authenticated session:

```sh
./bin/download video --browser firefox 'https://www.youtube.com/watch?v=VIDEO_ID'
./bin/download audio --browser chromium 'https://www.youtube.com/watch?v=VIDEO_ID'
```

`--profile PROFILE` can select a named browser profile when using `--browser`.
`--simulate` checks extraction and format selection without downloading media.

## Quality and format behavior

- **Audio:** selects yt-dlp's best available audio stream, extracts Opus at
  best quality without re-encoding when the source is already Opus, embeds
  metadata and the thumbnail. Files use the `.opus` extension.
- **Video:** selects the best available video stream with height at most
  1440p and the best audio stream, then merges them. If the source is below
  1440p, it downloads the best available lower resolution.
- Output is separated by mode so audio and video with the same title do not
  overwrite each other.

## Updating and packaging

After changing extension source code, rebuild the AMO submission archives:

```sh
./tools/package-extensions
```

Upload the resulting files from `packages/amo-upload/` as new AMO versions.
These ZIPs are **submission packages**, not the signed Firefox add-ons. Install
the signed `.xpi` supplied by AMO in Firefox. Chromium loads the unpacked
extension source folders above.

After moving this project or changing extension IDs, re-register the native
host by running `python3 native/linux/install`. If an ID changes, update the
allow-lists in `native/linux/install` and `native/linux/host`, rebuild the
packages, and submit/sign the changed Firefox versions.

## Troubleshooting

- **“This extension is not allowed”**: the running browser extension ID is
  absent from the native host allow-list. Install the Audio/Video builds from
  this project/AMO and rerun `python3 native/linux/install`.
- **“Specified native messaging host not found”**: check that the native host
  manifest exists under `~/.mozilla/native-messaging-hosts/` or the browser's
  `NativeMessagingHosts/` directory; rerun the installer and restart the
  browser.
- **“Native helper failed”**: confirm `native/linux/host` and `bin/download`
  are executable, and that `yt-dlp` and `ffmpeg` resolve on `PATH`.
- **Audio thumbnail/post-processing failure**: install `mutagen` into the
  Python environment used by yt-dlp, then retry the download.
- **YouTube extraction reports missing formats or a JavaScript challenge**:
  install Node.js and update yt-dlp using the method used to install it.
- **Progress notifications are missing**: allow browser/desktop notifications
  for the browser in system settings.
- **Moved the project**: rerun the native-host installer from its new location
  and restart the browser.

## Uninstall

Remove the registered native host manifests:

```sh
rm -f ~/.mozilla/native-messaging-hosts/com.broken.ytdlp.json
rm -f ~/.config/chromium/NativeMessagingHosts/com.broken.ytdlp.json
rm -f ~/.config/google-chrome/NativeMessagingHosts/com.broken.ytdlp.json
```

Then remove the two extensions through the browser's extension manager. This
does not remove downloaded media or system packages.

## Privacy and usage

The native host only accepts HTTPS YouTube URLs and only from the extension
IDs in its allow-list. Downloads run locally using the installed yt-dlp; the
extensions do not upload the video URL to a project server. Use the downloader
only for content you are authorized to download and in accordance with the
applicable service terms and local law.
