/// <reference lib="./phoenix.d.ts" />

// inspect logs with
// > log stream --process Phoenix

const wideFirstThird = {
  y: -286,
  x: 1512,
  width: 1280,
  height: 1575,
};

const wideSecondThirds = {
  y: -286,
  x: 2792,
  width: 2560,
  height: 1575,
};

// screens and spaces are zero-indexed, not hash-indexed
const config = {
  // "Calendar",
  // "Slack",
  Bitwarden: {
    screen: 1,
    space: 0,
    frame: {
      y: -388,
      x: 3859,
      width: 1421,
      height: 885,
    },
  },
  // "Hyper",
  Notion: {
    screen: 1,
    space: 0,
    frame: {
      y: -38,
      x: 1520,
      width: 1280,
      height: 1575,
    },
  },
  // "Music",
  // "Messages",
  Postman: {
    screen: 1,
    space: 0,
    frame: {
      y: -388,
      x: 2557,
      width: 1920,
      height: 1575,
    },
  },
  Code: {
    screen: 1,
    space: 1,
    frame: wideSecondThirds,
  },
  "IntelliJ IDEA": {
    screen: 1,
    space: 1,
    frame: wideSecondThirds,
  },
  "zoom.us": {
    screen: 0,
    space: 2,
    frame: {
      y: 121,
      x: 27,
      width: 880,
      height: 660,
    },
  },
  Miro: {
    screen: 1,
    space: 3,
    frame: {
      y: -388,
      x: 1439,
      width: 3840,
      height: 1575,
    },
  },
  "1Password 7": {
    screen: 1,
    space: 0,
    frame: {
      y: 312,
      x: 4165,
      width: 1115,
      height: 875,
    },
  },
  "Brave Browser": {
    screen: 1,
    space: 1,
    frame: wideFirstThird,
  },
};

const configApps = Object.keys(config);

Key.on("l", ["alt", "cmd"], useStandardLayout);
Key.on(";", ["alt", "cmd"], inspectWindow);
Event.on("screensDidChange", useStandardLayout);

Key.on("k", ["alt", "cmd"], () => {
  Phoenix.log("storing");
  Storage.set("test", { thing: "name" });
});

function useStandardLayout() {
  // build a map of the target screens and their spaces
  const screens = Screen.all();
  if (screens.length !== 2) return;

  const screenMap = screens.map((s) => ({
    spaces: s.spaces(),
  }));

  // iterate through all the windows, filter for ones in config
  const targetWindows = Window.all().filter((w) =>
    configApps.includes(w.app().name())
  );

  // map them into the correct space and set their frames
  targetWindows.forEach((window) => {
    const windowConfig = config[window.app().name()];
    const space = screenMap[windowConfig.screen].spaces[windowConfig.space];
    space.moveWindows([window]);
    window.setFrame(windowConfig.frame);
  });
}

function inspectWindow() {
  const window = Window.focused();
  log("Window", {
    title: window.title(),
    app: window.app().name(),
    frame: window.frame(),
  });
}

function log(...args) {
  Phoenix.log(JSON.stringify({ args: args }, null, 2));
}
