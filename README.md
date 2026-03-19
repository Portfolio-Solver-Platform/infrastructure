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

## Setup

Initialising the cluster:
- For local development, run `minikube addons enable metrics-server`
- Run `flux install`
- Run `kubectl apply -f init/dev.yaml`
- For local development, you can access the services through the gateway by using `minikube tunnel`. There after to get the ip address execute the `access.sh` script. Then, insert the following in your `/etc/hosts` file:
```
<IP> local keycloak.local grafana.local prometheus.local
```
where `<IP>` is the IP that `minikube/access.sh` gave you.
- Wait for all the services to be up. You can use `flux get all -A` to get the status of all the services
- Run the `post-data-setup.sh` script to initialise the data

