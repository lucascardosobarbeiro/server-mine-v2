# compute.tf - Versão Final Simplificada para GitOps

# Cria o disco persistente que irá sobreviver à recriação da VM.
resource "google_compute_disk" "minecraft_data_disk" {
  name = "minecraft-data-disk"
  type = "pd-balanced"
  zone = var.zone
  size = 50
}

# Reserva um endereço de IP público estático.
resource "google_compute_address" "static_ip" {
  name   = "minecraft-static-ip"
  region = var.region
}

# Cria a instância da máquina virtual.
resource "google_compute_instance" "minecraft_server_host" {
  name         = "minecraft-server-host"
  machine_type = "custom-4-18432"
  zone         = var.zone
  tags         = ["minecraft-server"]

  boot_disk {
    initialize_params {
      # Usamos a imagem Debian 11 pela sua flexibilidade.
      image = "debian-cloud/debian-11"
      size  = 20
    }
  }

  # Anexa o disco de dados persistente à VM.
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
    email  = google_service_account.minecraft_vm_sa.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    # O startup-script agora é mínimo. Ele apenas prepara a máquina.
    # A configuração e o início da aplicação são feitos pela pipeline de CI/CD.
    startup-script = <<-EOT
      #!/bin/bash
      sleep 10

      # ---- Montagem do Disco Persistente ----
      # Formata o disco (apenas se for a primeira vez) e monta-o em /mnt/data.
      # Garante que ele seja montado automaticamente em cada reinicialização.
      if ! blkid /dev/sdb; then
        mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
      fi
      mkdir -p /mnt/data
      mount -o discard,defaults /dev/sdb /mnt/data
      echo UUID=$(blkid -s UUID -o value /dev/sdb) /mnt/data ext4 discard,defaults,nofail 0 2 | tee -a /etc/fstab
      
      # ---- Instalação das Ferramentas Essenciais ----
      # Instala o Docker e o plugin Compose de forma robusta.
      apt-get update
      apt-get install -y ca-certificates curl
      install -m 0755 -d /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
      chmod a+r /etc/apt/keyrings/docker.asc
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
      apt-get update
      apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    EOT
  }

  depends_on = [google_compute_firewall.allow_iap_ssh]
}
