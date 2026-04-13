resource "google_project_service" "compute_api" {
  project = var.project_id
  service = "compute.googleapis.com"
  disable_dependent_services = !var.deletion_protection
  disable_on_destroy = !var.deletion_protection
}

resource "google_project_service" "container_api" {
  project = var.project_id
  service = "container.googleapis.com"
  disable_dependent_services = !var.deletion_protection
  disable_on_destroy = !var.deletion_protection 
}
