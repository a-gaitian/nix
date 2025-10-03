{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.sonarr;
in {
  options.gmodules.server.sonarr = {
    enable = mkEnableOption "sonarr";
  };

  config = mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      dataDir = "${fastStorage}/sonarr";
    };
    networking.firewall = {
      allowedTCPPorts = [
        8989
      ];
    };
    services.caddy.virtualHosts."sonarr.${host}".extraConfig = ''
      import authentik
      reverse_proxy localhost:8989
    '';
    services.prometheus = {
      exporters.exportarr-sonarr = {
        enable = true;
        url = "http://localhost:8989";
        apiKeyFile = ./sonarr-api-key.secret;
      };
      scrapeConfigs = [{
        job_name = "sonarr";
        static_configs = [{
          targets = [ "localhost:9708" ];
        }];
      }];
    };
  };
}