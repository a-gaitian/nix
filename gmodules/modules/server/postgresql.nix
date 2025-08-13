{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  mainStorage = config.gmodules.server.storage.main;
  cfg = config.gmodules.server.postgresql;
in {
  options.gmodules.server.postgresql = {
    enable = mkEnableOption "postgresql";
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_17;
      dataDir = "${mainStorage}/postgresql";
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
      } ];
    };
  };
}