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
    ohMyZsh = {
      enable = true;
      # theme = "robbyrussell";
      custom = "$HOME/.oh-my-zsh/custom/";
      theme = "powerlevel10k/powerlevel10k";
      plugins = [
        "docker"
        "dotenv"
        "git"
        "nvm"
        "rust"
        "sudo"
      ];
    };
  };
}