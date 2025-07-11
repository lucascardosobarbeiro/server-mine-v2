module "compute" {
  source                = "./modules/compute"
  zone                  = var.zone
  region                = var.region
  subnetwork_self_link  = module.network.subnetwork_self_link
  service_account_email = module.iam.service_account_email

    depends_on = [
    google_project_service.compute,
    google_project_service.iam,
    google_project_service.iap
  ]
}
