output "psp_cluster_name" {
  value       = google_container_cluster.psp.name
  description = "The name of the psp cluster"
}

output "psp_cluster_zone" {
  value       = google_container_cluster.psp.location
  description = "The zone of the psp cluster"
}
