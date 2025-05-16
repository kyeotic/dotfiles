{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    inputs.nix-gaming.nixosModules.platformOptimizations
  ];

  # nix-gaming module
  programs.steam.platformOptimizations.enable = true;

  # Recommended by nix-gaming: https://github.com/fufexan/nix-gaming?tab=readme-ov-file#-tips
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;

  # Enable coretemp for conky
  boot.kernelModules = [ "coretemp" "kvm-amd" ];

  # environment.systemPackages = with pkgs; [
  #   inputs.nix-gaming.packages.${pkgs.system}.
  # ];

  # Gaming
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  # enable in team options with
  # gamemoderun %command%
  programs.gamemode.enable = true;
}

