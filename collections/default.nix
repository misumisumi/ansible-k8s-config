{
  stdenv,
  lib,
  runCommand,
  fetchgit,
  fetchurl,
  fetchFromGitHub,
  dockerTools,
  ansible,
}:
/*
  Install ansible collections
*
* Collections are downloaded, then each collection is installed with:
* $ ansible-galaxy collection install <collection.tar.gz>.
*
* The resulting derivation is the ansible collections path.
*
* Example:
*
* ANSIBLE_COLLECTIONS_PATH = callPackage ./ansible-collections.nix {};
*/
let
  collectionSources = import ../_sources/generated.nix {inherit fetchgit fetchurl fetchFromGitHub dockerTools;};
  # installCollections =
  #   lib.concatStringsSep "\n" (lib.mapAttrsToList installCollection (lib.mapAttrsToList (name: value: "${name}") collectionSources));
  installCollections =
    lib.concatStringsSep "\n" (map installCollection ["kubernetes-core"]);

  installCollection = name: "${ansible}/bin/ansible-galaxy collection install ${collection name}/collection.tar.gz";

  collection = name:
    stdenv.mkDerivation {
      inherit (collectionSources."${name}") pname version src;

      phases = ["installPhase"];

      installPhase = ''
        mkdir -p $out
        cp $src $out/collection.tar.gz
      '';
    };
in
  runCommand "ansible-collections" {} ''
    mkdir -p $out
    export HOME=./
    export ANSIBLE_COLLECTIONS_PATHS=$out
    ${installCollections}
  ''