{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      flake-utils,
      git-hooks,
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

        preCommitCheck = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt.enable = true;
            trufflehog.enable = true;
            actionlint.enable = true;
            shellcheck.enable = true;
            ruff.enable = true;
            yamllint.enable = true;
            markdownlint = {
              enable = true;
              args = [ "--fix" ];
            };

            validateFlux = {
              enable = true;
              name = "Validate Flux configuration";
              pass_filenames = false;
              entry =
                let
                  packages = with pkgs; [
                    pkgsUnstable.fluxcd
                    kubeconform
                    yq-go
                    kubectl
                  ];

                  wrapper = pkgs.writeShellScript "validate-flux-wrapper" ''
                    export PATH="${pkgs.lib.makeBinPath packages}:$PATH"

                    exec ${pkgs.bash}/bin/bash ./tests/validate-flux.sh
                  '';
                in
                builtins.toString wrapper;
            };
          };
        };
      in
      {
        devShells = {
          ci = pkgs.mkShell {
            inherit (preCommitCheck) shellHook;
          };

          default = pkgs.mkShell {
            inherit (preCommitCheck) shellHook;
            packages = with pkgs; [
              minikube
              docker
              git
              kubectl
              kustomize
              kubernetes-helm
              terraform
              yq-go
              jq
              (python3.withPackages (
                ps: with ps; [
                  requests
                ]
              ))

              # The following are only used for development of other services
              cosign
              skaffold
              opentofu
              openbao # For the transit secrets manager init script
              (google-cloud-sdk.withExtraComponents (
                with google-cloud-sdk.components;
                [
                  gke-gcloud-auth-plugin
                ]
              ))
            ];
          };
        };
      }
    );
}
