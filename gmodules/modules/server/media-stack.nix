{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.media-stack;
in {
  options.gmodules.server.media-stack = {
    enable = mkEnableOption "media-stack";
  };

  config = mkIf cfg.enable {
    users.groups.media-stack = {
      members = [
        "transmission"
        "jellyfin"
      ];
    };
    gmodules.server = {
      transmission.enable = true;
      jellyfin.enable = true;
    };
  };
}