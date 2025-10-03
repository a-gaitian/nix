{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.n8n;
in {
  options.gmodules.server.n8n = {
    enable = mkEnableOption "n8n";
  };


  config = mkIf cfg.enable {
    services.n8n = {
      enable = true;
      openFirewall = true;
      webhookUrl = "https://n8n.${host}";
    };
    systemd.services.n8n.environment = {
      N8N_MFA_ENABLED = "false";
      GENERIC_TIMEZONE = "Europe/Moscow";
    };
    services.caddy.virtualHosts."n8n.${host}".extraConfig = ''
      reverse_proxy localhost:5678
    '';
  };
}