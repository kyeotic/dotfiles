/// <reference lib="./phoenix.d.ts" />

// inspect logs with
// > log stream --process Phoenix

require("./config.js");
require("./debug.js");

const configApps = Object.keys(config);

Event.on("screensDidChange", useStandardLayout);

const zoomEvents = ["spaceDidChange", "windowDidOpen", "windowDidMove"];
zoomEvents.forEach((e) => Event.on(e, useZoomLayout));

Key.on("l", ["alt", "cmd"], useStandardLayout);
Key.on(";", ["alt", "cmd"], inspectWindow);
// Key.on("'", ["alt", "cmd"], inspectApp);

Key.on("k", ["alt", "cmd"], () => {
  Phoenix.log("storing");
  Storage.set("test", { thing: "name" });
});

function useStandardLayout() {
  // iterate through all the windows, filter for ones in config
  const targetWindows = Window.all().filter((w) =>
    configApps.includes(w.app().name())
  );

  // map them into the correct space and set their frames
  targetWindows.forEach((window) => {
    const windowConfig = config[window.app().name()];
    if (!windowConfig.manage) return;
    moveWindowToSpace(window, windowConfig.screen, windowConfig.space);
    window.setFrame(windowConfig.frame);
  });
}

function useZoomLayout() {
  const zoom = config.zoomMeetings;

  // Try to identify the app window
  const appWindow = Window.all().find(
    (w) => w.title() === "Zoom" && getScreenIndex(w.screen()) === 0
  );

  // Try to identify the meeting windows
  const primary = Window.all().find((w) => w.title() === "Zoom Meeting");
  const secondary = Window.all().find(
    (w) => w.title() === "Zoom" && getScreenIndex(w.screen()) === 1
  );

  if (appWindow) {
    moveWindowToSpace(appWindow, zoom.app.screen, zoom.app.space);
  }

  if (primary) {
    moveWindowToSpace(primary, zoom.primary.screen, zoom.primary.space);
    primary.maximize();
  }

  if (secondary) {
    moveWindowToSpace(secondary, zoom.secondary.screen, zoom.secondary.space);
    secondary.maximize();
  }
}

function moveWindowToSpace(window, screenIndex, spaceIndex) {
  const screen = Screen.all()[screenIndex];
  const space = screen.spaces()[spaceIndex];
  space.moveWindows([window]);
  // log("screen", screen.hash(), space.hash());
}
