resource "google_compute_network" "main" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
  depends_on = [google_project_service.compute_api]
}

resource "google_compute_subnetwork" "secrets_manager_transit" {
  name          = "secrets-manager-transit-subnet"
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

resource "google_compute_subnetwork" "psp_cluster" {
  name          = "psp-cluster-subnet"
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
    google_compute_subnetwork.psp_cluster.ip_cidr_range,
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

resource "google_compute_router" "secrets_manager_transit" {
  name    = "secrets-manager-transit-router"
  network = google_compute_network.main.id
  region  = var.secrets_manager_transit_region
}

resource "google_compute_router_nat" "secrets_manager_transit" {
  name   = "secrets-manager-transit-nat"
  router = google_compute_router.secrets_manager_transit.name
  region  = var.secrets_manager_transit_region

  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.secrets_manager_transit.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_router" "psp_cluster" {
  name    = "psp-cluster-router"
  network = google_compute_network.main.id
  region  = var.region
}

resource "google_compute_router_nat" "psp_cluster" {
  name   = "psp-cluster-nat"
  router = google_compute_router.psp_cluster.name
  region = var.region

  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.psp_cluster.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
