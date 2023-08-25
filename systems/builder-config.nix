{ pkgs, lib, nixos-generators, ... }:
{
  imports = [
    nixos-generators.nixosModules.all-formats
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLRbdboacxCiIarRD/mdJUoZINJXF/YbsTELlcZNf04 katexochen@remoteBuilder"
  ];

  networking.hostName = "remoteBuilder";
  system.stateVersion = "23.11";
}
