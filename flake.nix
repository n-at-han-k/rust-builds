{
  description = "Prebuilt Rust packages nothing else ships";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" ];

      # A package is a directory under ./packages. That is the whole of
      # "adding a project": drop one in, the workflow picks it up.
      names = lib.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir ./packages));
    in
    {
      packages = lib.genAttrs systems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in lib.genAttrs names (name: pkgs.callPackage (./packages + "/${name}") { })
      );
    };
}
