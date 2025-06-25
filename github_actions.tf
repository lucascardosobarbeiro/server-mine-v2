# github_actions.tf - Versão Final e Limpa

# 1. Cria um "Pool de Identidades"
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool-${random_string.suffix.result}"
  display_name              = "GitHub Actions Pool"
}

# 2. Cria um "Provedor" dentro do Pool
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub OIDC Provider"
  attribute_condition                = "attribute.repository == '${var.github_repo}'"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Recurso auxiliar para gerar o sufixo aleatório.
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}