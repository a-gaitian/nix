{ pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics = {
    enable = true;
  };

  virtualisation.vmVariant.virtualisation = {
    cores = 4;
    memorySize = 4096;
    qemu.options = [
      "-display gtk,gl=off,zoom-to-fit=on"
    ];
  };
}