{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  cfg = config.gmodules.desktop.hyprland-catpuccin;
in {
  options.gmodules.desktop.hyprland-catpuccin = {
    enableFor = glib.mkEnableForOption "hyprland-catpuccin";
  };

  config = mkIf (length cfg.enableFor > 0) {

    services.xserver.enable = true;
    xdg.portal.enable = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    programs.hyprland = {
      enable = true;
    };

    home-manager.users = glib.usersConfig cfg.enableFor (user: {
      qt = {
        enable = true;
      };

      gtk = {
        enable = true;
      };

      wayland.windowManager.hyprland.enable = true;
      wayland.windowManager.hyprland.settings = {
      };
    });
  };
}