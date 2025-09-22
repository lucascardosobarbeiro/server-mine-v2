resource "google_compute_instance" "minecraft_server_host" {
  name         = "minecraft-server-host"
  machine_type = "e2-standard-2"
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
    subnetwork = var.subnetwork_self_link
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    # O startup-script agora é completo e idempotente. Ele prepara e inicia a aplicação.
    startup-script = <<-EOT
      #!/bin/bash
      sleep 10

      # ---- Montagem do Disco Persistente ----
      # Formata o disco (apenas se for a primeira vez) e monta-o em /mnt/data.
      if ! blkid /dev/sdb; then
        mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
      fi
      mkdir -p /mnt/data
      mount -o discard,defaults /dev/sdb /mnt/data
      echo UUID=$(blkid -s UUID -o value /dev/sdb) /mnt/data ext4 discard,defaults,nofail 0 2 | tee -a /etc/fstab
      
      # ---- Instalação das Ferramentas Essenciais ----
      # Instala o Docker, o plugin Compose e o Git.
      apt-get update
      apt-get install -y ca-certificates curl git
      install -m 0755 -d /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
      chmod a+r /etc/apt/keyrings/docker.asc
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
      apt-get update
      apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

      # ---- Sincronização e Início da Aplicação ----
      # Navega para o disco persistente.
      cd /mnt/data

      # Lógica idempotente: se a pasta existir, apenas atualiza. Se não, clona.
      if [ -d "server-mine-v2" ]; then
        echo "Pasta 'server-mine-v2' já existe. Atualizando..."
        cd server-mine-v2
        git pull
      else
        echo "Clonando o repositório..."
        git clone https://github.com/lucascardosobarbeiro/server-mine-v2.git
        cd server-mine-v2
      fi

      # Inicia os containers em modo 'detached'.
      docker compose up -d

    EOT
  }
}
