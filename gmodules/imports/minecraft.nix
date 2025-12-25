{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.minecraft;
in {
  options.gmodules.server.minecraft = {
    enable = mkEnableOption "minecraft";
  };

  # tmux -S /run/minecraft/lighthouse.sock attach
  # Ctrl + b then d to detach

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.tmux ];
    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
      dataDir = "${fastStorage}/minecraft";
      servers.lighthouse = {
        enable = true;
        package = pkgs.paperServers.paper-1_21_10;
      };
    };
    services.caddy.virtualHosts."map.${host}".extraConfig = ''
      reverse_proxy http://localhost:25585
    '';
  };
}