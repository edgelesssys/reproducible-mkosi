{ pkgs, lib, ... }:
{
  boot = {
    loader.systemd-boot.enable = true;
    initrd.availableKernelModules = [ "nvme" ];
    # TODO: correctly import ena module
    # extraModulePackages = [ boot.kernelPackages.ena ];
  };

  systemd.network.enable = true;
  networking.useDHCP = true;

  # debugging
  # boot.kernelParams = [ "rescue" "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1" ];
  # services.getty.autologinUser = "root";

  environment.systemPackages = with pkgs; [
    btop
  ];

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
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "@" = {
                mountpoint = "/";
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = [ "compress=zstd" ];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
            };
          };
        };
      };
    };
  };
}
