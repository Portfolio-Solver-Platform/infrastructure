#!/usr/bin/env bash

update() {
    echo "=========== Pulling from $1... =========="
    cd "$1" || {
        echo "Failed to change directory to $1, aborting"
        return 1
    }

    echo ""
    echo "---------- pulling main ----------"
    echo ""
    git fetch origin
    git branch -f main origin/main

    echo ""
    echo "---------- pulling your current branch ----------"
    echo ""
    git pull

}

update ../infrastructure/
update ../gateway/
update ../encryption/
update ../keycloak/
update ../monitoring/
update ../solver-director/
update ../solver-artifact-registry/
update ../user/
update ../minizinc-solvers/
