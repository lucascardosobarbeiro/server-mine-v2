# compute.tf

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

      # Instalação do Docker, Docker Compose e outras ferramentas
      apt-get update
      apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release docker-ce docker-ce-cli containerd.io docker-compose-plugin

      # Instalação do Ops Agent para Monitoramento
      curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
      bash add-google-cloud-ops-agent-repo.sh --also-install

      # --- Ambiente Minecraft ---
      mkdir -p /opt/minecraft
      cd /opt/minecraft

      # --- Criação dos Arquivos de Configuração ---

      # FIX 1: Cria o diretório de dados do Velocity ANTES de tentar criar um arquivo dentro dele.
      mkdir -p /opt/minecraft/velocity-data
      
      # Cria o arquivo de configuração do Velocity.
      cat <<EOF_VELOCITY > /opt/minecraft/velocity-data/velocity.toml
      [servers]
      lobby = "lobby:25565"
      sobrevivencia = "sobrevivencia:25565"
      criativo = "criativo:25565"
      try = ["lobby"]
      [forced-hosts]
      "${google_compute_address.static_ip.address}:25565" = ["lobby"]
      [advanced]
      player-info-forwarding-mode = "modern"
      [metrics]
      enabled = false
      EOF_VELOCITY

      # Cria o arquivo docker-compose.yml que define todos os nossos 4 contêineres.
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
            ENABLE_PLAYER_UUID_LOOKUP: "TRUE"
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
            ENABLE_PLAYER_UUID_LOOKUP: "TRUE"
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
            ENABLE_PLAYER_UUID_LOOKUP: "TRUE"
            BUNGEE_CORD: "TRUE"
          networks: ["minecraft-net"]
      EOF_COMPOSE

      # ---- Inicia os Serviços ----
      
      # FIX 2: Usa "docker compose" (com espaço), que é o comando correto para a versão em plugin.
      docker compose up -d
      EOT
  }

  depends_on = [google_compute_firewall.allow_iap_ssh]
}