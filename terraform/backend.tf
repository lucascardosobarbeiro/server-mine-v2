/*terraform {
  backend "gcs" {
    bucket  = "state-tf-minecraft"        # O bucket deve existir
    prefix  = "terraform/state"
  }
} */

variable "state_prefix" {
  type    = string
  default = "terraform/state"
}

terraform {
  required_version = ">= 1.5.0"
  backend "gcs" {
    bucket = var.backend_bucket
    prefix = var.state_prefix
  }
}
