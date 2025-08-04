{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  mainStorage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.nextcloud;

  hostName = "nextcloud.voxcel.ru";
  root = config.services.nginx.virtualHosts.${hostName}.root;
in {
  options.gmodules.server.nextcloud = {
    enable = mkEnableOption "nextcloud";
  };

  config = mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      inherit hostName;
      https = true;
      home = "${mainStorage}/nextcloud/home";
      datadir = "${mainStorage}/nextcloud/data";
      config = {
        adminuser = "admin";
        adminpassFile = "${mainStorage}/nextcloud/admin-pass";
        dbtype = "pgsql";
      };
      settings = {
        trusted_proxies = [
          "10.0.0.1"
        ];
        maintenance_window_start = "3";
        default_phone_region = "RU";
      };
      phpOptions."opcache.interned_strings_buffer" = "24";
      configureRedis = true;
    };
    services.postgresql = {
      ensureDatabases = [
        "nextcloud"
      ];
      ensureUsers = [ {
        name = "nextcloud";
        ensureDBOwnership = true;
      } ];
    };
    services.phpfpm.pools.nextcloud.settings = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
    };
    users.groups.nextcloud.members = [ "nextcloud" config.services.caddy.user ];
    services.nginx.enable = lib.mkForce false;
    services.caddy.virtualHosts.${hostName}.extraConfig = ''
      encode zstd gzip
      root * ${root}

      redir /.well-known/carddav /remote.php/dav 301
      redir /.well-known/caldav /remote.php/dav 301
      redir /.well-known/* /index.php{uri} 301
      redir /remote/* /remote.php{uri} 301

      header {
        Strict-Transport-Security max-age=31536000
        Permissions-Policy interest-cohort=()
        X-Content-Type-Options nosniff
        X-Frame-Options SAMEORIGIN
        Referrer-Policy no-referrer
        X-XSS-Protection "1; mode=block"
        X-Permitted-Cross-Domain-Policies none
        X-Robots-Tag "noindex, nofollow"
        -X-Powered-By
      }

      php_fastcgi unix/${config.services.phpfpm.pools.nextcloud.socket} {
        root ${root}
        env front_controller_active true
        env modHeadersAvailable true
      }

      @forbidden {
        path /build/* /tests/* /config/* /lib/* /3rdparty/* /templates/* /data/*
        path /.* /autotest* /occ* /issue* /indie* /db_* /console*
        not path /.well-known/*
      }
      error @forbidden 404

      @immutable {
        path *.css *.js *.mjs *.svg *.gif *.png *.jpg *.ico *.wasm *.tflite
        query v=*
      }
      header @immutable Cache-Control "max-age=15778463, immutable"

      @static {
        path *.css *.js *.mjs *.svg *.gif *.png *.jpg *.ico *.wasm *.tflite
        not query v=*
      }
      header @static Cache-Control "max-age=15778463"

      @woff2 path *.woff2
      header @woff2 Cache-Control "max-age=604800"

      file_server
    '';
  };
}