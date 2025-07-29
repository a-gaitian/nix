{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.desktop.swaync;
in {
  options.gmodules.desktop.swaync = {
    enable = mkEnableOption "swaync";
  };

  config = mkIf cfg.enable {
    home-manager.users."${user}" = {
      services.swaync = {
        enable = true;
        settings = {
          positionX = "center";
          positionY = "top";
          layer = "overlay";
          control-center-layer = "overlay";
          control-center-positionX = "center";
          control-center-positionY = "top";
          control-center-width = 500;
          control-center-height = 500;
          control-center-margin-top = 32;
          fit-to-screen = false;
          notification-inline-replies = true;
          widgets = [
            "backlight"
            "volume"
            "buttons-grid"
            "mpris"
            "dnd"
            "notifications"
          ];
          widget-config = {
            backlight = {
              label = "󰃟";
            };
            volume = {
              label = "󰕾";
            };
          };
        };
      };
    };
  };
}