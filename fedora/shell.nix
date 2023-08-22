{ pkgs, ... }:
pkgs.mkShell {
  nativeBuildInputs = [
    (pkgs.mkosi.override { withQemu = true; })

    # package management
    pkgs.dnf5
    pkgs.rpm

    # filesystem tools
    pkgs.btrfs-progs # mkfs.btrfs
    pkgs.squashfsTools # mksquashfs
    pkgs.dosfstools # mkfs.vfat
    pkgs.cryptsetup # dm-verity
    pkgs.util-linux # flock
  ];
}
