terraform {
  backend "gcs" {
    bucket  = "state-tf-minecraft"        # O bucket deve existir
    prefix  = "terraform/state"
  }
}