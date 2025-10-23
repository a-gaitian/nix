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
        turn_uris = ["turn:${config.services.coturn.realm}:3478?transport=udp" "turn:${config.services.coturn.realm}:3478?transport=tcp"];
        turn_shared_secret = config.services.coturn.static-auth-secret;
        turn_user_lifetime = "1h";
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

    services.coturn = rec {
      enable = true;
      no-cli = true;
      no-tcp-relay = true;
      min-port = 49000;
      max-port = 50000;
      use-auth-secret = true;
      static-auth-secret = "IANZhuRVwuvhhVjaknlGSboiyfvNDAum";
      realm = "gaitian.dev";
      cert = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${realm}/${realm}.crt";
      pkey = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${realm}/${realm}.key";
      extraConfig = ''
        # for debugging
        verbose
        # ban private IP ranges
        no-multicast-peers
        denied-peer-ip=0.0.0.0-0.255.255.255
        # denied-peer-ip=10.0.0.0-10.255.255.255
        denied-peer-ip=100.64.0.0-100.127.255.255
        denied-peer-ip=127.0.0.0-127.255.255.255
        denied-peer-ip=169.254.0.0-169.254.255.255
        denied-peer-ip=172.16.0.0-172.31.255.255
        denied-peer-ip=192.0.0.0-192.0.0.255
        denied-peer-ip=192.0.2.0-192.0.2.255
        denied-peer-ip=192.88.99.0-192.88.99.255
        denied-peer-ip=192.168.0.0-192.168.255.255
        denied-peer-ip=198.18.0.0-198.19.255.255
        denied-peer-ip=198.51.100.0-198.51.100.255
        denied-peer-ip=203.0.113.0-203.0.113.255
        denied-peer-ip=240.0.0.0-255.255.255.255
        denied-peer-ip=::1
        denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
        denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
        denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
        denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
        denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
        denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
        denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      '';
    };
    networking.firewall = let
      range = with config.services.coturn; [ {
        from = min-port;
        to = max-port;
      } ];
    in {
      allowedUDPPortRanges = range;
      allowedUDPPorts = [ 3478 5349 ];
      allowedTCPPortRanges = [ ];
      allowedTCPPorts = [ 3478 5349 ];
    };
  };
}