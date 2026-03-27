# Infrastructure

The deployment configuration for PSP.

## Prerequisites

- Have a Kubernetes cluster ready and started. For local development, you can use minikube and start it with `minikube start`
- Have [Nix (the package manager)](https://nixos.org/download/) installed
- Have Nix flakes enabled. This is done by creating the following config `~/.config/nix/nix.conf` and add the following:
```conf
experimental-features = nix-command flakes
```
- Enter the Nix environment using `nix develop`

## Development Setup

Initialising the cluster:
- Run `minikube addons enable metrics-server`
- Run `flux install`
- Run `cd init`
- Run `./flux-init dev [branch]` where `<branch>` is the branch of the infrastructure repo you want to apply (defaults to main).
- You can access the services through the gateway by using `minikube tunnel`. There after to get the IP address execute the `access.sh` script. Remember to follow the instructions the script gives you.
- Wait for all the services to be up. You can use `flux get all -A` to get the status of all the services
- Run the `post-data-setup.sh` script to initialise the data

## Production Setup

First, you need the [transit secrets manager](https://github.com/Portfolio-Solver-Platform/secrets-manager-transit) up and running.

Initialising the cluster:
- Run `flux install`
- Run `cd init`
- Run `./flux-init prod [branch]` where `<branch>` is the branch of this repo you want to apply (defaults to main).
- When the [secrets manager](https://github.com/Portfolio-Solver-Platform/secrets-manager) is up, follow the secrets manager production init guide.
- Wait for all the services to be up. You can use `flux get all -A` to get the status of all the services
- Run the `post-data-setup.sh` script to initialise the data

