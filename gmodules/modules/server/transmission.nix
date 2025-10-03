{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.transmission;
in {
  options.gmodules.server.transmission = {
    enable = mkEnableOption "transmission";
  };

  config = mkIf cfg.enable {
    services.transmission = {
      enable = true;
      package = pkgs.transmission_4;
      openFirewall = true;
      settings = {
        download-dir = "${storage}/share/Downloads";
        incomplete-dir = "${storage}/share/Downloads/.incomplete";
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist-enabled = false;
        rpc-host-whitelist-enabled = false;
      };
    };
    networking.firewall = {
      allowedTCPPorts = [
        9091
      ];
    };
    services.caddy.virtualHosts."torrent.${host}".extraConfig = ''
      import authentik
      reverse_proxy localhost:9091
    '';
  };
}