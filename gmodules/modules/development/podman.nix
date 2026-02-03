{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.development.podman;
in {
  options.gmodules.development.podman = {
    enable = mkEnableOption "podman";
  };

  config = mkIf cfg.enable {
    virtualisation.containers.enable = true;
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };
    environment = {
      sessionVariables = {
        PODMAN_COMPOSE_PROVIDER = "podman-compose";
        PODMAN_COMPOSE_WARNING_LOGS = "false";
      };
      systemPackages = with pkgs; [
        dive
        podman-compose
      ];
    };
    trustedInterfaces = [ "br+" "podman+" "veth+" ];
  };
}