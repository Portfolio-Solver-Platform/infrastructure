output "psp_cluster_name" {
  value       = google_container_cluster.psp.name
  description = "The name of the psp cluster"
}

output "psp_cluster_zone" {
  value       = google_container_cluster.psp.location
  description = "The zone of the psp cluster"
}

output "secrets_manager_transit_ip" {
  description = "The static internal IP address of the transit secrets manager VM"
  value       = google_compute_address.secrets_manager_transit_internal_ip.address
}
