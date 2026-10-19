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

A release tagged `<name>-v<version>` with:

| asset | what it is |
| --- | --- |
| `<name>-<version>-x86_64-linux.tar.gz` | the build output, unpacked from `result/` |
| `<name>-<version>-x86_64-linux.nar.gz` | `nix-store --export` of the whole closure |
| `<name>-<version>-x86_64-linux.sha256` | checksums for both |

The tarball's binaries still carry `/nix/store` references, so it is only
directly usable where that closure exists. The `.nar.gz` is the honest route
for a nix consumer: `gunzip < x.nar.gz | nix-store --import`. For regular use
a binary cache beats both.

`nixpkgs` is pinned to the same channel as the clan repo so `cargoHash` values
stay valid in both.

## Triggers

Daily at 04:00, on push to `packages/**` or the flake, and manually.
`workflow_dispatch` takes `package` to build just one and `force` to rebuild
over an existing release. The cron is a no-op once a tag exists, so pinned
versions cost nothing.
