{pkgs, ...}:
  pkgs.mkShell {
    nativeBuildInputs = [
      pkgs.mkosi

      # package management
      pkgs.dnf5

      # filesystem tools
      pkgs.squashfsTools # mksquashfs
      pkgs.dosfstools # mkfs.vfat
      pkgs.cryptsetup # dm-verity
      pkgs.util-linux # flock
    ];
  }
