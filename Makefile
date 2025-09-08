.ONESHELL:
SHELL := /bin/sh

DIRS := ../solver-director ../gateway ../keycloak

.PHONY: up down start stop

up start:
	set -euo pipefail
	trap '$(MAKE) down || true; exit 0' INT TERM
	trap '$(MAKE) down || true; exit 1' ERR

	( cd ../gateway && skaffold run --tail -p dev ) &
	( cd ../keycloak && skaffold run --tail -p dev ) &
	( cd ../solver-director && skaffold run --tail -p dev ) &

	echo "▶ All services deployed. Press Ctrl+C to delete..."
	wait

down stop:
	set -euo pipefail
	( cd ../gateway && skaffold delete -p dev) || true
	( cd ../keycloak && skaffold delete -p dev) || true
	( cd ../solver-director && skaffold delete -p dev) || true

