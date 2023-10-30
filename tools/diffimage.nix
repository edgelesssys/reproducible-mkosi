{ pkgs, extract }:
pkgs.writeShellApplication {
  name = "diffimage";
  runtimeInputs = with pkgs; [
    # util-linux
    cryptsetup
    coreutils
    binutils
    zstd
    systemd
    diffutils
  ] ++ [
    # mkosi # use mkosi from environment, so different versions can be used.
    extract
  ];
  text = (builtins.readFile ./diffimage.sh);
}
