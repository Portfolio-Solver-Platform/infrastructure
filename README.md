# Infrastructure

The deployment configuration for PSP.

## Prerequisites

- Have [Nix (the package manager)](https://nixos.org/download/) installed
- Enter the Nix environment: `nix --extra-experimental-features "nix-command flakes" develop`
  - If you have Nix flakes enabled globally, you can instead run `nix develop`

## Development Setup

Prerequisites:

- Have the CNI repo and the gateway repo installed along side this repo. I.e., have the following folder structure:
  - `infrastructure/`
  - `cni/`
  - `gateway/`

Deployment:

- Run `./deployments/local/init <profile> [--cpu <cores>] [--memory <mem>]`
  - `<profile>` can either be `dev` or `dev-prod`, where `dev-prod` is a profile that runs as much with production settings as is possible locally.
  - The `--cpu` and `--memory` can be used to limit the resources given to the local cluster. Its a good idea to set these because the defaults are relatively low.
- You can access the services through the gateway by using `minikube tunnel`. Thereafter, to get the IP address execute the `access.sh` script. Remember to follow the instructions the script gives you. Note that the `access.sh` script is dependent on the gateway being up.
- Initialise the data — see [Data Setup](#data-setup)

Useful information:

- The platform is running in `minikube`, so `minikube stop` can be used to stop it temporarily and `minikube start` can be used to start it again. Finally, `minikube delete` can be used to delete the platform.
- For development of individual services, to deploy your own build, you must first stop FluxCD from trying to control its deployment by using `flux suspend helmrelease <service-name> -n <service-namespace>`.
  - If this is not done, Flux will notice your own deployment and replace it with the one on GitHub.
- To make your cluster track a different infrastructure branch, use `scripts/update`.
- Use `scripts/watch` to see the live status of the services.
- You can access the secrets manager using port-forwarding: `kubectl port-forward -n secrets-manager svc/secrets-manager-openbao 8200:8200`

## Production Setup

Prerequisites:

- Have the [transit secrets manager repo](https://github.com/Portfolio-Solver-Platform/secrets-manager-transit), the secrets manager repo and the gateway repo installed along side this repo. I.e., have the following folder structure:
  - `infrastructure/`
  - `secrets-manager-transit/`
  - `secrets-manager/`
  - `gateway/`

Initialising the cluster:

- Run `./deployments/google/init <project-id>`
  - Pass `--no-deletion-protection` to allow automated tools to later delete all resources.
  - Pass `--destroy` to delete all the resources instead of creating them.
  - Pass `-y` to not be prompted to accept the changes to Google Cloud before they are applied.
  - If the transit secrets manager has been set up beforehand, use `--kubernetes-transit-token <token>` to skip setting up the transit secrets manager, and instead initialise the cluster using the provided transit token.
- IMPORTANT: The script prints various secrets to the terminal which you must save securely.
- Wait for all the services to be up. You can use `./scripts/watch` to get a live status of all the services.
- All secrets are randomly generated, but available in the secrets manager. Thus, you must access the secrets-manager using the root token that the script printed to the terminal. Here, you can find the credentials for the other services, like the auth-manager bootstrap admin credentials.
  - You access the secrets manager using port-forwarding: `kubectl port-forward -n secrets-manager svc/secrets-manager-openbao 8200:8200`
- Initialise the data — see [Data Setup](#data-setup)

For setting up the platform on a new cloud provider, you must copy the steps in the `./deployments/google/` folder.
The following settings are important for security:

- Enable etcd encryption at rest. How this is done depends on the cloud provider, but usually involves setting up a key in their proprietary Key Management Service (KMS) and during the cluster setup, configuring it to use the key for etcd encryption at rest.
- Enable a Container Networking Interface (CNI) that supports the native Kubernetes network policies. The default CNI typically does _not_ support this, so it is important to explicitly enable.

## Data Setup

Requires [`psp-cli`](https://github.com/Portfolio-Solver-Platform/psp-cli).

```bash
psp config set client_id admin-app
psp auth login
./post-data-setup.sh <problems-dir>
```

To override the solver image: `MINIZINC_SOLVERS_IMAGE=<url> ./post-data-setup.sh <problems-dir>`
