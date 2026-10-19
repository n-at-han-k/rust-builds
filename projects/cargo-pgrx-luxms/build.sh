# pgnats builds against luxms' pgrx fork, so cargo-pgrx has to come from the
# same commit -- upstream pgrx's versions clash.
set -euo pipefail

cargo build --release --package cargo-pgrx
install -Dm755 target/release/cargo-pgrx "$OUT/bin/cargo-pgrx"
