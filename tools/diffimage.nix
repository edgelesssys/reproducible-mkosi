{ pkgs, mkosiDev, extract }:
pkgs.writeShellApplication {
  name = "diffimage";
  runtimeInputs = with pkgs; [
    # util-linux
    cryptsetup
    coreutils
    mkosi
    binutils
    zstd
    systemd
    diffutils
  ] ++ [
    mkosiDev
    extract
  ];
  text = (builtins.readFile ./diffimage.sh);
}
