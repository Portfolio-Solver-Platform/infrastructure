output "psp_cluster_name" {
  value       = google_container_cluster.psp.name
  description = "The name of the psp cluster"
}

output "psp_cluster_zone" {
  value       = google_container_cluster.psp.location
  description = "The zone of the psp cluster"
}

output "secrets_manager_transit_host" {
  description = "The host of the transit secrets manager VM"
  value       = "secrets-manager-transit.${var.secrets_manager_transit_zone}.c.${var.project_id}.internal"
}
