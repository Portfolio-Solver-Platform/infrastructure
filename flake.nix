{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
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
            minikube
            kubernetes
            docker
            bash
            terraform
            cosign
            skaffold
            kubernetes-helm
            git
            kubectl
            kustomize
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
