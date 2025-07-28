{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  terminalCfg = config.gmodules.desktop.terminal;
  cfg = terminalCfg.kitty;
  isDefault = terminalCfg.default == "kitty";
in {
  options.gmodules.desktop.terminal.kitty = {
    enableFor = glib.mkEnableForOption "kitty";
  };

  config = {
    home-manager.users = glib.usersConfigOrDefault isDefault cfg.enableFor (user: {
      programs.kitty = {
        enable = true;
        font = {
          name = config.gmodules.desktop.terminal.font.family;
        };
      };
    });
  };
}