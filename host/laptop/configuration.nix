{ pkgs, ... }: let

  gaitian-nix = ../../.;
in {
  imports = [
    ./hardware.nix
    <home-manager/nixos>
    <catppuccin/modules/nixos>
    (import "${gaitian-nix}/gmodules")
    (import "${gaitian-nix}/gmodules/theme/catppuccin.nix")
  ];

  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home-manager = {
    useGlobalPkgs = false;
    users = {
      gaitian = { pkgs, ... }: {
        home.stateVersion = "24.05";
        nixpkgs.config.allowUnfree = true;
        imports = [
          <catppuccin/modules/home-manager>
        ];
      };
    };
  };

  users.users = {
    gaitian = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.fish;
    };
  };

  gmodules = {
    home.user = "gaitian";
    shell.fish.enable = true;
    utilities.enableAll = true;
    desktop.hyprland = {
      enable = true;
      monitor = [
        "DP-1, 3440x1440@120, 0x0, 1"
        "DP-2, preferred, 3120x-1080, 1.5"
        "desc:LG Display 0x06CF, 1920x1080@60, 3440x360, 1"
      ];
    };
    development = {
      idea = {
        enable = true;
        profiles = [ "java" "minecraft" ];
        hideDefaultDesktop = true;
      };
      kubernetes.enable = true;
      podman.enable = true;
    };
    network.mihomo.enable = true;
    app = {
      firefox.enable = true;
      chromium.enable = true;
      telegram.enable = true;
      obsidian.enable = true;
    };
    game = {
      minecraft.enable = true;
    };
    keyring.enable = true;
    jdks.enable = true;
  };

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "work-laptop";
  networking.networkmanager.enable = true;
  networking.resolvconf = {
    enable = true;
    extraOptions= [
      "rotate"
      "timeout:3"
    ];
  };

  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-broadcom;
    };
  };

  nix.buildMachines = [ {
    hostName = "10.0.0.10";
    protocol = "ssh-ng";
    system = "x86_64-linux";
    maxJobs = 16;
    speedFactor = 1;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    mandatoryFeatures = [ ];
  } ];
  nix.distributedBuilds = true;

  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  environment.systemPackages = with pkgs; [
    openconnect
    obs-studio
    ffmpeg
    vlc
  ];
}