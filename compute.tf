# =================================================================================
# IP ESTÁTICO EXTERNO
# Reserva um endereço de IP público que não mudará, mesmo se a VM for reiniciada.
# =================================================================================
resource "google_compute_address" "static_ip" {
  name   = "minecraft-static-ip"
  region = var.region
}

# =================================================================================
# INSTÂNCIA DE MÁQUINA VIRTUAL (VM)
# Cria o nosso "computador" na nuvem.
# =================================================================================
resource "google_compute_instance" "minecraft_server_host" {
  name         = "minecraft-server-host"
  # Tipo de máquina customizada: 4 CPUs virtuais e 18GB de RAM.
  machine_type = "custom-4-18432"
  zone         = var.zone
  # A tag que vincula esta VM às nossas regras de firewall.
  tags         = ["minecraft-server"]

  # Define o disco de inicialização (HD da VM).
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11" # Sistema Operacional Debian 11.
      size  = 70                      # Tamanho do disco em GB.
    }
  }

  # Define a interface de rede da VM.
  network_interface {
    subnetwork = google_compute_subnetwork.minecraft_subnet.self_link # Conecta à nossa sub-rede.
    access_config {
      # Associa o nosso IP estático reservado a esta VM.
      nat_ip = google_compute_address.static_ip.address
    }
  }

  # Associa nossa conta de serviço segura à VM.
  service_account {
    email  = google_service_account.minecraft_vm_sa.email
    scopes = ["cloud-platform"] # Escopo necessário para permitir as ações da SA.
  }

  # ===============================================================================
  # SCRIPT DE INICIALIZAÇÃO (STARTUP SCRIPT)
  # Este script é executado automaticamente na primeira vez que a VM é ligada.
  # Ele configura todo o software necessário de forma 100% automatizada.
  # ===============================================================================
  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      # Pequena pausa para garantir que a rede esteja 100% online.
      sleep 10

      # ---- Seção 1: Instalação de Dependências ----
      apt-get update
      # Instala o Docker, Docker Compose e outras ferramentas essenciais.
      apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release docker-ce docker-ce-cli containerd.io docker-compose-plugin

      # Instala o Agente de Operações do Google para monitoramento e logging.
      curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
      bash add-google-cloud-ops-agent-repo.sh --also-install

      # ---- Seção 2: Preparação do Ambiente Minecraft ----
      # Cria o diretório principal onde todos os dados dos servidores ficarão.
      mkdir -p /opt/minecraft
      cd /opt/minecraft

      # ---- Seção 3: Criação dos Arquivos de Configuração ----
      # Usa a técnica "heredoc" para criar um arquivo de texto multi-linha diretamente do script.

      # Cria o arquivo de configuração do proxy Velocity.
      # Note que a variável ${google_compute_address.static_ip.address} é substituída pelo Terraform
      # ANTES de o script ser enviado para a VM.
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

      # ---- Seção 4: Inicia os Serviços ----
      # O comando final que lê o arquivo docker-compose.yml e inicia todos os 4 contêineres.
      docker-compose up -d
      EOT
  }

  # Garante que a regra de firewall do IAP seja criada ANTES da VM, evitando condições de corrida.
  depends_on = [google_compute_firewall.allow_iap_ssh]
}

# =================================================================================
# PERMISSÃO DE ACESSO IAP
# Concede a permissão para o SEU usuário se conectar a ESTA VM específica via IAP.
# =================================================================================
