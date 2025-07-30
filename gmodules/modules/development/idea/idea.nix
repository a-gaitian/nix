{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  userHome = config.users.users."${user}".home;
  cfg = config.gmodules.development.idea;

  idea = with pkgs; jetbrains.plugins.addPlugins
    (jetbrains.idea-ultimate.override { forceWayland = true; })
    [
     "catppuccin-theme"
     "catppuccin-icons"
     "nixidea"
     "string-manipulation"
    ];

  baseProfilePath = ".config/JetBrains";

  mkIdeaProfiles = profiles:
    builtins.listToAttrs (builtins.concatLists (
      map (profile:
      let
        profilePath = "${baseProfilePath}/${profile}";
        executableFile = "${profilePath}/idea-${profile}.sh";
      in
      [
        {
          name = executableFile;
          value = {
            text = ''
              #!/bin/sh
              exec ${idea}/bin/idea-ultimate \
                -Didea.config.path=${userHome}/${profilePath}/config \
                -Didea.system.path=${userHome}/${profilePath}/system \
                -Didea.plugins.path=${userHome}/${profilePath}/plugins \
                -Didea.log.path=${userHome}/${profilePath}/log "$@"
            '';
            executable = true;
          };
        }
        {
          name = ".local/share/applications/idea-${profile}.desktop";
          value = {
            text = ''
              [Desktop Entry]
              Name=IntelliJ IDEA (${profile})
              Exec=${userHome}/${executableFile} %f
              Icon=jetbrains-idea
              Type=Application
              Categories=Development;IDE;
            '';
          };
        }
      ]) profiles
    ));
in {
  options.gmodules.development.idea = {
    enable = mkEnableOption "idea";
    profiles = mkOption {
      type = types.listOf types.str;
      description = "IntelliJ IDEA custom profiles";
      default = [];
      example = [ "java" "kotlin" ];
    };
    hideDefaultDesktop = mkEnableOption "Hide default .desktop entry";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ idea ];

    home-manager.users."${user}" = {
      home.file = mkIdeaProfiles cfg.profiles;
      xdg.desktopEntries.idea-ultimate = mkIf cfg.hideDefaultDesktop {
        name = "disabled";
        noDisplay = cfg.hideDefaultDesktop;
      };
    };
  };
}