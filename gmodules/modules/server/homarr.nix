{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.homarr;
in {
  options.gmodules.server.homarr = {
    enable = mkEnableOption "homarr";
  };
  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.homarr = {
      image = "ghcr.io/homarr-labs/homarr:latest";
      volumes = [ "${fastStorage}/homarr:/appdata" ];
      ports = [ "7575:7575" ];
      environmentFiles = [ /var/secrets/homarr.env ];
    };
    services.caddy.virtualHosts."dashboard.${host}".extraConfig = ''
      reverse_proxy localhost:7575
    '';
  };
}