variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "github_repo" {
  description = "GitHub repository for workload identity"
  type        = string
}

variable "account_id" {
  description = "Service account ID"
  type        = string
  default     = "sa-minecraft-vm"
}

variable "pool_id" {
  description = "Workload Identity Pool ID"
  type        = string
  default     = "github-pool-v2"
}

variable "provider_id" {
  description = "Workload Identity Provider ID"
  type        = string
  default     = "github-provider"
}
variable "velocity_secret" {
  description = "Secret key used to forward player info to backend servers"
  type        = string
  sensitive   = true
}
