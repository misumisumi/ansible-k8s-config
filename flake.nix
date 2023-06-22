{
  description = "Playbooks for apps of my k8s cluster";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
      ];
      systems = ["x86_64-linux"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        _pkgs = with pkgs; [
          bashInteractive
          jq
          yq # python-yq
          argocd
          ansible
          kubectl
          kubernetes-helm
        ];
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [];
          config.allowUnfree = true;
        };
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = _pkgs;
          buildInputs = [];
          shellHooks = ''
          '';
        };
      };
    };
}