{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.keyring;
in {
  options.gmodules.keyring = {
    enable = mkEnableOption "keyring";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = if config.gmodules.desktop.headless
      then [ pkgs.pinentry ]
      else [ pkgs.pinentry-qt ];

    programs.ssh.startAgent = true;

    programs.gnupg.agent.enable = true;

    security.pam.services = {
      greetd.enableGnomeKeyring = true;
      greetd-password.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
    };
    services.dbus.packages = [ pkgs.gnome-keyring pkgs.gcr ];

    programs.seahorse.enable = ! config.gmodules.desktop.headless;

    home-manager.users."${user}" = {
      services.gnome-keyring = {
        enable = true;
        components = [ "pkcs11" "secrets" "ssh" ];
      };
    };
  };
}