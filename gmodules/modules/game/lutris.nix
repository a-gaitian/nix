{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.game.lutris;
in {
  options.gmodules.game.lutris = {
    enable = mkEnableOption "lutris";
  };

  config = mkIf cfg.enable {
    home-manager.users."${user}" = {
      programs.lutris = {
        enable = true;
      };
    };
  };
}