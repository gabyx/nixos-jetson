{ inputs, ... }:
{
  imports = [
    inputs.jetpack.nixosModules.default
    ./nixpkgs.nix
    ./boot.nix
    ./hardware.nix
    ./disks.nix
  ];
}
