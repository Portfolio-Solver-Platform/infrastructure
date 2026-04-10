locals {
  secrets_manager_transit = {
    tag = "secrets-manager-transit-server"
    port = 8200
  }
}

resource "google_compute_instance" "secrets_manager_transit" {
  name         = "secrets-manager-transit"
  machine_type = var.secrets_manager_transit_machine_type
  zone         = var.secrets_manager_transit_zone
  tags = [local.secrets_manager_transit.tag]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.main.id
    subnetwork = google_compute_subnetwork.us.id
    # No public IP
  }

  # TODO: When ready for automated setup, write the following startup script
  # metadata_startup_script = <<-EOF
  #   #!/bin/bash
  #   # You can add your OpenBao installation and config generation commands here
  #   echo "Starting OpenBao setup..."
  # EOF
}
