{ config, pkgs, inputs, ... }:
{
  # enable Nvidia
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.open = true;
  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ]; 
  hardware.graphics.enable = true;

  # this can cause sleep/hibernate to fail
  hardware.nvidia.powerManagement.enable = false;
  hardware.nvidia.powerManagement.finegrained = false;
}