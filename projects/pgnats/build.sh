# A pgrx extension, so the artifact is a .so + control/sql for ONE postgres
# major, built with the matching cargo-pgrx (the luxms fork, same commit the
# cargo-pgrx-luxms project here builds).
set -euo pipefail

PGRX_REV=031b76754a414c8576b9d97228c8d4a8102baeff
PG_MAJOR=17

cargo install --locked --git https://github.com/luxms/pgrx --rev "$PGRX_REV" cargo-pgrx

# pgrx wants its own PGDATA tree even just to package; point it at the
# distro's pg_config so the .so links against that postgres.
cargo pgrx init "--pg$PG_MAJOR" "$(which pg_config)"

# The default feature set pins pg14; the pgNN feature must match.
cargo pgrx package \
  --no-default-features \
  --features "pg$PG_MAJOR,kv,object_store,sub"

# `package` lays out a staging tree rooted at the pg prefix; ship it whole.
cp -r target/release/pgnats-pg$PG_MAJOR/. "$OUT/"
