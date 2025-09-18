#!/bin/sh
# Bootstrap infrastructure
kubectl apply -f ./namespace.yaml

# Bootstrap other services
../gateway/bootstrap.sh
../encryption/bootstrap.sh
../monitoring/bootstrap.sh
../solver-artifact-registry/bootstrap.sh
../keycloak/bootstrap.sh


