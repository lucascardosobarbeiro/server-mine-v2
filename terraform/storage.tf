module "storage" {
  source     = "./modules/storage"
  project_id = var.project_id
  region     = var.region

    depends_on = [google_project_service.storage]
}
