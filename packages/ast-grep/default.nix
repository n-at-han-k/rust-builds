{ lib, pkgsStatic, fetchFromGitHub, patchelf, versionCheckHook }:

# nixpkgs ships 0.42.1, which has the rule engine but none of the `outline`
# command. 0.51.3 bundles maintained outline rules for Cpp and Ruby
# (crates/outline/src/default_rules/), which pin down the node kinds and field
# paths that rules match on.
#
# Built against pkgsStatic (musl, where rustc links crt-static by default)
# because the release asset is downloaded and run as-is. An ordinary build
# bakes the *runner's* store path into the ELF interpreter --
#   interpreter /nix/store/fsd4vbp9...-glibc-2.42-100/lib/ld-linux-x86-64.so.2
# -- which exists nowhere else, so the binary dies with a bare "no such file or
# directory" on any other machine, including a NixOS one.
pkgsStatic.rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ast-grep";
  version = "0.51.3";

  src = fetchFromGitHub {
    owner = "ast-grep";
    repo = "ast-grep";
    tag = finalAttrs.version;
    hash = "sha256-GAWLOX5e12YOpYGBK9Oq7xtsKU3EpejyBzoEGP+zivI=";
  };

  # Pins a linker (`aarch64-linux-gnu-gcc`) that does not exist here.
  postPatch = ''
    rm .cargo/config.toml
  '';

  # Vendoring is driven by Cargo.lock alone, so this is the same hash a glibc
  # build resolves to.
  cargoHash = "sha256-HklIyYa3lGwlrDgiUMUZCE95mf8h83TJofDP9QcSRL0=";

  # The workspace also builds the `sg` alias and the napi/pyo3 bindings; the
  # release only wants the one binary.
  cargoBuildFlags = [ "--package ast-grep --bin ast-grep" ];

  # Every tree-sitter grammar in the workspace compiles from scratch. The suite
  # is what made this an hours-long build elsewhere, and it adds no coverage
  # over the install check below.
  doCheck = false;

  nativeBuildInputs = [ patchelf ];

  # Fail the build rather than publish another asset that only runs on the
  # machine that produced it. A static binary has no .interp section at all.
  postInstall = ''
    if interp=$(patchelf --print-interpreter "$out/bin/ast-grep" 2>/dev/null); then
      echo "ast-grep is dynamically linked against $interp" >&2
      echo "release assets must be standalone -- refusing to install" >&2
      exit 1
    fi
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Fast and polyglot tool for code searching, linting, rewriting at large scale";
    homepage = "https://ast-grep.github.io/";
    changelog = "https://github.com/ast-grep/ast-grep/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "ast-grep";
    platforms = lib.platforms.linux;
  };
})
