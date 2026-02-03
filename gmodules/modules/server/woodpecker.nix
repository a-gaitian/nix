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
    services.woodpecker-server = {
      enable = true;
      environment = {
        WOODPECKER_DATABASE_DRIVER = "postgres";
        WOODPECKER_DATABASE_DATASOURCE = "postgres:///woodpecker-server?host=/var/run/postgresql";
        WOODPECKER_HOST = "https://woodpecker.${host}";
        WOODPECKER_SERVER_ADDR = ":3007";
        WOODPECKER_GRPC_ADDR = ":9001";
        WOODPECKER_OPEN = "true";
        WOODPECKER_FORGEJO = "true";
        WOODPECKER_FORGEJO_URL = "https://forgejo.${host}";
        WOODPECKER_ADMIN = "albert";
        DISABLE_VERSION_CHECK = "true";
      };
      environmentFile = /var/secrets/woodpecker.env;
    };

    services.postgresql = {
      ensureDatabases = [
        "woodpecker-server"
      ];
      ensureUsers = [ {
        name = "woodpecker-server";
        ensureDBOwnership = true;
      } ];
    };

    services.caddy.virtualHosts."woodpecker.${host}".extraConfig = ''
      reverse_proxy localhost:3007
    '';

    services.woodpecker-agents.agents.host = {
      enable = true;
      extraGroups = [ "podman" ];
      environment = {
        WOODPECKER_SERVER = "localhost:9001";
        WOODPECKER_BACKEND = "docker";
        DOCKER_HOST = "unix:///run/podman/podman.sock";
        WOODPECKER_MAX_WORKFLOWS = "8";
      };
      environmentFile = [ /var/secrets/woodpecker-agent.env ];
    };
  };
}