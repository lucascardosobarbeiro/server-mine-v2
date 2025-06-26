# compute.tf - Versão Final com Imagem Otimizada para Contêineres

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
      # CORREÇÃO: Usamos a "família" de imagens cos-stable.
      # Isso garante que sempre usaremos a versão estável mais recente.
      image = "cos-cloud/cos-stable"
      size  = 70
    }
  }

  # Bloco de rede que conecta a VM à nossa sub-rede e atribui o IP estático.
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
    # O startup-script agora é muito mais simples e focado.
    startup-script = <<-EOT
      #!/bin/bash
      # Espera 10 segundos para garantir que todos os serviços de rede estejam prontos.
      sleep 10

      # ---- Seção 1: Preparação do Ambiente ----
      # O Docker já está instalado, então apenas criamos os nossos diretórios.
      mkdir -p /home/root/minecraft/velocity-data
      cd /home/root/minecraft
      
      # ---- Seção 2: Criação dos Ficheiros de Configuração ----
      
      # Cria o ficheiro de configuração do Velocity.
      cat <<EOF_VELOCITY > /home/root/minecraft/velocity-data/velocity.toml
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

      # Cria o ficheiro docker-compose.yml.
      cat <<EOF_COMPOSE > /home/root/minecraft/docker-compose.yml
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
      # O comando 'docker compose' já está disponível globalmente nestas imagens.
      docker compose up -d
      EOT
  }

  depends_on = [google_compute_firewall.allow_iap_ssh]
}
