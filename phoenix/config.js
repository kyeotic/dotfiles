const wideFirstThird = {
  y: 25,
  x: 1728,
  width: 1280,
  height: 1575,
};

const wideSecondThirds = {
  y: 25,
  x: 3008,
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
    space: 2,
    frame: wideSecondThirds,
  },
  "Google Chrome": {
    screen: 1,
    space: 1,
    frame: wideFirstThird,
  },
  "Google Meet - Google Chrome": {
    screen: 0,
    space: 3,
    maximize: true,
  },
  "IntelliJ IDEA": {
    screen: 1,
    space: 1,
    frame: wideSecondThirds,
  },
  zoomMeetings: {
    app: {
      screen: 0,
      space: 3,
    },
    primary: {
      screen: 0,
      space: 3,
    },
    secondary: {
      screen: 1,
      space: 2,
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
