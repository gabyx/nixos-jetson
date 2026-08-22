{ ... }:
{
  perSystem =
    { pkgs, self', ... }:
    let
      default = pkgs.mkShellNoCC {
        packages = [
          self'.bootstrap
        ];

        shellHook = ''
          just --list
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
