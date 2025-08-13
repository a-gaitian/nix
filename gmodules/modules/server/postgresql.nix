{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.postgresql;
in {
  options.gmodules.server.postgresql = {
    enable = mkEnableOption "postgresql";
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_17;
      dataDir = "${fastStorage}/postgresql";
      enableTCPIP = true;
      authentication = pkgs.lib.mkOverride 10 ''
        local all all peer
        host all postgres localhost md5
      '';
      ensureDatabases = [
        "postgres"
      ];
      ensureUsers = [ {
        name = "postgres";
        ensureDBOwnership = true;
        ensureClauses.superuser = true;
      } {
        name = "postgres-exporter";
        ensureClauses.superuser = true;
      }];
    };
    services.prometheus = {
      exporters.postgres = {
        enable = true;
        dataSourceName = "user=postgres-exporter database=postgres host=/run/postgresql sslmode=disable";
      };
      scrapeConfigs = [{
        job_name = "postgres";
        static_configs = [{
          targets = [ "localhost:9187" ];
        }];
      }];
    };
  };
}