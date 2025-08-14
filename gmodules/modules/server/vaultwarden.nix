{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.vaultwarden;
in {
  options.gmodules.server.vaultwarden = {
    enable = mkEnableOption "vaultwarden";
  };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      package = pkgs.vaultwarden.overrideAttrs (oldAttrs: rec {
        name = "vaultwarden";
        version = "8e7eeab";
        src = pkgs.fetchFromGitHub {
          owner = "dani-garcia";
          repo = name;
          rev = "8e7eeab2931461081c5231939a3e1b882bf0f2b3";
          hash = "sha256-4s5cj55npj5oFelaFKElFNT9SRx9EwHZUwCmG3Im6lE=";
        };
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-YYAHSbdYdc23KKYhXfSchTabzx2DTDGEfIUw9DyLGCg=";
        };
      });
      backupDir = "${storage}/vaultwarden/backup";
      environmentFile = "/var/secrets/vaultwarden.env";
      config = {
        DOMAIN = "https://bitwarden.${host}";
        SIGNUPS_ALLOWED = false;

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        ROCKET_LOG = "critical";

        SSO_ENABLED = true;
        SSO_ONLY = false;
        SSO_AUTHORITY = "https://authentik.${host}/application/o/vaultwarden/";
        SSO_SCOPES = "openid email profile offline_access";

        SMTP_HOST = "mail.${host}";
        SMTP_FROM = "bitwarden@${host}";
        SMTP_USERNAME = "bitwarden@${host}";
        SMTP_FROM_NAME = "BitWarden | ${host}";
      };
    };
    services.caddy.virtualHosts."bitwarden.${host}".extraConfig = ''
      encode zstd gzip
      reverse_proxy :${toString config.services.vaultwarden.config.ROCKET_PORT} {
        header_up X-Real-IP {remote_host}
      }
    '';
  };
}