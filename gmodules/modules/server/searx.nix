{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  host = config.gmodules.server.host;
  host-email = config.gmodules.server.host-email;
  storage = config.gmodules.server.storage.main;
  fastStorage = config.gmodules.server.storage.fast;
  cfg = config.gmodules.server.searx;
in {
  options.gmodules.server.searx = {
    enable = mkEnableOption "searx";
  };

  config = mkIf cfg.enable {
    services.searx = {
      enable = true;
      redisCreateLocally = true;
      runInUwsgi = true;

      limiterSettings = {
        real_ip = {
          x_for = 1;
          ipv4_prefix = 32;
          ipv6_prefix = 56;
        };

        botdetection = {
          ip_limit = {
            filter_link_local = true;
            link_token = true;
          };
        };
      };
      settings.server = {
        # Instance settings
        general = {
          debug = false;
          instance_name = "SearXNG";
          donation_url = false;
          contact_url = false;
          privacypolicy_url = false;
          enable_metrics = false;
        };

        # User interface
        ui = {
          static_use_hash = true;
          default_locale = "en";
          query_in_title = true;
          infinite_scroll = false;
          center_alignment = true;
          default_theme = "simple";
          theme_args.simple_style = "auto";
          search_on_category_select = true;
          hotkeys = "default";
        };

        # Search engine settings
        search = {
          safe_search = 0;
          autocomplete_min = 3;
          autocomplete = "google";
          favicon_resolver = "google";
          ban_time_on_fail = 5;
          max_ban_time_on_fail = 120;
        };

        # Server configuration
        server = {
          base_url = "https://search.${host}";
          port = 64712;
          bind_address = "127.0.0.1";
          secret_key = "AAzPuJgRWkhDvlIgtoXDr3KO";
          limiter = true;
          public_instance = true;
          image_proxy = true;
          method = "GET";
        };
      };
    };
     services.caddy.virtualHosts."search.${host}".extraConfig = ''
       reverse_proxy localhost:64712
     '';
  };
}