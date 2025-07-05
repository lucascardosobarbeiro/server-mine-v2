# =================================================================================
# Disco persistente para os dados do Minecraft
resource "google_compute_disk" "minecraft_data_disk" {
  name = "minecraft-data-disk"
  type = "pd-balanced"
  zone = var.zone
  size = 50
}

# IP público estático para a VM
resource "google_compute_address" "static_ip" {
  name   = "minecraft-static-ip"
  region = var.region
}

# =================================================================================
# Instância da VM do Minecraft
resource "google_compute_instance" "minecraft_server_host" {
  name         = "minecraft-server-host"
  machine_type = "custom-4-18432"
  zone         = var.zone
  tags         = ["minecraft-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
    }
  }

  attached_disk {
    source = google_compute_disk.minecraft_data_disk.self_link
  }

  network_interface {
    subnetwork = google_compute_subnetwork.minecraft_subnet.self_link
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  service_account {
    email  = var.github_service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      …
    EOT
  }

  depends_on = [google_compute_firewall.allow_iap_ssh]
}
