{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.jdks;
in {
  options.gmodules.jdks = {
    enable = mkEnableOption "jdk";
  };

  config =
    let
      jdksHome = ".jdks";
      jdks = with pkgs; [
        # First - graalvm
        graalvm-ce

        temurin-bin-8
        temurin-bin-11
        temurin-bin-17
        openjdk17-bootstrap

        # Last - active
        temurin-bin
      ];

      graalvmJdk = pkgs.lib.elemAt jdks 0;
      currentJdk = pkgs.lib.last jdks;
    in mkIf cfg.enable {

    home-manager.users."${user}" = {
      home.sessionPath = [
        "$HOME/${jdksHome}/${currentJdk.name}-${currentJdk.version}/bin"
      ];
      home.sessionVariables = {
        JAVA_HOME = "$HOME/${jdksHome}/${currentJdk.version}";
        GRAALVM_HOME = "$HOME/${jdksHome}/${graalvmJdk.version}";
      };

      home.file = (builtins.listToAttrs (builtins.map (jdk: {
        name = "${jdksHome}/${jdk.name}-${jdk.version}";
        value = { source = jdk; };
      }) jdks));
    };
  };
}