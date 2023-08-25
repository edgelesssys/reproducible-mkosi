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
          owner = "katexochen";
          repo = "mkosi";
          rev = "e7b6792076cd45a83f103c1df3b0b1f6d31e529c";
          hash = "sha256-xc55is5Q0/m606Bf1P4GjUl0Vg3LMLrSC75mmo5thSs=";
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
