{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  cfg = config.gmodules.desktop.terminal;
in {
  options.gmodules.desktop.terminal = {
    default = mkOption {
      type = types.enum [ "kitty" ];
      description = "Default system terminal";
      default = "kitty";
    };
    font = {
      family = mkOption {
        type = types.str;
        default = "JetBrainsMonoNerdFontMono";
      };
    };
  };
}