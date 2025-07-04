resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Bucket para armazenar o estado remoto do Terraform
resource "google_storage_bucket" "tfstate" {
  name          = "tfstate-${var.project_id}"
  location      = var.region
  force_destroy = false
}

# Conta de serviço usada pelo servidor e pela pipeline
resource "google_service_account" "minecraft_vm_sa" {
  account_id   = "sa-minecraft-vm"
  display_name = "Service Account for Minecraft VM"
  project      = var.project_id
}

# Workload Identity Pool para o GitHub Actions
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool-${random_string.suffix.result}"
  display_name              = "GitHub Actions Pool"
  project                   = var.project_id
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub OIDC Provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  attribute_condition = "attribute.repository == \"${var.github_repo}\" && attribute.ref == \"refs/heads/main\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Permite que o GitHub use a conta de serviço via Workload Identity
resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.minecraft_vm_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
  ]
}

# Concede acesso de gravação ao bucket de estado
resource "google_storage_bucket_iam_member" "sa_state_admin" {
  bucket = google_storage_bucket.tfstate.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.minecraft_vm_sa.email}"
}

output "service_account_email" {
  value = google_service_account.minecraft_vm_sa.email
}

output "state_bucket_name" {
  value = google_storage_bucket.tfstate.name
}

output "workload_identity_pool" {
  value = google_iam_workload_identity_pool.github_pool.name
}
