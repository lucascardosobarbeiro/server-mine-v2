module "network" {
  source = "./modules/network"
  region = var.region

  depends_on = [google_project_service.compute]
}
