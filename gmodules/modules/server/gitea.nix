{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  host-email = config.gmodules.server.host-email;
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
      mailerPasswordFile = "${config.services.gitea.customDir}/conf/mailer_passwd";
      settings = {
        server = {
          DOMAIN = "gitea.${host}";
          ROOT_URL = "https://gitea.${host}/";
          HTTP_PORT = 3001;
          START_SSH_SERVER = true;
          SSH_LISTEN_PORT = 2222;
        };
        oauth2_client = {
          ENABLE_AUTO_REGISTRATION = true;
          UPDATE_AVATAR = true;
        };
        service = {
          SHOW_REGISTRATION_BUTTON = false;
          ENABLE_PASSWORD_SIGNIN_FORM = false;
          ENABLE_NOTIFY_MAIL = true;
          ENABLE_BASIC_AUTHENTICATION = false;
          ENABLE_PASSKEY_AUTHENTICATION = false;
        };
        mailer = {
          ENABLED = true;
          PROTOCOL = "smtp+starttls";
          SMTP_ADDR = host-email;
          SMTP_PORT = 587;
          USER = "gitea@${host}";
          FROM = "Gitea <gitea@${host}>";
        };
      };
    };
    services.caddy.virtualHosts."gitea.${host}".extraConfig = ''
      reverse_proxy localhost:3001
    '';
  };
}