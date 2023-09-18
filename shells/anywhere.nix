{ pkgs, ... }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    terraform
  ];
}
