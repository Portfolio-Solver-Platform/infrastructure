{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        pkgsUnstable = import nixpkgs-unstable {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          shellHook =
            let
              minikube = "${pkgs.minikube}/bin/minikube";
            in
            ''
              eval $(${minikube} docker-env)
            '';

          packages = with pkgs; [
            pkgsUnstable.fluxcd
            minikube
            docker
            bash
            git
            kubectl
            kustomize
            kubernetes-helm
            terraform

            # TODO: Remove the following, only used for development of other services
            cosign
            skaffold
            (python3.withPackages (
              ps: with ps; [
                requests
              ]
            ))
          ];
        };
      }
    );
}
