.ONESHELL:
SHELL := /bin/bash

DIRS := ../solver-director ../gateway ../keycloak

.PHONY: up down start stop

up start:
	set -euo pipefail
	trap '$(MAKE) down || true; exit 0' INT TERM
	trap '$(MAKE) down || true; exit 1' ERR

	for d in $(DIRS); do
		( cd $$d && skaffold run --tail -p dev ) &
	done

	echo "▶ All services deployed. Press Ctrl+C to delete..."
	wait

down stop:
	set -euo pipefail
	for d in $(DIRS); do
		( cd $$d && skaffold delete -p dev) || true
	done
