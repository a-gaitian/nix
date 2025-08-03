{ lib, ... }: let

hddDisks = [
  "/dev/disk/by-id/ata-ST1000LM035-1RK172_WDEBB3PF"
  "/dev/disk/by-id/ata-WDC_WD10EARS-00Y5B1_WD-WMAV50945020"
  "/dev/disk/by-id/ata-WDC_WD10EZEX-60WN4A0_WD-WCC6Y7HE2RC7"
  "/dev/disk/by-id/ata-WDC_WD10EZEX-22MFCA0_WD-WCC6Y1TFJE6T"
];

in {
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.kernelModules = [ "zfs" ];
  boot.zfs.extraPools = [ "storage" ];
  disko.devices = {
    disk = rec {
      disk0 = {
        type = "disk";
        device = builtins.elemAt hddDisks 0;
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };
      disk1 = lib.recursiveUpdate disk0 { device = builtins.elemAt hddDisks 1; };
      disk2 = lib.recursiveUpdate disk0 { device = builtins.elemAt hddDisks 2; };
      disk3 = lib.recursiveUpdate disk0 { device = builtins.elemAt hddDisks 3; };
    };
    zpool = {
      storage = {
        type = "zpool";
        mode = "raidz1";
        options.cachefile = "none";
        mountpoint = null;
        datasets = {
          storage = {
            type = "zfs_fs";
            options = {
              mountpoint = "/storage";
              canmount = "on";
            };
          };
        };
      };
    };
  };
}