# infrastructure

## First time setup
If this is your first time running the services locally on minikube you should run bootstrap.sh. But make sure the prerequisites are met:
- you have cloned all the services

- all repositories are in the same folder as the infrastructure is in. e.g. we can access them all by `../<service-name>`

- run `minikube addons enable metrics-server`

- for local development, have [Nix (the package manager)](https://nixos.org/download/) installed

- have [Nix (the package manager)](https://nixos.org/download/) installed and have created the following config `~/.config/nix/nix.conf` and add the following:
```conf
experimental-features = nix-command flakes
```

- Have docker installed and add `harbor.local` to the insecure registries, which can often be done by adding the following to `/etc/docker/daemon.json`

```json
{
  "insecure-registries": ["harbor.local"]
}
```


## How to run

install the dependencies using `nix develop`.

By running `make start` all services will be deployed on your local minikube.

You can access the services through the gateway by using minikube tunnel. There after to get the ip address execute the `access.sh` script. Then, insert the following in your `/etc/hosts` file:
```
<IP> local harbor.local keycloak.local grafana.local prometheus.local
```
where `<IP>` is the `minikube/access.sh` gave you.



Finally you can initialize the services with data through `post-data-setup.sh`.

So a typical setup would look like:
```
make start
minikube tunnel 
# open new terminal
./access.sh
# add your ip to /etc/hosts
./post-data-setup.sh
```

To stop the services write `make stop`


# update
The update.sh script simply runs git pull on all services' main branch and current branch

