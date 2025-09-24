# terraform/main.tf

module "wif" {
  source      = "./modules/wif"
  project_id  = var.project_id
  github_repo = var.github_repo

  depends_on = [
    google_project_service.iam,
    google_project_service.iamcredentials,
  ]
}