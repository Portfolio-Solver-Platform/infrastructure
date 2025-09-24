# infrastructure

## First time setup
If this is your first time running the services locally on minikube you should run bootstrap.sh. But make sure the prerequisites are met:
- you have cloned all the services

- all repositories are in the same folder as the infrastructure is in. e.g. we can access them all by `../<service-name>`

- run `minikube addons enable metrics-server`

- for local development, have [Nix (the package manager)](https://nixos.org/download/) installed

## How to run
For local development, install the dependencies using `nix develop`.

By running `make start` all services will be deployed on your local minikube.

You can access the services through the gateway by using minikube tunnel. There after to get the ip address execute the `access.sh` script.

Finally you can initialize the services with data through `post-data-setup.sh`.

So a typical setup would look like:
```
make start
minikube tunnel 
access.sh
post-data-setup.sh
```

To stop the services write `make stop`


# update
The update.sh script simply runs git pull on all services

