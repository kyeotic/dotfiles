{ config, pkgs, inputs, ... }:
{
  # SSH
  programs.ssh.startAgent = true;
  
  # zsh
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };
}