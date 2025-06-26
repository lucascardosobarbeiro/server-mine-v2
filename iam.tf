# iam.tf - Versão Final para WIF

resource "google_service_account" "minecraft_vm_sa" {
  account_id   = "sa-minecraft-vm"
  display_name = "Service Account for Minecraft VM"
}

# --- Permissões da Conta de Serviço para Operar ---
# Estas permissões permitem que a VM envie logs, métricas, backups e use o túnel IAP.

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

# ADIÇÃO: Permite que a SA modifique metadados da VM (Plano B de conexão)
# A role 'compute.instanceAdmin.v1' contém a permissão 'compute.instances.setMetadata',
# que resolve o erro de fallback do SSH no GitHub Actions.
resource "google_project_iam_member" "instance_admin_for_sa" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# --- Permissões para o seu Utilizador Humano ---

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

# --- A PERMISSÃO MAIS IMPORTANTE PARA O WIF ---
# Concede à identidade do GitHub (definida no github_actions.tf) a permissão 
# para "personificar" esta conta de serviço, o que resolve o erro 'getAccessToken'.

resource "google_service_account_iam_member" "github_wif_user" {
  # IMPORTANTE: A permissão é na CONTA DE SERVIÇO, não no projeto.
  service_account_id = google_service_account.minecraft_vm_sa.name
  role               = "roles/iam.workloadIdentityUser"
  
  # O 'member' é a identidade do GitHub que pode usar esta SA.
  # Ele usa os recursos criados no ficheiro 'github_actions.tf'.
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
}