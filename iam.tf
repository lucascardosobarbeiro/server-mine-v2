# =================================================================================
# CONTA DE SERVIÇO (SERVICE ACCOUNT)
# Cria uma identidade não-humana (um "robô") para a nossa VM.
# É mais seguro do que usar a conta padrão do projeto.
# =================================================================================
resource "google_service_account" "minecraft_vm_sa" {
  account_id   = "sa-minecraft-vm"
  display_name = "Service Account for Minecraft VM"
}

# =================================================================================
# VINCULAÇÃO DE PERMISSÕES (IAM BINDINGS)
# Concede permissões específicas à nossa conta de serviço.
# =================================================================================

# Permissão para a VM enviar logs para o serviço Cloud Logging.
# Necessário para o Ops Agent funcionar.
resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter" # Apenas a permissão de escrever logs.
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# Permissão para a VM enviar métricas (CPU, RAM) para o serviço Cloud Monitoring.
# Necessário para o Ops Agent e nossos dashboards.
resource "google_project_iam_member" "monitoring_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter" # Apenas a permissão de escrever métricas.
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# Permissão para a VM gerenciar arquivos APENAS no nosso bucket de backup.
# Note que esta permissão é no nível do bucket, não no projeto inteiro (mais seguro).
resource "google_storage_bucket_iam_member" "backup_writer" {
  bucket = google_storage_bucket.minecraft_backups.name # Vinculado ao nosso bucket.
  role   = "roles/storage.objectAdmin" # Permite criar, ler e apagar backups.
  member = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}
# VERIFIQUE SE ESTE BLOCO EXISTE NO FINAL DE iam.tf

resource "google_project_iam_member" "iap_ssh_access" {
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "user:${var.gcp_user_email}"
}