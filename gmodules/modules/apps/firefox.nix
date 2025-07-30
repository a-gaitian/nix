{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.app.firefox;
in {
  options.gmodules.app.firefox = {
    enable = mkEnableOption "firefox";
  };

  config = mkIf cfg.enable {
    home-manager.users."${user}" = {
      programs.firefox = {
        enable = true;
      };
    };
  };
}