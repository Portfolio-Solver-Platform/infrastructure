#!/usr/bin/env bash
# Bootstrap infrastructure
kubectl apply -f ./namespace.yaml

# Bootstrap other services
bootstrap() {
    echo "==== Bootstrapping $1"
    cur=$(pwd)
    # Go to the directory
    cd "$1" || {
        echo "Failed to change directory to $1, aborting"
        return 1
    }
    ./bootstrap.sh
    # Go back to original directory
    cd "$cur" || {
        echo "Failed to go back to infrastructure directory: Failed to change directory to $cur, aborting"
        return 1
    }
}

bootstrap ../gateway/
bootstrap ../encryption/
bootstrap ../monitoring/
bootstrap ../solver-artifact-registry/
bootstrap ../keycloak/
bootstrap ../pod-scheduler/

