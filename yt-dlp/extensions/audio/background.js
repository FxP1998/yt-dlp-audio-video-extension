"use strict";

const api = globalThis.browser ?? globalThis.chrome;
const action = api.action ?? api.browserAction;
const hostName = "com.broken.ytdlp";
const notificationId = "yt-dlp-audio-download";
let activePort = null;
let finished = false;
let notificationQueue = Promise.resolve();

function notify(title, message) {
  const options = {
    type: "basic",
    iconUrl: api.runtime.getURL("icons/audio-128.png"),
    title,
    message,
  };
  if (globalThis.browser) {
    return api.notifications.create(notificationId, options);
  }
  return new Promise((resolve, reject) => {
    api.notifications.create(notificationId, options, (id) => {
      const error = api.runtime.lastError;
      if (error) reject(new Error(error.message));
      else resolve(id);
    });
  });
}

function show(message) {
  notificationQueue = notificationQueue
    .then(() => notify("yt-dlp Audio", message))
    .catch(() => {});
}

function finishDownload() {
  finished = true;
  const port = activePort;
  activePort = null;
  port?.disconnect();
}

action.onClicked.addListener((tab) => {
  if (!tab.url) {
    void notify("yt-dlp Audio", "Could not read the current tab URL.");
    return;
  }
  if (activePort) {
    void notify("yt-dlp Audio", "An audio download is already running.");
    return;
  }

  finished = false;
  show("Starting download...");
  try {
    activePort = api.runtime.connectNative(hostName);
    activePort.onMessage.addListener((message) => {
      if (message.status === "started") {
        show("Preparing audio download...");
      } else if (message.status === "progress") {
        show(`Downloading: ${message.percent}%`);
      } else if (message.status === "complete") {
        finishDownload();
        show("Audio download complete.");
      } else if (message.status === "error") {
        finishDownload();
        show(`Download failed: ${message.message}`);
      }
    });
    activePort.onDisconnect.addListener(() => {
      const error = api.runtime.lastError;
      activePort = null;
      if (error && !finished) {
        finished = true;
        show(`Native helper failed: ${error.message}`);
      }
    });
    activePort.postMessage({ url: tab.url });
  } catch (error) {
    activePort = null;
    finished = true;
    show(`Could not start download: ${error.message}`);
  }
});
