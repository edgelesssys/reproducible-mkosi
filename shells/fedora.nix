{ pkgs, ... }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    ((mkosi.overrideAttrs (_: rec {
      src = fetchFromGitHub {
        owner = "malt3";
        repo = "mkosi";
        rev = "00073162dc1c8911cc41eba14e3fd31ed33e85ed";
        hash = "sha256-F5sDaRpneqb+RrTHUO8mOriqySpHA8Ays5UYlgGcX1c=";
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
