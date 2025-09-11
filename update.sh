#!/bin/sh

update() {
    echo "Pulling from $1..."
    cd "$1" || {
        echo "Failed to change directory to $1, aborting"
        return 1
    }
    git pull
}

update ../gateway/
update ../keycloak/
update ../monitoring/
update ../solver-director/
