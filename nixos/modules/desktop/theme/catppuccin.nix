{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  cfg = config.gmodules.desktop.theme.catppuccin;
  catppuccinGit = builtins.fetchGit {
    url = "git@github.com:catppuccin/nix.git";
  };
in {
  options.gmodules.desktop.theme.catppuccin = {
    enable = mkEnableOption "Catppuccin Theme";
    flavor = mkOption {
      type = types.enum [ "mocha" "macchiato" "frappe" "latte" ];
      default = "macchiato";
    };
  };

  imports = [
    (import "${catppuccinGit}/modules/nixos")
  ];

  config = mkIf cfg.enable {
    catppuccin = {
      enable = true;
      flavor = cfg.flavor;
    };

    home-manager.users = glib.usersConfig glib.users (user: {
      imports = [
        (import "${catppuccinGit}/modules/home-manager")
      ];

      catppuccin = {
        enable = true;
        flavor = cfg.flavor;
        kvantum.enable = true;
        gtk.enable = true;
      };

      wayland.windowManager.hyprland.settings.env = [
        "XCURSOR_THEME,BreezeX-RosePine-Linux"
        "XCURSOR_SIZE,24"
        "QT_STYLE_OVERRIDE,kvantum"
      ];

      qt = {
        platformTheme.name = "kvantum";
        style = {
          name = "kvantum";
        };
      };
      gtk = {
        cursorTheme = {
          package = pkgs.rose-pine-cursor;
          name = "BreezeX-RosePine-Linux";
          size = 24;
        };
        gtk4.extraConfig = {
          Settings = ''
            gtk-application-prefer-dark-theme=1
          '';
        };
      };
    });
  };
}