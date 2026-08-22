set positional-arguments
set dotenv-load := true
set shell := ["nu", "--no-config-file", "-c"]
root_dir := justfile_directory()
build_dir := root_dir / "build"

default:
    ^just --list

# The host for which most commands work below.
default_host := env("NIXOS_HOST", "thor")
# If the nix-output-monitor should be used.
use_nom := env("USE_NOM", "true")

# Enter a development shell to ensure all tools are here.
alias dev := develop
[group("dev")]
develop *args:
    #!/usr/bin/env nu
    def --wrapped main [...args: string] {
        let flake_dir = "."
        let shell = "default"
        let cmd = if ($args | is-empty) {
            [ env $"SHELL=($env.SHELL)" $env.SHELL ]
        } else {
            $args
        }
        ^nix develop --accept-flake-config $"($flake_dir)#($shell)" --command ...$cmd
    }

# Build the nixos configuration.
[group("nixos")]
build *args:
    #!/usr/bin/env nu
    def --wrapped main [...args: string] {
        ^just nix --subcmd=build ...$args
    }

# Eval the nixos configuration.
[group("nixos")]
eval *args:
    #!/usr/bin/env nu
    def --wrapped main [...args: string] {
        ^just nix --subcmd=eval ...$args
    }

# Build the NixOS.
[group("nixos")]
[private]
nix *args:
    #!/usr/bin/env nu
    def --wrapped main [--subcmd="build" --host: string = "{{default_host}}" ...args: string] {
        let cmd = [
            $subcmd
            --verbose
            --show-trace
            $".#nixosConfigurations.($host).config.system.build.toplevel"
        ] | append $args

        print "----"
        print $"nix ($cmd | str join ' ')"
        print "----"

        if "{{use_nom}}" == "true" {
            ^nix ...$cmd --log-format internal-json o+e>| nom --json
        } else {
            ^nix ...$cmd
        }
    }
