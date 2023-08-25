{ pkgs, mkosiDev }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    # package management
    apt
    dpkg
    gnupg

    # filesystem tools
    squashfsTools # mksquashfs
    dosfstools # mkfs.vfat
    cryptsetup # dm-verity
    util-linux # flock
  ] ++ [ mkosiDev ];
}
