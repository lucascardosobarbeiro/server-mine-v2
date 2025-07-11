module "compute" {
  source                = "./modules/compute"
  zone                  = var.zone
  region                = var.region
  subnetwork_self_link  = module.network.subnetwork_self_link
  service_account_email = module.iam.service_account_email
}
