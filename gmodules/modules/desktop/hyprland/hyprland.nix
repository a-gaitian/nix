
{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.desktop.hyprland;
  terminal = config.gmodules.desktop.terminal.default;
in {
  options.gmodules.desktop.hyprland = {
    enable = mkEnableOption "hyprland";
    monitor = mkOption {
      type = types.listOf types.str;
      description = "List of Hyprland 'monitor' values";
      default = [ ",preferred,auto,1" ];
      example = [ "DP-1, preferred, -1920x0, 1.5" ];
    };
    workspace = mkOption {
      type = types.listOf types.str;
      description = "List of Hyprland 'workspace' values";
      default = [ ];
      example = [ "1, name:Firefox, rounding:false, gapsin:0, gapsout:0, border:false, on-created-empty:firefox" ];
    };
    overrideSettings = mkOption {
      type = types.attrs;
      description = "Complete wayland.windowManager.hyprland.settings override";
      default = { };
    };
  };

  config = mkIf cfg.enable {
    gmodules.desktop = {
      headless = false;
      rofi.enable = true;
      swaync.enable = true;
    };

    services.xserver.enable = true;
    xdg.portal.enable = true;
    services.xserver.excludePackages = [ pkgs.xterm ];
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = ''${pkgs.greetd.tuigreet}/bin/tuigreet \
            --cmd Hyprland \
            --remember \
            --time
            '';
          user = "greeter";
        };
      };
    };

    programs.hyprland = {
      enable = true;
    };

    home-manager.users."${user}" = {

      qt.enable = true;
      gtk.enable = true;

      home.packages = with pkgs; [
        grimblast
        networkmanagerapplet
        nautilus
        playerctl
        brightnessctl
      ];

      wayland.windowManager.hyprland.plugins = with pkgs.hyprlandPlugins; [
        hyprsplit
        hyprexpo
      ];

      programs.wlogout = {
        enable = true;
      };

      wayland.windowManager.hyprland.enable = true;
      wayland.windowManager.hyprland.settings =
          if cfg.overrideSettings != { }
            then cfg.overrideSettings else {

        monitor = cfg.monitor;
        workspace = cfg.workspace;

        plugin = {
          hyprsplit = {
            num_workspaces = 4;
            persistent_workspaces = true;
          };
          hyprexpo = {
            columns = 2;
            gesture_positive = false;
          };
        };

        xwayland = {
          # Disable default scaling
          # use specific in env.GDK_SCALE etc.
          force_zero_scaling = true;
        };

        env = [
          #  Style
          # XWayland toolkit-specific scale
          # GDK 3/GTK 3 - integer will work, float may be ignored
          "GDK_SCALE,1"
          "NIXOS_OZONE_WL,1"
          "ELECTRON_OZONE_PLATFORM_HINT,wayland"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"

          # Icons
          "XDG_DATA_DIRS,$XDG_DATA_DIRS:/home/${user}/.local/share"
        ];

        input = {
          kb_layout = "us,ru";
          kb_options = "grp:alt_shift_toggle";

          touchpad = {
            natural_scroll = true;
          };
        };

        binds = {
          scroll_event_delay = 100;
        };

        gestures = {
          workspace_swipe = true;
        };

        misc = {
          animate_manual_resizes = true;
          animate_mouse_windowdragging = true;
          focus_on_activate = true;
        };

        ecosystem = {
          no_update_news = true;
        };

        decoration = {
          rounding = 16;
        };

        general = {
          "col.active_border" = "0xff363a4f";
          "col.inactive_border" = "0x00000000";
          layout = "dwindle";
        };

        dwindle = {
          smart_split = true;
        };

        exec-once = [
          "swaync"
          "xrandr --output ${builtins.elemAt (builtins.split "," (if builtins.length cfg.monitor > 0 then builtins.elemAt cfg.monitor 0 else "")) 0} --primary"
        ];

        windowrule = [
          "rounding 0, class:^(Rofi)$"
        ];

        "$mod" = "SUPER";
        "$alt" = "ALT";
        "$move" = "SHIFT";
        "$resize" = "CTRL";

        # Repeated and on lock screen
        bindel = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 0.1+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 0.1-"
          ", XF86MonBrightnessUp,  exec, brightnessctl set 5%+ "
          ", XF86MonBrightnessDown,exec, brightnessctl set 5%-"
        ];

        # On lock screen
        bindl = [
          ", XF86AudioPlay,       exec, playerctl play-pause"
        ];

        bind =
          [
            # General
            "$mod,  T,            exec, rofi -show combi -combi-modes drun,window,ssh -sidebar-mode"
            "$mod,  RETURN,       exec, ${terminal}"
            "$mod,  ESCAPE,       exec, wlogout"

            # Special
            "$mod,  Q,            killactive"
            "$mod,  F,            fullscreen"
            "$mod,  L,            togglefloating"
            "$mod,  P,            pin"
            "$mod,  S,            exec, grimblast copy area"
            "$mod $move, S,       exec, grimblast copy area --freeze"
            "$mod $resize, S,     exec, grimblast copy output"
            "$mod,  N,            exec, swaync-client -t -s"

            "$mod, mouse:274,     exec, hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 + 0.5}')\""
            "$mod $alt, mouse:274,exec, hyprctl keyword cursor:zoom_factor 1.0"

            ##### Window #####

            # Window focus
            "$mod, left,          movefocus, l"
            "$mod, right,         movefocus, r"
            "$mod, up,            movefocus, u"
            "$mod, down,          movefocus, d"

            # Window move
            "$mod $move, left,    movewindow, l"
            "$mod $move, right,   movewindow, r"
            "$mod $move, up,      movewindow, u"
            "$mod $move, down,    movewindow, d"

            # Window resize
            "$mod $resize, left,  resizeactive, -50   0"
            "$mod $resize, right, resizeactive,  50   0"
            "$mod $resize, up,    resizeactive,  0   -50"
            "$mod $resize, down,  resizeactive,  0    50"

            ##### Workspace #####

            "$mod, mouse_right,   split:workspace, r+1"
            "$mod, mouse_left,    split:workspace, r-1"

            "$mod $alt, right,    split:workspace, r+1"
            "$mod $alt, left,     split:workspace, r-1"

            "$mod, tab,           hyprexpo:expo, toggle"

            # Workspace
            "$mod, 1,             split:workspace, 1"
            "$mod, 2,             split:workspace, 2"
            "$mod, 3,             split:workspace, 3"
            "$mod, 4,             split:workspace, 4"

            # Workspace move
            "$mod $move, 1,       split:movetoworkspace, 1"
            "$mod $move, 2,       split:movetoworkspace, 2"
            "$mod $move, 3,       split:movetoworkspace, 3"
            "$mod $move, 4,       split:movetoworkspace, 4"
          ];

          bindm = [
            # Mouse
            "$mod, mouse:272,     movewindow"
            "$mod, mouse:273,     resizewindow"
          ];
      };
      wayland.windowManager.hyprland.extraConfig = ''
        bindl = , XF86AudioPlay, exec, sleep 0.2 && hyprctl dispatch submap reset
        bindl = , XF86AudioPlay, submap, double_click_play
        submap = double_click_play
        bindl = , XF86AudioPlay, exec, playerctl next
        submap = reset
      '';
    };
  };
}