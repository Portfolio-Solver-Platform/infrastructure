#!/bin/sh

update() {
    echo "Pulling from $1..."
    cd "$1" || {
        echo "Failed to cd, abort"
        return 1
    }
    git pull
}

update ../gateway/
update ../keycloak/
update ../monitoring/
update ../solver-director/

