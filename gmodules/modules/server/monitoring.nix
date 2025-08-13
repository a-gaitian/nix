{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.monitoring;
in {
  options.gmodules.server.monitoring = {
    enable = mkEnableOption "monitoring";
  };

  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      exporters.node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        extraFlags = [ "--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" ];
      };
      globalConfig.scrape_interval = "15s";
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{
            targets = [ "localhost:9100" ];
          }];
        }
      ];
    };
    services.caddy.virtualHosts."prometheus.${host}".extraConfig = ''
      @subnet {
        remote_ip 10.0.0.1/24
      }
      handle @subnet {
        reverse_proxy localhost:9090
      }
      respond 403
    '';

    services.loki = {
      enable = true;
      dataDir = "${storage}/loki";
      configFile = ./loki.yaml;
    };
    services.alloy = {
      enable = true;
    };
    environment.etc."alloy/config.alloy".source = ./config.alloy;

    services.grafana = {
      enable = true;
      dataDir = "${fastStorage}/grafana";
      settings = {
        server = {
          domain = "grafana.${host}";
          root_url = "https://grafana.${host}";
        };
      };
    };
    services.caddy.virtualHosts."grafana.${host}".extraConfig = ''
      reverse_proxy localhost:3000
    '';
  };
}