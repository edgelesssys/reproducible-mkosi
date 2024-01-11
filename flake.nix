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
      pkgsUnstable = import nixpkgs { inherit system; };

      mkosiDev = pkgsUnstable.mkosi;
      mkosiDevFull = pkgsUnstable.mkosi-full;
      mkosiNightly = (pkgsUnstable.mkosi.overrideAttrs (oldAttrs: rec {
        version = "unstable-2023-10-30";
        src = pkgsUnstable.fetchFromGitHub {
          owner = "systemd";
          repo = "mkosi";
          rev = "ea3e947eb89940c08bc1fad3a933aa3e05c16511";
          # Using sha256 here so it can be updated by update-nix-fetchgit.
          sha256 = "sha256-wadAHOAo1t7HjUZ+RJ3UvSG0vGIlrZnpvT/aneo/8IE=";
        };
        patches = [ ];
      })).override {
        # withQemu = true;
      };

      tools = import ./tools/default.nix { pkgs = pkgsUnstable; };
    in
    {
      packages = {
        mkosi-nightly = mkosiNightly;
        extract = tools.extract;
        diffimage = tools.diffimage;
      };

      devShells = {
        mkosiFedora = import ./shells/fedora.nix { pkgs = pkgsUnstable; inherit mkosiDev tools; };
        mkosiUbuntu = import ./shells/ubuntu.nix { pkgs = pkgsUnstable; inherit mkosiDev tools; };
        mkosiFedoraQemu = import ./shells/fedora.nix { pkgs = pkgsUnstable; mkosiDev = mkosiDevFull; inherit tools; };
        mkosiUbuntuQemu = import ./shells/ubuntu.nix { pkgs = pkgsUnstable; mkosiDev = mkosiDevFull; inherit tools; };
        mkosiDev = import ./shells/mkosi-dev.nix { pkgs = pkgsUnstable; };
        mkosi-fedora-nightly = import ./shells/fedora.nix { pkgs = pkgsUnstable; mkosiDev = mkosiNightly; inherit tools; };
        mkosi-ubuntu-nightly = import ./shells/ubuntu.nix { pkgs = pkgsUnstable; mkosiDev = mkosiNightly; inherit tools; };
      };

      formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    });
}
