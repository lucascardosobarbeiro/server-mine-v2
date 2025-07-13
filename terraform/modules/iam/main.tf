# =================================================================================
# MÓDULO IAM - PERMISSÕES E SERVICE ACCOUNT PARA A VM
# =================================================================================

# Service Account para a VM Minecraft
resource "google_service_account" "minecraft_vm_sa" {
  account_id   = "sa-minecraft-vm-2"
  display_name = "Service Account for Minecraft VM"
}

# =================================================================================
# PERMISSÕES PARA A SERVICE ACCOUNT
# =================================================================================

# Logging
resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# Monitoring
resource "google_project_iam_member" "monitoring_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# Storage (backup)
resource "google_storage_bucket_iam_member" "backup_writer" {
  bucket = var.backup_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# Compute Viewer
resource "google_project_iam_member" "compute_viewer_for_sa" {
  project = var.project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# IAP Tunnel
resource "google_project_iam_member" "iap_tunnel_for_sa" {
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# SA User (permite que ela atue como ela mesma, necessário para IAP)
resource "google_project_iam_member" "sa_user_for_sa" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# Compute Admin limitado (para alterar metadados e conectar)
resource "google_project_iam_member" "instance_admin_for_sa" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

# =================================================================================
# PERMISSÕES PARA O USUÁRIO HUMANO
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
# WORKLOAD IDENTITY FEDERATION (GITHUB ACTIONS)
# =================================================================================

resource "google_service_account_iam_member" "github_wif_user" {
  service_account_id = google_service_account.minecraft_vm_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${var.google_iam_workload_identity_pool}/attribute.repository/${var.github_repo}"
}

