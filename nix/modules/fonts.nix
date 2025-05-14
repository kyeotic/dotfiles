{ config, pkgs, ... }: {
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts = {
        monospace = [ "Iosevka" ];
      };
    };
    packages = with pkgs; [
      dejavu_fonts
      fira-code
      fira-code-symbols
      iosevka
      noto-fonts
      noto-fonts-emoji
      powerline-fonts
      source-code-pro
      symbola
      ubuntu_font_family
      nerd-fonts.meslo-lg
    ];
  };
}