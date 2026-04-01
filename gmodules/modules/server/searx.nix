{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  host-email = config.gmodules.server.host-email;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.searx;
in {
  options.gmodules.server.searx = {
    enable = mkEnableOption "searx";
  };

  config = mkIf cfg.enable {
     services.caddy.virtualHosts."search.${host}".extraConfig = ''
       reverse_proxy localhost:64712
     '';
  };
}