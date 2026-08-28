# NixOS Jetson

NixOS configuration for NVIDIA Jetson devices, built with
[flake-parts](https://flake.parts) and
[jetpack-nixos](https://github.com/anduril/jetpack-nixos) for more information.

## Preliminaries

- **NixOS** — install it: [nixos.org/download](https://nixos.org/download/#nixos-iso).
- **`direnv`** — install it: [direnv.net/docs/installation](https://direnv.net/docs/installation.html).

Then enter the repo and allow the environment (loads the Nix devShell with all tools):

```bash
cp .env.tmpl .env   # optional: adjust DEFAULT_NIXOS_CONFIG / USE_NOM
direnv allow
```

## How To

All commands are run with [`just`](https://github.com/casey/just) (available in the Nix devShell).
Run `just` to list all targets.

### Build

Build the NixOS configuration into `.output`:

```bash
just build [--nixos=thor-devkit] [--installer] [--cross] [... extra nix args ...]
```

The following configurations are exposed:

- `thor-devkit`: A NixOS configuration for the `thor` device with carrier board `devkit`.

> [!NOTE]
>
> Add the `--cross` flag to build the cross-compiled derivation from `x86_64-linux` to `aarch64-linux`.

> [!NOTE]
>
> Add the `--installer` flag to build the ISO image of the NixOS configuration.
> Installer ISO's are matching installers and not the system, it needs still a
> `nixos-rebuild switch .#thor-devkit`.

### Eval

Evaluate the NixOS configuration without building:

```bash
just eval [--nixos=thor-devkit] [--installer] [--cross] [... extra nix args ...]
```

### Pulling from the Cache

Pull the CI build derivations (only works for `--installer`) into your Nix store by
and create a link in `.output/...`

```bash
just pull [--nixos=thor-devkit] --installer [--cross] [... extra nix args ...]
```

> [!EXAMPLE]
>
> Pulling the `aarch64-linux` installer ISO image for `thor-devkit` with
> `just pull --nixos=thor-devkit --installer`.

### Download from the Cachix cache

Prebuilt artifacts in CI are published to
[nixos-jetson.cachix.org](https://app.cachix.org/cache/nixos-jetson). The cache is already
configured in `flake.nix` (`nixConfig`), so `just build|pull` uses it automatically.

## TODO

- Its weird why the `just eval --nixos=thor-devkit --cross` does not eval on a `x86_64-linux` since there are some evaluation guards in some CUDA modules. Why should evaluation have a problem with a cross configuration? It only evaluates on a

## License

[MIT](./LICENSE.md)
