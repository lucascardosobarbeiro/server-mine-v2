module "wif" {
  source     = "./modules/wif"
  project_id = var.project_id
  github_repo = var.github_repo
}
