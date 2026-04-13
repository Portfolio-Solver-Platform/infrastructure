resource "google_compute_address" "psp_gateway_ip" {
  name         = "psp-gateway-ip"
  region       = var.region
  description  = "Persistent IP for the PSP gateway"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

resource "google_container_cluster" "psp" {
  name     = "psp"
  location = var.zone # NOTE: For real production, should use var.region instead to replicate the cluster in all zones

  # We can't create a cluster with no node pool defined, but it is recommended
  # to manage the node pool outside of the cluster configuration since a
  # major change in the node pool may prompt OpenTofu to decide to delete the entire cluster.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.main.id
  subnetwork = google_compute_subnetwork.psp_cluster.id

  deletion_protection = var.deletion_protection

  ip_allocation_policy {
    cluster_secondary_range_name  = local.psp_cluster.network.pods_range_name
    services_secondary_range_name = local.psp_cluster.network.services_range_name
  }

  depends_on = [google_project_service.container_api]
}

resource "google_container_node_pool" "psp_nodes" {
  name       = "psp-nodes"
  location   = var.zone # NOTE: For real production, should use var.region instead to replicate the cluster in all zones
  cluster    = google_container_cluster.psp.name

  node_count = 1

  # autoscaling {
  #   min_node_count = 1
  #   max_node_count = 3
  # }

  node_config {
    machine_type = "e2-standard-8"
  }
}
