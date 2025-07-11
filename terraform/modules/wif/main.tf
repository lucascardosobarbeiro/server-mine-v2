resource "google_iam_workload_identity_pool" "github_pool" {
  provider                  = google-beta
  project                   = var.project_id
  workload_identity_pool_id = "github-wif-pool"
  display_name              = "GitHub Actions Identity Pool"
  description               = "Permite autenticação federada via GitHub Actions"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  provider                             = google-beta
  project                              = var.project_id
  workload_identity_pool_id            = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id   = "github-provider"
  display_name                         = "GitHub Provider"
  description                          = "Permite autenticação via GitHub Actions"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "attribute.repository == \"lucascardosobarbeiro/server-mine-v2\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
