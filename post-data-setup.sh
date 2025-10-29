#!/usr/bin/env bash

cd ../solver-artifact-registry && sh apply_terraform.sh 
(cd ../minizinc-solvers && sh push_to_harbor.sh) &
(cd ../solver-controller && sh push_to_harbor.sh) &
(cd ../infrastructure/upload_data_scripts && python setup.py) &

wait
