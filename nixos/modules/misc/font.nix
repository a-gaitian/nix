{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.gmodules.font;
in {
  options.gmodules.font = {
    enable = mkEnableOption "Fonts";
    families = mkOption {
      type = types.listOf types.str;
      default = [ "jetbrains-mono" ];
    };
    defaultMono = mkOption {
      type = types.listOf types.str;
      default = "jetbrains-mono";
    };
  };

  config = mkIf cfg.enable {
    fonts.packages = with pkgs;
      map (family:
        nerd-fonts."${family}"
      ) cfg.families;
  };
}