{ pkgs }:
let
  extract = pkgs.callPackage ./extract.nix { };
in
{
  inherit extract;
  diffimage = pkgs.callPackage ./diffimage.nix { inherit extract; };
}
