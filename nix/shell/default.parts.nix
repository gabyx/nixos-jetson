{ ... }:
{
  perSystem =
    { pkgs, self', ... }:
    let
      default = pkgs.mkShellNoCC {
        packages = [
          self'.packages.bootstrap
        ];

        shellHook = ''
          [ "$CI" != "true"] || just --list
        '';
      };
    in
    {
      devShells = {
        inherit default;
        ci = default;
      };
    };
}
