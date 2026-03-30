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
        devShells =
          let
            ciPackages = with pkgs; [
              pkgsUnstable.fluxcd
              kubeconform
              yamllint
              bash
            ];
          in
          {
            ci = pkgs.mkShell {
              packages = ciPackages;
            };

            default = pkgs.mkShell {
              packages =
                ciPackages
                ++ (with pkgs; [
                  minikube
                  docker
                  git
                  kubectl
                  kustomize
                  kubernetes-helm
                  terraform
                  yq-go
                  (python3.withPackages (
                    ps: with ps; [
                      requests
                    ]
                  ))

                  # The following are only used for development of other services
                  cosign
                  skaffold
                ]);
            };
          };
      }
    );
}
