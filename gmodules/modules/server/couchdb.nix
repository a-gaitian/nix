{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.couchdb;
in {
  options.gmodules.server.couchdb = {
    enable = mkEnableOption "couchdb";
  };

  config = mkIf cfg.enable {
    services.couchdb = {
      enable = true;
      bindAddress = "0.0.0.0";
      databaseDir = "${fastStorage}/couchdb";
      viewIndexDir = "${fastStorage}/couchdb";
    };
    services.caddy.virtualHosts."obsidian.${host}".extraConfig = ''
      reverse_proxy localhost:5984
    '';
  };
}