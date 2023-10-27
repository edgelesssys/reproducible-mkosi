{ nixpkgs, config, pkgs, lib, ... }:
{
  users.users.katexochen = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDcTVEfgXMnzE6iRJM8KWsrPHCXIgxqQNMfU+RmPM25g katexochen@remoteBuilder"
    ];
  };

  environment.systemPackages = with pkgs; [
    diskonaut
    git
    starship
    go
    gotools
  ];

  virtualisation.docker.enable = true;

  nix = {
    registry.nixpkgs.flake = nixpkgs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };
}
