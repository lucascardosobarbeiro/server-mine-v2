# =================================================================================
# VARIÁVEIS DE ENTRADA (INPUT VARIABLES)
# Cada bloco 'variable' define um parâmetro que podemos configurar no arquivo terraform.tfvars.
# =================================================================================

# O ID do seu projeto no GCP, a identificação principal.
variable "project_id" {
  description = "O ID do seu projeto no Google Cloud."
  type        = string
}

# A região geográfica onde a maioria dos recursos será criada.
variable "region" {
  description = "A região GCP para criar os recursos (ex: southamerica-east1)."
  type        = string
}

# A zona específica dentro da região. Uma região tem múltiplas zonas para alta disponibilidade.
variable "zone" {
  description = "A zona GCP para criar a VM (ex: southamerica-east1-a)."
  type        = string
}

# Seu e-mail, usado para te dar permissão de acesso administrativo à VM.
variable "gcp_user_email" {
  description = "Seu e-mail do Google para acesso administrativo seguro via IAP."
  type        = string
}

# O nome do seu repositório no GitHub, essencial para a configuração do CI/CD.
variable "github_repo" {
  description = "Seu repositório no GitHub no formato 'usuario/repositorio'."
  type        = string
}
#backend remoto
variable "backend_bucket" {
  description = "Nome do bucket GCS para o remote state"
  type        = string
}


