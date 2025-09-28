{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.jellyfin;
in {
  options.gmodules.server.jellyfin = {
    enable = mkEnableOption "jellyfin";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
    ];
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      dataDir = "${fastStorage}/jellyfin";
    };
    services.caddy.virtualHosts."jellyfin.${host}".extraConfig = ''
      reverse_proxy localhost:8096
    '';

    services.jellyseerr = {
      enable = true;
      package = (pkgs.jellyseerr.overrideAttrs (oldAttrs: rec {
        version = "preview-OIDC";
        src = pkgs.fetchFromGitHub {
          owner = "Fallenbagel";
          repo = "jellyseerr";
          tag = "preview-OIDC";
          hash = "sha256-EJz1W7ewEczizNRs/X3esjQUwJiTHruo7nkAzyKZbjc=";
        };
        pnpmDeps = ((pkgs.pnpm_9.override { nodejs = pkgs.nodejs_22; }).fetchDeps {
          inherit (oldAttrs) pname;
          inherit version src;
          fetcherVersion = 1;
          hash = "sha256-yjrlZfObAMj9WOywlsP51wNrbUNh8m1RxtbkjasnEW4=";
        });
      }));
    };
    services.caddy.virtualHosts."jellyseerr.${host}".extraConfig = ''
      reverse_proxy localhost:5055
    '';
  };
}