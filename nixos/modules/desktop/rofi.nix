{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  cfg = config.gmodules.desktop.rofi;
in {
  options.gmodules.desktop.rofi = {
    enableFor = glib.mkEnableForOption "rofi";
  };

  config = mkIf (length cfg.enableFor > 0) {
    home-manager.users = glib.usersConfig cfg.enableFor (user: {
      programs.rofi = {
        enable = true;
        plugins = [ pkgs.rofi-calc ];
        package = pkgs.rofi-wayland;
      };
    });
  };
}