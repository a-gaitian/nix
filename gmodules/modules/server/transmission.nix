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
      settings = {
        download-dir = "${storage}/share/Downloads";
        incomplete-dir = "${storage}/share/Downloads/.incomplete";
        rpc-whitelist-enabled = false;
        rpc-host-whitelist-enabled = false;
      };
    };
    networking.firewall = {
      allowedTCPPorts = [
        51413
      ];
      allowedUDPPorts = [
        51413
      ];
    };
    services.caddy.virtualHosts."torrent.${host}".extraConfig = ''
      route {
        reverse_proxy /outpost.goauthentik.io/* https://authentik.${host} {
            header_up Host {http.reverse_proxy.upstream.host}
        }
        forward_auth https://authentik.${host} {
          uri /outpost.goauthentik.io/auth/caddy
          copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Entitlements X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
        }

        reverse_proxy localhost:9091
      }
    '';
  };
}