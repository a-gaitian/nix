{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  cfg = config.gmodules.server.authentik;

  authentik-nix = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/authentik-nix/archive/version/2025.6.4.tar.gz";
    sha256 = "1ah7f7hn9wf3g1lgwblpi5fv7r22hvp0m8sndwicm3j5n6kcxv8q";
  });
in {
  options.gmodules.server.authentik = {
    enable = mkEnableOption "authentik";
  };

  imports = [
    authentik-nix.nixosModules.default
  ];

  config = mkIf cfg.enable {
    services.authentik = {
      enable = true;
      environmentFile = "/var/secrets/authentik.env";
      settings = {
        email = {
          host = "sm15.hosting.reg.ru";
          use_tls = true;
          username = "authentik@${host}";
          from = "gaitian.dev authentik";
        };
        disable_startup_analytics = true;
      };
    };
    services.caddy.extraConfig = ''
      (authentik) {
        reverse_proxy /outpost.goauthentik.io/* localhost:9000

        forward_auth localhost:9000 {
          uri /outpost.goauthentik.io/auth/caddy
          copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Entitlements X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
          trusted_proxies private_ranges
        }
      }
    '';
    services.caddy.virtualHosts."authentik.${host}".extraConfig = ''
      header Access-Control-Allow-Origin *
      reverse_proxy http://localhost:9000 {
          header_down -Access-Control-Allow-Origin
      }
    '';
  };
}