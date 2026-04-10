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
    subnetwork = google_compute_subnetwork.secrets_manager_transit.id
    # No public IP
  }

  depends_on = [
    google_compute_router_nat.secrets_manager_transit
  ]

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -euo pipefail

    export HOME=/root
    export USER=root

    echo "Setting up logging (outputs to /var/log/startup-script.log for debugging)..."
    exec > >(tee -a /var/log/startup-script.log) 2>&1

    echo "=== Waiting for internet connection... ==="
    until ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; do
      echo "Network unreachable. Waiting 5 seconds..."
      sleep 5
    done
    echo "Internet connection established!"

    echo "=== Installing prerequisites... ==="
    apt-get update
    apt-get install -y git curl ca-certificates gnupg lsb-release

    echo "=== Installing Docker... ==="
    apt-get install -y docker.io docker-compose
    systemctl enable docker
    systemctl start docker

    echo "=== Installing Nix daemon (multi-user installation)... ==="
    sh <(curl -L https://nixos.org/nix/install) --daemon --yes

    echo "=== Enabling Nix flakes... ==="
    mkdir -p /etc/nix
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
    # Source the Nix environment so the 'nix' command is available to the rest of this script
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

    echo "=== Cloning repository... ==="
    REPO_DIR="/opt/secrets-manager-transit"
    git clone https://github.com/Portfolio-Solver-Platform/secrets-manager-transit.git "$REPO_DIR"
    cd "$REPO_DIR"

    echo "=== Running init script via Nix... ==="
    nix develop --command bash -c "./scripts/init"

    echo "=== Startup finished ==="
  EOF
}
