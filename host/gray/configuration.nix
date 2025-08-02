{ pkgs, config, ... }:

let
  diskDevice = "/dev/nvme1n1";
  sources = import ./npins;

  sshPubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOUDeTLyvcsAAf2cKNd/LB+wFnwhK1M9w4nnAko6g1SO gaityan@pulse.insure"
  ];

  gaitian-nix = ../../.;
in
{
  system.stateVersion = "25.05";
  imports = [
    (sources.disko + "/module.nix")
    ./single-disk-layout.nix
    (import "${gaitian-nix}/gmodules")
    (sources.home-manager + "/nixos")
  ];

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  networking.hostName = "gray";

  # Hardware
  disko.devices.disk.main.device = diskDevice;
  boot.loader.grub = {
    devices = [ diskDevice ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # SSH
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = sshPubKeys;

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
    server = {
      inherit sshPubKeys;
      host = "gaitian.dev";
      caddy.enable = true;
      remote-builder.enable = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  environment.systemPackages = with pkgs; [
    btop
    fuc
  ];
}