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
            yamllint.enable = true;
            nixfmt.enable = true;
            trufflehog.enable = true;
            actionlint.enable = true;
            shellcheck.enable = true;
            ruff.enable = true;
            markdownlint.enable = true;

            validateFlux = {
              enable = true;
              name = "Validate Flux configuration";
              entry =
                let
                  # Use writeShellScript to create a sandboxed execution context
                  wrapper = pkgs.writeShellScript "validate-flux-wrapper" ''
                    # 1. Expose the exact tools your script needs to its PATH
                    export PATH="${
                      pkgs.lib.makeBinPath (
                        with pkgs;
                        [
                          pkgsUnstable.fluxcd
                          kubeconform
                          yq-go
                          # Add any other missing tools here (like jq, coreutils, etc.)
                        ]
                      )
                    }:$PATH"

                    # 2. Execute your local script, passing along any modified files as arguments
                    exec ./tests/validate-flux.sh "$@"
                  '';
                in
                builtins.toString wrapper;
            };
          };
        };
      in
      {
        checks = {
          inherit preCommitCheck;
        };

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
              inherit (preCommitCheck) shellHook;
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
                ]);
            };
          };
      }
    );
}
