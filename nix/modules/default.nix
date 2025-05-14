{ lib, ... }:
{
  imports = [
    ./config.nix
    ./desktop.nix
    ./fonts.nix
    ./grub.nix
    ./nvidia.nix
    ./packages.nix
    ./shell.nix
    ./syncthing.nix
  ];
}