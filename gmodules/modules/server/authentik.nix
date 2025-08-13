{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  mainStorage = config.gmodules.server.storage.main;
  cfg = config.gmodules.server.authentik;

  authentik-nix = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/authentik-nix/archive/version/2025.6.4.tar.gz";
    sha256 = "1ah7f7hn9wf3g1lgwblpi5fv7r22hvp0m8sndwicm3j5n6kcxv8q";
  });
in {
  options.gmodules.server.authentik = {
    enable = mkEnableOption "authentik";
  };

  imports = [
    authentik-nix.nixosModules.default
  ];

  config = mkIf cfg.enable {
    services.authentik = {
      enable = true;
      environmentFile = "/var/secrets/authentik.env";
      settings = {
        email = {
          host = "mail.${host}";
          use_tls = true;
          username = "authentik@${host}";
          from = "authentik@${host}";
        };
        disable_startup_analytics = true;
        avatars = "initials";
      };
    };
    services.caddy.virtualHosts."authentik.${host}".extraConfig = ''
      reverse_proxy localhost:9000
    '';
  };
}