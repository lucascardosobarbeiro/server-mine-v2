output "github_wif_pool_name" {
  value = google_iam_workload_identity_pool.github_pool.name
}

output "github_provider_name" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}
