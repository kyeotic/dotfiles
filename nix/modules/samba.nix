{ config, pkgs, lib, inputs, ... }:
{
   # For mount.cifs, required unless domain name resolution is not needed.
  environment.systemPackages = with pkgs; [
    cifs-utils
    samba
  ];

  services.samba = {
    enable = true;
    smbd.enable = true;
    settings.global.security = "user";
    openFirewall = true;
  };

  fileSystems = let cfg = name: {
      device = "//192.168.0.11/${name}";
      fsType = "cifs";
      options = [
      "credentials=/home/kyeotic/smb-secrets"
      "rw"
      "uid=1000"
      "gid=100"
      "vers=3.0" # adapt
      "noauto"
      "x-systemd.automount"
      "x-systemd.requires=network-online.target"
      "x-systemd.after=network-online.target"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      ]; 

    }; in {
      "/mnt/media" = cfg "media";
      "/mnt/nas" = cfg "nas";
    };


  networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
  services.gvfs.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 137 138 139 389 445 ];
    allowedUDPPorts = [ 137 138 139 389 445 ];
  };
}

