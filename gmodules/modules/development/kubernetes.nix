{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.development.kubernetes;
in {
  options.gmodules.development.kubernetes = {
    enable = mkEnableOption "kubernetes";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kubectl
      kubelogin-oidc
      kubernetes-helm
    ];

    home-manager.users."${user}" = {
      programs.k9s = {
        enable = true;
      };

      home.shellAliases = {
        kb = "kubectl";
      };
    };
  };
}