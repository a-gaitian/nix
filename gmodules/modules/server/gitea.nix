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
        admin = {
          EXTERNAL_USER_DISABLE_FEATURES = "deletion, manage_credentials, change_username, change_full_name";
        };
      };
    };
    services.gitea-actions-runner.instances.host =  {
      enable = true;
      name = "host";
      url = "https://gitea.gaitian.dev";
      tokenFile = "${config.services.gitea.customDir}/conf/runner_token";
      labels = [
        "ubuntu-latest:docker://docker.gitea.com/runner-images:ubuntu-latest"
        "ubuntu-24.04:docker://docker.gitea.com/runner-images:ubuntu-24.04"
        "ubuntu-22.04:docker://docker.gitea.com/runner-images:ubuntu-22.04"
        "ubuntu-20.04:docker://docker.gitea.com/runner-images:ubuntu-20.04"

        "ubuntu-latest:docker://docker.gitea.com/runner-images:ubuntu-latest-slim"
        "ubuntu-24.04:docker://docker.gitea.com/runner-images:ubuntu-24.04-slim"
        "ubuntu-22.04:docker://docker.gitea.com/runner-images:ubuntu-22.04-slim"
        "ubuntu-20.04:docker://docker.gitea.com/runner-images:ubuntu-20.04-slim"

        "ubuntu-latest:docker://docker.gitea.com/runner-images:ubuntu-latest-full"
        "ubuntu-24.04:docker://docker.gitea.com/runner-images:ubuntu-24.04-full"
        "ubuntu-22.04:docker://docker.gitea.com/runner-images:ubuntu-22.04-full"
        "ubuntu-20.04:docker://docker.gitea.com/runner-images:ubuntu-20.04-full"
      ];
    };
    services.caddy.virtualHosts."gitea.${host}".extraConfig = ''
      reverse_proxy localhost:3001
    '';
    networking.firewall = {
      allowedTCPPorts = [
        2222
      ];
    };
  };
}