{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  host-email = config.gmodules.server.host-email;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.forgejo;
in {
  options.gmodules.server.forgejo = {
    enable = mkEnableOption "forgejo";
  };

  config = mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;
      stateDir = "${fastStorage}/forgejo";
      lfs = {
        enable = true;
        contentDir = "${storage}/forgejo/lfs";
      };
      dump = {
        enable = true;
        backupDir = "${storage}/forgejo/dump";
      };
      database = {
        host = "/var/run/postgresql";
        socket = "/var/run/postgresql";
        type = "postgres";
      };
      secrets = {
        mailer.PASSWD = "${config.services.forgejo.customDir}/conf/mailer_passwd";
      };
      settings = {
        server = {
          DOMAIN = "forgejo.${host}";
          ROOT_URL = "https://${config.services.forgejo.settings.server.DOMAIN}/";
          HTTP_PORT = 3001;
          START_SSH_SERVER = true;
          SSH_LISTEN_PORT = 2222;
        };
        oauth2_client = {
          ENABLE_AUTO_REGISTRATION = true;
          UPDATE_AVATAR = true;
        };
        service = {
#          SHOW_REGISTRATION_BUTTON = false;
#          ENABLE_PASSWORD_SIGNIN_FORM = false;
          ENABLE_NOTIFY_MAIL = true;
          ENABLE_BASIC_AUTHENTICATION = false;
        };
        mailer = {
          ENABLED = true;
          PROTOCOL = "smtp+starttls";
          SMTP_ADDR = host-email;
          SMTP_PORT = 587;
          USER = "forgejo@${host}";
          FROM = "Forgejo <forgejo@${host}>";
        };
        log.LEVEL = "Debug";
        admin = {
          EXTERNAL_USER_DISABLE_FEATURES = "deletion";
        };
      };
    };

    services.postgresql = {
      ensureDatabases = [
        "forgejo"
      ];
      ensureUsers = [ {
        name = "forgejo";
        ensureDBOwnership = true;
      } ];
    };

    services.caddy.virtualHosts."forgejo.${host}".extraConfig = ''
      reverse_proxy localhost:3001
    '';

    networking.firewall = {
      allowedTCPPorts = [
        2222
      ];
    };
  };
}