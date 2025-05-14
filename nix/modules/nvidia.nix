{ config, pkgs, inputs, ... }:
{
  # enable Nvidia
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.open = false;
  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ]; 
  hardware.graphics.enable = true;
}