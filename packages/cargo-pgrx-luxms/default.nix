{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl }:

# pgnats builds against luxms' pgrx fork, so cargo-pgrx has to come from the
# same commit -- nixpkgs' cargo-pgrx is upstream pgrx and the versions clash.
rustPlatform.buildRustPackage {
  pname = "cargo-pgrx";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "luxms";
    repo = "pgrx";
    rev = "031b76754a414c8576b9d97228c8d4a8102baeff";
    hash = "sha256-IOtwmn0kHDz1kpsWp9PGGH3zg91SzGIzoKv0rfoK/5o=";
  };

  buildAndTestSubdir = "cargo-pgrx";
  cargoHash = "sha256-OhG4PyVSE43NNbUlADdFWPHR5+Agec36d2/hI9g0Zvk=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  doCheck = false;

  meta = {
    description = "Cargo subcommand for pgrx (luxms fork)";
    mainProgram = "cargo-pgrx";
    platforms = lib.platforms.linux;
  };
}
