{ stdenv
, lib
, runCommand
, fetchgit
, fetchurl
, fetchFromGitHub
, dockerTools
, ansible
,
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
  collectionSources = import ../_sources/generated.nix { inherit fetchgit fetchurl fetchFromGitHub dockerTools; };
  roles = [ "OndrejHome.ha-cluster-pacemaker" ];

  installCollections =
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: installCollection name)
        (lib.filterAttrs (n: v: lib.hasPrefix "collection-" n) collectionSources));
  installRoles =
    lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: installRole name) (lib.filterAttrs (n: v: lib.hasPrefix "role-" n) collectionSources));

  installCollection = name: "${ansible}/bin/ansible-galaxy collection install ${collection name}/collection.tar.gz";
  installRole = name: ''
    mkdir -p  "''${ANSIBLE_ROLES_PATH}/${name}"
    cp -r ${collectionSources.${name}.src}/* "''${ANSIBLE_ROLES_PATH}/${name}"
  '';

  collection = name:
    stdenv.mkDerivation {
      inherit (collectionSources."${name}") pname version src;

      phases = [ "installPhase" ];

      installPhase = ''
        mkdir -p $out
        cp $src $out/collection.tar.gz
      '';
    };
in
runCommand "ansible-collections" { } ''
  mkdir -p $out/roles
  export HOME=./
  export ANSIBLE_COLLECTIONS_PATHS=$out
  export ANSIBLE_ROLES_PATH=$out/roles
  ${installCollections}
  ${installRoles}
''
