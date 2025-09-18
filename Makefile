.ONESHELL:
SHELL := /bin/sh

.PHONY: up down start stop

up start:
	set -euo pipefail
	trap '$(MAKE) down || true; exit 0' INT TERM
	trap '$(MAKE) down || true; exit 1' ERR

	( cd ../gateway && skaffold run --tail -p dev ) &
	( cd ../encryption && skaffold run --tail -p dev ) &
	( cd ../keycloak && skaffold run --tail -p dev ) &
	( cd ../monitoring && skaffold run --tail -p dev ) &
	( cd ../solver-director && skaffold run --tail -p dev ) &

	echo "▶ All services deployed. Press Ctrl+C to delete..."
	wait

down stop:
	set -euo pipefail

	# Gateway
	( cd ../gateway && skaffold delete -p dev) || true
	(kubectl delete svc gateway-nginx) || true
	(kubectl delete deployment gateway-nginx) || true
	(kubectl delete svc gateway-nginx -n nginx-gateway) || true
	(kubectl delete deployment gateway-nginx -n nginx-gateway) || true

	# Other services
	( cd ../encryption && skaffold delete -p dev) || true
	( cd ../keycloak && skaffold delete -p dev) || true
	( cd ../monitoring && skaffold delete -p dev) || true
	( cd ../solver-director && skaffold delete -p dev) || true

