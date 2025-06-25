# iam.tf - Versão Final para WIF

resource "google_service_account" "minecraft_vm_sa" {
  account_id   = "sa-minecraft-vm"
  display_name = "Service Account for Minecraft VM"
}

# Permissões da Conta de Serviço para operar (Logging, Monitoring, Storage)
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
resource "google_storage_bucket_iam_member" "backup_writer" {
  bucket = google_storage_bucket.minecraft_backups.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# Permissões para o SEU USUÁRIO HUMANO
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

# Permissões para a CONTA DE SERVIÇO do CI/CD
resource "google_project_iam_member" "compute_viewer_for_sa" {
  project = var.project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}
resource "google_project_iam_member" "iap_tunnel_for_sa" {
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# A PERMISSÃO MAIS IMPORTANTE PARA O WIF
# Concede à identidade do GitHub a permissão para "personificar" esta conta de serviço.
resource "google_service_account_iam_member" "github_wif_user" {
  service_account_id = google_service_account.minecraft_vm_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
}

# iam.tf - Adicionar este bloco ao final do arquivo

# =================================================================================
# PERMISSÃO FINAL (BASEADA NA DOCUMENTAÇÃO)
# Concede à conta de serviço a capacidade de atuar em nome de outras contas
# de serviço, o que é necessário para o fluxo de conexão IAP em cenários de automação.
# =================================================================================
resource "google_project_iam_member" "sa_user_for_sa" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}