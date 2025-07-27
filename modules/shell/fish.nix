{ pkgs, lib, config, ... }:
let
  cfg = config.gmodules.shell.fish;
in {

  options.gmodules.shell.fish = {
    enable = lib.mkEnableOption "Friendly Interactive SHell";
  };

  config = lib.mkIf cfg.enable {

  };
}