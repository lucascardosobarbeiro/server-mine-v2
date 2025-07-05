data "google_service_account" "minecraft_vm_sa" {
  account_id = var.account_id
}

data "google_iam_workload_identity_pool" "github_pool" {
  name = "projects/${var.project_id}/locations/global/workloadIdentityPools/${var.pool_id}"
}

data "google_iam_workload_identity_pool_provider" "github_provider" {
  name = "projects/${var.project_id}/locations/global/workloadIdentityPools/${var.pool_id}/providers/${var.provider_id}"
}
