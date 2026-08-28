{
  inputs,
  ...
}:
let
  overlays = [ ];

  config = {
    allowUnfree = true;
  };

  stable =
    system:
    import inputs.nixpkgs {
      inherit system overlays config;
    };

  unstable =
    system:
    import inputs.nixpkgs-unstable {
      inherit system overlays config;
    };
in
{

  # Add two library functions.
  flake.lib.importPkgs = stable;
  flake.lib.importPkgsUnstable = unstable;

  perSystem =
    {
      system,
      ...
    }:
    let
      pkgs = stable system;
      pkgsUnstable = unstable system;
    in
    {
      _module.args.pkgs = pkgs;
      _module.args.pkgsUnstable = pkgsUnstable;
    };
}
