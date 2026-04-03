#!/usr/bin/env bash

set -e -o pipefail 

validate_flux_component() {
  local name=$1
  local target_path=$2
  local kustomization_file=$3

  echo "---------------------------------------------------"
  echo "Validating Flux Component: $name"
  echo "Path: $target_path -> Config: $kustomization_file"
  
  flux build kustomization "$name" \
    --path "$target_path" \
    --kustomization-file "$kustomization_file" \
    --dry-run | \
  kubeconform -strict -summary \
    -schema-location default \
    -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'
    
  echo "✅ Passed!"
}

validate_standard_kustomize() {
  local target_path=$1

  echo "---------------------------------------------------"
  echo "Validating Kustomize: $target_path"
  
  kubectl kustomize "$target_path" | \
  kubeconform -strict -summary \
    -skip CustomResourceDefinition \
    -schema-location default \
    -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'
    
  echo "✅ Passed!"
}

echo "🔍 Starting Flux validation..."

validate_flux_component controllers ./controllers/ ./clusters/base/controllers.yaml

validate_flux_component foundation ./foundation/dev ./clusters/base/foundation.yaml
validate_flux_component infrastructure ./infrastructure/dev ./clusters/base/infrastructure.yaml
validate_flux_component apps ./apps/dev ./clusters/base/apps.yaml

validate_standard_kustomize ./clusters/base
