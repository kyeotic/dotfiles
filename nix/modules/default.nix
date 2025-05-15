{ lib, ... }:
{
  imports = [
    ./audio.nix
    ./config.nix
    ./desktop.nix
    ./fonts.nix
    ./gaming.nix
    ./grub.nix
    ./nvidia.nix
    ./packages.nix
    ./shell.nix
    ./syncthing.nix
  ];
}