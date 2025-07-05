// server-mine-v2/terraform-modules/workload-identity/main.tf


resource "google_iam_workload_identity_pool_provider" "this" {
  project                            = var.project_id
  workload_identity_pool_id          = var.pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "GitHub OIDC Provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  // Condição sempre verdadeira, para não bloquear tokens
  attribute_condition = "assertion.sub != \"\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  lifecycle {
    prevent_destroy = true
  }
}
