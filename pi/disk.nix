# Specify the disk layout.
{
  disko.devices.disk.pi = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        firmware = {
          # Set the partition type to Microsoft basic data.
          # Needed for booting.
          type = "0700";
          size = "1G";
          content = {
            type = "filesystem";
            format = "vfat";
            # This should match boot.loader.raspberry-pi.firmwarePath.
            mountpoint = "/boot/firmware";
            mountOptions = ["noatime"];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            subvolumes = {
              root = {
                mountpoint = "/";
                mountOptions = [
                  # Use zstd compression.
                  # This option is filesystem-wide.
                  # It doesn't need to be repeated for other mountpoints.
                  "compress=zstd"
                  "noatime"
                ];
              };
              # Swap files on btrfs need their own subvolume (no copy-on-write or snapshots).
              swap = {
                mountpoint = "/swap";
                swap.swapfile.size = "8G";
              };
              nix = {
                mountpoint = "/nix";
                mountOptions = ["noatime"];
              };
              "var/lib" = {
                mountpoint = "/var/lib";
                mountOptions = ["noatime"];
              };
            };
          };
        };
      };
    };
  };
}
