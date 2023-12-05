{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // tools);
  tools = {
    extract = callPackage ./extract.nix { };
    diffimage = callPackage ./diffimage.nix { };
  };
in
tools
