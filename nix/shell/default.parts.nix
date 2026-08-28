{ ... }:
{
  perSystem =
    { pkgs, self', ... }:
    let
      default = pkgs.mkShellNoCC {
        packages = [
          self'.packages.bootstrap

          pkgs.nix-output-monitor
          pkgs.prek
        ];

        shellHook =
          # Bash
          ''
            [ "''${CI:-}" == "true" ] || {
              just --list
              prek install -c ./tools/configs/prek/prek.toml --overwrite
            }
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
