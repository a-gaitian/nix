{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.syncthing;
in {
  options.gmodules.server.syncthing = {
    enable = mkEnableOption "syncthing";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      dataDir = "${fastStorage}/syncthing";
      settings = {
        gui = {
          address = "10.0.0.10:8384";
        };
      };
    };
    services.caddy.virtualHosts."obsidian.${host}".extraConfig = ''
      reverse_proxy localhost:5984
    '';
  };
}