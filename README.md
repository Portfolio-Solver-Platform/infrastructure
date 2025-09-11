# infrastructure

## First time setup
If this is your first time running the services locally on minikube you should run bootstrap.sh. But make sure the prerequisites are met:
- all repositories are in the same folder as the infrastructure is in. e.g. we can access them all by `../<service-name>`
- you have cloned all the services


## How to run
By running `make start` all services will be deployed on your local minikube.
They can be stopped again with `make stop`.

You can access the services through the gateway by executing the `access.sh` script.

# update
The update.sh script simply runs git pull on all services

