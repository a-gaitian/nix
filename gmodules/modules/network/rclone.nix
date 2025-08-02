{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.network.rclone;
in {
  options.gmodules.network.rclone = {
    enable = mkEnableOption "rclone";
  };

  config = mkIf cfg.enable {
    home-manager.users."${user}" = {
      programs.rclone = {
        enable = true;
      };
    };
  };
}