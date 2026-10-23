<div align="center">

# 🎬 yt-dlp Audio & Video Downloader

### One click. Best available audio. Video up to 1440p. Progress you can see.

Download YouTube audio or video from Firefox and Chromium with two lightweight
browser extensions powered by [yt-dlp](https://github.com/yt-dlp/yt-dlp).

[**View repository**](https://github.com/FxP1998/yt-dlp-audio-video-extension)
· [**Installation guide**](yt-dlp/README.md)
· [**MIT License**](LICENSE)

</div>

---

## ✨ What it does

Choose the **Audio** or **Video** button in your browser toolbar while viewing
a YouTube video. The extension starts the download locally and shows progress
and completion in browser notifications.

| 🎵 Audio | 🎥 Video |
| --- | --- |
| Selects the best available audio stream | Selects the best available video up to **1440p** |
| Saves as `.opus` with metadata | Merges the selected video and best available audio |
| Embeds the video's thumbnail | Falls back to the best available resolution below 1440p |
| Saves in `~/Downloads/yt-dlp/Audio/` | Saves in `~/Downloads/yt-dlp/Videos/` |

> **Privacy by design:** the extensions talk to a local Native Messaging helper.
> yt-dlp and FFmpeg run on your computer; this project has no download server.

## 🧭 How it works

```text
YouTube tab
    │
    ├── 🎵 Audio button
    └── 🎥 Video button
            │
            ▼
    Browser extension
            │ Native Messaging
            ▼
    Local helper → yt-dlp + FFmpeg → Downloads folder
            │
            └── progress → browser notification
```

The native helper only accepts HTTPS YouTube URLs from the configured
extension IDs. Downloaded media stays on your computer.

## 📦 Repository map

```text
yt-dlp-audio-video-extension/
├── LICENSE
├── README.md                    # This overview and quick-start guide
└── yt-dlp/
    ├── README.md                # Full setup, troubleshooting, and maintenance
    ├── install.sh               # Linux dependency checks and setup
    ├── bin/download             # Command-line downloader
    ├── extensions/
    │   ├── audio/               # Audio browser extension
    │   └── video/               # Video browser extension
    ├── native/linux/
    │   ├── host                 # Browser-to-downloader bridge
    │   └── install              # Native host registration
    ├── packages/amo-upload/     # ZIPs submitted to AMO
    └── tools/package-extensions # Rebuild AMO submission ZIPs
```

## 🚀 Quick start

### 1. Clone the repository

```bash
git clone https://github.com/FxP1998/yt-dlp-audio-video-extension.git
cd yt-dlp-audio-video-extension/yt-dlp
```

### 2. Install the Linux prerequisites

The installer checks required tools and asks before installing missing
packages on Arch Linux or Debian/Ubuntu.

```bash
./install.sh
```

Run it as your regular user—**do not use `sudo ./install.sh`**. It registers
the local native host for Firefox, Chromium, and Google Chrome. Keep the
repository in a permanent location; moving it requires running the installer
again.

#### Install packages manually (optional)

**Arch Linux**

```bash
sudo pacman -Syu
sudo pacman -S yt-dlp ffmpeg python-mutagen nodejs
```

**Debian / Ubuntu**

```bash
sudo apt update
sudo apt install yt-dlp ffmpeg python3-mutagen nodejs
```

### 3. Load the browser extensions

#### Chromium / Google Chrome

1. Open `chrome://extensions`.
2. Enable **Developer mode**.
3. Click **Load unpacked** and select both folders:

   ```text
   yt-dlp/extensions/audio
   yt-dlp/extensions/video
   ```

4. Pin both toolbar icons and restart the browser.

Unpacked loading is intended for personal/development use. If you update the
extension source, click **Reload** for each extension at `chrome://extensions`.

#### Firefox

Install the signed **Audio** and **Video** add-ons from AMO, or install the
signed `.xpi` files using `about:addons` → ⚙ → **Install Add-on From File…**.
Then pin the toolbar icons and restart Firefox.

`packages/amo-upload/*.zip` are **AMO submission archives**, not signed
Firefox add-ons. Temporary add-ons loaded through `about:debugging` are only
for testing and disappear when Firefox closes. The full guide covers optional
Firefox startup installation using a policy and signed XPI files.

### 4. Download

Open a YouTube video and click the pinned **Audio** or **Video** icon.
Notifications show preparation, download percentage, and completion or error.

```text
~/Downloads/yt-dlp/
├── Audio/
└── Videos/
```

## 💻 Terminal usage

From the `yt-dlp/` directory:

```bash
./bin/download audio 'https://www.youtube.com/watch?v=VIDEO_ID'
./bin/download video 'https://youtu.be/VIDEO_ID'
```

Quote URLs that contain `?` or `&`; unquoted characters may be interpreted by
your shell.

Check format selection without downloading:

```bash
./bin/download audio --simulate 'https://youtu.be/VIDEO_ID'
./bin/download video --simulate 'https://youtu.be/VIDEO_ID'
```

Use browser cookies for videos that require a signed-in session:

```bash
./bin/download video --browser firefox 'https://www.youtube.com/watch?v=VIDEO_ID'
./bin/download audio --browser chromium 'https://www.youtube.com/watch?v=VIDEO_ID'
```

Use `--profile PROFILE` with `--browser` to select a browser profile. Use
`--output-dir PATH` to choose another download root.

## 🧰 Requirements

- **Linux** for the included native host installer (Python 3 required).
- **yt-dlp** — extracts the media streams.
- **FFmpeg / ffprobe** — extracts audio and merges video/audio.
- **Mutagen** — embeds audio thumbnail artwork.
- **Node.js** — recommended for YouTube JavaScript challenge handling.
- **Firefox 136+**, Chromium, or Google Chrome.

The installer checks `yt-dlp`, `ffmpeg`, and Python `mutagen`. Node.js is
optional but recommended. If yt-dlp uses an isolated Python environment,
Mutagen must be available to that same environment.

## 🔧 Maintenance

After changing extension code or manifests, rebuild the AMO submission ZIPs:

```bash
cd yt-dlp
./tools/package-extensions
```

Upload the generated archives in `packages/amo-upload/` as new AMO versions.
Install the **signed XPI** from AMO in Firefox. For Chromium, reload the
unpacked extension folders.

Moved the repository? Re-register the native host:

```bash
cd yt-dlp
./install.sh
```

For detailed setup on another Linux system, Firefox policy configuration,
browser profile options, troubleshooting, and uninstall instructions, see
[`yt-dlp/README.md`](yt-dlp/README.md).

## ⚠️ Troubleshooting at a glance

| Message / issue | First thing to check |
| --- | --- |
| “This extension is not allowed” | Run `./install.sh`, confirm the intended extension IDs, then restart the browser. |
| Native Messaging host not found | Re-run the installer and confirm the browser's native-host manifest exists. |
| Audio thumbnail/post-processing failure | Check `ffmpeg -version` and `python3 -c 'import mutagen'`. |
| Missing formats or YouTube extraction error | Update yt-dlp; install Node.js if it is missing. |
| No progress notifications | Allow notifications for your browser in desktop settings. |

See the [full troubleshooting guide](yt-dlp/README.md#troubleshooting) for
details.

## 🔐 Responsible use

Use this downloader only for content you are authorized to download and in
accordance with applicable service terms and local law. This project does not
grant rights to content hosted by YouTube or any other service.

## 📄 License

Released under the [MIT License](LICENSE).
