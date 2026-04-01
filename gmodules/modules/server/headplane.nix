{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  host-email = config.gmodules.server.host-email;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.headplane;
in {
  options.gmodules.server.headplane = {
    enable = mkEnableOption "headplane";
  };

  config = mkIf cfg.enable {
     services.caddy.virtualHosts."headplane.${host}".extraConfig = ''
       reverse_proxy localhost:11530
     '';
  };
}