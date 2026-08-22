{
  inputs,
  withSystem,
  self,
  ...
}:
let

  # Creates a nixoConfiguration or an image.
  mkSystem =
    name:
    args@{ system, ... }:
    # Wrap flake-parts arguments into using `withSystem`...
    withSystem system (
      {
        config,
        inputs',
        self',
        pkgs,
        pkgsUnstable,
        ...
      }:
      inputs.nixpkgs.lib.nixosSystem (
        args
        // {
          # Import all modules.
          modules = [
            ./${name}/configuration.nix
          ];

          # Set special arguments to the modules.
          specialArgs = {
            inherit
              system
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
      )
    );

  thor = mkSystem "thor" {
    system = "aarch64-linux";
  };
in
{
  flake.nixosConfigurations = {
    inherit thor;
  };

  perSystem =
    { ... }:
    {
    };
}
