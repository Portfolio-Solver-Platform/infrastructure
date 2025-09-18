#!/bin/sh

update() {
    echo "Pulling from $1..."
    cd "$1" || {
        echo "Failed to change directory to $1, aborting"
        return 1
    }
    git pull
}

update ../infrastructure/
update ../gateway/
update ../encryption/
update ../keycloak/
update ../monitoring/
update ../solver-director/
update ../solver-artifact-registry/
update ../minizinc-solvers/
