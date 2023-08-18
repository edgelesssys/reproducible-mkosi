{
  description = "Build fedora image with mkosi";

  inputs = {
    nixpkgs.url = "github:malt3/nixpkgs/5f73d95fe27526346bfeb7d88d080f2539382740";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
   {
    devShells."${system}".mkosi = import ./shell.nix {inherit pkgs;};
  };
}
