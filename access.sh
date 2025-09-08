#!/bin/sh
../gateway/minikube/access.sh

echo
echo "Press CTRL+C to close access..."

trap "echo; echo Closing access...; ../gateway/minikube/kill-tunnel.sh; exit 0" INT
# Wait indefinitely (until they press CTRL+C)
while true; do
  sleep 1
done

