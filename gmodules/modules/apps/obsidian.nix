{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.app.obsidian;
in {
  options.gmodules.app.obsidian = {
    enable = mkEnableOption "obsidian";
  };

  config = mkIf cfg.enable {
    home-manager.users."${user}" = {
      programs.obsidian = {
        enable = true;
      };
    };
  };
}