{ config, pkgs, lib, inputs, ... }:
{

  # an alternative setup might be found here
  # https://github.com/AtaraxiaSjel/nixos-config/blob/a4e0e3919fd56b715a534f46f650efb3627021e0/flake.nix#L46
  # https://github.com/AtaraxiaSjel/nixos-config/blob/master/profiles/workspace/wayland/hyprland.nix
  # https://github.com/AtaraxiaSjel/nixos-config/blob/a4e0e3919fd56b715a534f46f650efb3627021e0/profiles/workspace/hyprland/default.nix#L68


  programs.kitty.enable = true; # required for the default Hyprland config
  # wayland.windowManager.hyprland.enable = true; # enable Hyprlan
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   extraConfig = ''
  #     # Hyprland config
  #     source = ~/.config/hypr/hypr-local.conf
  #     '';
  # };

  #  wayland.windowManager.hyprland.settings = {
  #   "monitor" = ",preferred,auto,1";
    
  #   "$terminal" = "kityy";
  #   "$browser" = "firefox";
  #   "exec-once" = "waybar";
  #   input = {
  #     kb_layout = "us";
  #     touchpad.natural_scroll = true;
  #     sensitivity = 0;
  #   };
  #   general = {
  #     gaps_in = 0;
  #     gaps_out = 0;
  #     border_size = 0;
      
  #     layout = "dwindle";
  #     allow_tearing = false;
  #   };
  #   bind = [
  #     "$mainMod = SUPER"
  #     "$mainMod, F, fullscreen"
  #     "$mainMod, Q, exec, $terminal"
  #     "$mainMod, B, exec, $browser"
  #     "$mainMod, C, killactive,"
  #     "$mainMod, M, exit,"

  #     # Bind to reload waybar
  #     "$mainMod, Z, exec, kill $(pidof waybar) && waybar"

  #     # Scroll through existing workspaces with mainMod + scroll
  #     "$mainMod, mouse_down, workspace, e+1"
  #     "$mainMod, mouse_up, workspace, e-1"
  #   ];
  #   bindm = [
  #     "$mainMod, mouse:272, movewindow"
  #     "$mainMod, mouse:273, resizewindow"
  #   ];
  #  };


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