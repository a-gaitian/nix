{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.server.caddy;
in {
  options.gmodules.server.storage = {
    main = mkOption {
      type = types.str;
    };
    fast = mkOption {
      type = types.str;
    };
  };
}