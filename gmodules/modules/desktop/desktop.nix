{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  cfg = config.gmodules.desktop;
in {
  options.gmodules.desktop = {
    headless = mkOption {
      type = types.bool;
      description = "Is setup running without GUI?";
      default = true;
    };
  };

  config = mkIf (!cfg.headless) {
    gmodules.font.enable = true;
  };
}