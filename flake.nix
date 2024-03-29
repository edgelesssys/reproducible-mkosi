{
  description = "Build bit-by-bit reproducible OS images with mkosi";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };

      # mkosi, built from main. Used for the daily e2e test.
      mkosi-nightly = (pkgs.mkosi.overrideAttrs (oldAttrs: {
        version = "unstable-2024-02-02";
        src = pkgs.fetchFromGitHub {
          owner = "systemd";
          repo = "mkosi";
          rev = "d3b035a1e1cef4f744d982b6187cbfd07894dd5b";
          hash = "sha256-lS9RBmt2RUpbCYD/5nuTD5MZudl31J2c+uFWvq+re2Q=";
        };
        patches = [ ];
      })).override {
        # Uncomment the following line to build mkosi from main with QEMU support.
        # withQemu = true;
      };

      tools = import ./tools/default.nix { inherit pkgs; };
    in
    {
      packages = {
        inherit mkosi-nightly;

        # extract extracts partions from a disk image based on the partition table.
        extract = tools.extract;

        # diffimage builds two mkosi images, extracts and compares them.
        diffimage = tools.diffimage;
      };

      # Activate a devShell using `nix develop .#<shell-name>`.
      devShells = {
        # Build environments for reproducible mkosi builds.
        # Contain mkosi and tools used by mkosi to build images.
        mkosi-fedora = import ./shells/fedora.nix { inherit pkgs tools; };
        mkosi-ubuntu = import ./shells/ubuntu.nix { inherit pkgs tools; };

        # Build environments for reproducible mkosi builds with QEMU support,
        # enabling `mkosi qemu` to start the built image in a local VM.
        mkosi-fedora-qemu = import ./shells/fedora.nix { inherit pkgs tools; mkosi = pkgs.mkosi-full; };
        mkosi-ubuntu-qemu = import ./shells/ubuntu.nix { inherit pkgs tools; mkosi = pkgs.mkosi-full; };

        # Build environments using the nightly mkosi builds (for testing).
        mkosi-fedora-nightly = import ./shells/fedora.nix { inherit pkgs tools; mkosi = mkosi-nightly; };
        mkosi-ubuntu-nightly = import ./shells/ubuntu.nix { inherit pkgs tools; mkosi = mkosi-nightly; };

        # Development envionment for hacking on mkosi.
        mkosi-dev = import ./shells/mkosi-dev.nix { inherit pkgs; };
      };

      # Run `nix fmt` to format the Nix code.
      formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    });
}
