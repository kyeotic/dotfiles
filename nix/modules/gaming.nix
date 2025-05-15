{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    inputs.nix-gaming.nixosModules.platformOptimizations
  ];

  # nix-gaming module
  programs.steam.platformOptimizations.enable = true;

  # Recommended by nix-gaming: https://github.com/fufexan/nix-gaming?tab=readme-ov-file#-tips
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;

  # environment.systemPackages = with pkgs; [
  #   inputs.nix-gaming.packages.${pkgs.system}.
  # ];

  # Gaming
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true; 
}

