{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.matrix;
in {
  options.gmodules.server.matrix = {
    enable = mkEnableOption "matrix";
  };

  config = mkIf cfg.enable {
    services.matrix-synapse = {
      enable = true;
      dataDir = "${fastStorage}/matrix/synapse";
      extraConfigFiles = [ ./matrix-oidc.secret.yaml ];
      settings = {
        server_name = host;
        public_baseurl = "https://matrix-synapse.${host}";
        listeners = [
          {
            port = 8008;
            bind_addresses = [ "::1" ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = [
                  "client"
                  "federation"
                ];
                compress = true;
              }
            ];
          }
        ];
      };
    };
    services.postgresql = {
      ensureDatabases = [
        "matrix-synapse"
      ];
      ensureUsers = [ {
        name = "matrix-synapse";
        ensureDBOwnership = true;
      } ];
    };
    services.caddy.virtualHosts."${host}".extraConfig = ''
      reverse_proxy /.well-known/matrix/* https://matrix-synapse.${host} {
        header_up Host {http.reverse_proxy.upstream.hostport}
      }
    '';
    services.caddy.virtualHosts."matrix-synapse.${host}".extraConfig = ''
      reverse_proxy localhost:8008
    '';

    services.caddy.virtualHosts."matrix.${host}".extraConfig = let
      elementRoot = pkgs.element-web.override {
        conf = {
          default_server_config = {
            "m.homeserver" = {
              base_url = config.services.matrix-synapse.settings.public_baseurl;
              server_name = config.services.matrix-synapse.settings.server_name;
            };
          };
        };
      };
    in ''
      root * ${elementRoot}
      file_server
    '';
  };
}