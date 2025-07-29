{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  terminalCfg = config.gmodules.desktop.terminal;
  cfg = terminalCfg.kitty;
  isDefault = terminalCfg.default == "kitty";
in {
  options.gmodules.desktop.terminal.kitty = {
    enable = mkEnableOption "kitty";
  };

  config = mkIf (isDefault || cfg.enable) {
    home-manager.users."${user}" = {
      programs.kitty = {
        enable = true;
        font = {
          name = config.gmodules.desktop.terminal.font.family;
        };
      };
    };
  };
}