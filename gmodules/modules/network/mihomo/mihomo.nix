{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  cfg = config.gmodules.network.mihomo;
in {

  options.gmodules.network.mihomo = {
    enable = mkEnableOption "mihomo";
    configFile = mkOption {
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    services.mihomo = {
      enable = true;
      tunMode = true;
      configFile = cfg.configFile;
    };
  };
}