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
    useGlobalPkgs = true;
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

  fileSystems."/share" = {
    device = "10.0.0.10:/storage/share";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
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
    network = {
      mihomo = {
        enable = true;
        configFile = ./mihomo.yaml;
      };
      rclone.enable = true;
    };
    app = {
      firefox.enable = true;
      chromium.enable = true;
      telegram.enable = true;
      obsidian.enable = true;
    };
    game = {
      minecraft.enable = true;
      lutris.enable = true;
    };
    keyring.enable = true;
    jdks.enable = true;
    bitwarden.enable = true;
  };

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "work-laptop";
  networking.networkmanager.enable = true;
#  networking.resolvconf = {
#    enable = true;
#    extraOptions= [
#      "rotate"
#      "timeout:3"
#    ];
#  };

  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-broadcom;
    };
  };

  nix.buildMachines = [ {
    hostName = "10.0.0.10";
    sshUser = "nix-remote";
#    sshKey = "/home/gaitian/.ssh/id_ed25519";
    protocol = "ssh";
    speedFactor = 1;
    maxJobs = 16;
    system = "x86_64-linux";
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    mandatoryFeatures = [ ];
  } ];
  nix.distributedBuilds = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };
  nix.settings = {
    builders-use-substitutes = true;
    auto-optimise-store = true;
    substituters = [
      "https://cache.gaitian.dev"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.gaitian.dev:PYy5ClYQBITMMUVWJ82uMGcBDMZK9l2nOhc0/f9tKvQ="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  security.pki.certificateFiles = [
    ./mitmproxy-ca-cert.pem
  ];

  programs.steam = {
    enable = true;
  };

  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-7.0.20"
  ];

  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-runtime_7}/share/dotnet";
  };

  environment.systemPackages = with pkgs; [
    openconnect
    obs-studio
    ffmpeg
    vlc
    mitmproxy
    python3
    transmission_4-qt
    dotnet-runtime_7
    vesktop
    godot
    aseprite
    gimp
    blueman
    vulkan-tools
  ];
  programs.amnezia-vpn.enable = true;
}
