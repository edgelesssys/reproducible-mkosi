{
  description = "Build fedora image with mkosi";

  inputs = {
    nixpkgs.url = "github:katexochen/nixpkgs/working";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };

      mkosiDev = (pkgs.mkosi.overrideAttrs (_: rec {
        src = pkgs.fetchFromGitHub {
          owner = "katexochen";
          repo = "mkosi";
          rev = "6e61f2808cdec7f4620f9735ebbbc1ad12a1e74d";
          hash = "sha256-2Z9AmltoIBW1qQvzlBo+iNfq+zb9UMUqy3Qkm6TMuhM=";
        };
      })).override { withQemu = true; };
    in
    {
      devShells."${system}" = {
        mkosiFedora = import ./shells/fedora.nix { inherit pkgs mkosiDev; };
        mkosiUbuntu = import ./shells/ubuntu.nix { inherit pkgs mkosiDev; };
      };

    };
}
