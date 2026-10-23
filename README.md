# yt-dlp Audio & Video Browser Downloader

One-click YouTube audio and video downloads from Firefox and Chromium, powered
by [yt-dlp](https://github.com/yt-dlp/yt-dlp). Choose the Audio or Video
toolbar button, then follow download progress in browser notifications.

## Features

- **Audio:** best available audio, saved as Opus with metadata and an embedded
  thumbnail.
- **Video:** best available video up to **1440p**, merged with the best
  available audio.
- Separate Audio and Video extensions, output folders, and progress
  notifications.
- Command-line downloader for use without a browser extension.
- Linux installer for dependencies and native-messaging host registration.

## Repository contents

```text
.
├── LICENSE
├── README.md
└── yt-dlp/
    ├── bin/                 # Downloader command
    ├── extensions/          # Audio and Video browser extensions
    ├── native/linux/        # Native-messaging host and registration helper
    ├── packages/amo-upload/ # ZIP packages for AMO submission
    ├── tools/               # Extension packaging helper
    ├── install.sh           # Linux setup installer
    └── README.md            # Full setup, usage, and troubleshooting guide
```

## Quick start on Linux

1. Clone or download this repository and keep the entire `yt-dlp/` directory
   in a permanent location. The native host registration uses its absolute
   path.
2. Open a terminal in `yt-dlp/` and run:

   ```sh
   ./install.sh
   ```

   The installer checks for required packages, asks before installing missing
   dependencies on supported distributions, and registers the native host for
   Firefox, Chromium, and Google Chrome.
3. Install the browser extensions:
   - **Chromium / Chrome:** open `chrome://extensions`, enable **Developer
     mode**, select **Load unpacked**, and choose `yt-dlp/extensions/audio`
     and `yt-dlp/extensions/video`.
   - **Firefox:** install the signed add-ons from AMO or use their signed XPI
     files. Temporary add-ons are only for development and do not persist
     across browser restarts.
4. Restart the browser, pin the extension icons, open a YouTube video, and
   click **yt-dlp Audio** or **yt-dlp Video**.

Downloads are saved under `~/Downloads/yt-dlp/Audio/` and
`~/Downloads/yt-dlp/Videos/`.

## Requirements

- Linux, Python 3, `yt-dlp`, and `ffmpeg`.
- Python `mutagen` package for embedding audio thumbnails.
- Node.js is recommended for YouTube format extraction.
- Firefox 136+ or a Chromium-based browser.

The installer handles dependency checks and setup on supported Linux
distributions. See [`yt-dlp/README.md`](yt-dlp/README.md) for package-manager
commands, manual downloads, browser profiles, Firefox policy installation,
troubleshooting, updates, and uninstall instructions.

## Command-line downloads

From inside the `yt-dlp/` directory:

```sh
./bin/download audio 'https://www.youtube.com/watch?v=VIDEO_ID'
./bin/download video 'https://youtu.be/VIDEO_ID'
```

Quote URLs containing `?` or `&` so your shell does not interpret them.

## License

This project is distributed under the [MIT License](LICENSE).
