# compute.tf - Versão Final com Otimização de Performance do Túnel IAP

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
      # Usamos a imagem Debian, que é flexível e nos dá total controlo.
      image = "debian-cloud/debian-11"
      size  = 70
    }
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
      # Espera a rede estar totalmente pronta
      sleep 10

      # ---- Seção 1: Instalação de Dependências ----
      apt-get update
      # ADIÇÃO: Instala o pip, o gestor de pacotes do Python.
      apt-get install -y python3-pip ca-certificates curl

      # ADIÇÃO: Usa o pip para instalar a biblioteca NumPy.
      pip3 install numpy

      # Instalação Robusta do Docker
      for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove -y $pkg; done
      install -m 0755 -d /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
      chmod a+r /etc/apt/keyrings/docker.asc
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
      apt-get update
      apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

      # Instalação do Ops Agent
      curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
      bash add-google-cloud-ops-agent-repo.sh --also-install

      # ---- Seção 2: Ambiente Minecraft ----
      mkdir -p /opt/minecraft/velocity-data
      cd /opt/minecraft
      
      # Cria o ficheiro de configuração do Velocity
      cat <<EOF_VELOCITY > /opt/minecraft/velocity-data/velocity.toml
      [servers]
      lobby = "lobby:25565"
      sobrevivencia = "sobrevivencia:25565"
      criativo = "criativo:25565"
      try = ["lobby"]
      [forced-hosts]
      "${google_compute_address.static_ip.address}:25565" = ["lobby"]
      [advanced]
      player-info-forwarding-mode = "bungeecord"
      [metrics]
      enabled = false
      EOF_VELOCITY

      # Cria o ficheiro docker-compose.yml
      cat <<EOF_COMPOSE > /opt/minecraft/docker-compose.yml
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
            PLAYER_INFO_FORWARDING_MODE: "BUNGEECORD"
          networks: ["minecraft-net"]
        sobrevivencia:
          image: itzg/minecraft-server
          container_name: mc-sobrevivencia
          restart: unless-stopped
          volumes: ["./sobrevivencia-data:/data"]
          environment:
            EULA: "TRUE"
            TYPE: "PAPER"
            MEMORY: "5G"
            ONLINE_MODE: "FALSE"
            BUNGEE_CORD: "TRUE"
          networks: ["minecraft-net"]
        criativo:
          image: itzg/minecraft-server
          container_name: mc-criativo
          restart: unless-stopped
          volumes: ["./criativo-data:/data"]
          environment:
            EULA: "TRUE"
            TYPE: "PAPER"
            MEMORY: "5G"
            GAMEMODE: "creative"
            ONLINE_MODE: "FALSE"
            BUNGEE_CORD: "TRUE"
          networks: ["minecraft-net"]
        lobby:
          image: itzg/minecraft-server
          container_name: mc-lobby
          restart: unless-stopped
          volumes: ["./lobby-data:/data"]
          environment:
            EULA: "TRUE"
            TYPE: "PAPER"
            MEMORY: "3G"
            GAMEMODE: "adventure"
            ONLINE_MODE: "FALSE"
            BUNGEE_CORD: "TRUE"
          networks: ["minecraft-net"]
      EOF_COMPOSE

      # ---- Seção 3: Inicia os Serviços ----
      docker compose up -d
      EOT
  }

  depends_on = [google_compute_firewall.allow_iap_ssh]
}
