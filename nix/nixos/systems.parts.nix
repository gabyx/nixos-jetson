{
  lib,
  inputs,
  withSystem,
  self,
  ...
}:
let
  jetsonSystem = "aarch64-linux";

  # Normal compile (NixOS module).
  aarch64-config = {
    nixpkgs = {
      buildPlatform.system = jetsonSystem;
      hostPlatform.system = jetsonSystem;
    };
  };

  # Cross compile (NixOS module).
  aarch64-cross-config = {
    nixpkgs = {
      buildPlatform.system = "x86_64-linux";
      hostPlatform.system = jetsonSystem;
    };
  };

  # Creates a nixoConfiguration or an image.
  mkSystem =
    name:
    {
      cross ? false,
      ...
    }:
    # Wrap flake-parts arguments into by using `withSystem`...
    withSystem jetsonSystem (
      {
        config,
        inputs',
        self',
        pkgsUnstable,
        ...
      }:
      inputs.nixpkgs.lib.nixosSystem {
        system = jetsonSystem;

        # Import all modules.
        modules = [
          ./${name}/configuration.nix
        ]
        ++ (if cross then [ aarch64-cross-config ] else [ aarch64-config ]);

        # Set special arguments to the modules.
        specialArgs = {
          inherit
            inputs
            self
            ;

          # Flake parts inputs (already system scoped).
          inherit inputs';
          inherit self';
          packages = config.packages;
          inherit pkgsUnstable;
        };
      }
    );

  installer-minimal-jp7 = inputs.jetpack.nixosConfigurations.installer_minimal_jp7;
  installer-minimal-jp7-cross = inputs.jetpack.nixosConfigurations.installer_minimal_cross_jp7;

  systems = {
    thor-devkit = mkSystem "thor-devkit" { };
    thor-devkit-cross = mkSystem "thor-devkit" { cross = true; };
    thor-devkit-installer = installer-minimal-jp7;
    thor-devkit-installer-cross = installer-minimal-jp7-cross;
  };

  installers = {
    inherit (systems) thor-devkit-installer;
  };
  installersCross = {
    inherit (systems) thor-devkit-installer-cross;
  };

in
{
  flake.nixosConfigurations = systems;

  perSystem =
    { system, ... }:
    {
      packages =
        let
          mk = nixos: lib.concatMapAttrs (k: v: { "${k}-iso" = v.config.system.build.isoImage; }) nixos;
        in
        if system == "x86_64-linux" then
          mk installersCross
        else if system == jetsonSystem then
          mk installers
        else
          { };
    };
}
