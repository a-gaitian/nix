{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.app.telegram;
in {
  options.gmodules.app.telegram = {
    enable = mkEnableOption "telegram";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      telegram-desktop
    ];
  };
}