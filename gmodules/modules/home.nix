{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  cfg = config.gmodules.home;
in {
  options.gmodules.home = {
    user = mkOption {
      type = types.str;
      description = "User for gmodules home-manager modules";
      example = "my-user";
    };
  };
}