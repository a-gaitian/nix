{ pkgs, config, lib, ... }:

let
  rootDisk = "/dev/disk/by-id/nvme-X15_SSD_256GB_AA000000000000000032";

  sshPubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOUDeTLyvcsAAf2cKNd/LB+wFnwhK1M9w4nnAko6g1SO gaityan@pulse.insure"
  ];

  sources = import ./npins;
  gaitian-nix = ../../.;
in
{
  system.stateVersion = "25.05";
  imports = [
    (sources.disko + "/module.nix")
    (import "${gaitian-nix}/gmodules")
    (import "${gaitian-nix}/gmodules/imports/minecraft.nix")
    (sources.home-manager + "/nixos")
    ./disko/single-disk-layout.nix
    ./disko/raidz1.nix
    ./disko/ssd.nix
    (import sources.nix-minecraft).outputs.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [
    (import sources.nix-minecraft).outputs.overlay
  ];

  # Hardware
  boot.loader.grub = {
    devices = [ rootDisk ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  networking.hostName = "gray";
  networking.hostId = "0B2DC7D0";

  # Kiosk
  users.users.kiosk = {
    isNormalUser = true;
  };
  services.getty = {
    autologinUser = "kiosk";
    autologinOnce = true;
  };
  environment.loginShellInit = ''
    if [ "$(tty)" = "/dev/tty1" ] && [ -t 0 ] && [ "$USER" = kiosk ]; then
      exec btop
    fi
  '';

  # SSH
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = sshPubKeys;

  # NFS
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /storage/share  10.0.0.1/24(rw,no_subtree_check)
  '';

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    users = {
      root = { pkgs, ... }: {
        home.stateVersion = "25.05";
        home.homeDirectory = "/root";
        nixpkgs.config.allowUnfree = true;
      };
    };
  };

  users.users.root.shell = pkgs.fish;

  gmodules = {
    home.user = "root";
    shell.fish.enable = true;
    utilities.enableAll = true;
    network.rclone.enable = true;
    development.podman.enable = true;
    server = {
      inherit sshPubKeys;
      host = "gaitian.dev";
      storage = {
        main = "/storage";
        fast = "/storage-fast";
      };
      caddy.enable = true;
      remote-builder.enable = true;
      minecraft.enable = true;
      postgresql.enable = true;
      nextcloud.enable = true;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      80 443 2049
    ];
    allowedUDPPorts = [

    ];
  };

  environment.systemPackages = with pkgs; [
    btop
    fuc
    ncdu
  ];
}