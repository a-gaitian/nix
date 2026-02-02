{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.gitea;
in {
  options.gmodules.server.gitea = {
    enable = mkEnableOption "gitea";
  };

  config = mkIf cfg.enable {
    services.gitea = {
      enable = true;
      stateDir = "${fastStorage}/gitea";
      lfs = {
        enable = true;
        contentDir = "${storage}/gitea/lfs";
      };
      dump = {
        enable = true;
        backupDir = "${storage}/gitea/dump";
      };
      settings = {
        server = {
          DOMAIN = "gitea.${host}";
          ROOT_URL = "https://gitea.${host}/";
          HTTP_PORT = 3001;
          DISABLE_REGISTRATION = true;
          service.ENABLE_PASSWORD_SIGNIN_FORM = false;
        };
      };
    };
    services.caddy.virtualHosts."gitea.${host}".extraConfig = ''
      reverse_proxy localhost:3001
    '';
  };
}