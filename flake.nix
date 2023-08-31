{
  description = "Build fedora image with mkosi";

  inputs = {
    nixpkgs.url = "github:katexochen/nixpkgs/working";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        mkosiDev = (pkgs.mkosi.overrideAttrs (_: rec {
          src = pkgs.fetchFromGitHub {
            owner = "katexochen";
            repo = "mkosi";
            rev = "e7b6792076cd45a83f103c1df3b0b1f6d31e529c";
            hash = "sha256-xc55is5Q0/m606Bf1P4GjUl0Vg3LMLrSC75mmo5thSs=";
          };
        })).override {
          # withQemu = true;
        };

        tools = import ./tools/default.nix { inherit pkgs; };
      in
      {
        devShells = {
          mkosiFedora = import ./shells/fedora.nix { inherit pkgs mkosiDev tools; };
          mkosiUbuntu = import ./shells/ubuntu.nix { inherit pkgs mkosiDev tools; };
          mkosiDev = import ./shells/mkosi-dev.nix { inherit pkgs; };
        };

        formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
      });
}
