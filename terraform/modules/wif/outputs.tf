output "github_wif_pool_name" {
  description = "Resource name completo do Workload Identity Pool"
  value       = google_iam_workload_identity_pool.github_pool.name
}

output "github_wif_provider_name" {
  description = "Resource name completo do Workload Identity Pool Provider"
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}

output "pool_name" {
  description = "O resource name do Workload Identity Pool criado pelo módulo wif"
  value       = google_iam_workload_identity_pool.github_pool.name
}