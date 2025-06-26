# iam.tf - Versão Final com Permissão de Fallback para o CI/CD

resource "google_service_account" "minecraft_vm_sa" {
  account_id   = "sa-minecraft-vm"
  display_name = "Service Account for Minecraft VM"
}

# --- Permissões da Conta de Serviço para Operar ---

# Permite enviar logs e métricas para o Cloud Operations
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

# Permite gerenciar backups no Cloud Storage
resource "google_storage_bucket_iam_member" "backup_writer" {
  bucket = google_storage_bucket.minecraft_backups.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# Permite ver informações da VM (necessário para o gcloud ssh)
resource "google_project_iam_member" "compute_viewer_for_sa" {
  project = var.project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# Permite usar o túnel IAP (Plano A de conexão)
resource "google_project_iam_member" "iap_tunnel_for_sa" {
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# ADIÇÃO: Permite que a SA modifique metadados da VM (Plano B de conexão)
# A role 'compute.instanceAdmin.v1' contém a permissão 'compute.instances.setMetadata',
# que resolve o erro de fallback do SSH no GitHub Actions.
resource "google_project_iam_member" "instance_admin_for_sa" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}


# --- Permissões para o seu Usuário Humano ---

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
