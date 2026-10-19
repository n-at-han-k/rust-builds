# rust-builds

Daily GitHub Actions builds of Rust packages nothing else ships, released as
tarballs so consumers don't compile them from source.

## Adding a package

Drop a directory under `packages/`. Nothing else — the flake discovers it with
`readDir` and the workflow matrixes over `nix flake`'s package names.

    packages/<name>/default.nix

It is an ordinary `callPackage` derivation and must set `version`, which is
what the release tag is built from.

## What it produces

A release tagged `<name>-v<version>` whose assets are the build outputs
themselves -- the binary for a plain Rust package, the `.so` plus its `.sql`
and `.control` for a pgrx extension -- alongside a `SHA256SUMS`.

`nixpkgs` is pinned to the same channel as the clan repo so `cargoHash` values
stay valid in both.

## Triggers

Daily at 04:00, on push to `packages/**` or the flake, and manually.
`workflow_dispatch` takes `package` to build just one and `force` to rebuild
over an existing release. The cron is a no-op once a tag exists, so pinned
versions cost nothing.
