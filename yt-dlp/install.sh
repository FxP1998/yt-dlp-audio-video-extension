#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DOWNLOAD="$ROOT/bin/download"
NATIVE_HOST="$ROOT/native/linux/host"
NATIVE_INSTALLER="$ROOT/native/linux/install"

say() {
  printf '%s\n' "$*"
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

[[ "$(id -u)" -ne 0 ]] || fail "Run this installer as your normal user, not with sudo."
[[ -x "$DOWNLOAD" ]] || fail "Downloader is missing or not executable: $DOWNLOAD"
[[ -f "$NATIVE_HOST" ]] || fail "Native host is missing: $NATIVE_HOST"
[[ -f "$NATIVE_INSTALLER" ]] || fail "Native host installer is missing: $NATIVE_INSTALLER"
command -v python3 >/dev/null || fail "Python 3 is required to run the native host installer."

missing=()
command -v yt-dlp >/dev/null || missing+=("yt-dlp")
command -v ffmpeg >/dev/null || missing+=("ffmpeg")
python3 -c 'import mutagen' >/dev/null 2>&1 || missing+=("python-mutagen")

if ((${#missing[@]})); then
  if command -v pacman >/dev/null; then
    package_manager="pacman"
    packages=(yt-dlp ffmpeg python-mutagen nodejs)
    install_command=(sudo pacman -S --needed "${packages[@]}")
  elif command -v apt-get >/dev/null; then
    package_manager="apt"
    packages=(yt-dlp ffmpeg python3-mutagen nodejs)
    install_command=(sudo apt-get install -y "${packages[@]}")
  else
    fail "Missing dependencies: ${missing[*]}. Install yt-dlp, ffmpeg, mutagen, and preferably Node.js using your Linux distribution's package manager."
  fi

  say "Missing required command/package(s): ${missing[*]}"
  say "The detected package manager is $package_manager."
  if [[ "$package_manager" == "apt" ]]; then
    say "The installer will run 'sudo apt-get update' before installing packages."
  fi
  read -r -p "Install the required packages now? [y/N] " answer
  case "$answer" in
    y|Y|yes|YES)
      if [[ "$package_manager" == "apt" ]]; then
        sudo apt-get update
      fi
      "${install_command[@]}"
      ;;
    *)
      fail "Dependencies were not installed. Install them manually, then rerun ./install.sh."
      ;;
  esac
fi

command -v yt-dlp >/dev/null || fail "yt-dlp is still unavailable on PATH."
command -v ffmpeg >/dev/null || fail "ffmpeg is still unavailable on PATH."
python3 -c 'import mutagen' >/dev/null 2>&1 || fail "mutagen is unavailable to the system Python."

if ! command -v node >/dev/null; then
  say "Note: Node.js is not installed. Some YouTube videos may expose fewer formats."
fi

chmod +x "$DOWNLOAD" "$NATIVE_HOST" "$NATIVE_INSTALLER"
python3 "$NATIVE_INSTALLER"

say ""
say "Native host installed successfully."
say "Next, load the browser extensions:"
say "  Chromium: open chrome://extensions, enable Developer mode, and Load unpacked:"
say "    $ROOT/extensions/audio"
say "    $ROOT/extensions/video"
say "  Firefox: install the signed Audio and Video add-ons from AMO."
say "Restart the browser after installing/loading the extensions."
say ""
say "Keep this project at its current path. If you move it, rerun ./install.sh."
