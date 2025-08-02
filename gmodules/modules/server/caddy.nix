{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.server.caddy;
in {
  options.gmodules.server.caddy = {
    enable = mkEnableOption "caddy";
    virtualHosts = mkOption {
      type = types.attrs;
      default = {};
    };
  };
  options.gmodules.server.host = mkOption {
    type = types.str;
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
        hash = "sha256-2D7dnG50CwtCho+U+iHmSj2w14zllQXPjmTHr6lJZ/A=";
      };
      environmentFile = "/etc/nixos/caddy.env";
      globalConfig = ''
        email galik-ya@yandex.ru
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      '';
    };
  };
}