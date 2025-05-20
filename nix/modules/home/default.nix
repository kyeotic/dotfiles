{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./hyprland.nix
  ];
  # The state version is required and should stay at the version you
    # originally installed.
  home.stateVersion = "24.11";
}