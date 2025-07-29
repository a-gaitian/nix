{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.theme.catppuccin;
in {
  options.gmodules.theme.catppuccin = {
    enable = mkOption {
      type = types.bool;
      description = "Catppuccin Theme";
      default = true;
    };
    flavor = mkOption {
      type = types.enum [ "mocha" "macchiato" "frappe" "latte" ];
      default = "macchiato";
    };
  };

  config = mkIf cfg.enable {
    catppuccin = {
      enable = true;
      flavor = cfg.flavor;
    };

    home-manager.users."${user}" = {
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
    };
  };
}