{ ... }:
{
  perSystem =
    { pkgs, self', ... }:
    let
      default = pkgs.mkShellNoCC {
        packages = [
          self'.packages.bootstrap

          pkgs.nix-output-monitor
        ];

        shellHook = ''
          [ "$CI" != "true" ] || just --list
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
