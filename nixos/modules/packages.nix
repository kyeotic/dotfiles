{ config, pkgs, lib, inputs, ... }:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    (conky.override { nvidiaSupport = true; })
    #btrfs-progs
    #pulseaudio
    autokey
    bind
    bitwarden-desktop
    curl
    discord
    fd
    git
    killall
    kitty
    lm_sensors
    lshw
    lutris
    mangohud
    nerd-fonts.meslo-lg
    networkmanager
    obsidian
    protonup
    signal-desktop
    starship
    stdenv
    stow
    sudo
    thunderbird
    unzip
    vscode-fhs
    wget
    wmctrl
    xdotool
  ];
}