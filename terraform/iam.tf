module "iam" {
  source             = "./modules/iam"
  project_id         = var.project_id
  gcp_user_email     = var.gcp_user_email
  github_repo        = var.github_repo
  backup_bucket_name = module.storage.bucket_name
}
