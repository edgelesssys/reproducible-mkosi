{ pkgs, ... }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    ((mkosi.overrideAttrs (_: rec {
      src = fetchFromGitHub {
        owner = "malt3";
        repo = "mkosi";
        rev = "de380587ce65903eaf09397e4dfe5ea53de0c66e";
        hash = "sha256-LHPDfkSYQsK1HDFZHdG1jP75lzwisM6KE6cFj4VSeBQ=";
      };
    })).override
      { withQemu = true; })

    # package management
    dnf5
    rpm

    # filesystem tools
    btrfs-progs # mkfs.btrfs
    squashfsTools # mksquashfs
    dosfstools # mkfs.vfat
    cryptsetup # dm-verity
    util-linux # flock
  ];
}
