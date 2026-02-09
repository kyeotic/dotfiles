{ pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  isWSL = builtins.pathExists /proc/sys/fs/binfmt_misc/WSLInterop;
in
{
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ansible
    awscli2
    bat
    direnv
    eza
    fd
    findutils
    fzf
    gettext
    git
    jq
    just
    openssl
    pcre
    pcre2
    python3
    readline
    stow
    starship
    unzip
    watch
    watchman
    wget
    yq-go
    podman
    pnpm
    zsh-completions
    zsh-autosuggestions
  ] ++ lib.optionals isDarwin [
    inetutils
  ] ++ lib.optionals (isLinux && !isWSL) [
    nerd-fonts.hack
    nerd-fonts.meslo-lg
    nerd-fonts.fira-code
  ] ++ lib.optionals (isDarwin) [
    nerd-fonts.hack
    nerd-fonts.meslo-lg
    nerd-fonts.fira-code
  ];

  fonts.fontconfig.enable = !isWSL;
}
