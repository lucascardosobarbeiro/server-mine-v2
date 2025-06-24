# =================================================================================
# FEDERAÇÃO DE IDENTIDADE (WORKLOAD IDENTITY FEDERATION)
# Permite que sistemas externos (como o GitHub) se autentiquem no GCP de forma segura.
# =================================================================================

# 1. Cria um "Pool de Identidades": um grupo que confiará em provedores de identidade externos.
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool-${random_string.suffix.result}"
  display_name              = "GitHub Actions Pool"
}

# 2. Cria um "Provedor" dentro do Pool: Este provedor confia especificamente no GitHub.
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub OIDC Provider"

  # CORRIGIDO: Adiciona uma condição explícita para segurança.
  # Esta linha diz ao Google para APENAS aceitar tokens que venham
  # do repositório especificado na sua variável `github_repo`.
  attribute_condition = "attribute.repository == '${var.github_repo}'"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# 3. A CONEXÃO MÁGICA: Permite que uma identidade do GitHub (nosso repositório)
#    personifique (aja como) a nossa conta de serviço da VM.
resource "google_service_account_iam_member" "github_wif_user" {
  service_account_id = google_service_account.minecraft_vm_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
}

# Recurso auxiliar para gerar o sufixo aleatório.
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}