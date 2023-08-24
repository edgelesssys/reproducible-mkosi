{ pkgs, ... }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    ((mkosi.overrideAttrs (_: rec {
      src = fetchFromGitHub {
        owner = "systemd";
        repo = "mkosi";
        rev = "aff069b5a2c3eec676f436129944fa8b323df0d9";
        hash = "sha256-dcYdCK1+HN/p5cvViKxEFecMZ0DigMz3uXuZic6dwLA=";
      };
    })).override
      { withQemu = true; })

    # package management
    apt
    dpkg
    gnupg

    # filesystem tools
    squashfsTools # mksquashfs
    dosfstools # mkfs.vfat
    cryptsetup # dm-verity
    util-linux # flock
  ];
}
