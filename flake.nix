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
    in
    {
      devShells."${system}" = {
        mkosiFedora = import ./fedora/shell.nix { inherit pkgs; };
      };

    };
}
