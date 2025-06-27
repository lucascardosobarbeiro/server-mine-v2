# compute.tf - Versão Final com Servidor Único de 8GB e Plugins

# --- RECURSO DO DISCO PERSISTENTE ---
# Este disco existe independentemente da VM. É o nosso "cofre" de dados.
resource "google_compute_disk" "minecraft_data_disk" {
  name = "minecraft-data-disk"
  type = "pd-balanced" # Um bom equilíbrio entre custo e performance.
  zone = var.zone
  size = 50 # Tamanho do disco em GB, pode ser ajustado.
}

resource "google_compute_address" "static_ip" {
  name   = "minecraft-static-ip"
  region = var.region
}

resource "google_compute_instance" "minecraft_server_host" {
  name         = "minecraft-server-host"
  machine_type = "custom-4-18432"
  zone         = var.zone
  tags         = ["minecraft-server"]

  boot_disk {
    initialize_params {
      # O disco de boot agora é apenas para o sistema operativo.
      image = "debian-cloud/debian-11"
      size  = 20 # Podemos reduzir o tamanho, já que os dados não ficam aqui.
    }
  }

  # --- ALTERAÇÃO CRÍTICA: ANEXAR O DISCO DE DADOS ---
  # Anexamos o nosso "cofre" à VM.
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
    startup-script = <<-EOT
      #!/bin/bash
      sleep 10

      # ---- Montagem do Disco Persistente ----
      # Formata o disco de dados (apenas se ainda não tiver um sistema de ficheiros)
      # e monta-o no diretório /mnt/data.
      mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
      mkdir -p /mnt/data
      mount -o discard,defaults /dev/sdb /mnt/data
      # Adiciona ao fstab para montar automaticamente nos reboots.
      echo UUID=$(blkid -s UUID -o value /dev/sdb) /mnt/data ext4 discard,defaults,nofail 0 2 | tee -a /etc/fstab

      # ---- Instalação do Docker ----
      for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove -y $pkg; done
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

      # ---- Ambiente Minecraft ----
      # ALTERAÇÃO: Agora criamos a nossa estrutura de trabalho no disco montado.
      mkdir -p /mnt/data/minecraft/velocity-data
      cd /mnt/data/minecraft
      
      # Cria o arquivo de configuração do Velocity
      cat <<EOF_VELOCITY > /mnt/data/minecraft/velocity-data/velocity.toml
      [servers]
      # ATUALIZAÇÃO: Agora temos apenas um servidor de destino.
      sobrevivencia = "sobrevivencia:25565"
      # ATUALIZAÇÃO: O servidor de tentativa inicial agora é o de sobrevivência.
      try = ["sobrevivencia"]
      [forced-hosts]
      "${google_compute_address.static_ip.address}:25565" = ["sobrevivencia"]
      [advanced]
      player-info-forwarding-mode = "modern"
      [metrics]
      enabled = false
      EOF_VELOCITY

      # Cria o arquivo docker-compose.yml
      cat <<EOF_COMPOSE > /mnt/data/minecraft/docker-compose.yml
      version: '3.8'
      networks:
        minecraft-net:
          driver: bridge
      services:
        velocity:
          image: itzg/bungeecord
          container_name: velocity-proxy
          restart: unless-stopped
          ports: ["25565:25565"]
          volumes: ["./velocity-data:/server"]
          environment:
            TYPE: "VELOCITY"
            TZ: "America/Sao_Paulo"
          networks: ["minecraft-net"]
        sobrevivencia:
          image: itzg/minecraft-server
          container_name: mc-sobrevivencia
          restart: unless-stopped
          # ALTERAÇÃO: Os volumes agora apontam para o diretório de trabalho no disco montado.
          volumes: ["./sobrevivencia-data:/data"]
          environment:
            EULA: "TRUE"
            TYPE: "PAPER"
            # ATUALIZAÇÃO: Memória alocada aumentada para 8GB
            MEMORY: "8G"
            BUNGEE_CORD: "TRUE"
            ONLINE_MODE: "FALSE"
            # ATUALIZAÇÃO: Instalação automática dos plugins solicitados
            PLUGINS: "https://hangar.papermc.io/api/v1/projects/Plan/versions/5.6.3315/platforms/paper/download,https://hangar.papermc.io/api/v1/projects/ViaVersion/versions/5.1.0/platforms/paper/download,https://hangar.papermc.io/api/v1/projects/GeyserMC/versions/2.3.1-SNAPSHOT/platforms/paper/download,https://hangar.papermc.io/api/v1/projects/CoreProtect/versions/22.4/platforms/paper/download,https://hangar.papermc.io/api/v1/projects/EssentialsX/versions/2.21.0/platforms/paper/download"
          networks: ["minecraft-net"]
        # ATUALIZAÇÃO: Servidores 'criativo' e 'lobby' foram removidos.
      EOF_COMPOSE

      # ---- Inicia os Serviços ----
      docker compose up -d
      EOT
  }

  depends_on = [google_compute_firewall.allow_iap_ssh]
}
