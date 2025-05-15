{ config, pkgs, inputs, ... }:
{
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasmax11";


  # eventually you need to configure kde to remove the taskbar shortcuts
  # that conflict with autokey window positions
  # https://github.com/nix-community/plasma-manager?tab=readme-ov-file#whats-supported
}