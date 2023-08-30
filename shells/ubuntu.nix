{ pkgs, mkosiDev, tools }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    # package management
    apt
    dpkg
    gnupg

    # filesystem tools
    squashfsTools # mksquashfs
    dosfstools # mkfs.vfat
    mtools # mcopy
    cryptsetup # dm-verity
    util-linux # flock
  ] ++ [ mkosiDev tools.extract ];
}
