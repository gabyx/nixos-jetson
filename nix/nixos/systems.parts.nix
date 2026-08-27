{
  inputs,
  withSystem,
  self,
  ...
}:
let
  jetsonSystem = "aarch64-linux";

  aarch64-config = {
    nixpkgs = {
      buildPlatform.system = jetsonSystem;
      hostPlatform.system = jetsonSystem;
    };
  };

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
      inputs.nixpkgs.lib.nixosSystem ({
        system = jetsonSystem;

        # Import all modules.
        modules = [
          ./${name}/configuration.nix
        ]
        ++ (if cross then [ aarch64-cross-config ] else [ aarch64-config ]);

        # Set special arguments to the modules.
        specialArgs = {
          system = jetsonSystem;
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
      })
    );

  thor-devkit = mkSystem "thor-devkit" { };
  thor-devkit-cross = mkSystem "thor-devkit" { cross = true; };

  # Referring to the minimal installer from upstream.
  installer-minimal-jp7 = inputs.jetpack.nixosConfigurations.installer_minimal_jp7;
  installer-minimal-jp7-cross = inputs.jetpack.nixosConfigurations.installer_minimal_cross_jp7;

in
{
  flake.nixosConfigurations = {
    # No-cross compile versions.
    inherit thor-devkit;
    thor-devkit-installer = installer-minimal-jp7;

    # Cross compile versions.
    inherit thor-devkit-cross;
    thor-devkit-installer-cross = installer-minimal-jp7-cross;

    inherit installer-minimal-jp7;
  };
}
