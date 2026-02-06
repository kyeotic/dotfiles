{ config, pkgs, inputs, ... }:
{
  # Don't create default ~/Sync folder
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    group = "users";
    user = "kyeotic";
    dataDir = "/home/kyeotic";
    settings = {
      devices = {
        "kye-0" = { id = "2USR2ZN-4UN3CWS-4XQK6HL-6PFAUB2-WSRZSPT-WHNFT7F-RKDCOCU-VNOPLAV"; };
      };
      folders = {
        "Drive" = {
          id = "gchnj-ydqu4";
          path = "/home/kyeotic/sync/drive";
          devices = [ "kye-0" ];
        };
        "Notes" = {
          id = "2tuzu-km3cr";
          path = "/home/kyeotic/sync/notes";
          devices = [ "kye-0" ];
        };
      };
    };
  };
}