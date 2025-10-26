{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.frps;
in {
  options.gmodules.server.frps = {
    enable = mkEnableOption "frps";
  };

  config = mkIf cfg.enable {
    services.frp = {
      role = "server";
      enable = true;
      settings = {
        bindPort = 7000;
        transport.tls.force = true;
      };
    };
    networking.firewall = {
      allowedTCPPorts = [
        7000
        70
        8443
      ];
    };
    services.caddy.virtualHosts."vpn.${host}".extraConfig = ''
      reverse_proxy localhost:7080 {
        transport http {
          tls
          tls_insecure_skip_verify
        }
      }
    '';
  };
}