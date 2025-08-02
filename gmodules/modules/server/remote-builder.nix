{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  host = config.gmodules.server.host;
  sshPubKeys = config.gmodules.server.sshPubKeys;
  cfg = config.gmodules.server.remote-builder;
in {
  options.gmodules.server.remote-builder = {
    enable = mkEnableOption "remote-builder";
  };

  config = mkIf cfg.enable {
    users.users.nix-remote = {
      isNormalUser = true;
      createHome = false;
      group = "nix-remote";
      openssh.authorizedKeys.keys = sshPubKeys;
    };
    users.groups.nix-remote = { };
    nix = {
      nrBuildUsers = 64;
      settings = {
        trusted-users = [ "nix-remote" ];
        auto-optimise-store = true;

        min-free = "32G";
        max-free = "128G";

        max-jobs = "auto";
        cores = 0;
      };
    };
    systemd.services.nix-daemon.serviceConfig = {
      MemoryAccounting = true;
      MemoryMax = "90%";
      OOMScoreAdjust = 500;
    };
    services.nix-serve = {
      enable = true;
      secretKeyFile = "/var/secrets/private-cache-key.pem";
    };
    services.caddy.virtualHosts."cache.${host}".extraConfig = ''
      reverse_proxy http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}
    '';
  };
}