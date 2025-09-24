#!/usr/bin/env bash

cd ../solver-artifact-registry && sh apply_terraform.sh
cd ../minizinc-solvers && sh push_to_harbor.sh
