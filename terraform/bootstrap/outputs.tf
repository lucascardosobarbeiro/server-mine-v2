output "service_account_email" {
  value = module.gha_sa.email
}

output "state_bucket_name" {
  value = google_storage_bucket.tfstate.name
}

output "workload_identity_pool" {
  value = module.wif_pool.name
}

output "workload_identity_provider" {
  value = module.wif_provider.name
}

output "iam_binding_id" {
  value = module.iam_binding.id
}
