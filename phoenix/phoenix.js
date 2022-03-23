/// <reference lib="phoenix.d.ts" />

// inspect logs with
// $ log stream --process Phoenix

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
    frame: {
      y: -388,
      x: 2720,
      width: 2560,
      height: 1575,
    },
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
    frame: {
      y: -388,
      x: 1440,
      width: 1280,
      height: 1575,
    },
  },
};

const configApps = Object.keys(config);

Key.on("l", ["alt", "cmd"], useStandardLayout);
Key.on(";", ["alt", "cmd"], inspectWindow);
Event.on("screensDidChange", useStandardLayout);

function useStandardLayout() {
  // build a map of the target screens and their spaces
  const screens = Screen.all();
  if (screens.length !== 2) return;

  const screenSpaces = screens.map((s) => ({
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
    // screen: window.screen().hash(),
    // space: window.space().hash(),
    frame: window.frame(),
  });
}

function log(...args) {
  Phoenix.log(JSON.stringify({ args: args }, null, 2));
}

// function serialize(obj, { full = false } = {}) {
//   if (obj instanceof App) {
//     return serializeApp(obj, { full });
//   } else if (obj instanceof Space) {
//     return serializeSpace(obj, { full });
//   } else if (obj instanceof Window) {
//     return serializeWindow(obj, { full });
//   } else if (obj instanceof Screen) {
//     return serializeScreen(obj, { full });
//   } else {
//     Phoenix.log("unknown type", obj.constructor.name);
//   }
//   return {};
// }

// function serializeApp(app, { full = false } = {}) {
//   if (!full) return app.name();
//   return {
//     name: app.name(),
//     isActive: app.isActive(),
//     isHidden: app.isHidden(),
//     isTerminated: app.isTerminated(),
//     windows: app.windows.length,
//   };
// }

// function serializeSpace(space, { full = false } = {}) {
//   if (!full) return space.hash();
//   const screens = space.screens();
//   return {
//     id: space.hash(),
//     screen: screens.length === 1 ? serializeScreen(screens[0]) : undefined,
//     screens:
//       screens.length === 1
//         ? undefined
//         : screens.map((s) => serializeScreen(s, { full: false })),
//   };
// }

// function serializeWindow(window, { full = false } = {}) {
//   if (!full) return window.hash();
//   return {
//     id: window.hash(),
//     title: window.title(),
//     screen: serializeScreen(window.screen()),
//     spaces: window.spaces()?.map((s) => serializeSpace(s)),
//     frame: window.frame(),
//   };
// }

// function serializeScreen(screen, { full = false } = {}) {
//   if (!full) return screen.hash();
//   return {
//     id: screen.identifier(),
//     hash: screen.hash(),
//     spaces: screen.spaces().map((s) => serializeSpace(s)),
//   };
// }
