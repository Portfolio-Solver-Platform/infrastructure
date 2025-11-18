#!/usr/bin/env bash

if [ "$1" = "dev" ]; then
  echo "Using default development options, unless overridden by environment variables..."
    (cd ../keycloak && sh apply-terraform.sh dev) &

else
    (cd ../keycloak && sh apply-terraform.sh) &

fi



cd ../solver-artifact-registry && sh apply_terraform.sh 

(cd ../minizinc-solvers && sh push_to_harbor.sh) &
(cd ../solver-controller && sh push_to_harbor.sh) &
(cd ../data-gatherer && sh push_to_harbor.sh) &

(cd ../infrastructure/upload_data_scripts && python setup.py) &


wait
