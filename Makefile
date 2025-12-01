.ONESHELL:
SHELL := bash

.PHONY: up down start stop

up start:
	set -euo pipefail
	trap '$(MAKE) down || true; exit 0' INT TERM
	trap '$(MAKE) down || true; exit 1' ERR

	# Deploy cert-manager first and wait for it to be ready
	echo "▶ Deploying cert-manager..."
	( cd ../cert-manager && skaffold run -p dev )

	# Wait for cert-manager webhook to be ready
	echo "▶ Waiting for cert-manager webhook to be ready..."
	kubectl wait --for=condition=available --timeout=120s deployment/cert-manager-deployment-webhook -n cert-manager
	kubectl wait --for=condition=available --timeout=120s deployment/cert-manager-deployment -n cert-manager
	kubectl wait --for=condition=available --timeout=120s deployment/cert-manager-deployment-cainjector -n cert-manager
	sleep 5  # Extra grace period for webhook to start accepting connections

	echo "▶ Deploying remaining services..."
	( cd ../gateway && skaffold run --tail -p dev ) &
	( cd ../encryption && skaffold run --tail -p dev ) &
	( cd ../keycloak && skaffold run --tail -p dev ) &
	( cd ../secrets-manager && skaffold run --tail -p dev ) &
	( cd ../message-broker && skaffold run --tail -p dev ) &
	( cd ../monitoring && skaffold run --tail -p dev ) &
	( cd ../solver-director && skaffold run --tail -p dev ) &
	( cd ../solver-artifact-registry && skaffold run --tail -p dev ) &
	( cd ../user && skaffold run --tail -p dev ) &
	( cd ../message-broker && skaffold run --tail -p dev ) &
	( cd ../pod-scheduler && skaffold run --tail -p dev ) &

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
	( cd ../cert-manager && skaffold delete -p dev) || true
	( cd ../encryption && skaffold delete -p dev) || true
	( cd ../keycloak && skaffold delete -p dev) || true
	( cd ../secrets-manager && skaffold delete -p dev) || true
	( cd ../message-broker && skaffold delete -p dev) || true
	( cd ../monitoring && skaffold delete -p dev) || true
	( cd ../solver-director && skaffold delete -p dev) || true
	( cd ../solver-artifact-registry && skaffold delete -p dev && rm terraform/terraform.tfstate*) || true
	( cd ../user && skaffold delete -p dev) || true
	( cd ../message-broker && skaffold delete -p dev) || true
	( cd ../pod-scheduler && skaffold run --tail -p dev ) &

