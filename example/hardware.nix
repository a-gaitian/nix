{ pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics = {
    enable = true;
  };

  virtualisation.vmVariant.virtualisation = {
    cores = 4;
    memorySize = 8192;
    qemu.options = [
      "-display gtk,gl=off,zoom-to-fit=on"
    ];
  };
}