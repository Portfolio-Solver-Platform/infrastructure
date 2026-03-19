#!/usr/bin/env bash
set -euo pipefail

(cd ./upload_data_scripts && python setup.py) &
(cd ../secrets-manager && sh post-setup-dev.sh) &

wait
