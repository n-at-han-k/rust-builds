{ lib, buildPgrxExtension, callPackage, fetchFromGitHub, postgresql_17, openssl, pkg-config }:

buildPgrxExtension (finalAttrs: {
  pname = "pgnats";
  version = "1.1.1";

  postgresql = postgresql_17;
  cargo-pgrx = callPackage ../cargo-pgrx-luxms { };

  src = fetchFromGitHub {
    owner = "luxms";
    repo = "pgnats";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7mbilS+yGQjEJfOC+BiNt5p16AYCGo2IoWnH2JJWZS8=";
  };

  cargoHash = "sha256-ys8kcWlMPeofsiSTJtEglj/8mVdydQmAcYZDbUy+k8Q=";

  # The default feature set pins pg14; the pgNN feature has to match the
  # postgresql this is built against.
  buildNoDefaultFeatures = true;
  buildFeatures = [
    "pg${lib.versions.major postgresql_17.version}"
    "kv"
    "object_store"
    "sub"
  ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  # The suite wants a live NATS server.
  doCheck = false;

  meta = {
    description = "PostgreSQL extension for publishing to and subscribing from NATS";
    homepage = "https://github.com/luxms/pgnats";
    platforms = lib.platforms.linux;
  };
})
