# chama o iam no /modules/iam
module "iam" {
  source                            = "./modules/iam"
  project_id                        = var.project_id
  gcp_user_email                    = var.gcp_user_email
  github_repo                       = var.github_repo
  backup_bucket_name                = module.storage.bucket_name
  google_iam_workload_identity_pool = module.wif.github_wif_pool_name
  depends_on                        = [module.wif]
}
