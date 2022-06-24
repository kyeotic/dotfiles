/// <reference lib="./phoenix.d.ts" />

function log(...args) {
  Phoenix.log(JSON.stringify({ args: args }, null, 2));
}

function inspectWindow() {
  const window = Window.focused();
  log("Window", windowJson(window));
}

function inspectApp() {
  const window = Window.focused();
  const app = window.app();
  log("App", appJson(app));
}

function windowJson(window) {
  return {
    title: window.title(),
    app: window.app().name(),
    frame: window.frame(),
    screen: window.screen().identifier(),
    screenIndex: getScreenIndex(window.screen()),
  };
}

function appJson(app) {
  return {
    app: app.name(),
    windows: app.windows().map((w) => ({
      title: w.title(),
      frame: w.frame(),
      screen: w.screen().identifier(),
    })),
  };
}

function getScreenIndex(screen) {
  return Screen.all().indexOf(screen);
}
