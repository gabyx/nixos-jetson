set positional-arguments
set dotenv-load := true
set shell := ["nu", "--no-config-file", "-c"]
root_dir := justfile_directory()
output_dir := root_dir / ".output"
build_dir := root_dir / "build"
shell := env("SHELL", "zsh")

default:
    ^just --list

# The host for which most commands work below.
default_nixos_config := env("NIXOS_CONFIG", "thor-devkit")

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
        ^just nix --subcmd=build ...$args
    }

# Eval the nixos configuration.
[group("nixos")]
eval *args:
    #!/usr/bin/env nu
    def --wrapped main [...args: string] {
        ^just nix --subcmd=eval ...$args
    }

[group("ci")]
upload *args:
    #!/usr/bin/env nu
    def --wrapped main [...args: string] {
        print "Set cachix token."
        ^cachix authtoken $env.CACHIX_AUTH_TOKEN
        print "Upload to nixos-jetson.cachix.org."
        ^just build ...$args | cachix push nixos-jetson
    }

# Subcommand for the NixOS system attributes.
[group("nixos")]
[private]
nix *args:
    #!/usr/bin/env nu
    def --wrapped main [
        --subcmd="build"
        --nixos: string = "{{default_nixos_config}}"
        --iso
        --use-nom = {{use_nom}}
        ...args: string
    ] {
        mut cmd = [
            $subcmd
            --accept-flake-config
            --verbose
            --show-trace
        ] | append $args

        mut attr = $"nixosConfigurations.($nixos).config.system.build.toplevel"
        if $iso {
            $attr = $"($nixos)-iso"
        }

        if $subcmd == "build" {
            $cmd = $cmd | append [
                "--out-link" $"{{output_dir}}/($attr)"
                "--print-out-paths"
            ]
        }

        if $iso and not ($nixos | str contains "-installer") {
            error make {msg: "You cannot only build ISO's for installers."}
        }

        $cmd = $cmd | append $".#($attr)"

        print -e "----"
        print -e $"nix ($cmd | str join ' ')"
        print -e "----"

        if ($env.CI? | default "false") == "false" and $use_nom {
            ^nix ...$cmd --log-format internal-json o+e>| nom --json
        } else {
            ^nix ...$cmd
        }
    }
