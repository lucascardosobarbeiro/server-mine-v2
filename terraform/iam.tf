# iam.tf - Versão Final e Consolidada de Todas as Permissões

resource "google_service_account" "minecraft_vm_sa" {
  account_id   = "sa-minecraft-vm"
  display_name = "Service Account for Minecraft VM"
}

# =================================================================================
# Permissões para a CONTA DE SERVIÇO (sa-minecraft-vm@...)
# =================================================================================

# --- Permissões Operacionais Básicas ---

# Permite que a VM (via Ops Agent) envie logs e métricas para o Cloud Operations.
resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

resource "google_project_iam_member" "monitoring_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# Permite que a VM (via script de backup) escreva ficheiros no bucket de backups.
resource "google_storage_bucket_iam_member" "backup_writer" {
  bucket = google_storage_bucket.minecraft_backups.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# --- Permissões para Acesso Remoto do CI/CD ---

# Permite que o gcloud veja os detalhes da VM antes de se conectar.
resource "google_project_iam_member" "compute_viewer_for_sa" {
  project = var.project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# Permite que a conta de serviço use o túnel IAP (Plano A de conexão).
resource "google_project_iam_member" "iap_tunnel_for_sa" {
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# Permite que a conta de serviço atue como ela mesma, necessário para fluxos IAP complexos.
resource "google_project_iam_member" "sa_user_for_sa" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# Permite que a SA modifique metadados da VM (Plano B de conexão), resolvendo o erro de fallback do SSH.
resource "google_project_iam_member" "instance_admin_for_sa" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}


# =================================================================================
# Permissões para o seu UTILIZADOR HUMANO 
# =================================================================================

resource "google_project_iam_member" "iap_ssh_access" {
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "user:${var.gcp_user_email}"
}

resource "google_project_iam_member" "compute_viewer_for_user" {
  project = var.project_id
  role    = "roles/compute.viewer"
  member  = "user:${var.gcp_user_email}"
}


# =================================================================================
# Permissão para o WORKLOAD IDENTITY FEDERATION
# =================================================================================

# Concede à identidade do GitHub a permissão para "personificar" esta conta de serviço.
resource "google_service_account_iam_member" "github_wif_user" {
  service_account_id = google_service_account.minecraft_vm_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
}
