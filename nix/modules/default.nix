{ lib, ... }:
{
  imports = [
    ./config.nix
    ./fonts.nix
    ./grub.nix
    ./nvidia.nix
    ./packages.nix
    ./shell.nix
    ./syncthing.nix
  ];
}