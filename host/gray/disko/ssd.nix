{ ... }: let

ssdDisk = "/dev/disk/by-id/nvme-SK_hynix_BC501_HFM256GDJTNG-8310A_NY9BN05301010C53Y";

in {
  disko.devices = {
    disk = {
      storage-fast = {
        device = ssdDisk;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            storage-fast = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/storage-fast";
              };
            };
          };
        };
      };
    };
  };
}