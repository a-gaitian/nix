{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  host-email = config.gmodules.server.host-email;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.woodpecker;
in {
  options.gmodules.server.woodpecker = {
    enable = mkEnableOption "woodpecker";
  };

  config = mkIf cfg.enable {
    services.woodpecker = {
      enable = true;
      environment = {
        WOODPECKER_DATABASE_DRIVER = "woodpecker";
        WOODPECKER_DATABASE_DATASOURCE = "postgres:///var/run/postgresql/woodpecker";
        WOODPECKER_HOST = "https://woodpecker.${host}";
        WOODPECKER_FORGEJO = true;
        WOODPECKER_FORGEJO_URL = "https://forgejo.${host}";
      };
      environmentFile = ./woodpecker.secret;
    };

    services.postgresql = {
      ensureDatabases = [
        "woodpecker"
      ];
      ensureUsers = [ {
        name = "woodpecker";
        ensureDBOwnership = true;
      } ];
    };

    services.caddy.virtualHosts."woodpecker.${host}".extraConfig = ''
      reverse_proxy localhost:8000
    '';

    networking.firewall = {
      allowedTCPPorts = [
        2222
      ];
    };
  };
}