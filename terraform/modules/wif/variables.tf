variable "project_id" {
  type        = string
  description = "ID do projeto onde será criado o Workload Identity Pool"
}

variable "github_repo" {
  description = "GitHub repository slug, ex: user/repo"
  type        = string
}
