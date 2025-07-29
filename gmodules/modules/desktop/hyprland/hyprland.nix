{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  globalCfg = config;
  cfg = config.gmodules.desktop.hyprland;
  terminal = config.gmodules.desktop.terminal.default;
in {
  options.gmodules.desktop.hyprland = {
    enableFor = glib.mkEnableForOption "hyprland";
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

  config = mkIf (length cfg.enableFor > 0) {
    gmodules.desktop.headless = false;
    gmodules.desktop.rofi.enableFor = cfg.enableFor;

    services.xserver.enable = true;
    xdg.portal.enable = true;

    services.xserver.excludePackages = [ pkgs.xterm ];

    programs.hyprland = {
      enable = true;
    };

    home-manager.users = glib.usersConfig cfg.enableFor (user: {

      qt.enable = true;
      gtk.enable = true;

      home.packages = with pkgs; [
        grimblast
        networkmanagerapplet
        nautilus
        playerctl
        brightnessctl
      ];

      wayland.windowManager.hyprland.enable = true;
      wayland.windowManager.hyprland.settings =
          if cfg.overrideSettings != { }
            then cfg.overrideSettings else {

        monitor = cfg.monitor;
        workspace = cfg.workspace;

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
          "WLR_NO_HARDWARE_CURSORS,1"
          "NIXOS_OZONE_WL,1"
          "ELECTRON_OZONE_PLATFORM_HINT,wayland"

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
            # Apps
            "$mod,  T,            exec, rofi -show drun"
            "$mod,  RETURN,       exec, ${terminal}"

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

            "$mod, mouse_right,   workspace, +1"
            "$mod, mouse_left,    workspace, -1"

            "$mod $alt, right,    workspace, +1"
            "$mod $alt, left,     workspace, -1"

            # Workspace
            "$mod, 1,             workspace, 1"
            "$mod, 2,             workspace, 2"
            "$mod, 3,             workspace, 3"
            "$mod, 4,             workspace, 4"
            "$mod, 5,             workspace, 5"
            "$mod, 6,             workspace, 6"
            "$mod, 7,             workspace, 7"
            "$mod, 8,             workspace, 8"
            "$mod, 9,             workspace, 9"
            "$mod, 0,             workspace, 10"

            # Workspace move
            "$mod $move, 1,       movetoworkspace, 1"
            "$mod $move, 2,       movetoworkspace, 2"
            "$mod $move, 3,       movetoworkspace, 3"
            "$mod $move, 4,       movetoworkspace, 4"
            "$mod $move, 5,       movetoworkspace, 5"
            "$mod $move, 6,       movetoworkspace, 6"
            "$mod $move, 7,       movetoworkspace, 7"
            "$mod $move, 8,       movetoworkspace, 8"
            "$mod $move, 9,       movetoworkspace, 9"
            "$mod $move, 0,       movetoworkspace, 10"
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
    });
  };
}