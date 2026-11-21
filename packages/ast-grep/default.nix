{ lib, rustPlatform, fetchFromGitHub, versionCheckHook }:

# nixpkgs ships 0.42.1, which has the rule engine but none of the `outline`
# command. 0.51.3 bundles maintained outline rules for Cpp and Ruby
# (crates/outline/src/default_rules/), which pin down the node kinds and field
# paths that rules match on.
rustPlatform.buildRustPackage (finalAttrs: {
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

  cargoHash = "sha256-HklIyYa3lGwlrDgiUMUZCE95mf8h83TJofDP9QcSRL0=";

  # The workspace also builds the `sg` alias and the napi/pyo3 bindings; the
  # release only wants the one binary.
  cargoBuildFlags = [ "--package ast-grep --bin ast-grep" ];

  # Every tree-sitter grammar in the workspace compiles from scratch, so this
  # is already an hours-long build on a CI runner. The suite adds no coverage
  # the install check below does not.
  doCheck = false;

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
