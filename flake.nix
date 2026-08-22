{
  description = "My NixOS Configurations";

  nixConfig = {
    substituters = [
      # Replace the official cache with a mirror located in China
      # Add here some other mirror if needed.
      "https://cache.nixos.org/"
    ];
    extra-substituters = [
      # Nix community's cache server
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # We use flake-parts to assemble all flake outputs.
  # This gives nicer modularity. All `.mod` files are
  # `flake-parts` files.
  outputs =
    inputs:
    let
      lib = inputs.nixpkgs.lib;

      tree =
        inputs.import-tree # -
          (i: i.map (x: lib.info "Importing: '${x}'" x))
          (i: i.filter (lib.hasInfix ".parts."))
          (
            i:
            i [
              ./.
            ]
          );
    in
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
    } tree;

  inputs = {
    import-tree = {
      url = "github:vic/import-tree";
    };

    systems = {
      # Using `nix-systems` flake specification.
      url = "path:./flake/systems.nix";
      flake = false;
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    # Nixpkgs (26.05 from the jetpack flake)
    nixpkgs.url = "github:nixos/nixpkgs?rev=714a5f8c4ead6b31148d829288440ed033ccc041";

    # Nixpkgs (unstable stuff for certain packages.)
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    jetpack = {
      # Using `nix-systems` flake specification.
      url = "path:../..";
      flake = false;
    };

    # Declarative Disk partitioning for VMs.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Some Hardware Modules.
    hardware = {
      url = "github:NixOS/nixos-hardware";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
}
