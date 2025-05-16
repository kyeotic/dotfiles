{ config, pkgs, lib, inputs, ... }:
{

  # an alternative setup might be found here
  # https://github.com/AtaraxiaSjel/nixos-config/blob/a4e0e3919fd56b715a534f46f650efb3627021e0/flake.nix#L46
  # https://github.com/AtaraxiaSjel/nixos-config/blob/master/profiles/workspace/wayland/hyprland.nix
  # https://github.com/AtaraxiaSjel/nixos-config/blob/a4e0e3919fd56b715a534f46f650efb3627021e0/profiles/workspace/hyprland/default.nix#L68


  # Hyperlabd
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  # services.hypridle.enable = true;


  programs.kitty.enable = true; # required for the default Hyprland config
  wayland.windowManager.hyprland.enable = true; # enable Hyprlan
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
  home.sessionVariables.NIXOS_OZONE_WL = "1";

   wayland.windowManager.hyprland.settings = {
    bind = [

    ];
   };


  #   wayland.windowManager.hyprland.settings = {
  #   "$mod" = "SUPER";
  #   bind =
  #     [
  #       "$mod, F, exec, firefox"
  #       ", Print, exec, grimblast copy area"
  #     ]
  #     ++ (
  #       # workspaces
  #       # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
  #       builtins.concatLists (builtins.genList (i:
  #           let ws = i + 1;
  #           in [
  #             "$mod, code:1${toString i}, workspace, ${toString ws}"
  #             "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
  #           ]
  #         )
  #         9)
  #     );
  # };

#   env = LIBVA_DRIVER_NAME,nvidia
# env = __GLX_VENDOR_LIBRARY_NAME,nvidia

#maybe needed for electron (flickering)
# env = ELECTRON_OZONE_PLATFORM_HINT,auto

# maybe also NIXOS_OZONE_WL=1
}