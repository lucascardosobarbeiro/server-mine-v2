# =================================================================================
# REDE VIRTUAL PRIVADA (VPC - VIRTUAL PRIVATE CLOUD)
# Cria uma rede isolada para nossos recursos, em vez de usar a rede 'default' do GCP.
# =================================================================================
resource "google_compute_network" "minecraft_vpc" {
  name = "minecraft-vpc"
  # Boa prática de segurança: Desabilita a criação automática de sub-redes.
  # Nós criaremos nossa própria sub-rede manualmente, tendo controle total.
  auto_create_subnetworks = false
}

# =================================================================================
# SUB-REDE (SUBNET)
# Define uma faixa de endereços IP internos (10.10.1.0/24) para nossos recursos
# dentro da VPC e da região especificada.
# =================================================================================
resource "google_compute_subnetwork" "minecraft_subnet" {
  name          = "minecraft-subnet"
  ip_cidr_range = "10.10.1.0/24"
  network       = google_compute_network.minecraft_vpc.self_link # Vincula à nossa VPC.
  region        = var.region
}

# =================================================================================
# REGRAS DE FIREWALL
# Controlam o tráfego que pode chegar às nossas VMs.
# =================================================================================

# Regra 1: Permite que jogadores se conectem ao proxy Velocity.
resource "google_compute_firewall" "allow_velocity_proxy" {
  name    = "allow-velocity-tcp-25565"
  network = google_compute_network.minecraft_vpc.self_link # Aplica-se à nossa VPC.

  # 'allow' define o que é permitido.
  allow {
    protocol = "tcp"         # Protocolo de comunicação do Minecraft.
    ports    = ["25565"]     # A única porta que os jogadores usarão.
  }
  # 'source_ranges' define de onde o tráfego pode vir.
  # "0.0.0.0/0" é um CIDR especial que significa "qualquer lugar da internet".
  source_ranges = ["0.0.0.0/0"]

  # 'target_tags' aplica esta regra apenas a VMs que tenham esta tag.
  target_tags = ["minecraft-server"]
}

# Regra 2: Permite acesso administrativo via SSH de forma segura.
# Esta é a regra de segurança mais importante para o administrador.
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh"
  network = google_compute_network.minecraft_vpc.self_link
  allow {
    protocol = "tcp"
    ports    = ["22"] # Porta padrão do SSH.
  }
  # A CHAVE DA SEGURANÇA: Só permite tráfego vindo da faixa de IPs do serviço
  # Identity-Aware Proxy (IAP) do próprio Google. Ninguém mais na internet
  # pode sequer tentar se conectar à porta 22.
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["minecraft-server"]
}