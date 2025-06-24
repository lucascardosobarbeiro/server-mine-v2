resource "google_service_account" "minecraft_vm_sa" {
  account_id   = "sa-minecraft-vm"
  display_name = "Service Account for Minecraft VM"
}

// Permissões de Logging, Monitoring, e Storage (sem alterações)
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

// Permissão para o seu usuário humano usar o IAP (sem alterações)
resource "google_project_iam_member" "iap_ssh_access" {
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "user:${var.gcp_user_email}"
}

// Permissões de acesso para a CONTA DE SERVIÇO
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

# =================================================================================
# PERMISSÕES FINAIS ADICIONADAS (OS LOGIN)
# Concede à conta de serviço as permissões para interagir com o serviço OS Login,
# cobrindo a última causa provável da falha de conexão.
# =================================================================================
resource "google_project_iam_member" "os_login_for_sa" {
  project = var.project_id
  role    = "roles/compute.osLogin"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}
resource "google_project_iam_member" "sa_user_for_sa" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}