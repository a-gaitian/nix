{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.desktop.rofi;
in {
  options.gmodules.desktop.rofi = {
    enable = mkEnableOption "rofi";
  };

  config = mkIf cfg.enable {
    home-manager.users."${user}" =  {
      programs.rofi = {
        enable = true;
        plugins = [ pkgs.rofi-calc ];
        package = pkgs.rofi-wayland;
      };
    };
  };
}