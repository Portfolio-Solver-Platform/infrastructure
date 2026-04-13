output "psp_cluster_name" {
  value       = google_container_cluster.psp.name
  description = "The name of the psp cluster"
}

output "psp_cluster_zone" {
  value       = google_container_cluster.psp.location
  description = "The zone of the psp cluster"
}

output "psp_cluster_ip" {
  description = "The external IP address of the PSP cluster"
  value       = google_compute_address.psp_gateway_ip.address
}


output "secrets_manager_transit_host" {
  description = "The host of the transit secrets manager VM"
  value       = "secrets-manager-transit.${var.secrets_manager_transit_zone}.c.${var.project_id}.internal"
}

