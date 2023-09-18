{ pkgs, lib, ... }:
{
  boot = {
    loader.systemd-boot.enable = true;
    initrd.availableKernelModules = [ "nvme" ];
  };

  # debugging
  # boot.kernelParams = [ "rescu" "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1" ];
  # services.getty.autologinUser = "root";

  disko.devices.disk.nvme0n1 = {
    device = "/dev/nvme0n1";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          size = "500M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
