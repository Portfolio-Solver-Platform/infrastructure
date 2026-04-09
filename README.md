# Infrastructure

The deployment configuration for PSP.

## Prerequisites

- Have [Nix (the package manager)](https://nixos.org/download/) installed
- Enter the Nix environment: `nix --extra-experimental-features "nix-command flakes" develop`
    - If you have Nix flakes enabled globally, you can instead run `nix develop`

## Development Setup

Prerequisites:
- Have the CNI repo installed along side this repo. I.e., have the following folder structure:
    - `infrastructure/`
    - `cni/`

Automated steps:
- Run `./deployments/local/init <profile> [--cpu <cores>] [--memory <mem>]`
    - `<profile>` can either be `dev` or `dev-prod`, where `dev-prod` is a profile that runs as much with production settings as is possible locally.
    - The `--cpu` and `--memory` can be used to limit the resources given to the local cluster. Its a good idea to set these because the defaults are relatively low.

Manual steps:
- Start minikube: `minikube start --cni=false`. The `--cni=false` makes minikube avoid installing its default CNI.
    - It is a good idea to also pass the `--cpu <cores>` and `--memory <mem>` to give minikube additional resources.
- Install CNI: Go to the [`cni` repo](https://github.com/Portfolio-Solver-Platform/cni) and use `skaffold run -p dev`
- Enable metrics server: `minikube addons enable metrics-server`
- Install FluxCD in the cluster: `flux install`
- Go to the init folder: `cd init`
- Initialise FluxCD: `./flux-init dev [branch]` where `[branch]` is the branch of the infrastructure repo you want to apply (defaults to main).
The platform will now deploy. Additional information for development:
- You can access the services through the gateway by using `minikube tunnel`. There after to get the IP address execute the `access.sh` script. Remember to follow the instructions the script gives you.
- Wait for all the services to be up. You can use `flux get all -A` to get the status of all the services
- Run the `post-data-setup.sh` script to initialise the data

## Production Setup

First, you need the [transit secrets manager](https://github.com/Portfolio-Solver-Platform/secrets-manager-transit) up and running.

Initialising the cluster:
- Start up the cluster
    - It is important to enable etcd encryption at rest. How this is done depends on the cloud provider, but usually involves setting up a key in their proprietary Key Management Service (KMS) and during the cluster setup, configuring it to use the key for etcd encryption at rest.
    - It is important to enable a Container Networking Interface (CNI) that supports the native Kubernetes network policies. The default CNI typically does _not_ support this, so it is important to explicitly enable. In Google Cloud, you should currently use Dataplane V2.
- Run `flux install`
- Run `cd init`
- Run `./flux-init prod [branch]` where `[branch]` is the branch of this repo you want to apply (defaults to main).
- When the [secrets manager](https://github.com/Portfolio-Solver-Platform/secrets-manager) is up, follow the secrets manager production init guide.
- For the secrets manager Terraform to run, you must create a secret containing the root token similar to the one created in dev mode. When this has run once, it can be deleted since it from then on can use its service account.
- Wait for all the services to be up. You can use `flux get all -A` to get the status of all the services
- Run the `post-data-setup.sh` script to initialise the data

