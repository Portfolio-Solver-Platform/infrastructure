#!/usr/bin/env bash
set -euo pipefail

(cd ./upload_data_scripts && python setup.py) &

wait
