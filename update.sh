#!/usr/bin/env bash

# ==== FLAGS ====

verbose=false

for arg in "$@"
do
    if [[ "$arg" == "-v" ]]; then
        verbose=true
    fi
done

# ==== MAIN ====

declare -a non_main_repos=()
declare -a not_up_to_date=()

update() {
    if [[ "$verbose" == "true" ]]; then
        echo "=========== Updating $1 =========="
    else
        echo "Updating $1..."
    fi

    cd "$1" || {
        echo "Failed to change directory to $1, aborting"
        return 1
    }

    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ]; then
        echo "Not in main branch"
        non_main_repos+=("$1")
    fi

    if [[ "$verbose" == "true" ]]; then
        echo ""
        echo "---------- Fetching ----------"
        echo ""
    fi
    fetch_output=$(git fetch)
    if [[ "$verbose" == "true" ]]; then
        echo "$fetch_output"
    fi

    if [[ "$verbose" == "true" ]]; then
        echo ""
        echo "---------- Pulling ----------"
        echo ""
    fi
    pull_output=$(git pull)
    if [[ "$verbose" == "true" ]]; then
        echo "$pull_output"
    else
        if [ "$pull_output" != "Already up to date." ]; then
            echo "Not up to date"
            not_up_to_date+=("$1")
        fi
    fi
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
update ../data-gatherer/
update ../solver-controller/
update ../cert-manager/


if [ ${#not_up_to_date[@]} -ne 0 ]; then
    echo
    echo "WARNING: The following repos were not up to date. These have either been updated or failed to update:"
    for repo in "${not_up_to_date[@]}"; do
        echo "- $repo"
    done
fi

echo
if [ ${#non_main_repos[@]} -eq 0 ]; then
    echo "All repos are on the main branch"
else
    echo "WARNING: The following repos are not in the main branch:"
    for repo in "${non_main_repos[@]}"; do
        echo "- $repo"
    done
fi


