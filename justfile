set positional-arguments
set dotenv-load := true
set shell := ["nu", "--no-config-file", "-c"]
root_dir := justfile_directory()
build_dir := root_dir / "build"
shell := env("SHELL", "zsh")

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
    def --wrapped main [--nix-shell="default" ...args: string] {
        let flake_dir = "."
        let shell = "{{shell}}"
        let cmd = if ($args | is-empty) {
            [ "env" $"SHELL=($shell)" $shell ]
        } else {
            $args
        }

        ^nix develop --accept-flake-config $"($flake_dir)#($nix_shell)" --command ...$cmd
    }

[group("ci")]
ci *args:
    #!/usr/bin/env nu
    def --wrapped main [...args: string] {
        just develop --nix-shell="ci" ...$args
    }

# Build the nixos configuration.
[group("nixos")]
build *args:
    #!/usr/bin/env nu
    def --wrapped main [...args: string] {
        ^just nix-system --subcmd=build ...$args
    }

# Eval the nixos configuration.
[group("nixos")]
eval *args:
    #!/usr/bin/env nu
    def --wrapped main [...args: string] {
        ^just nix-system --subcmd=eval ...$args
    }

[group("ci")]
upload *args:
    #!/usr/bin/env nu
    def --wrapped main [...args: string] {
        ^cachix authtoken $env.CACHIX_AUTH_TOKEN
        print "Upload to nixos-jetson.cachix.org."
        ^just build ...$args | cachix push nixos-jetson
    }

# Subcommand for the NixOS system attributes.
[group("nixos")]
[private]
nix-system *args:
    #!/usr/bin/env nu
    def --wrapped main [--subcmd="build" --host: string = "{{default_host}}" ...args: string] {
        let cmd = [
            $subcmd
            --verbose
            --no-link
            --show-trace
            --print-out-paths
            $".#nixosConfigurations.($host).config.system.build.toplevel"
        ] | append $args

        print "----"
        print $"nix ($cmd | str join ' ')"
        print "----"

        if ($env.CI? | default "false") == "false" and "{{use_nom}}" == "true" {
            ^nix ...$cmd --log-format internal-json o+e>| nom --json
        } else {
            ^nix ...$cmd
        }
    }
