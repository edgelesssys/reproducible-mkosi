{ pkgs }:
pkgs.writeShellApplication {
  name = "extract";
  runtimeInputs = with pkgs; [
    util-linux
    jq
    coreutils
  ];
  text = (builtins.readFile ./extract.sh);
}
