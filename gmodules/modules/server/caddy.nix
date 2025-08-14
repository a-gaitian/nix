{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  storage = config.gmodules.server.storage.main;
  cfg = config.gmodules.server.caddy;
in {
  options.gmodules.server.caddy = {
    enable = mkEnableOption "caddy";
    virtualHosts = mkOption {
      type = types.attrs;
      default = {};
    };
  };
  options.gmodules.server.host = mkOption {
    type = types.str;
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
        hash = "sha256-S1JN7brvH2KIu7DaDOH1zij3j8hWLLc0HdnUc+L89uU=";
      };
      environmentFile = "/var/secrets/caddy.env";
      globalConfig = ''
        email galik-ya@yandex.ru
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      '';
      virtualHosts."log.voxcel.ru" = {
        logFormat = ''
          output file "${storage}/nextcloud/log/access"
        '';
        extraConfig = ''
          respond "Logged" 200
        '';
      };
      virtualHosts."view-log.voxcel.ru".extraConfig = ''
        basicauth /* {
          admin ${builtins.readFile ./log-password-hash.secret}
        }
        root * ${storage}/nextcloud/log
        file_server
      '';
    };
  };
}