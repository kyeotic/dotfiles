{ config, pkgs, lib, inputs, ... }:
{
   # For mount.cifs, required unless domain name resolution is not needed.
  environment.systemPackages = with pkgs; [
    cifs-utils
    samba
  ];
  
  fileSystems."/mnt/media" = {
    device = "//kye-nas/media";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"];
  };

  networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
  services.gvfs.enable = true;

  firewall = {
    enable = true;
    allowedTCPPorts = [ 137 138 139 389 445 ];
    allowedUDPPorts = [ 137 138 139 389 445 ];
  };


  # # List packages installed in system profile. To search, run:
  # # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   cifs-utils
  #   samba
  # ];
  # services.samba = {
  #   enable = true;
  #   securityType = "user";
  # #  openFirewall = true;
  #   extraConfig = ''
  #     workgroup = WORKGROUP
  #     client min protocol = CORE
  #   '';
  # };
  # security.wrappers."mount.cifs" = {
  #   program = "mount.cifs";
  #   source = "${lib.getBin pkgs.cifs-utils}/bin/mount.cifs";
  #   owner = "root";
  #   group = "root";
  #   setuid = true;
  # };
}

