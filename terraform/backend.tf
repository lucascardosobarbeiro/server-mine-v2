terraform {
  required_version = ">= 1.5.0"
  backend "gcs" {
    bucket = var.backend_bucket
    prefix = "terraform/state"
  }
}
