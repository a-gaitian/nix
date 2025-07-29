{ pkgs, config, lib, glib, ... }:
let
  user = config.gmodules.home.user;
  cfg = config.gmodules.shell.fish;
in {

  options.gmodules.shell.fish = {
    enable = lib.mkEnableOption "fish";
  };

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;
    home-manager.users."${user}" = {
      programs = {
        fish.enable = true;
        fish.shellInit = ''
          set -Ux fish_greeting
          set -Ux fish_features no-keyboard-protocols
        '';

        starship = {
          enable = true;
          enableFishIntegration = true;
        };

        bat.enable = true;

        eza = {
          enable = true;
          enableFishIntegration = true;
          git = true;
        };

        direnv = {
          enable = true;
          silent = true;
        };
      };

      home.shellAliases = {
        cat = "bat";
        cat-git = "bat -d";

        ls = "eza -x --group-directories-first --icons=auto --classify=auto";
        ls-tree = "ls -T";
        ls-git = "git ls-files --modified --others --exclude-standard | ls -l --stdin";

        kb = "kubectl";
      };
    };
  };
}