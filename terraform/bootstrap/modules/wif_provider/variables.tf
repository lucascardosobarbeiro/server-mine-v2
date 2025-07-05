variable "project_id" {
  type = string
}

variable "pool_id" {
  type = string
}

variable "provider_id" {
  type    = string
  default = "github-provider"
}

variable "github_repo" {
  type = string
}
