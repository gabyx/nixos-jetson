{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells = {
        default = pkgs.mkShellNoCC {
          packages = [
            pkgs.coreutils
            pkgs.findutils

            (lib.hiPrio pkgs.git)
            pkgs.git-lfs
            pkgs.bash

            pkgs.direnv
            pkgs.just
            pkgs.nushell
          ];

          shellHook = ''
            just --list
          '';
        };
      };
    };
}
