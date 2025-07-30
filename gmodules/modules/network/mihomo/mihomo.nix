{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  cfg = config.gmodules.network.mihomo;
in {

  options.gmodules.network.mihomo = {
    enable = lib.mkEnableOption "mihomo";
  };

  config = mkIf cfg.enable {
    services.mihomo = {
      enable = true;
      tunMode = true;
      configFile = ./config.yaml;
    };
  };
}