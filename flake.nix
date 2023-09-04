{
  description = "Build fedora image with mkosi";

  inputs = {
    nixpkgsWorking = {
      url = "github:katexochen/nixpkgs/working";
    };
    nixpkgsUnstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgsUnstable";
    };
    nixos-anywhere = {
      url = "github:numtide/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgsUnstable";
    };
    srvos = {
      url = "github:numtide/srvos";
      inputs.nixpkgs.follows = "nixpkgsUnstable";
    };
    nixpkgsSrvos = {
      follows = "srvos/nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgsUnstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs =
    { self
    , nixpkgsWorking
    , nixpkgsUnstable
    , nixpkgsSrvos
    , nixos-generators
    , nixos-anywhere
    , srvos
    , disko
    , flake-utils
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgsWorking = import nixpkgsWorking { inherit system; };
      pkgsUnstable = import nixpkgsUnstable { inherit system; };

      mkosiDev = (pkgsWorking.mkosi.overrideAttrs (_: rec {
        src = pkgsWorking.fetchFromGitHub {
          owner = "systemd";
          repo = "mkosi";
          rev = "4b776f1cfc498c88468ce7e44050d8b06289f8ac";
          hash = "sha256-nM7YI4iyaKOESG+Euvd+rtyu5buVQw4AHYywsB98MN4=";
        };
      })).override {
        # withQemu = true;
      };

      tools = import ./tools/default.nix { pkgs = pkgsWorking; };
    in
    {
      devShells = {
        mkosiFedora = import ./shells/fedora.nix { pkgs = pkgsWorking; inherit mkosiDev tools; };
        mkosiUbuntu = import ./shells/ubuntu.nix { pkgs = pkgsWorking; inherit mkosiDev tools; };
        mkosiDev = import ./shells/mkosi-dev.nix { pkgs = pkgsWorking; };
      };

      nixosConfigurations.remoteBuilder = nixpkgsUnstable.lib.nixosSystem {
        inherit system;
        modules = [
          srvos.nixosModules.hardware-amazon
          srvos.nixosModules.server
          srvos.nixosModules.roles-nix-remote-builder
          nixos-generators.nixosModules.all-formats
          ./systems/builder-config.nix
          {
            roles.nix-remote-builder.schedulerPublicKeys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLRbdboacxCiIarRD/mdJUoZINJXF/YbsTELlcZNf04 katexochen@remoteBuilder"
            ];
          }
        ];
        specialArgs = { pkgs = pkgsUnstable; inherit nixos-generators; };
      };

      formatter = nixpkgsUnstable.legacyPackages.${system}.nixpkgs-fmt;
    });
}
