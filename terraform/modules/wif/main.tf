resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool-${random_string.suffix.result}"
  display_name              = "GitHub Actions Pool"
  project                   = var.project_id
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                             = var.project_id
  workload_identity_pool_id           = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id  = "github-provider"
  display_name                        = "GitHub OIDC Provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # Se quiser aceitar apenas main e/ou PRs, use:
  # attribute_condition = "attribute.repository == \"${var.github_repo}\" && (attribute.ref == \"refs/heads/main\" || startsWith(attribute.ref, \"refs/pull/\"))"
  #
  # Ou, para não filtrar ref:
  attribute_condition = "attribute.repository == \"${var.github_repo}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "minecraft_sa" {
  account_id   = "sa-minecraft-vm"
  display_name = "SA for Minecraft VM"
  project      = var.project_id
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.minecraft_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    # use o principalSet completo que coincide com attribute.repository
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
  ]
}

# (Não esqueça de adicionar também o papel Token Creator:)
resource "google_service_account_iam_binding" "token_creator_binding" {
  service_account_id = google_service_account.minecraft_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
  ]
}
