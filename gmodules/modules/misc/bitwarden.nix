{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.bitwarden;
in {
  options.gmodules.bitwarden = {
    enable = mkEnableOption "bitwarden";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bitwarden
      bitwarden-cli
      bitwarden-desktop
    ];
    environment.sessionVariables = {
      SSH_AUTH_SOCK = "/home/${user}/.bitwarden-ssh-agent.sock";
    };
  };
}