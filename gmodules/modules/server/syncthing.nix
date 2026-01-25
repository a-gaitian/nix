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
      openDefaultPorts = true;
      dataDir = "${fastStorage}/syncthing";
    };
    services.caddy.virtualHosts."syncthing.${host}".extraConfig = ''
      reverse_proxy localhost:8384
    '';
  };
}