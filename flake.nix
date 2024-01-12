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
      mkosi-nightly = (pkgs.mkosi.overrideAttrs (oldAttrs: rec {
        version = "unstable-2023-10-30";
        src = pkgs.fetchFromGitHub {
          owner = "systemd";
          repo = "mkosi";
          rev = "ea3e947eb89940c08bc1fad3a933aa3e05c16511";
          # Using sha256 here so it can be updated by update-nix-fetchgit.
          sha256 = "sha256-wadAHOAo1t7HjUZ+RJ3UvSG0vGIlrZnpvT/aneo/8IE=";
        };
      })).override {
        # Uncomment the following line to build mkosi from main with QEMU support.
        # withQemu = true;
      };

      tools = import ./tools/default.nix { inherit pkgs; };
    in
    {
      packages = {
        inherit mkosi-nightly;
        extract = tools.extract;
        diffimage = tools.diffimage;
      };

      devShells = {
        mkosi-fedora = import ./shells/fedora.nix { inherit pkgs tools; };
        mkosi-ubuntu = import ./shells/ubuntu.nix { inherit pkgs tools; };
        mkosi-fedora-qemu = import ./shells/fedora.nix { inherit pkgs tools; mkosi = pkgs.mkosi-full; };
        mkosi-ubuntu-qemu = import ./shells/ubuntu.nix { inherit pkgs tools; mkosi = pkgs.mkosi-full; };
        mkosi-fedora-nightly = import ./shells/fedora.nix { inherit pkgs tools; mkosi = mkosi-nightly; };
        mkosi-ubuntu-nightly = import ./shells/ubuntu.nix { inherit pkgs tools; mkosi = mkosi-nightly; };
        mkosi-dev = import ./shells/mkosi-dev.nix { inherit pkgs; };
      };

      formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    });
}
