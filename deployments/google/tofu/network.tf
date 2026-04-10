resource "google_compute_network" "main" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
  depends_on = [google_project_service.compute_api]
}

resource "google_compute_subnetwork" "us" {
  name          = "us-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.secrets_manager_transit_region
  network       = google_compute_network.main.id
}

locals {
  psp_cluster = {
    network = {
      pods_range_name = "psp-pods-range"
      pods_range = "10.10.0.0/16"
      services_range_name = "psp-services-range"
      services_range = "10.20.0.0/16"
    }
  }
}

resource "google_compute_subnetwork" "eu" {
  name          = "eu-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.main.id

  secondary_ip_range {
    range_name    = local.psp_cluster.network.pods_range_name
    ip_cidr_range = local.psp_cluster.network.pods_range
  }
  secondary_ip_range {
    range_name    = local.psp_cluster.network.services_range_name
    ip_cidr_range = local.psp_cluster.network.services_range
  }
}

resource "google_compute_firewall" "allow_cluster_to_secrets_manager_transit" {
  name    = "allow-cluster-to-secrets-manager-transit"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = [local.secrets_manager_transit.port]
  }

  source_ranges = [
    google_compute_subnetwork.eu.ip_cidr_range,
    local.psp_cluster.network.pods_range
  ]

  target_tags = [local.secrets_manager_transit.tag]
}

resource "google_compute_firewall" "allow_iap_ssh_to_secrets_manager_transit" {
  name    = "allow-iap-ssh-to-secrets-manager-transit"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # This is the dedicated IP block Google uses for IAP TCP forwarding
  source_ranges = ["35.235.240.0/20"] 

  target_tags   = [local.secrets_manager_transit.tag] 
}
