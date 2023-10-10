{
  description = "Playbooks for apps of my k8s cluster";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.devenv.url = "github:cachix/devenv";
  inputs.nvfetcher.url = "github:berberman/nvfetcher";

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = [ "x86_64-linux" ];
      perSystem =
        { config
        , self'
        , inputs'
        , pkgs
        , system
        , ...
        }:
        let
          myScripts = pkgs.callPackage (import ./scripts) { };
          ANSIBLE_COLLECTIONS_PATHS = pkgs.callPackage ./collections { };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                python3Packages = prev.python3Packages.override {
                  overrides = pfinal: pprev: {
                    ansible-core = pprev.ansible-core.overridePythonAttrs (old: {
                      buildInputs = (old.buildInputs or [ ]) ++ [ pprev.kubernetes ];
                      makeWrapperArgs = (old.makeWrapperArgs or [ ]) ++ [ "--set PYTHONPATH $PYTHONPATH" ];
                    });
                  };
                };
              })
            ];
            config.allowUnfree = true;
          };

          devenv.shells = {
            # nvfetcher = inputs.nvfetcher.packages.${system};
            default = {
              env = {
                "ANSIBLE_COLLECTIONS_PATHS" = ANSIBLE_COLLECTIONS_PATHS;
                "ANSIBLE_ROLES_PATH" = "${ANSIBLE_COLLECTIONS_PATHS}/roles";
              };
              packages = with pkgs;
                with myScripts; [
                  bashInteractive
                  jq
                  yq # python-yq
                  argocd
                  ansible
                  kubectl
                  kubernetes-helm
                  nvfetcher
                  # MyScripts
                  k
                  he
                ];
            };
          };
        };
    };
}

