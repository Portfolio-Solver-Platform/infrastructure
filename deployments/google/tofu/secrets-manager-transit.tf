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
  tags         = [local.secrets_manager_transit.tag]

  boot_disk {
    initialize_params {
      image = "projects/cos-cloud/global/images/family/cos-stable"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.main.id
    subnetwork = google_compute_subnetwork.secrets_manager_transit.id
    # No public IP
  }

  depends_on = [
    google_compute_router_nat.secrets_manager_transit
  ]

  metadata = {
    user-data = <<-EOF
      #cloud-config

      write_files:
        - path: /etc/systemd/system/secrets-manager-transit.service
          permissions: 0644
          owner: root
          content: |
            [Unit]
            Description=Secrets Manager Transit Container
            After=docker.service
            Requires=docker.service

            [Service]
            Restart=always
            ExecStartPre=/usr/bin/docker pull ghcr.io/portfolio-solver-platform/secrets-manager-transit:latest
            ExecStart=/usr/bin/docker run --rm --name secrets-manager -p 8200:8200 ghcr.io/portfolio-solver-platform/secrets-manager-transit:latest
            ExecStop=/usr/bin/docker stop secrets-manager

            [Install]
            WantedBy=multi-user.target

      runcmd:
        - systemctl daemon-reload
        - systemctl enable secrets-manager-transit.service
        - systemctl start secrets-manager-transit.service
    EOF
  }
}
