.PHONY: dev

dev:
	(cd ../solver-director && skaffold dev) &
	(cd ../gateway && skaffold dev) &
	(cd ../keycloak && skaffold dev) &
	wait
