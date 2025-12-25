{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.virtualisation;
in {
  options.gmodules.server.virtualisation = {
    enable = mkEnableOption "virtualisation";
  };

  config = mkIf cfg.enable {
    virtualisation = {
      libvirtd = {
        enable = true;
        allowedBridges = [
          "br0"
        ];
      };
      spiceUSBRedirection.enable = true;
    };
    environment.systemPackages = with pkgs; [
      virtio-win
      quickemu
    ];
    networking.firewall = {
      allowedTCPPorts = [ 5930 ];
      allowedUDPPorts = [ 5930 ];
    };
    networking.useDHCP = false;
    networking.interfaces.enp6s0.useDHCP = true;
    networking.interfaces.br0.useDHCP = true;
    networking.bridges = {
      "br0" = {
        interfaces = [ "enp6s0" ];
      };
    };
  };
}