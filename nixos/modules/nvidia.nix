{ config, pkgs, inputs, ... }:
{
  hardware.graphics.enable = true;
  
  # enable Nvidia
  services.xserver.videoDrivers = [ "nvidia" ]; 
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.open = true;
  hardware.nvidia.modesetting.enable = true;

  # this can cause sleep/hibernate to fail
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = false;

  # systemd.sleep.extraConfig = ''
  #   SuspendState=freeze
  # '';

  systemd.services."systemd-suspend" = {
    serviceConfig = {
      Environment = "SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false";
    };
  };
}