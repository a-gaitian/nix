{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.prowlarr;
in {
  options.gmodules.server.prowlarr = {
    enable = mkEnableOption "prowlarr";
  };

  config = mkIf cfg.enable {
    services.prowlarr = {
      enable = true;
      dataDir = "${fastStorage}/prowlarr";
      openFirewall = true;
    };
    services.caddy.virtualHosts."prowlarr.${host}".extraConfig = ''
      import authentik
      reverse_proxy localhost:9696
    '';
    services.prometheus = {
      exporters.exportarr-prowlarr = {
        enable = true;
        url = "http://localhost:9696";
        apiKeyFile = ./prowlarr-api-key.secret;
        port = 9709;
      };
      scrapeConfigs = [{
        job_name = "prowlarr";
        static_configs = [{
          targets = [ "localhost:9709" ];
        }];
      }];
    };
  };
}