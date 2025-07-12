module "apis" {
  source     = ".apis"
  project_id = var.project_id
}

module "wif" {
  source      = "./modules/wif"
  project_id  = var.project_id
  github_repo = var.github_repo

  # força o Terraform a criar/habilitar as APIs antes de mexer no pool
  depends_on = [ module.apis ]
}
