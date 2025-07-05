# Bucket para armazenar o estado remoto do Terraform
resource "google_storage_bucket" "tfstate" {
  name          = "tfstate-${var.project_id}"
  location      = var.region
  force_destroy = false
}

module "gha_sa" {
  source     = "./modules/gha_sa"
  project_id = var.project_id
  account_id = var.account_id
}

module "wif_pool" {
  source     = "./modules/wif_pool"
  project_id = var.project_id
  pool_id    = var.pool_id
}

module "wif_provider" {
  source      = "./modules/wif_provider"
  project_id  = var.project_id
  pool_id     = module.wif_pool.workload_identity_pool_id
  provider_id = var.provider_id
  github_repo = var.github_repo
}

module "iam_binding" {
  source               = "./modules/iam_binding"
  service_account_name = module.gha_sa.name
  pool_name            = module.wif_pool.name
  github_repo          = var.github_repo
}

# Concede acesso de gravação ao bucket de estado
resource "google_storage_bucket_iam_member" "sa_state_admin" {
  bucket = google_storage_bucket.tfstate.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.gha_sa.email}"
}
