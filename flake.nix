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
    , srvos
    , disko
    , flake-utils
    }:
    let
      authorizedKeys = {
        katexochen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLRbdboacxCiIarRD/mdJUoZINJXF/YbsTELlcZNf04 katexochen@remoteBuilder";
        malt3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObVCN/buB1d64ptwqIQrLDGpA2xO8plc/FltqE1oK+D malt3@remoteBuilder";
      };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgsWorking = import nixpkgsWorking { inherit system; };
        pkgsUnstable = import nixpkgsUnstable { inherit system; };

        mkosiDev = pkgsWorking.mkosi;
        mkosiDevFull = pkgsWorking.mkosi-full;
        # mkosiDev = (pkgsWorking.mkosi.overrideAttrs (_: rec {
        #   src = pkgsWorking.fetchFromGitHub {
        #     owner = "katexochen";
        #     repo = "mkosi";
        #     rev = "9db8a2f61b7ff0bfbf6226e2e3547c06a734115c";
        #     hash = "sha256-NDFXD0gvHq6+Enyva668a6k6UFyY9P5nOhvJhwZBNbU=";
        #   };
        #   patches = [ ];
        # })).override {
        #   # withQemu = true;
        # };

        tools = import ./tools/default.nix { pkgs = pkgsUnstable; };
      in
      {
        devShells = {
          anywhere = import ./shells/anywhere.nix { pkgs = pkgsUnstable; };
          mkosiFedora = import ./shells/fedora.nix { pkgs = pkgsUnstable; inherit mkosiDev tools; };
          mkosiUbuntu = import ./shells/ubuntu.nix { pkgs = pkgsUnstable; inherit mkosiDev tools; };
          mkosiFedoraQemu = import ./shells/fedora.nix { pkgs = pkgsUnstable; mkosiDev = mkosiDevFull; inherit tools; };
          mkosiUbuntuQemu = import ./shells/ubuntu.nix { pkgs = pkgsUnstable; mkosiDev = mkosiDevFull; inherit tools; };
          mkosiDev = import ./shells/mkosi-dev.nix { pkgs = pkgsUnstable; };
        };

        formatter = nixpkgsUnstable.legacyPackages.${system}.nixpkgs-fmt;
      }) // {
      /*
        anywhereBuilder is a nixos system to be used with nixos-anywhere on AWS.

        nix run github:numtide/nixos-anywhere -- --flake .#anywhereAWS -i ~/.ssh/some_key ec2-user@some_host
        terraform -chdir=terraform init
        terraform -chdir=terraform apply -auto-approve
      */
      nixosConfigurations.anywhereAWS = nixpkgsUnstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # srvos.nixosModules.hardware-amazon # not compatible with disko
          srvos.nixosModules.server
          disko.nixosModules.disko
          srvos.nixosModules.roles-nix-remote-builder
          ./systems/anywhere.nix
          {
            users.users.root.openssh.authorizedKeys.keys = (nixpkgsUnstable.lib.attrValues authorizedKeys);
            roles.nix-remote-builder.schedulerPublicKeys = (nixpkgsUnstable.lib.attrValues authorizedKeys);
          }
        ];
      };

      nixConfig = {
        extra-substituters = [
          "https://katexochen.cachix.org"
        ];
        extra-trusted-public-keys = [
          "katexochen.cachix.org-1:ScfG6cUxfuZxn3n43fYVqK3ha2TMPLG7kJ52s6PKHqo="
        ];
      };
    };
}
