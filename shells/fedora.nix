{ pkgs, tools, mkosi ? pkgs.mkosi }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    # package management
    dnf5
    rpm

    # filesystem tools
    btrfs-progs # mkfs.btrfs
    squashfsTools # mksquashfs
    dosfstools # mkfs.vfat
    mtools # mcopy
    cryptsetup # dm-verity
    util-linux # flock
  ] ++ [ mkosi tools.extract ];
}
