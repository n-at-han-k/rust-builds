# rust-builds

Daily GitHub Actions builds of Rust projects that nothing else ships, released
as prebuilt tarballs so consumers don't compile them from source.

## Adding a project

One directory under `projects/`. No workflow changes.

    projects/<name>/config.json
    projects/<name>/build.sh

`config.json`:

| key | required | meaning |
| --- | --- | --- |
| `repo` | yes | upstream `owner/name` on GitHub |
| `ref` | yes | a commit, tag, branch, or `latest-tag` to track the newest tag |
| `version` | no | release version; defaults to the tag (minus `v`) or a 12-char sha |
| `apt` | no | packages to install before building |
| `toolchain` | no | rust toolchain, default `stable` |

`build.sh` runs with the upstream checkout as its working directory and must
put everything to be released into `$OUT`. Also available: `$SRC`, `$VERSION`,
`$SHA`.

## What it produces

A release tagged `<name>-v<version>` holding
`<name>-<version>-x86_64-linux.tar.gz` and its `.sha256`.

The daily cron is a no-op once that tag exists, so a pinned `ref` costs
nothing; only `latest-tag` or a branch will ever produce new releases.
`workflow_dispatch` takes a `project` to build one, and `force` to rebuild
over an existing release.

## Consuming from nix

    fetchurl {
      url = "https://github.com/<owner>/rust-builds/releases/download/cargo-pgrx-luxms-v0.15.0/cargo-pgrx-luxms-0.15.0-x86_64-linux.tar.gz";
      hash = "...";
    }

For a pgrx extension the tarball is the `cargo pgrx package` staging tree, so
the files land at the postgres prefix they were built for.
