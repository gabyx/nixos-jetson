# NixOS Jetson

NixOS configuration for NVIDIA Jetson devices, built with
[flake-parts](https://flake.parts) and [jetpack-nixos](https://github.com/anduril/jetpack-nixos).

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
just build [--nixos=thor-devkit] [--iso] [... extra nix args ...]
```

The following configurations are exposed:

- `thor-devkit`: A NixOS configuration for the `thor` device with carrier board `devkit`.
- `thor-devkit-installer`: The minimal installer ISO matching the `thor-devkit` system.

> [!NOTE]
>
> Add `-cross` to all of the above configuration names to do a cross-compile from `x86_64-linux` to `aarch64-linux`.

> [!NOTE]
>
> Add the `--iso` flag to all `*-installers` configurations to build the ISO image.

### Eval

Evaluate the NixOS configuration without building:

```bash
just eval [--nixos=thor-devkit] [... extra nix args ...]
```

### Download from the Cachix cache

Prebuilt artifacts in CI are published to
[nixos-jetson.cachix.org](https://app.cachix.org/cache/nixos-jetson). The cache is already
configured in `flake.nix` (`nixConfig`), so `just build` uses it automatically when you
pass `--accept-flake-config`.

To use it outside the flake, install [`cachix`](https://docs.cachix.org/installation) and run:

```bash
cachix use nixos-jetson
```

## License

[MIT](./LICENSE.md)
