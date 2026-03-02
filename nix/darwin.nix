{ lib, username, isWork ? false, ... }:

{
  # Required by nix-darwin (do not change after initial install)
  system.stateVersion = 5;

  # Determinate Nix manages its own daemon — disable nix-darwin's Nix management
  nix.enable = false;
  system.primaryUser = username;

  # Dock
  system.defaults.dock = {
    tilesize = 36;          # icon size (pixels)
    orientation = "left"; # left | bottom | right
    autohide = true;
    show-recents = false;
    mru-spaces = false;     # disable "Automatically rearrange Spaces based on most recent use"
  };

  # Keyboard
  system.defaults.NSGlobalDomain = {
    KeyRepeat = 1;
    InitialKeyRepeat = 10;
  };

  # Trackpad: tap to click + three-finger drag (Accessibility > Pointer Control > Trackpad Options)
  system.defaults.trackpad = {
    Clicking = true;
    TrackpadThreeFingerDrag = true;
  };

  # Stage Manager: clicking wallpaper only reveals desktop when in Stage Manager
  system.defaults.WindowManager.EnableStandardClickToShowDesktop = false;

  # 4-finger gestures for Mission Control, App Expose, and full-screen app switching
  # Values: 0 = disabled, 2 = enabled
  system.defaults.CustomUserPreferences = {
    # App shortcut: Shift+Cmd+L = Lock Screen (@ = Cmd, $ = Shift)
    "NSGlobalDomain" = {
      NSUserKeyEquivalents = {
        "Lock Screen" = "@$l";
      };
    };
    "com.apple.AppleMultitouchTrackpad" = {
      TrackpadFourFingerVertSwipeGesture = 2;  # Mission Control (up) + App Expose (down) with 4 fingers
      TrackpadFourFingerHorizSwipeGesture = 2; # Swipe between full-screen apps with 4 fingers
    };
    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      TrackpadFourFingerVertSwipeGesture = 2;
      TrackpadFourFingerHorizSwipeGesture = 2;
    };
  };
}
