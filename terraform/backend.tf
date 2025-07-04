# terraform/backend.tf

terraform {
  backend "gcs" {
    bucket = "terraform-state-server-mine-463823" # Nome do bucket definido diretamente
    prefix = "server-mine-v2/terraform.tfstate"
  }
}
