{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  cfg = config.gmodules.utilities;
in {
  options.gmodules.utilities = {
    enableAll = mkEnableOption "Utilities";
    vim = glib.mkEnableOption cfg.enableAll "Utility: vim";
    neofetch = glib.mkEnableOption cfg.enableAll "Utility: neofetch";
    p7z = glib.mkEnableOption cfg.enableAll "Utility: 7z";
    btop = glib.mkEnableOption cfg.enableAll "Utility: btop";
    git = glib.mkEnableOption cfg.enableAll "Utility: git";
    file = glib.mkEnableOption cfg.enableAll "Utility: file";
  };

  config = {
    programs.vim = mkIf cfg.vim {
      enable = true;
      package = pkgs.vim-full;
      defaultEditor = true;
    };

    environment.systemPackages = with pkgs;
      lib.optional cfg.neofetch neofetch
      ++ lib.optional cfg.p7z p7zip-rar
      ++ lib.optional cfg.file file;

    home-manager.users = glib.usersConfig glib.users (user: {
      programs.git = mkIf cfg.git {
        enable = true;
      };
      programs.btop = mkIf cfg.btop {
        enable = true;
      };
    });
  };
}