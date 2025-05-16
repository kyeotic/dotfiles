{ config, pkgs, lib, inputs, ... }:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    thunderbird
    stdenv
    bind
    vscode-fhs
    lshw
    lm_sensors
    discord
    lutris
    bitwarden-desktop
    (conky.override { nvidiaSupport = true; })
    obsidian
    git
    networkmanager
    #btrfs-progs
    #pulseaudio
    sudo
    wget
    killall
    mangohud
    protonup
    curl
    fd
    nerd-fonts.meslo-lg
    xdotool
    wmctrl
    autokey
  ];
}